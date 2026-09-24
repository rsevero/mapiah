// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/foundation.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_flatten_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// Labels of one controller's rows, valid for one structure revision and one
/// locale.
class _TH2ElementTreeLabelCache {
  final int structureRevision;
  final String localeName;
  final Map<int, TH2ElementTreeLabel> labelsByMPID =
      <int, TH2ElementTreeLabel>{};

  _TH2ElementTreeLabelCache({
    required this.structureRevision,
    required this.localeName,
  });
}

/// Builds the sidebar rows and labels of a `.th2` file from its controller.
///
/// Only scraps (file children) and their points, lines and areas become rows,
/// in exact `childrenMPIDs` order. Every other child stays hidden.
class TH2ElementTreeAux {
  static final Expando<_TH2ElementTreeLabelCache> _labelCaches =
      Expando<_TH2ElementTreeLabelCache>('TH2ElementTreeLabelCache');

  /// How many times a label cache was (re)built. Test-only instrumentation.
  @visibleForTesting
  static int debugLabelCacheBuildCount = 0;

  /// How many times [rowsForFile] ran. Test-only instrumentation.
  @visibleForTesting
  static int debugRowsForFileCallCount = 0;

  /// Returns the rows below the file row of [th2FilePath] and whether any of
  /// its scraps or elements matched the active filter.
  ///
  /// [controller] is the file's registered controller, if any. [fileDepth]
  /// is the depth of the file row. [onNeedsLoad] receives the path when the
  /// file needs a tree load; it is never called while [filterActive].
  static TH2ElementRowsResult rowsForFile({
    required String th2FilePath,
    required TH2FileEditController? controller,
    required int fileDepth,
    required bool filterActive,
    required bool Function(String label) matchesFilterText,
    required bool Function(String scrapRowId) isScrapCollapsed,
    void Function(String th2FilePath)? onNeedsLoad,
  }) {
    debugRowsForFileCallCount++;

    final TH2FileStatusTreeRowKind? statusKind = _statusKindFor(controller);

    if (statusKind != null) {
      final bool needsLoad =
          (statusKind == TH2FileStatusTreeRowKind.loading) &&
          _needsLoad(controller);

      if (needsLoad && !filterActive) {
        onNeedsLoad?.call(th2FilePath);
      }

      if (filterActive) {
        return (rows: const <THProjectTreeVisibleRow>[], hasMatch: false);
      }

      return (
        rows: <THProjectTreeVisibleRow>[
          TH2FileStatusTreeRow(
            th2FilePath: th2FilePath,
            kind: statusKind,
            depth: fileDepth + 1,
          ),
        ],
        hasMatch: false,
      );
    }

    return _elementRows(
      th2FilePath: th2FilePath,
      controller: controller!,
      fileDepth: fileDepth,
      filterActive: filterActive,
      matchesFilterText: matchesFilterText,
      isScrapCollapsed: isScrapCollapsed,
    );
  }

  /// The status row a file shows instead of element rows, or `null` when
  /// it is loaded and valid. Reads the observable load state so observers
  /// rebuild on every transition.
  static TH2FileStatusTreeRowKind? _statusKindFor(
    TH2FileEditController? controller,
  ) {
    if (controller == null) {
      return TH2FileStatusTreeRowKind.loading;
    }

    final bool isFileLoaded = controller.isFileLoaded;
    final bool isLoading = controller.isLoading;
    final Object? loadError = controller.loadError;
    final bool isBroken = controller.isBroken;

    controller.structureRevision;

    if (loadError != null) {
      return TH2FileStatusTreeRowKind.loadError;
    }

    if (isLoading || !isFileLoaded) {
      return TH2FileStatusTreeRowKind.loading;
    }

    if (isBroken) {
      return TH2FileStatusTreeRowKind.broken;
    }

    return null;
  }

  /// Whether a tree load must be requested: no controller, or one that is
  /// neither loaded nor loading and never failed.
  static bool _needsLoad(TH2FileEditController? controller) {
    if (controller == null) {
      return true;
    }

    return !controller.isFileLoaded &&
        !controller.isLoading &&
        (controller.loadError == null);
  }

  /// The scrap and point/line/area rows of a loaded valid file.
  static TH2ElementRowsResult _elementRows({
    required String th2FilePath,
    required TH2FileEditController controller,
    required int fileDepth,
    required bool filterActive,
    required bool Function(String label) matchesFilterText,
    required bool Function(String scrapRowId) isScrapCollapsed,
  }) {
    final TH2File th2File = controller.th2File;
    final List<THProjectTreeVisibleRow> rows = <THProjectTreeVisibleRow>[];
    bool hasMatch = false;

    for (final int scrapMPID in th2File.childrenMPIDs) {
      final THElement scrap = th2File.elementByMPID(scrapMPID);

      if (scrap is! THScrap) {
        continue;
      }

      final List<TH2ElementTreeRow> childRows = _childRowsOf(
        scrap: scrap,
        th2FilePath: th2FilePath,
        controller: controller,
        depth: fileDepth + 2,
      );
      final TH2ElementTreeLabel scrapLabel = labelFor(
        controller: controller,
        element: scrap,
      );
      final String scrapRowId = th2ElementTreeRowId(
        th2FilePath: th2FilePath,
        elementMPID: scrapMPID,
      );
      final bool isCollapsed = isScrapCollapsed(scrapRowId);

      if (!filterActive) {
        rows.add(
          _scrapRow(
            scrap: scrap,
            th2FilePath: th2FilePath,
            depth: fileDepth + 1,
            isExpanded: !isCollapsed,
            label: scrapLabel,
          ),
        );

        if (!isCollapsed) {
          rows.addAll(childRows);
        }

        continue;
      }

      final List<TH2ElementTreeRow> matchingChildRows = childRows
          .where(
            (TH2ElementTreeRow row) => matchesFilterText(row.label.plainText),
          )
          .toList();
      final bool scrapMatches = matchesFilterText(scrapLabel.plainText);

      if (!scrapMatches && matchingChildRows.isEmpty) {
        continue;
      }

      hasMatch = true;
      rows.add(
        _scrapRow(
          scrap: scrap,
          th2FilePath: th2FilePath,
          depth: fileDepth + 1,
          isExpanded: matchingChildRows.isNotEmpty || !isCollapsed,
          label: scrapLabel,
        ),
      );
      rows.addAll(matchingChildRows);
    }

    return (rows: rows, hasMatch: hasMatch);
  }

  static TH2ElementTreeRow _scrapRow({
    required THScrap scrap,
    required String th2FilePath,
    required int depth,
    required bool isExpanded,
    required TH2ElementTreeLabel label,
  }) {
    return TH2ElementTreeRow(
      th2FilePath: th2FilePath,
      elementMPID: scrap.mpID,
      elementType: THElementType.scrap,
      depth: depth,
      isExpandable: true,
      isExpanded: isExpanded,
      label: label,
    );
  }

  /// The point, line and area rows of [scrap], in its children order.
  static List<TH2ElementTreeRow> _childRowsOf({
    required THScrap scrap,
    required String th2FilePath,
    required TH2FileEditController controller,
    required int depth,
  }) {
    final TH2File th2File = controller.th2File;
    final List<TH2ElementTreeRow> rows = <TH2ElementTreeRow>[];

    for (final int childMPID in scrap.childrenMPIDs) {
      final THElement child = th2File.elementByMPID(childMPID);

      if ((child is! THPoint) && (child is! THLine) && (child is! THArea)) {
        continue;
      }

      rows.add(
        TH2ElementTreeRow(
          th2FilePath: th2FilePath,
          elementMPID: childMPID,
          elementType: child.elementType,
          depth: depth,
          isExpandable: false,
          isExpanded: false,
          label: labelFor(controller: controller, element: child),
        ),
      );
    }

    return rows;
  }

  /// The label of [element], cached per controller, structure revision and
  /// locale.
  static TH2ElementTreeLabel labelFor({
    required TH2FileEditController controller,
    required THElement element,
  }) {
    final _TH2ElementTreeLabelCache cache = _labelCacheFor(controller);

    return cache.labelsByMPID.putIfAbsent(
      element.mpID,
      () => buildLabel(element),
    );
  }

  static _TH2ElementTreeLabelCache _labelCacheFor(
    TH2FileEditController controller,
  ) {
    final int structureRevision = controller.structureRevision;
    final String localeName = mpLocator.appLocalizations.localeName;
    final _TH2ElementTreeLabelCache? existing = _labelCaches[controller];

    if ((existing != null) &&
        (existing.structureRevision == structureRevision) &&
        (existing.localeName == localeName)) {
      return existing;
    }

    debugLabelCacheBuildCount++;

    final _TH2ElementTreeLabelCache rebuilt = _TH2ElementTreeLabelCache(
      structureRevision: structureRevision,
      localeName: localeName,
    );

    _labelCaches[controller] = rebuilt;

    return rebuilt;
  }

  /// Builds the label of [element] without reading or changing anything but
  /// the element itself. Never generates an id.
  static TH2ElementTreeLabel buildLabel(THElement element) {
    final String kind = MPTextToUser.getElementType(element.elementType);

    switch (element) {
      case THScrap scrap:
        return TH2ElementTreeLabel(primaryText: kind, thID: scrap.thID);
      case THPoint point:
        return TH2ElementTreeLabel(
          primaryText: _joinNonEmpty(
            kind,
            MPTextToUser.getPointTypeSubtypeFromPoint(point),
          ),
          thID: MPCommandOptionAux.getID(point),
        );
      case THLine line:
        return TH2ElementTreeLabel(
          primaryText: _joinNonEmpty(
            kind,
            MPTextToUser.getLineTypeSubtypeFromLine(line),
          ),
          thID: MPCommandOptionAux.getID(line),
        );
      case THArea area:
        return TH2ElementTreeLabel(
          primaryText: _joinNonEmpty(
            kind,
            MPTextToUser.getAreaTypeSubtypeFromArea(area),
          ),
          thID: MPCommandOptionAux.getID(area),
        );
      default:
        return TH2ElementTreeLabel(primaryText: kind);
    }
  }

  /// Joins [first] and [second] with a space, leaving empty parts out.
  static String _joinNonEmpty(String first, String second) {
    return <String>[
      first,
      second,
    ].where((String part) => part.isNotEmpty).join(' ');
  }
}
