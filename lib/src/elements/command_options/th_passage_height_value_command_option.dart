import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_has_options.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

part 'th_passage_height_value_command_option.mapper.dart';

@MappableEnum()
enum THPassageHeightModes {
  height,
  depth,
  distanceBetweenFloorAndCeiling,
  distanceToCeilingAndDistanceToFloor,
}

// passage-height: the following four forms of value are supported: +<number> (the height
// of the ceiling), -<number> (the depth of the floor or water depth), <number> (the dis-
// tance between floor and ceiling) and [+<number> -<number>] (the distance to ceiling
// and distance to floor).
@MappableClass()
class THPassageHeightValueCommandOption extends THCommandOption
    with THPassageHeightValueCommandOptionMappable {
  static const String _thisOptionType = 'value';
  late THDoublePart? _plusNumber;
  late THDoublePart? _minusNumber;
  late THPassageHeightModes _mode;
  late bool _plusHasSign;

  /// Constructor necessary for dart_mappable support.
  THPassageHeightValueCommandOption.withExplicitOptionType(
      super.thFile,
      super.parentMapiahID,
      super.optionType,
      THDoublePart? plusNumber,
      THDoublePart? minusNumber,
      THPassageHeightModes mode,
      bool plusHasSign)
      : super.withExplicitProperties() {
    _checkOptionParent();

    _plusNumber = plusNumber;
    _minusNumber = minusNumber;
    _mode = mode;
    _plusHasSign = plusHasSign;
  }

  THPassageHeightValueCommandOption.fromString(
      THHasOptions optionParent, String plusNumber, String minusNumber)
      : super(optionParent, _thisOptionType) {
    _checkOptionParent();
    plusAndMinusNumbersFromString(plusNumber, minusNumber);
  }

  void _checkOptionParent() {
    if ((optionParent is! THPoint) ||
        ((optionParent as THPoint).plaType != 'passage-height')) {
      throw THCustomException(
          "'$optionType' command option only supported on points of type 'passage-height'.");
    }
  }

  void _setMode() {
    if (_plusNumber == null) {
      if (_minusNumber == null) {
        throw THCustomException(
            "Passage-height command option must have at least one number.");
      } else {
        _mode = THPassageHeightModes.depth;
      }
    } else {
      if (_minusNumber == null) {
        if (_plusHasSign) {
          _mode = THPassageHeightModes.height;
        } else {
          _mode = THPassageHeightModes.distanceBetweenFloorAndCeiling;
        }
      } else {
        _mode = THPassageHeightModes.distanceToCeilingAndDistanceToFloor;
      }
    }
  }

  void plusAndMinusNumbersFromString(String aPlusNumber, String aMinusNumber) {
    if (aPlusNumber.isEmpty) {
      _plusNumber = null;
      _plusHasSign = false;
    } else {
      if (aPlusNumber.startsWith('+')) {
        _plusHasSign = true;
        aPlusNumber = aPlusNumber.substring(1);
      } else {
        _plusHasSign = false;
      }

      _plusNumber = THDoublePart.fromString(aPlusNumber);

      if (_plusNumber!.value < 0) {
        throw THCustomException(
            "Plus number in passage-height command option must be positive.");
      }
    }

    if (aMinusNumber.isEmpty) {
      _minusNumber = null;
    } else {
      _minusNumber = THDoublePart.fromString(aMinusNumber);

      if (_minusNumber!.value > 0) {
        throw THCustomException(
            "Minus number in passage-height command option must be negative.");
      }
    }

    _setMode();
  }

  @override
  String specToFile() {
    switch (_mode) {
      case THPassageHeightModes.height:
        return "+${_plusNumber!.toString()}";
      case THPassageHeightModes.depth:
        return _minusNumber!.toString();
      case THPassageHeightModes.distanceBetweenFloorAndCeiling:
        return _plusNumber!.toString();
      case THPassageHeightModes.distanceToCeilingAndDistanceToFloor:
        return "[ +${_plusNumber!.toString()} ${_minusNumber!.toString()} ]";
    }
  }

  THDoublePart? get plusNumber => _plusNumber;

  THDoublePart? get minusNumber => _minusNumber;

  THPassageHeightModes get mode => _mode;

  bool get plusHasSign => _plusHasSign;
}
