import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_name_command_option.mapper.dart';

// name <reference> . if the point type is station, this option gives the reference to the
// real survey station.
@MappableClass()
class THNameCommandOption extends THCommandOption
    with THNameCommandOptionMappable {
  late String reference;

  THNameCommandOption(super.optionParent, this.reference) {
    if (optionParent is THPoint) {
      final parentAsPoint = optionParent as THPoint;
      if ((optionParent as THPoint).plaType != 'station') {
        throw THCustomException(
            "Unsupported point type '${parentAsPoint.plaType}' 'name' option.");
      }
    } else {
      throw THCustomException(
          "Unsupported parent command type '${optionParent.elementType}' for 'name' option.");
    }
  }

  @override
  String get optionType => 'name';

  @override
  String specToFile() {
    return reference;
  }
}
