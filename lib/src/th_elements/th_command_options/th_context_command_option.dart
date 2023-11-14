import 'package:mapiah/src/th_elements/th_area.dart';
import 'package:mapiah/src/th_elements/th_command_options/th_command_option.dart';
import 'package:mapiah/src/th_elements/th_line.dart';
import 'package:mapiah/src/th_elements/th_point.dart';
import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

// context <point/line/area> <symbol-type> . (to be used with symbol-hide and
// symbol-show layout options) symbol will be hidden/shown according to rules for spec-
// ified <symbol-type>.
class THContextCommandOption extends THCommandOption {
  late String _elementType;
  late String _symbolType;

  static final _supportedElementTypes = <String>{'point', 'line', 'area'};

  THContextCommandOption(
      super.parentOption, String aElementType, String aSymbolType) {
    elementType = aElementType;
    symbolType = aSymbolType;
  }

  set elementType(String aElementType) {
    if (!_supportedElementTypes.contains(aElementType)) {
      throw THCustomException("Unsupported element type '$aElementType'.");
    }
    _elementType = aElementType;
  }

  set symbolType(String aSymbolType) {
    switch (elementType) {
      case 'point':
        if (!THPoint.hasPointType(aSymbolType)) {
          throw THCustomException("Unsupported point type '$aSymbolType'.");
        }
      case 'line':
        if (!THLine.hasLineType(aSymbolType)) {
          throw THCustomException("Unsupported line type '$aSymbolType'.");
        }
      case 'area':
        if (!THArea.hasAreaType(aSymbolType)) {
          throw THCustomException("Unsupported area type '$aSymbolType'.");
        }
      default:
        throw THCustomException("Unsupported element type '$elementType'.");
    }
    _symbolType = aSymbolType;
  }

  String get elementType {
    return _elementType;
  }

  String get symbolType {
    return _symbolType;
  }

  @override
  String get optionType => 'context';

  @override
  String specToFile() {
    return "$elementType $symbolType";
  }
}
