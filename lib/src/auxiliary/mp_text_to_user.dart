import 'package:mapiah/main.dart';
import 'package:mapiah/src/commands/types/mp_command_description_type.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPTextToUser {
  static final Map<MPCommandDescriptionType, String> _commandDescriptionMap =
      {};
  static final Map<THLengthUnitType, String> _lengthUnitMap = {};

  static void resetTextToUser() {
    final AppLocalizations localizations = mpLocator.appLocalizations;

    _commandDescriptionMap[MPCommandDescriptionType.moveBezierLineSegment] =
        localizations.mpMoveBezierLineSegmentCommandDescription;
    _commandDescriptionMap[MPCommandDescriptionType.moveElements] =
        localizations.mpMoveElementsCommandDescription;
    _commandDescriptionMap[MPCommandDescriptionType.moveLine] =
        localizations.mpMoveLineCommandDescription;
    _commandDescriptionMap[MPCommandDescriptionType.movePoint] =
        localizations.mpMovePointCommandDescription;
    _commandDescriptionMap[MPCommandDescriptionType.moveStraightLineSegment] =
        localizations.mpMoveStraightLineSegmentCommandDescription;

    _lengthUnitMap[THLengthUnitType.centimeter] =
        localizations.mpLengthUnitCentimeterAbbreviation;
    _lengthUnitMap[THLengthUnitType.feet] =
        localizations.mpLengthUnitFootAbbreviation;
    _lengthUnitMap[THLengthUnitType.inch] =
        localizations.mpLengthUnitInchAbbreviation;
    _lengthUnitMap[THLengthUnitType.meter] =
        localizations.mpLengthUnitMeterAbbreviation;
    _lengthUnitMap[THLengthUnitType.yard] =
        localizations.mpLengthUnitYardAbbreviation;
  }

  static String getCommandDescription(MPCommandDescriptionType commandType) {
    return _commandDescriptionMap[commandType]!;
  }

  static String getLengthUnitAbbreviation(THLengthUnitType lengthUnitType) {
    return _lengthUnitMap[lengthUnitType]!;
  }
}
