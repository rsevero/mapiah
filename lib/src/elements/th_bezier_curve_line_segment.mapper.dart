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
      THElementMapper.ensureInitialized();
      THPositionPartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THBezierCurveLineSegment';

  static THParent _$parent(THBezierCurveLineSegment v) => v.parent;
  static const Field<THBezierCurveLineSegment, THParent> _f$parent =
      Field('parent', _$parent);
  static THPositionPart _$controlPoint1(THBezierCurveLineSegment v) =>
      v.controlPoint1;
  static const Field<THBezierCurveLineSegment, THPositionPart>
      _f$controlPoint1 = Field('controlPoint1', _$controlPoint1);
  static THPositionPart _$controlPoint2(THBezierCurveLineSegment v) =>
      v.controlPoint2;
  static const Field<THBezierCurveLineSegment, THPositionPart>
      _f$controlPoint2 = Field('controlPoint2', _$controlPoint2);
  static THPositionPart _$endPointPosition(THBezierCurveLineSegment v) =>
      v.endPointPosition;
  static const Field<THBezierCurveLineSegment, THPositionPart>
      _f$endPointPosition = Field('endPointPosition', _$endPointPosition);
  static int _$parentMapiahID(THBezierCurveLineSegment v) => v.parentMapiahID;
  static const Field<THBezierCurveLineSegment, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, mode: FieldMode.member);
  static String? _$sameLineComment(THBezierCurveLineSegment v) =>
      v.sameLineComment;
  static const Field<THBezierCurveLineSegment, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THBezierCurveLineSegment> fields = const {
    #parent: _f$parent,
    #controlPoint1: _f$controlPoint1,
    #controlPoint2: _f$controlPoint2,
    #endPointPosition: _f$endPointPosition,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THBezierCurveLineSegment _instantiate(DecodingData data) {
    return THBezierCurveLineSegment(
        data.dec(_f$parent),
        data.dec(_f$controlPoint1),
        data.dec(_f$controlPoint2),
        data.dec(_f$endPointPosition));
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
    $Out> implements THElementCopyWith<$R, $In, $Out> {
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get controlPoint1;
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get controlPoint2;
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart>
      get endPointPosition;
  @override
  $R call(
      {THParent? parent,
      THPositionPart? controlPoint1,
      THPositionPart? controlPoint2,
      THPositionPart? endPointPosition});
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
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart>
      get endPointPosition => $value.endPointPosition.copyWith
          .$chain((v) => call(endPointPosition: v));
  @override
  $R call(
          {THParent? parent,
          THPositionPart? controlPoint1,
          THPositionPart? controlPoint2,
          THPositionPart? endPointPosition}) =>
      $apply(FieldCopyWithData({
        if (parent != null) #parent: parent,
        if (controlPoint1 != null) #controlPoint1: controlPoint1,
        if (controlPoint2 != null) #controlPoint2: controlPoint2,
        if (endPointPosition != null) #endPointPosition: endPointPosition
      }));
  @override
  THBezierCurveLineSegment $make(CopyWithData data) => THBezierCurveLineSegment(
      data.get(#parent, or: $value.parent),
      data.get(#controlPoint1, or: $value.controlPoint1),
      data.get(#controlPoint2, or: $value.controlPoint2),
      data.get(#endPointPosition, or: $value.endPointPosition));

  @override
  THBezierCurveLineSegmentCopyWith<$R2, THBezierCurveLineSegment, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THBezierCurveLineSegmentCopyWithImpl($value, $cast, t);
}
