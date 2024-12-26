import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_extend_command_option.mapper.dart';

// extend [prev[ious] <station>] . if the point type is station and scrap projection
// is extended elevation, you can adjust the extension of the centreline using this option.
@MappableClass()
class THExtendCommandOption extends THCommandOption
    with THExtendCommandOptionMappable {
  String station;

  THExtendCommandOption(super.optionParent, this.station) {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'station')) {
      throw THCustomException(
          "Option 'extend' only valid for points of type 'station'.");
    }
  }

  @override
  String get optionType => 'extend';

  @override
  String specToFile() {
    if (station.isNotEmpty) {
      return "previous $station";
    } else {
      return '';
    }
  }
}
