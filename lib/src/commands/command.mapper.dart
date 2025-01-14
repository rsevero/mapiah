// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'command.dart';

class CommandMapper extends ClassMapperBase<Command> {
  CommandMapper._();

  static CommandMapper? _instance;
  static CommandMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CommandMapper._());
      MovePointCommandMapper.ensureInitialized();
      CommandTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Command';

  static CommandType _$type(Command v) => v.type;
  static const Field<Command, CommandType> _f$type = Field('type', _$type);
  static String _$description(Command v) => v.description;
  static const Field<Command, String> _f$description =
      Field('description', _$description);

  @override
  final MappableFields<Command> fields = const {
    #type: _f$type,
    #description: _f$description,
  };

  static Command _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('Command');
  }

  @override
  final Function instantiate = _instantiate;

  static Command fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Command>(map);
  }

  static Command fromJson(String json) {
    return ensureInitialized().decodeJson<Command>(json);
  }
}

mixin CommandMappable {
  String toJson();
  Map<String, dynamic> toMap();
  CommandCopyWith<Command, Command, Command> get copyWith;
}

abstract class CommandCopyWith<$R, $In extends Command, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({CommandType? type, String? description});
  CommandCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

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
      case 'movePoint':
        return CommandType.movePoint;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(CommandType self) {
    switch (self) {
      case CommandType.movePoint:
        return 'movePoint';
    }
  }
}

extension CommandTypeMapperExtension on CommandType {
  String toValue() {
    CommandTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<CommandType>(this) as String;
  }
}

class MovePointCommandMapper extends ClassMapperBase<MovePointCommand> {
  MovePointCommandMapper._();

  static MovePointCommandMapper? _instance;
  static MovePointCommandMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MovePointCommandMapper._());
      CommandMapper.ensureInitialized();
      THPositionPartMapper.ensureInitialized();
      CommandTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MovePointCommand';

  static int _$pointMapiahID(MovePointCommand v) => v.pointMapiahID;
  static const Field<MovePointCommand, int> _f$pointMapiahID =
      Field('pointMapiahID', _$pointMapiahID);
  static THPositionPart _$originalPosition(MovePointCommand v) =>
      v.originalPosition;
  static const Field<MovePointCommand, THPositionPart> _f$originalPosition =
      Field('originalPosition', _$originalPosition);
  static THPositionPart _$newPosition(MovePointCommand v) => v.newPosition;
  static const Field<MovePointCommand, THPositionPart> _f$newPosition =
      Field('newPosition', _$newPosition);
  static CommandType _$type(MovePointCommand v) => v.type;
  static const Field<MovePointCommand, CommandType> _f$type =
      Field('type', _$type, opt: true, def: CommandType.movePoint);
  static String _$description(MovePointCommand v) => v.description;
  static const Field<MovePointCommand, String> _f$description =
      Field('description', _$description, opt: true, def: 'Move Point');

  @override
  final MappableFields<MovePointCommand> fields = const {
    #pointMapiahID: _f$pointMapiahID,
    #originalPosition: _f$originalPosition,
    #newPosition: _f$newPosition,
    #type: _f$type,
    #description: _f$description,
  };

  static MovePointCommand _instantiate(DecodingData data) {
    return MovePointCommand(
        pointMapiahID: data.dec(_f$pointMapiahID),
        originalPosition: data.dec(_f$originalPosition),
        newPosition: data.dec(_f$newPosition),
        type: data.dec(_f$type),
        description: data.dec(_f$description));
  }

  @override
  final Function instantiate = _instantiate;

  static MovePointCommand fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MovePointCommand>(map);
  }

  static MovePointCommand fromJson(String json) {
    return ensureInitialized().decodeJson<MovePointCommand>(json);
  }
}

mixin MovePointCommandMappable {
  String toJson() {
    return MovePointCommandMapper.ensureInitialized()
        .encodeJson<MovePointCommand>(this as MovePointCommand);
  }

  Map<String, dynamic> toMap() {
    return MovePointCommandMapper.ensureInitialized()
        .encodeMap<MovePointCommand>(this as MovePointCommand);
  }

  MovePointCommandCopyWith<MovePointCommand, MovePointCommand, MovePointCommand>
      get copyWith => _MovePointCommandCopyWithImpl(
          this as MovePointCommand, $identity, $identity);
  @override
  String toString() {
    return MovePointCommandMapper.ensureInitialized()
        .stringifyValue(this as MovePointCommand);
  }

  @override
  bool operator ==(Object other) {
    return MovePointCommandMapper.ensureInitialized()
        .equalsValue(this as MovePointCommand, other);
  }

  @override
  int get hashCode {
    return MovePointCommandMapper.ensureInitialized()
        .hashValue(this as MovePointCommand);
  }
}

extension MovePointCommandValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MovePointCommand, $Out> {
  MovePointCommandCopyWith<$R, MovePointCommand, $Out>
      get $asMovePointCommand =>
          $base.as((v, t, t2) => _MovePointCommandCopyWithImpl(v, t, t2));
}

abstract class MovePointCommandCopyWith<$R, $In extends MovePointCommand, $Out>
    implements CommandCopyWith<$R, $In, $Out> {
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart>
      get originalPosition;
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get newPosition;
  @override
  $R call(
      {int? pointMapiahID,
      THPositionPart? originalPosition,
      THPositionPart? newPosition,
      CommandType? type,
      String? description});
  MovePointCommandCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _MovePointCommandCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MovePointCommand, $Out>
    implements MovePointCommandCopyWith<$R, MovePointCommand, $Out> {
  _MovePointCommandCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MovePointCommand> $mapper =
      MovePointCommandMapper.ensureInitialized();
  @override
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart>
      get originalPosition => $value.originalPosition.copyWith
          .$chain((v) => call(originalPosition: v));
  @override
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get newPosition =>
      $value.newPosition.copyWith.$chain((v) => call(newPosition: v));
  @override
  $R call(
          {int? pointMapiahID,
          THPositionPart? originalPosition,
          THPositionPart? newPosition,
          CommandType? type,
          String? description}) =>
      $apply(FieldCopyWithData({
        if (pointMapiahID != null) #pointMapiahID: pointMapiahID,
        if (originalPosition != null) #originalPosition: originalPosition,
        if (newPosition != null) #newPosition: newPosition,
        if (type != null) #type: type,
        if (description != null) #description: description
      }));
  @override
  MovePointCommand $make(CopyWithData data) => MovePointCommand(
      pointMapiahID: data.get(#pointMapiahID, or: $value.pointMapiahID),
      originalPosition:
          data.get(#originalPosition, or: $value.originalPosition),
      newPosition: data.get(#newPosition, or: $value.newPosition),
      type: data.get(#type, or: $value.type),
      description: data.get(#description, or: $value.description));

  @override
  MovePointCommandCopyWith<$R2, MovePointCommand, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _MovePointCommandCopyWithImpl($value, $cast, t);
}
