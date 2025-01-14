// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'move_point_command.dart';

class MovePointCommandMapper extends ClassMapperBase<MovePointCommand> {
  MovePointCommandMapper._();

  static MovePointCommandMapper? _instance;
  static MovePointCommandMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MovePointCommandMapper._());
      CommandMapper.ensureInitialized();
      MapperContainer.globals.useAll([OffsetMapper()]);
      CommandTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MovePointCommand';

  static int _$pointMapiahID(MovePointCommand v) => v.pointMapiahID;
  static const Field<MovePointCommand, int> _f$pointMapiahID =
      Field('pointMapiahID', _$pointMapiahID);
  static Offset _$originalCoordinates(MovePointCommand v) =>
      v.originalCoordinates;
  static const Field<MovePointCommand, Offset> _f$originalCoordinates =
      Field('originalCoordinates', _$originalCoordinates);
  static Offset _$newCoordinates(MovePointCommand v) => v.newCoordinates;
  static const Field<MovePointCommand, Offset> _f$newCoordinates =
      Field('newCoordinates', _$newCoordinates);
  static CommandType _$type(MovePointCommand v) => v.type;
  static const Field<MovePointCommand, CommandType> _f$type =
      Field('type', _$type, opt: true, def: CommandType.movePoint);
  static String _$description(MovePointCommand v) => v.description;
  static const Field<MovePointCommand, String> _f$description =
      Field('description', _$description, opt: true, def: 'Move Point');

  @override
  final MappableFields<MovePointCommand> fields = const {
    #pointMapiahID: _f$pointMapiahID,
    #originalCoordinates: _f$originalCoordinates,
    #newCoordinates: _f$newCoordinates,
    #type: _f$type,
    #description: _f$description,
  };

  static MovePointCommand _instantiate(DecodingData data) {
    return MovePointCommand(
        pointMapiahID: data.dec(_f$pointMapiahID),
        originalCoordinates: data.dec(_f$originalCoordinates),
        newCoordinates: data.dec(_f$newCoordinates),
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
  @override
  $R call(
      {int? pointMapiahID,
      Offset? originalCoordinates,
      Offset? newCoordinates,
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
  $R call(
          {int? pointMapiahID,
          Offset? originalCoordinates,
          Offset? newCoordinates,
          CommandType? type,
          String? description}) =>
      $apply(FieldCopyWithData({
        if (pointMapiahID != null) #pointMapiahID: pointMapiahID,
        if (originalCoordinates != null)
          #originalCoordinates: originalCoordinates,
        if (newCoordinates != null) #newCoordinates: newCoordinates,
        if (type != null) #type: type,
        if (description != null) #description: description
      }));
  @override
  MovePointCommand $make(CopyWithData data) => MovePointCommand(
      pointMapiahID: data.get(#pointMapiahID, or: $value.pointMapiahID),
      originalCoordinates:
          data.get(#originalCoordinates, or: $value.originalCoordinates),
      newCoordinates: data.get(#newCoordinates, or: $value.newCoordinates),
      type: data.get(#type, or: $value.type),
      description: data.get(#description, or: $value.description));

  @override
  MovePointCommandCopyWith<$R2, MovePointCommand, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _MovePointCommandCopyWithImpl($value, $cast, t);
}
