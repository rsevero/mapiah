import 'dart:convert';

import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/th_area.dart';
import 'package:mapiah/src/elements/th_area_border_thid.dart';
import 'package:mapiah/src/elements/th_bezier_curve_line_segment.dart';
import 'package:mapiah/src/elements/th_comment.dart';
import 'package:mapiah/src/elements/th_empty_line.dart';
import 'package:mapiah/src/elements/th_encoding.dart';
import 'package:mapiah/src/elements/th_endarea.dart';
import 'package:mapiah/src/elements/th_endcomment.dart';
import 'package:mapiah/src/elements/th_endline.dart';
import 'package:mapiah/src/elements/th_endscrap.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_multiline_comment_content.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/elements/th_straight_line_segment.dart';
import 'package:mapiah/src/elements/th_unrecognized_command.dart';
import 'package:mapiah/src/elements/th_xtherion_config.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';
import 'package:mapiah/src/stores/general_store.dart';

enum THElementType {
  areaBorderTHID,
  area,
  bezierCurveLineSegment,
  comment,
  emptyLine,
  encoding,
  endarea,
  endcomment,
  endline,
  endscrap,
  line,
  lineSegment,
  multilineCommentContent,
  multilineComment,
  point,
  scrap,
  straightLineSegment,
  unrecognizedCommand,
  xTherionConfig,
}

/// Base class for all elements that form a THFile, including THFile itself.
abstract class THElement {
  // Internal ID used by Mapiah to identify each element during this run. This
  // value is never saved anywhere.
  final int _mapiahID;
  final int parentMapiahID;
  String? sameLineComment;

  THElement.forCWJM({
    required int mapiahID,
    required this.parentMapiahID,
    this.sameLineComment,
  }) : _mapiahID = mapiahID;

  /// Main constructor.
  ///
  /// Main constructor that sets all essential properties. Any change made here
  /// should eventually be reproduced in the special descendants that don´t use
  /// this constructor but the [Generic private constructor].
  THElement.addToParent({required this.parentMapiahID, this.sameLineComment})
      : _mapiahID = getIt<GeneralStore>().nextMapiahIDForElements();

  THParent parent(THFile thFile) {
    if (parentMapiahID < 0) {
      return thFile;
    }

    return thFile.elementByMapiahID(parentMapiahID) as THParent;
  }

  THElementType get elementType;

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap();

  THElement copyWith();

  static THElement fromMap(Map<String, dynamic> map) {
    switch (map['elementType']) {
      case THElementType.areaBorderTHID:
        return THAreaBorderTHID.fromMap(map);
      case THElementType.area:
        return THArea.fromMap(map);
      case THElementType.bezierCurveLineSegment:
        return THBezierCurveLineSegment.fromMap(map);
      case THElementType.comment:
        return THComment.fromMap(map);
      case THElementType.emptyLine:
        return THEmptyLine.fromMap(map);
      case THElementType.encoding:
        return THEncoding.fromMap(map);
      case THElementType.endarea:
        return THEndarea.fromMap(map);
      case THElementType.endcomment:
        return THEndcomment.fromMap(map);
      case THElementType.endline:
        return THEndline.fromMap(map);
      case THElementType.endscrap:
        return THEndscrap.fromMap(map);
      case THElementType.line:
        return THLine.fromMap(map);
      case THElementType.lineSegment:
        return THMultilineCommentContent.fromMap(map);
      case THElementType.multilineCommentContent:
        return THMultilineCommentContent.fromMap(map);
      case THElementType.point:
        return THPoint.fromMap(map);
      case THElementType.scrap:
        return THScrap.fromMap(map);
      case THElementType.straightLineSegment:
        return THStraightLineSegment.fromMap(map);
      case THElementType.unrecognizedCommand:
        return THUnrecognizedCommand.fromMap(map);
      case THElementType.xTherionConfig:
        return THXTherionConfig.fromMap(map);
      default:
        throw THCustomException(
            "Unknown element type: '${map['elementType']}'.");
    }
  }

  int get mapiahID => _mapiahID;

  bool isSameClass(Object object);
}

/// Parent elements.
///
/// Mixin that provides parenting capabilities.
mixin THParent {
  // Here are registered all children mapiah IDs.
  final List<int> childrenMapiahID = <int>[];

  void addElementToParent(THElement element) {
    childrenMapiahID.add(element.mapiahID);
  }

  void deleteElementFromParent(THFile thFile, THElement element) {
    if (!childrenMapiahID.remove(element.mapiahID)) {
      throw THCustomException("'$element' not found.");
    }

    if (thFile.hasTHIDByElement(element)) {
      thFile.unregisterElementTHIDByElement(element);
    }
  }

  int get mapiahID;
}
