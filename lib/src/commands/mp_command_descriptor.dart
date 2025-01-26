import 'package:mapiah/main.dart';
import 'package:mapiah/src/commands/mp_command_description_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPCommandDescriptor {
  static final Map<MPCommandDescriptionType, String> _commandDescriptionMap =
      {};

  static void resetCommandDescriptions() {
    final localizations = getIt<AppLocalizations>();
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
  }

  static String getCommandDescription(MPCommandDescriptionType commandType) {
    return _commandDescriptionMap[commandType]!;
  }
}
