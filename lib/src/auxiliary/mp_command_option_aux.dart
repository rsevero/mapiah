import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';

class MPCommandOptionAux {
  static bool isSmooth(THHasOptionsMixin element) {
    return element.hasOption(THCommandOptionType.smooth) &&
        (element.optionByType(THCommandOptionType.smooth)
                    as THSmoothCommandOption)
                .choice ==
            THOptionChoicesOnOffAutoType.on;
  }
}
