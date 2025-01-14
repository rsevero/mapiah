// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_straight_line_segment.dart';

class THStraightLineSegmentMapper
    extends ClassMapperBase<THStraightLineSegment> {
  THStraightLineSegmentMapper._();

  static THStraightLineSegmentMapper? _instance;
  static THStraightLineSegmentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THStraightLineSegmentMapper._());
      THElementMapper.ensureInitialized();
      THPositionPartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THStraightLineSegment';

  static THParent _$parent(THStraightLineSegment v) => v.parent;
  static const Field<THStraightLineSegment, THParent> _f$parent =
      Field('parent', _$parent);
  static THPositionPart _$endPointPosition(THStraightLineSegment v) =>
      v.endPointPosition;
  static const Field<THStraightLineSegment, THPositionPart>
      _f$endPointPosition = Field('endPointPosition', _$endPointPosition);
  static int _$parentMapiahID(THStraightLineSegment v) => v.parentMapiahID;
  static const Field<THStraightLineSegment, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, mode: FieldMode.member);
  static String? _$sameLineComment(THStraightLineSegment v) =>
      v.sameLineComment;
  static const Field<THStraightLineSegment, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THStraightLineSegment> fields = const {
    #parent: _f$parent,
    #endPointPosition: _f$endPointPosition,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THStraightLineSegment _instantiate(DecodingData data) {
    return THStraightLineSegment(
        data.dec(_f$parent), data.dec(_f$endPointPosition));
  }

  @override
  final Function instantiate = _instantiate;

  static THStraightLineSegment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THStraightLineSegment>(map);
  }

  static THStraightLineSegment fromJson(String json) {
    return ensureInitialized().decodeJson<THStraightLineSegment>(json);
  }
}

mixin THStraightLineSegmentMappable {
  String toJson() {
    return THStraightLineSegmentMapper.ensureInitialized()
        .encodeJson<THStraightLineSegment>(this as THStraightLineSegment);
  }

  Map<String, dynamic> toMap() {
    return THStraightLineSegmentMapper.ensureInitialized()
        .encodeMap<THStraightLineSegment>(this as THStraightLineSegment);
  }

  THStraightLineSegmentCopyWith<THStraightLineSegment, THStraightLineSegment,
          THStraightLineSegment>
      get copyWith => _THStraightLineSegmentCopyWithImpl(
          this as THStraightLineSegment, $identity, $identity);
  @override
  String toString() {
    return THStraightLineSegmentMapper.ensureInitialized()
        .stringifyValue(this as THStraightLineSegment);
  }

  @override
  bool operator ==(Object other) {
    return THStraightLineSegmentMapper.ensureInitialized()
        .equalsValue(this as THStraightLineSegment, other);
  }

  @override
  int get hashCode {
    return THStraightLineSegmentMapper.ensureInitialized()
        .hashValue(this as THStraightLineSegment);
  }
}

extension THStraightLineSegmentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THStraightLineSegment, $Out> {
  THStraightLineSegmentCopyWith<$R, THStraightLineSegment, $Out>
      get $asTHStraightLineSegment =>
          $base.as((v, t, t2) => _THStraightLineSegmentCopyWithImpl(v, t, t2));
}

abstract class THStraightLineSegmentCopyWith<
    $R,
    $In extends THStraightLineSegment,
    $Out> implements THElementCopyWith<$R, $In, $Out> {
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart>
      get endPointPosition;
  @override
  $R call({THParent? parent, THPositionPart? endPointPosition});
  THStraightLineSegmentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THStraightLineSegmentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THStraightLineSegment, $Out>
    implements THStraightLineSegmentCopyWith<$R, THStraightLineSegment, $Out> {
  _THStraightLineSegmentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THStraightLineSegment> $mapper =
      THStraightLineSegmentMapper.ensureInitialized();
  @override
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart>
      get endPointPosition => $value.endPointPosition.copyWith
          .$chain((v) => call(endPointPosition: v));
  @override
  $R call({THParent? parent, THPositionPart? endPointPosition}) =>
      $apply(FieldCopyWithData({
        if (parent != null) #parent: parent,
        if (endPointPosition != null) #endPointPosition: endPointPosition
      }));
  @override
  THStraightLineSegment $make(CopyWithData data) => THStraightLineSegment(
      data.get(#parent, or: $value.parent),
      data.get(#endPointPosition, or: $value.endPointPosition));

  @override
  THStraightLineSegmentCopyWith<$R2, THStraightLineSegment, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THStraightLineSegmentCopyWithImpl($value, $cast, t);
}
