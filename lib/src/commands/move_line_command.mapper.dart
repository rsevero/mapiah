// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'move_line_command.dart';

class MoveLineCommandMapper extends ClassMapperBase<MoveLineCommand> {
  MoveLineCommandMapper._();

  static MoveLineCommandMapper? _instance;
  static MoveLineCommandMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MoveLineCommandMapper._());
      CommandMapper.ensureInitialized();
      MapperContainer.globals.useAll([OffsetMapper()]);
      THLineMapper.ensureInitialized();
      THLineSegmentMapper.ensureInitialized();
      CommandTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MoveLineCommand';

  static THLine _$originalLine(MoveLineCommand v) => v.originalLine;
  static const Field<MoveLineCommand, THLine> _f$originalLine =
      Field('originalLine', _$originalLine);
  static LinkedHashMap<int, THLineSegment> _$originalLineSegmentsMap(
          MoveLineCommand v) =>
      v.originalLineSegmentsMap;
  static const Field<MoveLineCommand, LinkedHashMap<int, THLineSegment>>
      _f$originalLineSegmentsMap =
      Field('originalLineSegmentsMap', _$originalLineSegmentsMap);
  static THLine _$newLine(MoveLineCommand v) => v.newLine;
  static const Field<MoveLineCommand, THLine> _f$newLine =
      Field('newLine', _$newLine);
  static LinkedHashMap<int, THLineSegment> _$newLineSegmentsMap(
          MoveLineCommand v) =>
      v.newLineSegmentsMap;
  static const Field<MoveLineCommand, LinkedHashMap<int, THLineSegment>>
      _f$newLineSegmentsMap = Field('newLineSegmentsMap', _$newLineSegmentsMap);
  static CommandType _$type(MoveLineCommand v) => v.type;
  static const Field<MoveLineCommand, CommandType> _f$type =
      Field('type', _$type, opt: true, def: CommandType.moveLine);
  static String _$description(MoveLineCommand v) => v.description;
  static const Field<MoveLineCommand, String> _f$description =
      Field('description', _$description, opt: true, def: 'Move Line');
  static Offset _$deltaOnCanvas(MoveLineCommand v) => v.deltaOnCanvas;
  static const Field<MoveLineCommand, Offset> _f$deltaOnCanvas =
      Field('deltaOnCanvas', _$deltaOnCanvas, opt: true, def: Offset.zero);
  static bool _$isFromDelta(MoveLineCommand v) => v.isFromDelta;
  static const Field<MoveLineCommand, bool> _f$isFromDelta =
      Field('isFromDelta', _$isFromDelta, opt: true, def: false);

  @override
  final MappableFields<MoveLineCommand> fields = const {
    #originalLine: _f$originalLine,
    #originalLineSegmentsMap: _f$originalLineSegmentsMap,
    #newLine: _f$newLine,
    #newLineSegmentsMap: _f$newLineSegmentsMap,
    #type: _f$type,
    #description: _f$description,
    #deltaOnCanvas: _f$deltaOnCanvas,
    #isFromDelta: _f$isFromDelta,
  };

  static MoveLineCommand _instantiate(DecodingData data) {
    return MoveLineCommand(
        originalLine: data.dec(_f$originalLine),
        originalLineSegmentsMap: data.dec(_f$originalLineSegmentsMap),
        newLine: data.dec(_f$newLine),
        newLineSegmentsMap: data.dec(_f$newLineSegmentsMap),
        type: data.dec(_f$type),
        description: data.dec(_f$description),
        deltaOnCanvas: data.dec(_f$deltaOnCanvas),
        isFromDelta: data.dec(_f$isFromDelta));
  }

  @override
  final Function instantiate = _instantiate;

  static MoveLineCommand fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MoveLineCommand>(map);
  }

  static MoveLineCommand fromJson(String json) {
    return ensureInitialized().decodeJson<MoveLineCommand>(json);
  }
}

mixin MoveLineCommandMappable {
  String toJson() {
    return MoveLineCommandMapper.ensureInitialized()
        .encodeJson<MoveLineCommand>(this as MoveLineCommand);
  }

  Map<String, dynamic> toMap() {
    return MoveLineCommandMapper.ensureInitialized()
        .encodeMap<MoveLineCommand>(this as MoveLineCommand);
  }

  MoveLineCommandCopyWith<MoveLineCommand, MoveLineCommand, MoveLineCommand>
      get copyWith => _MoveLineCommandCopyWithImpl(
          this as MoveLineCommand, $identity, $identity);
  @override
  String toString() {
    return MoveLineCommandMapper.ensureInitialized()
        .stringifyValue(this as MoveLineCommand);
  }

  @override
  bool operator ==(Object other) {
    return MoveLineCommandMapper.ensureInitialized()
        .equalsValue(this as MoveLineCommand, other);
  }

  @override
  int get hashCode {
    return MoveLineCommandMapper.ensureInitialized()
        .hashValue(this as MoveLineCommand);
  }
}

extension MoveLineCommandValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MoveLineCommand, $Out> {
  MoveLineCommandCopyWith<$R, MoveLineCommand, $Out> get $asMoveLineCommand =>
      $base.as((v, t, t2) => _MoveLineCommandCopyWithImpl(v, t, t2));
}

abstract class MoveLineCommandCopyWith<$R, $In extends MoveLineCommand, $Out>
    implements CommandCopyWith<$R, $In, $Out> {
  THLineCopyWith<$R, THLine, THLine> get originalLine;
  THLineCopyWith<$R, THLine, THLine> get newLine;
  @override
  $R call(
      {THLine? originalLine,
      LinkedHashMap<int, THLineSegment>? originalLineSegmentsMap,
      THLine? newLine,
      LinkedHashMap<int, THLineSegment>? newLineSegmentsMap,
      CommandType? type,
      String? description,
      Offset? deltaOnCanvas,
      bool? isFromDelta});
  MoveLineCommandCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _MoveLineCommandCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MoveLineCommand, $Out>
    implements MoveLineCommandCopyWith<$R, MoveLineCommand, $Out> {
  _MoveLineCommandCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MoveLineCommand> $mapper =
      MoveLineCommandMapper.ensureInitialized();
  @override
  THLineCopyWith<$R, THLine, THLine> get originalLine =>
      $value.originalLine.copyWith.$chain((v) => call(originalLine: v));
  @override
  THLineCopyWith<$R, THLine, THLine> get newLine =>
      $value.newLine.copyWith.$chain((v) => call(newLine: v));
  @override
  $R call(
          {THLine? originalLine,
          LinkedHashMap<int, THLineSegment>? originalLineSegmentsMap,
          THLine? newLine,
          LinkedHashMap<int, THLineSegment>? newLineSegmentsMap,
          CommandType? type,
          String? description,
          Offset? deltaOnCanvas,
          bool? isFromDelta}) =>
      $apply(FieldCopyWithData({
        if (originalLine != null) #originalLine: originalLine,
        if (originalLineSegmentsMap != null)
          #originalLineSegmentsMap: originalLineSegmentsMap,
        if (newLine != null) #newLine: newLine,
        if (newLineSegmentsMap != null) #newLineSegmentsMap: newLineSegmentsMap,
        if (type != null) #type: type,
        if (description != null) #description: description,
        if (deltaOnCanvas != null) #deltaOnCanvas: deltaOnCanvas,
        if (isFromDelta != null) #isFromDelta: isFromDelta
      }));
  @override
  MoveLineCommand $make(CopyWithData data) => MoveLineCommand(
      originalLine: data.get(#originalLine, or: $value.originalLine),
      originalLineSegmentsMap: data.get(#originalLineSegmentsMap,
          or: $value.originalLineSegmentsMap),
      newLine: data.get(#newLine, or: $value.newLine),
      newLineSegmentsMap:
          data.get(#newLineSegmentsMap, or: $value.newLineSegmentsMap),
      type: data.get(#type, or: $value.type),
      description: data.get(#description, or: $value.description),
      deltaOnCanvas: data.get(#deltaOnCanvas, or: $value.deltaOnCanvas),
      isFromDelta: data.get(#isFromDelta, or: $value.isFromDelta));

  @override
  MoveLineCommandCopyWith<$R2, MoveLineCommand, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _MoveLineCommandCopyWithImpl($value, $cast, t);
}
