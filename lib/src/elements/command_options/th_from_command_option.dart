import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_from_command_option.mapper.dart';

// from <station> . valid for extra points, specifies reference station.
@MappableClass()
class THFromCommandOption extends THCommandOption
    with THFromCommandOptionMappable {
  static const String _thisOptionType = 'from';
  String station;

  /// Constructor necessary for dart_mappable support.
  THFromCommandOption.withExplicitParameters(
      super.thFile, super.parentMapiahID, super.optionType, this.station)
      : super.withExplicitParameters() {
    _checkOptionParent();
  }

  THFromCommandOption(THHasOptions optionParent, this.station)
      : super(optionParent, _thisOptionType) {
    _checkOptionParent();
  }

  void _checkOptionParent() {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'extra')) {
      throw THCustomException(
          "Option 'dist' only valid for points of type 'extra'.");
    }
  }

  @override
  String specToFile() {
    return station;
  }
}
