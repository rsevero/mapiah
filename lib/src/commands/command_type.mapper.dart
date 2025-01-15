// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'command_type.dart';

class CommandTypeMapper extends EnumMapper<CommandType> {
  CommandTypeMapper._();

  static CommandTypeMapper? _instance;
  static CommandTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CommandTypeMapper._());
    }
    return _instance!;
  }

  static CommandType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  CommandType decode(dynamic value) {
    switch (value) {
      case 'moveBezierLineSegment':
        return CommandType.moveBezierLineSegment;
      case 'moveLine':
        return CommandType.moveLine;
      case 'movePoint':
        return CommandType.movePoint;
      case 'moveStraightLineSegment':
        return CommandType.moveStraightLineSegment;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(CommandType self) {
    switch (self) {
      case CommandType.moveBezierLineSegment:
        return 'moveBezierLineSegment';
      case CommandType.moveLine:
        return 'moveLine';
      case CommandType.movePoint:
        return 'movePoint';
      case CommandType.moveStraightLineSegment:
        return 'moveStraightLineSegment';
    }
  }
}

extension CommandTypeMapperExtension on CommandType {
  String toValue() {
    CommandTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<CommandType>(this) as String;
  }
}
