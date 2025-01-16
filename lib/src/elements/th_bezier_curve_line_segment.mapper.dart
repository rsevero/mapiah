// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_bezier_curve_line_segment.dart';

class THBezierCurveLineSegmentMapper
    extends ClassMapperBase<THBezierCurveLineSegment> {
  THBezierCurveLineSegmentMapper._();

  static THBezierCurveLineSegmentMapper? _instance;
  static THBezierCurveLineSegmentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THBezierCurveLineSegmentMapper._());
      THLineSegmentMapper.ensureInitialized();
      THPositionPartMapper.ensureInitialized();
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THBezierCurveLineSegment';

  static int _$mapiahID(THBezierCurveLineSegment v) => v.mapiahID;
  static const Field<THBezierCurveLineSegment, int> _f$mapiahID =
      Field('mapiahID', _$mapiahID);
  static int _$parentMapiahID(THBezierCurveLineSegment v) => v.parentMapiahID;
  static const Field<THBezierCurveLineSegment, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String? _$sameLineComment(THBezierCurveLineSegment v) =>
      v.sameLineComment;
  static const Field<THBezierCurveLineSegment, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment);
  static THPositionPart _$controlPoint1(THBezierCurveLineSegment v) =>
      v.controlPoint1;
  static const Field<THBezierCurveLineSegment, THPositionPart>
      _f$controlPoint1 = Field('controlPoint1', _$controlPoint1);
  static THPositionPart _$controlPoint2(THBezierCurveLineSegment v) =>
      v.controlPoint2;
  static const Field<THBezierCurveLineSegment, THPositionPart>
      _f$controlPoint2 = Field('controlPoint2', _$controlPoint2);
  static THPositionPart _$endPoint(THBezierCurveLineSegment v) => v.endPoint;
  static const Field<THBezierCurveLineSegment, THPositionPart> _f$endPoint =
      Field('endPoint', _$endPoint);
  static LinkedHashMap<String, THCommandOption> _$optionsMap(
          THBezierCurveLineSegment v) =>
      v.optionsMap;
  static const Field<THBezierCurveLineSegment,
          LinkedHashMap<String, THCommandOption>> _f$optionsMap =
      Field('optionsMap', _$optionsMap);

  @override
  final MappableFields<THBezierCurveLineSegment> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
    #controlPoint1: _f$controlPoint1,
    #controlPoint2: _f$controlPoint2,
    #endPoint: _f$endPoint,
    #optionsMap: _f$optionsMap,
  };

  static THBezierCurveLineSegment _instantiate(DecodingData data) {
    return THBezierCurveLineSegment.withExplicitParameters(
        data.dec(_f$mapiahID),
        data.dec(_f$parentMapiahID),
        data.dec(_f$sameLineComment),
        data.dec(_f$controlPoint1),
        data.dec(_f$controlPoint2),
        data.dec(_f$endPoint),
        data.dec(_f$optionsMap));
  }

  @override
  final Function instantiate = _instantiate;

  static THBezierCurveLineSegment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THBezierCurveLineSegment>(map);
  }

  static THBezierCurveLineSegment fromJson(String json) {
    return ensureInitialized().decodeJson<THBezierCurveLineSegment>(json);
  }
}

mixin THBezierCurveLineSegmentMappable {
  String toJson() {
    return THBezierCurveLineSegmentMapper.ensureInitialized()
        .encodeJson<THBezierCurveLineSegment>(this as THBezierCurveLineSegment);
  }

  Map<String, dynamic> toMap() {
    return THBezierCurveLineSegmentMapper.ensureInitialized()
        .encodeMap<THBezierCurveLineSegment>(this as THBezierCurveLineSegment);
  }

  THBezierCurveLineSegmentCopyWith<THBezierCurveLineSegment,
          THBezierCurveLineSegment, THBezierCurveLineSegment>
      get copyWith => _THBezierCurveLineSegmentCopyWithImpl(
          this as THBezierCurveLineSegment, $identity, $identity);
  @override
  String toString() {
    return THBezierCurveLineSegmentMapper.ensureInitialized()
        .stringifyValue(this as THBezierCurveLineSegment);
  }

  @override
  bool operator ==(Object other) {
    return THBezierCurveLineSegmentMapper.ensureInitialized()
        .equalsValue(this as THBezierCurveLineSegment, other);
  }

  @override
  int get hashCode {
    return THBezierCurveLineSegmentMapper.ensureInitialized()
        .hashValue(this as THBezierCurveLineSegment);
  }
}

extension THBezierCurveLineSegmentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THBezierCurveLineSegment, $Out> {
  THBezierCurveLineSegmentCopyWith<$R, THBezierCurveLineSegment, $Out>
      get $asTHBezierCurveLineSegment => $base
          .as((v, t, t2) => _THBezierCurveLineSegmentCopyWithImpl(v, t, t2));
}

abstract class THBezierCurveLineSegmentCopyWith<
    $R,
    $In extends THBezierCurveLineSegment,
    $Out> implements THLineSegmentCopyWith<$R, $In, $Out> {
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get controlPoint1;
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get controlPoint2;
  @override
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get endPoint;
  @override
  $R call(
      {int? mapiahID,
      int? parentMapiahID,
      String? sameLineComment,
      THPositionPart? controlPoint1,
      THPositionPart? controlPoint2,
      THPositionPart? endPoint,
      LinkedHashMap<String, THCommandOption>? optionsMap});
  THBezierCurveLineSegmentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THBezierCurveLineSegmentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THBezierCurveLineSegment, $Out>
    implements
        THBezierCurveLineSegmentCopyWith<$R, THBezierCurveLineSegment, $Out> {
  _THBezierCurveLineSegmentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THBezierCurveLineSegment> $mapper =
      THBezierCurveLineSegmentMapper.ensureInitialized();
  @override
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart>
      get controlPoint1 =>
          $value.controlPoint1.copyWith.$chain((v) => call(controlPoint1: v));
  @override
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart>
      get controlPoint2 =>
          $value.controlPoint2.copyWith.$chain((v) => call(controlPoint2: v));
  @override
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get endPoint =>
      $value.endPoint.copyWith.$chain((v) => call(endPoint: v));
  @override
  $R call(
          {int? mapiahID,
          int? parentMapiahID,
          Object? sameLineComment = $none,
          THPositionPart? controlPoint1,
          THPositionPart? controlPoint2,
          THPositionPart? endPoint,
          LinkedHashMap<String, THCommandOption>? optionsMap}) =>
      $apply(FieldCopyWithData({
        if (mapiahID != null) #mapiahID: mapiahID,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (sameLineComment != $none) #sameLineComment: sameLineComment,
        if (controlPoint1 != null) #controlPoint1: controlPoint1,
        if (controlPoint2 != null) #controlPoint2: controlPoint2,
        if (endPoint != null) #endPoint: endPoint,
        if (optionsMap != null) #optionsMap: optionsMap
      }));
  @override
  THBezierCurveLineSegment $make(CopyWithData data) =>
      THBezierCurveLineSegment.withExplicitParameters(
          data.get(#mapiahID, or: $value.mapiahID),
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#sameLineComment, or: $value.sameLineComment),
          data.get(#controlPoint1, or: $value.controlPoint1),
          data.get(#controlPoint2, or: $value.controlPoint2),
          data.get(#endPoint, or: $value.endPoint),
          data.get(#optionsMap, or: $value.optionsMap));

  @override
  THBezierCurveLineSegmentCopyWith<$R2, THBezierCurveLineSegment, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THBezierCurveLineSegmentCopyWithImpl($value, $cast, t);
}
