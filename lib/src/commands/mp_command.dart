library;

import 'dart:collection';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/commands/factories/mp_command_factory.dart';
import 'package:mapiah/src/commands/mp_undo_redo_command.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';

part 'mp_add_area_border_thid_command.dart';
part 'mp_add_area_command.dart';
part 'mp_add_line_command.dart';
part 'mp_add_line_segment_command.dart';
part 'mp_add_point_command.dart';
part 'mp_add_scrap_command.dart';
part 'mp_add_xtherion_image_insert_config_command.dart';
part 'mp_edit_area_type_command.dart';
part 'mp_edit_line_segment_command.dart';
part 'mp_edit_line_type_command.dart';
part 'mp_edit_point_type_command.dart';
part 'mp_move_area_command.dart';
part 'mp_move_bezier_line_segment_command.dart';
part 'mp_move_line_command.dart';
part 'mp_move_point_command.dart';
part 'mp_move_straight_line_segment_command.dart';
part 'mp_multiple_elements_command.dart';
part 'mp_remove_area_border_thid_command.dart';
part 'mp_remove_area_command.dart';
part 'mp_remove_attr_option_from_element_command.dart';
part 'mp_remove_line_command.dart';
part 'mp_remove_line_segment_command.dart';
part 'mp_remove_option_from_element_command.dart';
part 'mp_remove_point_command.dart';
part 'mp_remove_scrap_command.dart';
part 'mp_remove_xtherion_image_insert_config_command.dart';
part 'mp_set_attr_option_to_element_command.dart';
part 'mp_set_option_to_element_command.dart';
part 'mp_replace_line_segments_command.dart';
part 'types/mp_command_type.dart';

/// Abstract class that defines the structure of a command.
///
/// It is responsible both for executing and undoing the command, therefore, all
/// actions that should support undo must be implemented as a command.
abstract class MPCommand {
  final MPCommandDescriptionType descriptionType;
  MPUndoRedoCommand? _undoRedoCommand;

  MPCommand.forCWJM({required this.descriptionType});

  MPCommand({required this.descriptionType});

  MPCommandType get type;

  MPCommandDescriptionType get defaultDescriptionType;

  MPUndoRedoCommand getUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    _undoRedoCommand ??= _createUndoRedoCommand(th2FileEditController);

    return _undoRedoCommand!;
  }

  /// The description for the undo/redo command should be the description of
  /// the original command so the message on undo and redo are the same even
  /// if the actual original and opposite commands are different.
  MPUndoRedoCommand _createUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  );

  void execute(
    TH2FileEditController th2FileEditController, {
    bool keepOriginalLineTH2File = false,
  }) {
    if (hasNewExecuteMethod) {
      _prepareUndoRedoInfo();
      _newActualExecute(
        th2FileEditController,
        keepOriginalLineTH2File: keepOriginalLineTH2File,
      );
      _undoRedoCommand ??= _newCreateUndoRedoCommand(th2FileEditController);
    } else {
      _undoRedoCommand ??= _createUndoRedoCommand(th2FileEditController);
      _actualExecute(
        th2FileEditController,
        keepOriginalLineTH2File: keepOriginalLineTH2File,
      );
    }
  }

  void _actualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  });

  MPCommand copyWith({MPCommandDescriptionType? descriptionType});

  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap() {
    return {'commandType': type.name, 'descriptionType': descriptionType.name};
  }

  static MPCommand fromJson(String jsonString) {
    return fromMap(jsonDecode(jsonString));
  }

  bool equalsBase(Object other) {
    return other is MPCommand && other.descriptionType == descriptionType;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return equalsBase(other);
  }

  @override
  int get hashCode => descriptionType.hashCode;

  static MPCommand fromMap(Map<String, dynamic> map) {
    switch (MPCommandType.values.byName(map['commandType'])) {
      case MPCommandType.addArea:
        return MPAddAreaCommand.fromMap(map);
      case MPCommandType.addAreaBorderTHID:
        return MPAddAreaBorderTHIDCommand.fromMap(map);
      case MPCommandType.addLine:
        return MPAddLineCommand.fromMap(map);
      case MPCommandType.addLineSegment:
        return MPAddLineSegmentCommand.fromMap(map);
      case MPCommandType.addPoint:
        return MPAddPointCommand.fromMap(map);
      case MPCommandType.addScrap:
        return MPAddScrapCommand.fromMap(map);
      case MPCommandType.addXTherionImageInsertConfig:
        return MPAddXTherionImageInsertConfigCommand.fromMap(map);
      case MPCommandType.editAreaType:
        return MPEditAreaTypeCommand.fromMap(map);
      case MPCommandType.editLineSegment:
        return MPEditLineSegmentCommand.fromMap(map);
      case MPCommandType.editLineType:
        return MPEditLineTypeCommand.fromMap(map);
      case MPCommandType.editPointType:
        return MPEditPointTypeCommand.fromMap(map);
      case MPCommandType.moveArea:
        return MPMoveAreaCommand.fromMap(map);
      case MPCommandType.moveBezierLineSegment:
        return MPMoveBezierLineSegmentCommand.fromMap(map);
      case MPCommandType.moveLine:
        return MPMoveLineCommand.fromMap(map);
      case MPCommandType.movePoint:
        return MPMovePointCommand.fromMap(map);
      case MPCommandType.moveStraightLineSegment:
        return MPMoveStraightLineSegmentCommand.fromMap(map);
      case MPCommandType.multipleElements:
        return MPMultipleElementsCommand.fromMap(map);
      case MPCommandType.removeAttrOptionFromElement:
        return MPRemoveAttrOptionFromElementCommand.fromMap(map);
      case MPCommandType.removeArea:
        return MPRemoveAreaCommand.fromMap(map);
      case MPCommandType.removeAreaBorderTHID:
        return MPRemoveAreaBorderTHIDCommand.fromMap(map);
      case MPCommandType.removeLine:
        return MPRemoveLineCommand.fromMap(map);
      case MPCommandType.removeLineSegment:
        return MPRemoveLineSegmentCommand.fromMap(map);
      case MPCommandType.removeOptionFromElement:
        return MPRemoveOptionFromElementCommand.fromMap(map);
      case MPCommandType.removePoint:
        return MPRemovePointCommand.fromMap(map);
      case MPCommandType.removeScrap:
        return MPRemoveScrapCommand.fromMap(map);
      case MPCommandType.removeXTherionImageInsertConfig:
        return MPRemoveXTherionImageInsertConfigCommand.fromMap(map);
      case MPCommandType.replaceLineSegments:
        return MPReplaceLineSegmentsCommand.fromMap(map);
      case MPCommandType.setAttrOptionToElement:
        return MPSetAttrOptionToElementCommand.fromMap(map);
      case MPCommandType.setOptionToElement:
        return MPSetOptionToElementCommand.fromMap(map);
    }
  }

  bool get hasNewExecuteMethod => false;

  void _prepareUndoRedoInfo() {
    throw UnimplementedError();
  }

  void _newActualExecute(
    TH2FileEditController th2FileEditController, {
    required bool keepOriginalLineTH2File,
  }) {
    throw UnimplementedError();
  }

  MPUndoRedoCommand _newCreateUndoRedoCommand(
    TH2FileEditController th2FileEditController,
  ) {
    throw UnimplementedError();
  }
}
