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
      THPointPositionPartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MovePointCommand';

  static String _$description(MovePointCommand v) => v.description;
  static const Field<MovePointCommand, String> _f$description =
      Field('description', _$description);
  static String _$oppositeCommandJson(MovePointCommand v) =>
      v.oppositeCommandJson;
  static const Field<MovePointCommand, String> _f$oppositeCommandJson =
      Field('oppositeCommandJson', _$oppositeCommandJson);
  static int _$pointMapiahID(MovePointCommand v) => v.pointMapiahID;
  static const Field<MovePointCommand, int> _f$pointMapiahID =
      Field('pointMapiahID', _$pointMapiahID);
  static THPointPositionPart _$newPosition(MovePointCommand v) => v.newPosition;
  static const Field<MovePointCommand, THPointPositionPart> _f$newPosition =
      Field('newPosition', _$newPosition);

  @override
  final MappableFields<MovePointCommand> fields = const {
    #description: _f$description,
    #oppositeCommandJson: _f$oppositeCommandJson,
    #pointMapiahID: _f$pointMapiahID,
    #newPosition: _f$newPosition,
  };

  static MovePointCommand _instantiate(DecodingData data) {
    return MovePointCommand.withDescription(
        data.dec(_f$description),
        data.dec(_f$oppositeCommandJson),
        data.dec(_f$pointMapiahID),
        data.dec(_f$newPosition));
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
  THPointPositionPartCopyWith<$R, THPointPositionPart, THPointPositionPart>
      get newPosition;
  @override
  $R call(
      {String? description,
      String? oppositeCommandJson,
      int? pointMapiahID,
      THPointPositionPart? newPosition});
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
  THPointPositionPartCopyWith<$R, THPointPositionPart, THPointPositionPart>
      get newPosition =>
          $value.newPosition.copyWith.$chain((v) => call(newPosition: v));
  @override
  $R call(
          {String? description,
          String? oppositeCommandJson,
          int? pointMapiahID,
          THPointPositionPart? newPosition}) =>
      $apply(FieldCopyWithData({
        if (description != null) #description: description,
        if (oppositeCommandJson != null)
          #oppositeCommandJson: oppositeCommandJson,
        if (pointMapiahID != null) #pointMapiahID: pointMapiahID,
        if (newPosition != null) #newPosition: newPosition
      }));
  @override
  MovePointCommand $make(CopyWithData data) => MovePointCommand.withDescription(
      data.get(#description, or: $value.description),
      data.get(#oppositeCommandJson, or: $value.oppositeCommandJson),
      data.get(#pointMapiahID, or: $value.pointMapiahID),
      data.get(#newPosition, or: $value.newPosition));

  @override
  MovePointCommandCopyWith<$R2, MovePointCommand, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _MovePointCommandCopyWithImpl($value, $cast, t);
}
