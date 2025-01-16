// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'move_straight_line_segment_command.dart';

class MoveStraightLineSegmentCommandMapper
    extends ClassMapperBase<MoveStraightLineSegmentCommand> {
  MoveStraightLineSegmentCommandMapper._();

  static MoveStraightLineSegmentCommandMapper? _instance;
  static MoveStraightLineSegmentCommandMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = MoveStraightLineSegmentCommandMapper._());
      CommandMapper.ensureInitialized();
      MapperContainer.globals.useAll([OffsetMapper()]);
      THStraightLineSegmentMapper.ensureInitialized();
      CommandTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MoveStraightLineSegmentCommand';

  static THStraightLineSegment _$lineSegment(
          MoveStraightLineSegmentCommand v) =>
      v.lineSegment;
  static const Field<MoveStraightLineSegmentCommand, THStraightLineSegment>
      _f$lineSegment = Field('lineSegment', _$lineSegment);
  static Offset _$endPointOriginalCoordinates(
          MoveStraightLineSegmentCommand v) =>
      v.endPointOriginalCoordinates;
  static const Field<MoveStraightLineSegmentCommand, Offset>
      _f$endPointOriginalCoordinates =
      Field('endPointOriginalCoordinates', _$endPointOriginalCoordinates);
  static Offset _$endPointNewCoordinates(MoveStraightLineSegmentCommand v) =>
      v.endPointNewCoordinates;
  static const Field<MoveStraightLineSegmentCommand, Offset>
      _f$endPointNewCoordinates =
      Field('endPointNewCoordinates', _$endPointNewCoordinates);
  static CommandType _$type(MoveStraightLineSegmentCommand v) => v.type;
  static const Field<MoveStraightLineSegmentCommand, CommandType> _f$type =
      Field('type', _$type,
          opt: true, def: CommandType.moveStraightLineSegment);
  static String _$description(MoveStraightLineSegmentCommand v) =>
      v.description;
  static const Field<MoveStraightLineSegmentCommand, String> _f$description =
      Field('description', _$description,
          opt: true, def: 'Move Straight Line Segment');

  @override
  final MappableFields<MoveStraightLineSegmentCommand> fields = const {
    #lineSegment: _f$lineSegment,
    #endPointOriginalCoordinates: _f$endPointOriginalCoordinates,
    #endPointNewCoordinates: _f$endPointNewCoordinates,
    #type: _f$type,
    #description: _f$description,
  };

  static MoveStraightLineSegmentCommand _instantiate(DecodingData data) {
    return MoveStraightLineSegmentCommand(
        lineSegment: data.dec(_f$lineSegment),
        endPointOriginalCoordinates: data.dec(_f$endPointOriginalCoordinates),
        endPointNewCoordinates: data.dec(_f$endPointNewCoordinates),
        type: data.dec(_f$type),
        description: data.dec(_f$description));
  }

  @override
  final Function instantiate = _instantiate;

  static MoveStraightLineSegmentCommand fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MoveStraightLineSegmentCommand>(map);
  }

  static MoveStraightLineSegmentCommand fromJson(String json) {
    return ensureInitialized().decodeJson<MoveStraightLineSegmentCommand>(json);
  }
}

mixin MoveStraightLineSegmentCommandMappable {
  String toJson() {
    return MoveStraightLineSegmentCommandMapper.ensureInitialized()
        .encodeJson<MoveStraightLineSegmentCommand>(
            this as MoveStraightLineSegmentCommand);
  }

  Map<String, dynamic> toMap() {
    return MoveStraightLineSegmentCommandMapper.ensureInitialized()
        .encodeMap<MoveStraightLineSegmentCommand>(
            this as MoveStraightLineSegmentCommand);
  }

  MoveStraightLineSegmentCommandCopyWith<MoveStraightLineSegmentCommand,
          MoveStraightLineSegmentCommand, MoveStraightLineSegmentCommand>
      get copyWith => _MoveStraightLineSegmentCommandCopyWithImpl(
          this as MoveStraightLineSegmentCommand, $identity, $identity);
  @override
  String toString() {
    return MoveStraightLineSegmentCommandMapper.ensureInitialized()
        .stringifyValue(this as MoveStraightLineSegmentCommand);
  }

  @override
  bool operator ==(Object other) {
    return MoveStraightLineSegmentCommandMapper.ensureInitialized()
        .equalsValue(this as MoveStraightLineSegmentCommand, other);
  }

  @override
  int get hashCode {
    return MoveStraightLineSegmentCommandMapper.ensureInitialized()
        .hashValue(this as MoveStraightLineSegmentCommand);
  }
}

extension MoveStraightLineSegmentCommandValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MoveStraightLineSegmentCommand, $Out> {
  MoveStraightLineSegmentCommandCopyWith<$R, MoveStraightLineSegmentCommand,
          $Out>
      get $asMoveStraightLineSegmentCommand => $base.as(
          (v, t, t2) => _MoveStraightLineSegmentCommandCopyWithImpl(v, t, t2));
}

abstract class MoveStraightLineSegmentCommandCopyWith<
    $R,
    $In extends MoveStraightLineSegmentCommand,
    $Out> implements CommandCopyWith<$R, $In, $Out> {
  THStraightLineSegmentCopyWith<$R, THStraightLineSegment,
      THStraightLineSegment> get lineSegment;
  @override
  $R call(
      {THStraightLineSegment? lineSegment,
      Offset? endPointOriginalCoordinates,
      Offset? endPointNewCoordinates,
      CommandType? type,
      String? description});
  MoveStraightLineSegmentCommandCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _MoveStraightLineSegmentCommandCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MoveStraightLineSegmentCommand, $Out>
    implements
        MoveStraightLineSegmentCommandCopyWith<$R,
            MoveStraightLineSegmentCommand, $Out> {
  _MoveStraightLineSegmentCommandCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MoveStraightLineSegmentCommand> $mapper =
      MoveStraightLineSegmentCommandMapper.ensureInitialized();
  @override
  THStraightLineSegmentCopyWith<$R, THStraightLineSegment,
          THStraightLineSegment>
      get lineSegment =>
          $value.lineSegment.copyWith.$chain((v) => call(lineSegment: v));
  @override
  $R call(
          {THStraightLineSegment? lineSegment,
          Offset? endPointOriginalCoordinates,
          Offset? endPointNewCoordinates,
          CommandType? type,
          String? description}) =>
      $apply(FieldCopyWithData({
        if (lineSegment != null) #lineSegment: lineSegment,
        if (endPointOriginalCoordinates != null)
          #endPointOriginalCoordinates: endPointOriginalCoordinates,
        if (endPointNewCoordinates != null)
          #endPointNewCoordinates: endPointNewCoordinates,
        if (type != null) #type: type,
        if (description != null) #description: description
      }));
  @override
  MoveStraightLineSegmentCommand $make(CopyWithData data) =>
      MoveStraightLineSegmentCommand(
          lineSegment: data.get(#lineSegment, or: $value.lineSegment),
          endPointOriginalCoordinates: data.get(#endPointOriginalCoordinates,
              or: $value.endPointOriginalCoordinates),
          endPointNewCoordinates: data.get(#endPointNewCoordinates,
              or: $value.endPointNewCoordinates),
          type: data.get(#type, or: $value.type),
          description: data.get(#description, or: $value.description));

  @override
  MoveStraightLineSegmentCommandCopyWith<$R2, MoveStraightLineSegmentCommand,
      $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _MoveStraightLineSegmentCommandCopyWithImpl($value, $cast, t);
}
