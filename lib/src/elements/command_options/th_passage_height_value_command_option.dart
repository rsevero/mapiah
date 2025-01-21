import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

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
class THPassageHeightValueCommandOption extends THCommandOption {
  late final THDoublePart? _plusNumber;
  late final THDoublePart? _minusNumber;
  late final THPassageHeightModes _mode;
  late final bool _plusHasSign;

  THPassageHeightValueCommandOption({
    required super.parentMapiahID,
    THDoublePart? plusNumber,
    THDoublePart? minusNumber,
    required THPassageHeightModes mode,
    required bool plusHasSign,
  })  : _plusNumber = plusNumber,
        _minusNumber = minusNumber,
        _mode = mode,
        _plusHasSign = plusHasSign,
        super();

  THPassageHeightValueCommandOption.fromString({
    required super.optionParent,
    required String plusNumber,
    required String minusNumber,
  }) : super.addToOptionParent() {
    plusAndMinusNumbersFromString(plusNumber, minusNumber);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.passageHeightValue;

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'plusNumber': _plusNumber?.toMap(),
      'minusNumber': _minusNumber?.toMap(),
      'mode': _mode.toString(),
      'plusHasSign': _plusHasSign,
    };
  }

  factory THPassageHeightValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THPassageHeightValueCommandOption(
      parentMapiahID: map['parentMapiahID'],
      plusNumber: map['plusNumber'] != null
          ? THDoublePart.fromMap(map['plusNumber'])
          : null,
      minusNumber: map['minusNumber'] != null
          ? THDoublePart.fromMap(map['minusNumber'])
          : null,
      mode: THPassageHeightModes.values
          .firstWhere((e) => e.toString() == map['mode']),
      plusHasSign: map['plusHasSign'],
    );
  }

  factory THPassageHeightValueCommandOption.fromJson(String jsonString) {
    return THPassageHeightValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THPassageHeightValueCommandOption copyWith({
    int? parentMapiahID,
    THDoublePart? plusNumber,
    THDoublePart? minusNumber,
    THPassageHeightModes? mode,
    bool? plusHasSign,
    bool makePlusNumberNull = false,
    bool makeMinusNumberNull = false,
  }) {
    return THPassageHeightValueCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      plusNumber: makePlusNumberNull ? null : (plusNumber ?? _plusNumber),
      minusNumber: makeMinusNumberNull ? null : (minusNumber ?? _minusNumber),
      mode: mode ?? _mode,
      plusHasSign: plusHasSign ?? _plusHasSign,
    );
  }

  @override
  bool operator ==(covariant THPassageHeightValueCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other._plusNumber == _plusNumber &&
        other._minusNumber == _minusNumber &&
        other._mode == _mode &&
        other._plusHasSign == _plusHasSign;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        _plusNumber,
        _minusNumber,
        _mode,
        _plusHasSign,
      );

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

  void plusAndMinusNumbersFromString(String plusNumber, String minusNumber) {
    if (plusNumber.isEmpty) {
      _plusNumber = null;
      _plusHasSign = false;
    } else {
      if (plusNumber.startsWith('+')) {
        _plusHasSign = true;
        plusNumber = plusNumber.substring(1);
      } else {
        _plusHasSign = false;
      }

      _plusNumber = THDoublePart.fromString(valueString: plusNumber);

      if (_plusNumber!.value < 0) {
        throw THCustomException(
            "Plus number in passage-height command option must be positive.");
      }
    }

    if (minusNumber.isEmpty) {
      _minusNumber = null;
    } else {
      _minusNumber = THDoublePart.fromString(valueString: minusNumber);

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
