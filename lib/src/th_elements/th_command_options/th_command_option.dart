import 'package:mapiah/src/th_elements/th_command_options/th_projection_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_scale_command_option.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_unrecognized_command_option.dart';
import 'package:mapiah/src/th_elements/th_has_options.dart';

abstract class THCommandOption {
  final THHasOptions parent;

  THCommandOption(this.parent) {
    parent.addUpdateOption(this);
  }

  String optionType();

  String specToString();

  factory THCommandOption.scrapOption(
      String aOptionType, THHasOptions aParent) {
    switch (aOptionType.toLowerCase()) {
      case 'projection':
        return THProjectionCommandOption(aParent);
      case 'scale':
        return THScaleCommandOption(aParent);
      default:
        return THUnrecognizedCommandOption(aParent);
    }
  }
}
