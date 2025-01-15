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
      THLineSegmentMapper.ensureInitialized();
      THPositionPartMapper.ensureInitialized();
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THStraightLineSegment';

  static int _$mapiahID(THStraightLineSegment v) => v.mapiahID;
  static const Field<THStraightLineSegment, int> _f$mapiahID =
      Field('mapiahID', _$mapiahID);
  static THParent _$parent(THStraightLineSegment v) => v.parent;
  static const Field<THStraightLineSegment, THParent> _f$parent =
      Field('parent', _$parent);
  static String? _$sameLineComment(THStraightLineSegment v) =>
      v.sameLineComment;
  static const Field<THStraightLineSegment, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment);
  static THPositionPart _$endPoint(THStraightLineSegment v) => v.endPoint;
  static const Field<THStraightLineSegment, THPositionPart> _f$endPoint =
      Field('endPoint', _$endPoint);
  static LinkedHashMap<String, THCommandOption> _$optionsMap(
          THStraightLineSegment v) =>
      v.optionsMap;
  static const Field<THStraightLineSegment,
          LinkedHashMap<String, THCommandOption>> _f$optionsMap =
      Field('optionsMap', _$optionsMap);
  static int _$parentMapiahID(THStraightLineSegment v) => v.parentMapiahID;
  static const Field<THStraightLineSegment, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, mode: FieldMode.member);

  @override
  final MappableFields<THStraightLineSegment> fields = const {
    #mapiahID: _f$mapiahID,
    #parent: _f$parent,
    #sameLineComment: _f$sameLineComment,
    #endPoint: _f$endPoint,
    #optionsMap: _f$optionsMap,
    #parentMapiahID: _f$parentMapiahID,
  };

  static THStraightLineSegment _instantiate(DecodingData data) {
    return THStraightLineSegment.withExplicitParameters(
        data.dec(_f$mapiahID),
        data.dec(_f$parent),
        data.dec(_f$sameLineComment),
        data.dec(_f$endPoint),
        data.dec(_f$optionsMap));
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
    $Out> implements THLineSegmentCopyWith<$R, $In, $Out> {
  @override
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get endPoint;
  @override
  $R call(
      {int? mapiahID,
      THParent? parent,
      String? sameLineComment,
      THPositionPart? endPoint,
      LinkedHashMap<String, THCommandOption>? optionsMap});
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
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get endPoint =>
      $value.endPoint.copyWith.$chain((v) => call(endPoint: v));
  @override
  $R call(
          {int? mapiahID,
          THParent? parent,
          Object? sameLineComment = $none,
          THPositionPart? endPoint,
          LinkedHashMap<String, THCommandOption>? optionsMap}) =>
      $apply(FieldCopyWithData({
        if (mapiahID != null) #mapiahID: mapiahID,
        if (parent != null) #parent: parent,
        if (sameLineComment != $none) #sameLineComment: sameLineComment,
        if (endPoint != null) #endPoint: endPoint,
        if (optionsMap != null) #optionsMap: optionsMap
      }));
  @override
  THStraightLineSegment $make(CopyWithData data) =>
      THStraightLineSegment.withExplicitParameters(
          data.get(#mapiahID, or: $value.mapiahID),
          data.get(#parent, or: $value.parent),
          data.get(#sameLineComment, or: $value.sameLineComment),
          data.get(#endPoint, or: $value.endPoint),
          data.get(#optionsMap, or: $value.optionsMap));

  @override
  THStraightLineSegmentCopyWith<$R2, THStraightLineSegment, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THStraightLineSegmentCopyWithImpl($value, $cast, t);
}
