import 'package:mapiah/main.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';

class MPTextToUser {
  static String getCommandDescription(MPCommandDescriptionType commandType) {
    switch (commandType) {
      case MPCommandDescriptionType.addElements:
        return mpLocator.appLocalizations.mpAddElementsCommandDescription;
      case MPCommandDescriptionType.addLine:
        return mpLocator.appLocalizations.mpAddLineCommandDescription;
      case MPCommandDescriptionType.addLineSegment:
        return mpLocator.appLocalizations.mpAddLineSegmentCommandDescription;
      case MPCommandDescriptionType.addPoint:
        return mpLocator.appLocalizations.mpAddPointCommandDescription;
      case MPCommandDescriptionType.deleteElements:
        return mpLocator.appLocalizations.mpDeleteElementsCommandDescription;
      case MPCommandDescriptionType.deleteLine:
        return mpLocator.appLocalizations.mpDeleteLineSegmentCommandDescription;
      case MPCommandDescriptionType.deleteLineSegment:
        return mpLocator.appLocalizations.mpDeleteLineCommandDescription;
      case MPCommandDescriptionType.deletePoint:
        return mpLocator.appLocalizations.mpDeletePointCommandDescription;
      case MPCommandDescriptionType.editBezierCurve:
        return mpLocator.appLocalizations.mpEditBezierCurveCommandDescription;
      case MPCommandDescriptionType.editLine:
        return mpLocator.appLocalizations.mpEditLineCommandDescription;
      case MPCommandDescriptionType.editLineSegment:
        return mpLocator.appLocalizations.mpEditLineSegmentCommandDescription;
      case MPCommandDescriptionType.moveBezierLineSegment:
        return mpLocator
            .appLocalizations.mpMoveBezierLineSegmentCommandDescription;
      case MPCommandDescriptionType.moveElements:
        return mpLocator.appLocalizations.mpMoveElementsCommandDescription;
      case MPCommandDescriptionType.moveLine:
        return mpLocator.appLocalizations.mpMoveLineCommandDescription;
      case MPCommandDescriptionType.movePoint:
        return mpLocator.appLocalizations.mpMovePointCommandDescription;
      case MPCommandDescriptionType.moveStraightLineSegment:
        return mpLocator
            .appLocalizations.mpMoveStraightLineSegmentCommandDescription;
    }
  }

  static String getLengthUnitAbbreviation(THLengthUnitType lengthUnitType) {
    switch (lengthUnitType) {
      case THLengthUnitType.centimeter:
        return mpLocator.appLocalizations.mpLengthUnitCentimeterAbbreviation;
      case THLengthUnitType.feet:
        return mpLocator.appLocalizations.mpLengthUnitFootAbbreviation;
      case THLengthUnitType.inch:
        return mpLocator.appLocalizations.mpLengthUnitInchAbbreviation;
      case THLengthUnitType.meter:
        return mpLocator.appLocalizations.mpLengthUnitMeterAbbreviation;
      case THLengthUnitType.yard:
        return mpLocator.appLocalizations.mpLengthUnitYardAbbreviation;
    }
  }
}
