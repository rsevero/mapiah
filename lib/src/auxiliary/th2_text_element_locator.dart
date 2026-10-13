// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';

/// The canvas target of a TH2 text line.
sealed class TH2TextLocation {
  const TH2TextLocation();
}

/// Select a point, line or area.
class TH2TextLocationSelectElement extends TH2TextLocation {
  final int mpID;
  final int scrapMPID;

  const TH2TextLocationSelectElement({
    required this.mpID,
    required this.scrapMPID,
  });

  @override
  bool operator ==(Object other) =>
      (other is TH2TextLocationSelectElement) &&
      (other.mpID == mpID) &&
      (other.scrapMPID == scrapMPID);

  @override
  int get hashCode => Object.hash(mpID, scrapMPID);

  @override
  String toString() =>
      'TH2TextLocationSelectElement(mpID: $mpID, scrapMPID: $scrapMPID)';
}

/// Select a line and one of its line points.
class TH2TextLocationSelectLinePoint extends TH2TextLocation {
  final int lineMPID;
  final int lineSegmentMPID;
  final int scrapMPID;

  const TH2TextLocationSelectLinePoint({
    required this.lineMPID,
    required this.lineSegmentMPID,
    required this.scrapMPID,
  });

  @override
  bool operator ==(Object other) =>
      (other is TH2TextLocationSelectLinePoint) &&
      (other.lineMPID == lineMPID) &&
      (other.lineSegmentMPID == lineSegmentMPID) &&
      (other.scrapMPID == scrapMPID);

  @override
  int get hashCode => Object.hash(lineMPID, lineSegmentMPID, scrapMPID);

  @override
  String toString() =>
      'TH2TextLocationSelectLinePoint(lineMPID: $lineMPID, lineSegmentMPID: $lineSegmentMPID, scrapMPID: $scrapMPID)';
}

/// Make a scrap the active one.
class TH2TextLocationActivateScrap extends TH2TextLocation {
  final int scrapMPID;

  const TH2TextLocationActivateScrap({required this.scrapMPID});

  @override
  bool operator ==(Object other) =>
      (other is TH2TextLocationActivateScrap) && (other.scrapMPID == scrapMPID);

  @override
  int get hashCode => scrapMPID.hashCode;

  @override
  String toString() => 'TH2TextLocationActivateScrap(scrapMPID: $scrapMPID)';
}

/// A line that belongs to no scrap: nothing to select on the canvas.
class TH2TextLocationFileLevel extends TH2TextLocation {
  const TH2TextLocationFileLevel();

  @override
  bool operator ==(Object other) => other is TH2TextLocationFileLevel;

  @override
  int get hashCode => (TH2TextLocationFileLevel).hashCode;

  @override
  String toString() => 'TH2TextLocationFileLevel()';
}

/// Turns a TH2 text line into its canvas target. Reads the model and changes
/// nothing.
class TH2TextElementLocator {
  static TH2TextLocation locate({
    required int line,
    required TH2TextLineMap lineMap,
    required TH2File th2File,
  }) {
    final int? owner = lineMap.ownerOfLine(line);

    /// The file's MPID names no element, so it is checked before any
    /// elementByMPID call.
    if ((owner == null) || (owner == th2File.mpID)) {
      return const TH2TextLocationFileLevel();
    }

    final THElement ownerElement = th2File.elementByMPID(owner);

    if (ownerElement is THLineSegment) {
      final int lineMPID = ownerElement.parentMPID;
      final int? scrapMPID = _scrapMPIDOf(lineMPID, th2File);

      if (scrapMPID == null) {
        assert(false, "Line '$lineMPID' has no scrap ancestor.");

        return const TH2TextLocationFileLevel();
      }

      return TH2TextLocationSelectLinePoint(
        lineMPID: lineMPID,
        lineSegmentMPID: owner,
        scrapMPID: scrapMPID,
      );
    }

    int mpID = owner;

    for (int depth = 0; depth <= mpMaxParseNestingDepth; depth++) {
      if (mpID == th2File.mpID) {
        return const TH2TextLocationFileLevel();
      }

      final THElement element = th2File.elementByMPID(mpID);

      if ((element is THPoint) || (element is THLine) || (element is THArea)) {
        final int? scrapMPID = _scrapMPIDOf(element.parentMPID, th2File);

        if (scrapMPID == null) {
          assert(false, "Element '$mpID' has no scrap ancestor.");

          return const TH2TextLocationFileLevel();
        }

        return TH2TextLocationSelectElement(mpID: mpID, scrapMPID: scrapMPID);
      }

      if (element is THScrap) {
        return TH2TextLocationActivateScrap(scrapMPID: mpID);
      }

      mpID = element.parentMPID;
    }

    return const TH2TextLocationFileLevel();
  }

  /// The MPID of [mpID] or of its nearest scrap ancestor, or `null` when there
  /// is none.
  static int? _scrapMPIDOf(int mpID, TH2File th2File) {
    int currentMPID = mpID;

    for (int depth = 0; depth <= mpMaxParseNestingDepth; depth++) {
      if (currentMPID == th2File.mpID) {
        return null;
      }

      final THElement element = th2File.elementByMPID(currentMPID);

      if (element is THScrap) {
        return currentMPID;
      }

      currentMPID = element.parentMPID;
    }

    return null;
  }
}
