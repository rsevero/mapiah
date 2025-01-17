// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'move_bezier_line_segment_command.dart';

class MoveBezierLineSegmentCommandMapper
    extends ClassMapperBase<MoveBezierLineSegmentCommand> {
  MoveBezierLineSegmentCommandMapper._();

  static MoveBezierLineSegmentCommandMapper? _instance;
  static MoveBezierLineSegmentCommandMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = MoveBezierLineSegmentCommandMapper._());
      CommandMapper.ensureInitialized();
      MapperContainer.globals.useAll([OffsetMapper()]);
      CommandTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MoveBezierLineSegmentCommand';

  static THBezierCurveLineSegment _$lineSegment(
          MoveBezierLineSegmentCommand v) =>
      v.lineSegment;
  static const Field<MoveBezierLineSegmentCommand, THBezierCurveLineSegment>
      _f$lineSegment = Field('lineSegment', _$lineSegment);
  static Offset _$endPointOriginalCoordinates(MoveBezierLineSegmentCommand v) =>
      v.endPointOriginalCoordinates;
  static const Field<MoveBezierLineSegmentCommand, Offset>
      _f$endPointOriginalCoordinates =
      Field('endPointOriginalCoordinates', _$endPointOriginalCoordinates);
  static Offset _$endPointNewCoordinates(MoveBezierLineSegmentCommand v) =>
      v.endPointNewCoordinates;
  static const Field<MoveBezierLineSegmentCommand, Offset>
      _f$endPointNewCoordinates =
      Field('endPointNewCoordinates', _$endPointNewCoordinates);
  static Offset _$controlPoint1OriginalCoordinates(
          MoveBezierLineSegmentCommand v) =>
      v.controlPoint1OriginalCoordinates;
  static const Field<MoveBezierLineSegmentCommand, Offset>
      _f$controlPoint1OriginalCoordinates = Field(
          'controlPoint1OriginalCoordinates',
          _$controlPoint1OriginalCoordinates);
  static Offset _$controlPoint1NewCoordinates(MoveBezierLineSegmentCommand v) =>
      v.controlPoint1NewCoordinates;
  static const Field<MoveBezierLineSegmentCommand, Offset>
      _f$controlPoint1NewCoordinates =
      Field('controlPoint1NewCoordinates', _$controlPoint1NewCoordinates);
  static Offset _$controlPoint2OriginalCoordinates(
          MoveBezierLineSegmentCommand v) =>
      v.controlPoint2OriginalCoordinates;
  static const Field<MoveBezierLineSegmentCommand, Offset>
      _f$controlPoint2OriginalCoordinates = Field(
          'controlPoint2OriginalCoordinates',
          _$controlPoint2OriginalCoordinates);
  static Offset _$controlPoint2NewCoordinates(MoveBezierLineSegmentCommand v) =>
      v.controlPoint2NewCoordinates;
  static const Field<MoveBezierLineSegmentCommand, Offset>
      _f$controlPoint2NewCoordinates =
      Field('controlPoint2NewCoordinates', _$controlPoint2NewCoordinates);
  static CommandType _$type(MoveBezierLineSegmentCommand v) => v.type;
  static const Field<MoveBezierLineSegmentCommand, CommandType> _f$type =
      Field('type', _$type, opt: true, def: CommandType.moveBezierLineSegment);
  static String _$description(MoveBezierLineSegmentCommand v) => v.description;
  static const Field<MoveBezierLineSegmentCommand, String> _f$description =
      Field('description', _$description,
          opt: true, def: 'Move Bezier Line Segment');

  @override
  final MappableFields<MoveBezierLineSegmentCommand> fields = const {
    #lineSegment: _f$lineSegment,
    #endPointOriginalCoordinates: _f$endPointOriginalCoordinates,
    #endPointNewCoordinates: _f$endPointNewCoordinates,
    #controlPoint1OriginalCoordinates: _f$controlPoint1OriginalCoordinates,
    #controlPoint1NewCoordinates: _f$controlPoint1NewCoordinates,
    #controlPoint2OriginalCoordinates: _f$controlPoint2OriginalCoordinates,
    #controlPoint2NewCoordinates: _f$controlPoint2NewCoordinates,
    #type: _f$type,
    #description: _f$description,
  };

  static MoveBezierLineSegmentCommand _instantiate(DecodingData data) {
    return MoveBezierLineSegmentCommand(
        lineSegment: data.dec(_f$lineSegment),
        endPointOriginalCoordinates: data.dec(_f$endPointOriginalCoordinates),
        endPointNewCoordinates: data.dec(_f$endPointNewCoordinates),
        controlPoint1OriginalCoordinates:
            data.dec(_f$controlPoint1OriginalCoordinates),
        controlPoint1NewCoordinates: data.dec(_f$controlPoint1NewCoordinates),
        controlPoint2OriginalCoordinates:
            data.dec(_f$controlPoint2OriginalCoordinates),
        controlPoint2NewCoordinates: data.dec(_f$controlPoint2NewCoordinates),
        type: data.dec(_f$type),
        description: data.dec(_f$description));
  }

  @override
  final Function instantiate = _instantiate;

  static MoveBezierLineSegmentCommand fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MoveBezierLineSegmentCommand>(map);
  }

  static MoveBezierLineSegmentCommand fromJson(String json) {
    return ensureInitialized().decodeJson<MoveBezierLineSegmentCommand>(json);
  }
}

mixin MoveBezierLineSegmentCommandMappable {
  String toJson() {
    return MoveBezierLineSegmentCommandMapper.ensureInitialized()
        .encodeJson<MoveBezierLineSegmentCommand>(
            this as MoveBezierLineSegmentCommand);
  }

  Map<String, dynamic> toMap() {
    return MoveBezierLineSegmentCommandMapper.ensureInitialized()
        .encodeMap<MoveBezierLineSegmentCommand>(
            this as MoveBezierLineSegmentCommand);
  }

  MoveBezierLineSegmentCommandCopyWith<MoveBezierLineSegmentCommand,
          MoveBezierLineSegmentCommand, MoveBezierLineSegmentCommand>
      get copyWith => _MoveBezierLineSegmentCommandCopyWithImpl(
          this as MoveBezierLineSegmentCommand, $identity, $identity);
  @override
  String toString() {
    return MoveBezierLineSegmentCommandMapper.ensureInitialized()
        .stringifyValue(this as MoveBezierLineSegmentCommand);
  }

  @override
  bool operator ==(Object other) {
    return MoveBezierLineSegmentCommandMapper.ensureInitialized()
        .equalsValue(this as MoveBezierLineSegmentCommand, other);
  }

  @override
  int get hashCode {
    return MoveBezierLineSegmentCommandMapper.ensureInitialized()
        .hashValue(this as MoveBezierLineSegmentCommand);
  }
}

extension MoveBezierLineSegmentCommandValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MoveBezierLineSegmentCommand, $Out> {
  MoveBezierLineSegmentCommandCopyWith<$R, MoveBezierLineSegmentCommand, $Out>
      get $asMoveBezierLineSegmentCommand => $base.as(
          (v, t, t2) => _MoveBezierLineSegmentCommandCopyWithImpl(v, t, t2));
}

abstract class MoveBezierLineSegmentCommandCopyWith<
    $R,
    $In extends MoveBezierLineSegmentCommand,
    $Out> implements CommandCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {THBezierCurveLineSegment? lineSegment,
      Offset? endPointOriginalCoordinates,
      Offset? endPointNewCoordinates,
      Offset? controlPoint1OriginalCoordinates,
      Offset? controlPoint1NewCoordinates,
      Offset? controlPoint2OriginalCoordinates,
      Offset? controlPoint2NewCoordinates,
      CommandType? type,
      String? description});
  MoveBezierLineSegmentCommandCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _MoveBezierLineSegmentCommandCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MoveBezierLineSegmentCommand, $Out>
    implements
        MoveBezierLineSegmentCommandCopyWith<$R, MoveBezierLineSegmentCommand,
            $Out> {
  _MoveBezierLineSegmentCommandCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MoveBezierLineSegmentCommand> $mapper =
      MoveBezierLineSegmentCommandMapper.ensureInitialized();
  @override
  $R call(
          {THBezierCurveLineSegment? lineSegment,
          Offset? endPointOriginalCoordinates,
          Offset? endPointNewCoordinates,
          Offset? controlPoint1OriginalCoordinates,
          Offset? controlPoint1NewCoordinates,
          Offset? controlPoint2OriginalCoordinates,
          Offset? controlPoint2NewCoordinates,
          CommandType? type,
          String? description}) =>
      $apply(FieldCopyWithData({
        if (lineSegment != null) #lineSegment: lineSegment,
        if (endPointOriginalCoordinates != null)
          #endPointOriginalCoordinates: endPointOriginalCoordinates,
        if (endPointNewCoordinates != null)
          #endPointNewCoordinates: endPointNewCoordinates,
        if (controlPoint1OriginalCoordinates != null)
          #controlPoint1OriginalCoordinates: controlPoint1OriginalCoordinates,
        if (controlPoint1NewCoordinates != null)
          #controlPoint1NewCoordinates: controlPoint1NewCoordinates,
        if (controlPoint2OriginalCoordinates != null)
          #controlPoint2OriginalCoordinates: controlPoint2OriginalCoordinates,
        if (controlPoint2NewCoordinates != null)
          #controlPoint2NewCoordinates: controlPoint2NewCoordinates,
        if (type != null) #type: type,
        if (description != null) #description: description
      }));
  @override
  MoveBezierLineSegmentCommand $make(CopyWithData data) =>
      MoveBezierLineSegmentCommand(
          lineSegment: data.get(#lineSegment, or: $value.lineSegment),
          endPointOriginalCoordinates: data
              .get(#endPointOriginalCoordinates,
                  or: $value.endPointOriginalCoordinates),
          endPointNewCoordinates:
              data
                  .get(
                      #endPointNewCoordinates,
                      or: $value.endPointNewCoordinates),
          controlPoint1OriginalCoordinates:
              data
                  .get(
                      #controlPoint1OriginalCoordinates,
                      or: $value.controlPoint1OriginalCoordinates),
          controlPoint1NewCoordinates:
              data
                  .get(#controlPoint1NewCoordinates,
                      or: $value.controlPoint1NewCoordinates),
          controlPoint2OriginalCoordinates: data.get(
              #controlPoint2OriginalCoordinates,
              or: $value.controlPoint2OriginalCoordinates),
          controlPoint2NewCoordinates: data.get(#controlPoint2NewCoordinates,
              or: $value.controlPoint2NewCoordinates),
          type: data.get(#type, or: $value.type),
          description: data.get(#description, or: $value.description));

  @override
  MoveBezierLineSegmentCommandCopyWith<$R2, MoveBezierLineSegmentCommand, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _MoveBezierLineSegmentCommandCopyWithImpl($value, $cast, t);
}
