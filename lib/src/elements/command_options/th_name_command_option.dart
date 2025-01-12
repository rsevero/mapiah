import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_name_command_option.mapper.dart';

// name <reference> . if the point type is station, this option gives the reference to the
// real survey station.
@MappableClass()
class THNameCommandOption extends THCommandOption
    with THNameCommandOptionMappable {
  static const String _thisOptionType = 'name';
  late String reference;

  /// Constructor necessary for dart_mappable support.
  THNameCommandOption.withExplicitOptionType(
      super.thFile, super.parentMapiahID, super.optionType, this.reference)
      : super.withExplicitProperties() {
    _checkOptionParent();
  }

  THNameCommandOption(THHasOptions optionParent, this.reference)
      : super(optionParent, _thisOptionType) {
    _checkOptionParent();
  }

  void _checkOptionParent() {
    if (optionParent is THPoint) {
      final THPoint parentPoint = optionParent as THPoint;
      if (parentPoint.plaType != 'station') {
        throw THCustomException(
            "Unsupported point type '${parentPoint.plaType}' 'name' option.");
      }
    } else {
      throw THCustomException(
          "Unsupported parent command type '${optionParent.elementType}' for 'name' option.");
    }
  }

  @override
  String specToFile() {
    return reference;
  }
}
