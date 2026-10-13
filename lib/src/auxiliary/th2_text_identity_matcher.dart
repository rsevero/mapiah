// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';

import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/auxiliary/th2_text_normalization_analyzer.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// One side of an identity match: a file, the text its writer wrote and the
/// map of that text.
typedef TH2TextMatchSide = (TH2File, String, TH2TextLineMap);

/// Matches the elements of a detached model to the elements of the live
/// model by content, so unchanged elements keep their MPIDs on apply.
///
/// A pair matches only when its key, the element type and the texts of its
/// own lines without endings, is unique among the candidates of the pass on
/// both sides. Order and position never break a tie.
class TH2TextIdentityMatcher {
  static const Set<THElementType> _genericTypes = <THElementType>{
    THElementType.endline,
    THElementType.endarea,
    THElementType.endscrap,
    THElementType.endcomment,
    THElementType.emptyLine,
    THElementType.comment,
    THElementType.multilineComment,
    THElementType.multilineCommentContent,
  };

  static const Set<THElementType> _substantiveTypes = <THElementType>{
    THElementType.point,
    THElementType.bezierCurveLineSegment,
    THElementType.straightLineSegment,
    THElementType.areaBorderTHID,
  };

  final _TH2TextMatchSideData _live;
  final _TH2TextMatchSideData _detached;

  /// Detached MPID → live MPID.
  final Map<int, int> _detachedToLive = <int, int>{};
  final Map<int, int> _liveToDetached = <int, int>{};
  final Queue<(int, int)> _parentPairs = Queue<(int, int)>();

  /// Detached parents whose pair was already scanned.
  final Set<int> _visited = <int>{};

  TH2TextIdentityMatcher._(this._live, this._detached);

  /// Detached MPID → live MPID, injective. The file's MPID maps to itself.
  static Map<int, int> match({
    required TH2TextMatchSide live,
    required TH2TextMatchSide detached,
  }) {
    final TH2TextIdentityMatcher matcher = TH2TextIdentityMatcher._(
      _TH2TextMatchSideData(live),
      _TH2TextMatchSideData(detached),
    );

    return matcher._match();
  }

  Map<int, int> _match() {
    final int liveFileMPID = _live.file.mpID;
    final int detachedFileMPID = _detached.file.mpID;

    _addMatch(detachedFileMPID, liveFileMPID);

    /// Pass 1, from the file pair.
    _drainParentPairs();

    /// Pass 2.
    _matchAcrossFile();

    /// Pass 3.
    _matchContainers(const <THElementType>{
      THElementType.line,
      THElementType.area,
    });
    _matchContainers(const <THElementType>{THElementType.scrap});

    return _detachedToLive;
  }

  void _addMatch(int detachedMPID, int liveMPID) {
    _detachedToLive[detachedMPID] = liveMPID;
    _liveToDetached[liveMPID] = detachedMPID;

    final bool isDetachedParent =
        (detachedMPID == _detached.file.mpID) ||
        (_detached.file.elementByMPID(detachedMPID) is THIsParentMixin);

    if (isDetachedParent) {
      _parentPairs.add((detachedMPID, liveMPID));
    }
  }

  /// Pass 1: matches the unmatched children of every queued parent pair.
  void _drainParentPairs() {
    while (_parentPairs.isNotEmpty) {
      final (int detachedParentMPID, int liveParentMPID) = _parentPairs
          .removeFirst();

      if (!_visited.add(detachedParentMPID)) {
        continue;
      }

      final List<int> detachedChildren = _detached
          .childrenOf(detachedParentMPID)
          .where((int mpID) => !_detachedToLive.containsKey(mpID))
          .toList();
      final List<int> liveChildren = _live
          .childrenOf(liveParentMPID)
          .where((int mpID) => !_liveToDetached.containsKey(mpID))
          .toList();

      _matchUniqueKeys(detachedChildren, liveChildren);
    }
  }

  /// Pass 2: matches non-generic elements unmatched on both sides whose key
  /// is unique across the file.
  void _matchAcrossFile() {
    final List<int> detachedCandidates = _detached.elementMPIDs
        .where(
          (int mpID) =>
              !_detachedToLive.containsKey(mpID) && !_detached.isGeneric(mpID),
        )
        .toList();
    final List<int> liveCandidates = _live.elementMPIDs
        .where(
          (int mpID) =>
              !_liveToDetached.containsKey(mpID) && !_live.isGeneric(mpID),
        )
        .toList();

    _matchUniqueKeys(detachedCandidates, liveCandidates);
    _drainParentPairs();
  }

  void _matchUniqueKeys(List<int> detachedMPIDs, List<int> liveMPIDs) {
    final Map<String, List<int>> detachedByKey = _detached.groupByKey(
      detachedMPIDs,
    );
    final Map<String, List<int>> liveByKey = _live.groupByKey(liveMPIDs);

    for (final MapEntry<String, List<int>> entry in detachedByKey.entries) {
      final List<int>? liveWithKey = liveByKey[entry.key];

      if ((entry.value.length != 1) ||
          (liveWithKey == null) ||
          (liveWithKey.length != 1)) {
        continue;
      }

      _addMatch(entry.value.single, liveWithKey.single);
    }
  }

  /// Pass 3: matches containers of [types] through their matched children.
  void _matchContainers(Set<THElementType> types) {
    final Map<int, int> candidateByDetached = <int, int>{};
    final Map<int, int> qualifyingCountByLive = <int, int>{};

    for (final int detachedMPID in _detached.elementMPIDs) {
      if (_detachedToLive.containsKey(detachedMPID)) {
        continue;
      }

      final THElement detachedContainer = _detached.file.elementByMPID(
        detachedMPID,
      );

      if (!types.contains(detachedContainer.elementType)) {
        continue;
      }

      final int? liveMPID = _containerCandidate(detachedMPID);

      if (liveMPID == null) {
        continue;
      }

      candidateByDetached[detachedMPID] = liveMPID;
      qualifyingCountByLive[liveMPID] =
          (qualifyingCountByLive[liveMPID] ?? 0) + 1;
    }

    for (final MapEntry<int, int> entry in candidateByDetached.entries) {
      if (qualifyingCountByLive[entry.value] == 1) {
        _addMatch(entry.key, entry.value);
      }
    }

    _drainParentPairs();
  }

  /// The single unmatched live container of the same type that the detached
  /// container [detachedMPID] qualifies for, or `null`.
  int? _containerCandidate(int detachedMPID) {
    final THElement detachedContainer = _detached.file.elementByMPID(
      detachedMPID,
    );
    final List<int> matchedChildren = _detached
        .childrenOf(detachedMPID)
        .where((int mpID) => _detachedToLive.containsKey(mpID))
        .toList();
    bool hasSubstantiveChild = false;
    int? liveCandidate;

    for (final int childMPID in matchedChildren) {
      final int liveChildMPID = _detachedToLive[childMPID]!;
      final int liveParentMPID = _live.file
          .elementByMPID(liveChildMPID)
          .parentMPID;

      if ((liveCandidate != null) && (liveCandidate != liveParentMPID)) {
        return null;
      }

      liveCandidate = liveParentMPID;

      if (_isSubstantive(childMPID)) {
        hasSubstantiveChild = true;
      }
    }

    if (!hasSubstantiveChild ||
        (liveCandidate == null) ||
        (liveCandidate == _live.file.mpID) ||
        _liveToDetached.containsKey(liveCandidate)) {
      return null;
    }

    final THElement liveContainer = _live.file.elementByMPID(liveCandidate);

    if (liveContainer.elementType != detachedContainer.elementType) {
      return null;
    }

    for (final int liveChildMPID in _live.childrenOf(liveCandidate)) {
      final int? detachedChildMPID = _liveToDetached[liveChildMPID];

      if ((detachedChildMPID != null) &&
          (_detached.file.elementByMPID(detachedChildMPID).parentMPID !=
              detachedMPID)) {
        return null;
      }
    }

    return liveCandidate;
  }

  bool _isSubstantive(int detachedMPID) {
    final THElementType type = _detached.file
        .elementByMPID(detachedMPID)
        .elementType;

    return _substantiveTypes.contains(type) ||
        (type == THElementType.line) ||
        (type == THElementType.area);
  }
}

class _TH2TextMatchSideData {
  final TH2File file;
  final List<String> _lineTexts;
  final TH2TextLineMap _lineMap;
  final Map<int, String> _keyByMPID = <int, String>{};

  _TH2TextMatchSideData(TH2TextMatchSide side)
    : file = side.$1,
      _lineTexts = TH2TextNormalizationAnalyzer.lineTexts(side.$2),
      _lineMap = side.$3;

  Iterable<int> get elementMPIDs => file.elements.keys;

  List<int> childrenOf(int parentMPID) {
    if (parentMPID == file.mpID) {
      return file.childrenMPIDs;
    }

    final THElement parent = file.elementByMPID(parentMPID);

    return (parent is THIsParentMixin)
        ? (parent as THIsParentMixin).childrenMPIDs
        : const <int>[];
  }

  bool isGeneric(int mpID) {
    return TH2TextIdentityMatcher._genericTypes.contains(
          file.elementByMPID(mpID).elementType,
        ) ||
        (_lineMap.firstOwnLineOf(mpID) == null);
  }

  /// The element type and the texts of its own lines, without endings.
  String keyOf(int mpID) {
    return _keyByMPID.putIfAbsent(mpID, () {
      final StringBuffer key = StringBuffer(
        file.elementByMPID(mpID).elementType.name,
      );

      for (final int line in _lineMap.ownLinesOf(mpID)) {
        key
          ..write('\u0000')
          ..write(_lineTexts[line]);
      }

      return key.toString();
    });
  }

  Map<String, List<int>> groupByKey(List<int> mpIDs) {
    final Map<String, List<int>> byKey = <String, List<int>>{};

    for (final int mpID in mpIDs) {
      byKey.putIfAbsent(keyOf(mpID), () => <int>[]).add(mpID);
    }

    return byKey;
  }
}

/// Rewrites a detached file map with live MPIDs.
class TH2TextMPIDRemapper {
  /// A new map: [detachedFileMap] is never changed. Rewrites the file map's
  /// `childrenMPIDs` and `elementByMPID` keys and, inside every element map,
  /// `mpID`, `parentMPID` and each entry of `childrenMPIDs`, and inside every
  /// option map under `optionsMap` and `attrOptionsMap`, `parentMPID`. MPIDs
  /// not in [detachedToLive] are kept.
  static Map<String, dynamic> remap(
    Map<String, dynamic> detachedFileMap,
    Map<int, int> detachedToLive,
  ) {
    int mapMPID(int mpID) => detachedToLive[mpID] ?? mpID;

    final Map<String, dynamic> remapped = Map<String, dynamic>.of(
      detachedFileMap,
    );

    remapped['mpID'] = mapMPID(detachedFileMap['mpID'] as int);
    remapped['childrenMPIDs'] = <int>[
      for (final dynamic mpID in detachedFileMap['childrenMPIDs'] as List)
        mapMPID(mpID as int),
    ];

    final Map<dynamic, dynamic> elementByMPID =
        detachedFileMap['elementByMPID'] as Map<dynamic, dynamic>;

    remapped['elementByMPID'] = <int, dynamic>{
      for (final MapEntry<dynamic, dynamic> entry in elementByMPID.entries)
        mapMPID(entry.key as int): _remapElementMap(
          entry.value as Map<String, dynamic>,
          mapMPID,
        ),
    };

    return remapped;
  }

  static Map<String, dynamic> _remapElementMap(
    Map<String, dynamic> elementMap,
    int Function(int) mapMPID,
  ) {
    final Map<String, dynamic> remapped = Map<String, dynamic>.of(elementMap);

    remapped['mpID'] = mapMPID(elementMap['mpID'] as int);
    remapped['parentMPID'] = mapMPID(elementMap['parentMPID'] as int);

    if (elementMap.containsKey('childrenMPIDs')) {
      remapped['childrenMPIDs'] = <int>[
        for (final dynamic mpID in elementMap['childrenMPIDs'] as List)
          mapMPID(mpID as int),
      ];
    }

    for (final String optionsKey in const <String>[
      'optionsMap',
      'attrOptionsMap',
    ]) {
      if (!elementMap.containsKey(optionsKey)) {
        continue;
      }

      final Map<dynamic, dynamic> options =
          elementMap[optionsKey] as Map<dynamic, dynamic>;

      remapped[optionsKey] = <String, dynamic>{
        for (final MapEntry<dynamic, dynamic> entry in options.entries)
          entry.key as String: _remapOptionMap(
            entry.value as Map<String, dynamic>,
            mapMPID,
          ),
      };
    }

    return remapped;
  }

  static Map<String, dynamic> _remapOptionMap(
    Map<String, dynamic> optionMap,
    int Function(int) mapMPID,
  ) {
    final Map<String, dynamic> remapped = Map<String, dynamic>.of(optionMap);

    remapped['parentMPID'] = mapMPID(optionMap['parentMPID'] as int);

    return remapped;
  }
}
