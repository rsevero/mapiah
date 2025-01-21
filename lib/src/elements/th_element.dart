import 'dart:convert';

import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th_serializeable.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';
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

/// Base class for all elements that form a THFile, including THFile itself.
abstract class THElement implements THSerializable {
  // Internal ID used by Mapiah to identify each element during this run. This
  // value is never saved anywhere.
  final int _mapiahID;
  final int parentMapiahID;
  final String? sameLineComment;

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

  String get elementType;

  @override
  String toJson() {
    return jsonEncode(toMap());
  }

  static THElement fromMap(Map<String, dynamic> map) {
    switch (map['elementType']) {
      case thAreaBorderTHIDID:
        return THAreaBorderTHID.fromMap(map);
      case thAreaID:
        return THArea.fromMap(map);
      case thBezierCurveLieSegmentID:
        return THBezierCurveLineSegment.fromMap(map);
      case thCommentID:
        return THComment.fromMap(map);
      case thEmptyLineID:
        return THEmptyLine.fromMap(map);
      case thEncodingID:
        return THEncoding.fromMap(map);
      case thEndareaID:
        return THEndarea.fromMap(map);
      case thEndcommentID:
        return THEndcomment.fromMap(map);
      case thEndlineID:
        return THEndline.fromMap(map);
      case thEndscrapID:
        return THEndscrap.fromMap(map);
      case thLineID:
        return THLine.fromMap(map);
      case thMultilineCommentContentID:
        return THMultilineCommentContent.fromMap(map);
      case thMultilineCommentID:
        return THMultilineCommentContent.fromMap(map);
      case thPointID:
        return THPoint.fromMap(map);
      case thScrapID:
        return THScrap.fromMap(map);
      case thStraightLineSegmentID:
        return THStraightLineSegment.fromMap(map);
      case thUnrecognizedCommandID:
        return THUnrecognizedCommand.fromMap(map);
      case thXTherionConfigID:
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
