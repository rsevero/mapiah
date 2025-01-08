// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_point.dart';

class THPointMapper extends ClassMapperBase<THPoint> {
  THPointMapper._();

  static THPointMapper? _instance;
  static THPointMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THPointMapper._());
      THElementMapper.ensureInitialized();
      THPointPositionPartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THPoint';

  static THParent _$parent(THPoint v) => v.parent;
  static const Field<THPoint, THParent> _f$parent = Field('parent', _$parent);
  static THPointPositionPart _$point(THPoint v) => v.point;
  static const Field<THPoint, THPointPositionPart> _f$point =
      Field('point', _$point);
  static String _$pointType(THPoint v) => v.pointType;
  static const Field<THPoint, String> _f$pointType =
      Field('pointType', _$pointType);
  static int _$parentMapiahID(THPoint v) => v.parentMapiahID;
  static const Field<THPoint, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, mode: FieldMode.member);
  static String? _$sameLineComment(THPoint v) => v.sameLineComment;
  static const Field<THPoint, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THPoint> fields = const {
    #parent: _f$parent,
    #point: _f$point,
    #pointType: _f$pointType,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THPoint _instantiate(DecodingData data) {
    return THPoint(
        data.dec(_f$parent), data.dec(_f$point), data.dec(_f$pointType));
  }

  @override
  final Function instantiate = _instantiate;

  static THPoint fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THPoint>(map);
  }

  static THPoint fromJson(String json) {
    return ensureInitialized().decodeJson<THPoint>(json);
  }
}

mixin THPointMappable {
  String toJson() {
    return THPointMapper.ensureInitialized()
        .encodeJson<THPoint>(this as THPoint);
  }

  Map<String, dynamic> toMap() {
    return THPointMapper.ensureInitialized()
        .encodeMap<THPoint>(this as THPoint);
  }

  THPointCopyWith<THPoint, THPoint, THPoint> get copyWith =>
      _THPointCopyWithImpl(this as THPoint, $identity, $identity);
  @override
  String toString() {
    return THPointMapper.ensureInitialized().stringifyValue(this as THPoint);
  }

  @override
  bool operator ==(Object other) {
    return THPointMapper.ensureInitialized()
        .equalsValue(this as THPoint, other);
  }

  @override
  int get hashCode {
    return THPointMapper.ensureInitialized().hashValue(this as THPoint);
  }
}

extension THPointValueCopy<$R, $Out> on ObjectCopyWith<$R, THPoint, $Out> {
  THPointCopyWith<$R, THPoint, $Out> get $asTHPoint =>
      $base.as((v, t, t2) => _THPointCopyWithImpl(v, t, t2));
}

abstract class THPointCopyWith<$R, $In extends THPoint, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  THPointPositionPartCopyWith<$R, THPointPositionPart, THPointPositionPart>
      get point;
  @override
  $R call({THParent? parent, THPointPositionPart? point, String? pointType});
  THPointCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THPointCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THPoint, $Out>
    implements THPointCopyWith<$R, THPoint, $Out> {
  _THPointCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THPoint> $mapper =
      THPointMapper.ensureInitialized();
  @override
  THPointPositionPartCopyWith<$R, THPointPositionPart, THPointPositionPart>
      get point => $value.point.copyWith.$chain((v) => call(point: v));
  @override
  $R call({THParent? parent, THPointPositionPart? point, String? pointType}) =>
      $apply(FieldCopyWithData({
        if (parent != null) #parent: parent,
        if (point != null) #point: point,
        if (pointType != null) #pointType: pointType
      }));
  @override
  THPoint $make(CopyWithData data) => THPoint(
      data.get(#parent, or: $value.parent),
      data.get(#point, or: $value.point),
      data.get(#pointType, or: $value.pointType));

  @override
  THPointCopyWith<$R2, THPoint, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _THPointCopyWithImpl($value, $cast, t);
}
