// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_point_position_part.dart';

class THPointPositionPartMapper extends ClassMapperBase<THPointPositionPart> {
  THPointPositionPartMapper._();

  static THPointPositionPartMapper? _instance;
  static THPointPositionPartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THPointPositionPartMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THPointPositionPart';

  static double _$x(THPointPositionPart v) => v.x;
  static const Field<THPointPositionPart, double> _f$x = Field('x', _$x);
  static double _$y(THPointPositionPart v) => v.y;
  static const Field<THPointPositionPart, double> _f$y = Field('y', _$y);
  static int _$xDecimalPositions(THPointPositionPart v) => v.xDecimalPositions;
  static const Field<THPointPositionPart, int> _f$xDecimalPositions =
      Field('xDecimalPositions', _$xDecimalPositions);
  static int _$yDecimalPositions(THPointPositionPart v) => v.yDecimalPositions;
  static const Field<THPointPositionPart, int> _f$yDecimalPositions =
      Field('yDecimalPositions', _$yDecimalPositions);
  static THDoublePart _$xDoublePart(THPointPositionPart v) => v.xDoublePart;
  static const Field<THPointPositionPart, THDoublePart> _f$xDoublePart =
      Field('xDoublePart', _$xDoublePart, mode: FieldMode.member);
  static THDoublePart _$yDoublePart(THPointPositionPart v) => v.yDoublePart;
  static const Field<THPointPositionPart, THDoublePart> _f$yDoublePart =
      Field('yDoublePart', _$yDoublePart, mode: FieldMode.member);

  @override
  final MappableFields<THPointPositionPart> fields = const {
    #x: _f$x,
    #y: _f$y,
    #xDecimalPositions: _f$xDecimalPositions,
    #yDecimalPositions: _f$yDecimalPositions,
    #xDoublePart: _f$xDoublePart,
    #yDoublePart: _f$yDoublePart,
  };

  static THPointPositionPart _instantiate(DecodingData data) {
    return THPointPositionPart(data.dec(_f$x), data.dec(_f$y),
        data.dec(_f$xDecimalPositions), data.dec(_f$yDecimalPositions));
  }

  @override
  final Function instantiate = _instantiate;

  static THPointPositionPart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THPointPositionPart>(map);
  }

  static THPointPositionPart fromJson(String json) {
    return ensureInitialized().decodeJson<THPointPositionPart>(json);
  }
}

mixin THPointPositionPartMappable {
  String toJson() {
    return THPointPositionPartMapper.ensureInitialized()
        .encodeJson<THPointPositionPart>(this as THPointPositionPart);
  }

  Map<String, dynamic> toMap() {
    return THPointPositionPartMapper.ensureInitialized()
        .encodeMap<THPointPositionPart>(this as THPointPositionPart);
  }

  THPointPositionPartCopyWith<THPointPositionPart, THPointPositionPart,
          THPointPositionPart>
      get copyWith => _THPointPositionPartCopyWithImpl(
          this as THPointPositionPart, $identity, $identity);
  @override
  String toString() {
    return THPointPositionPartMapper.ensureInitialized()
        .stringifyValue(this as THPointPositionPart);
  }

  @override
  bool operator ==(Object other) {
    return THPointPositionPartMapper.ensureInitialized()
        .equalsValue(this as THPointPositionPart, other);
  }

  @override
  int get hashCode {
    return THPointPositionPartMapper.ensureInitialized()
        .hashValue(this as THPointPositionPart);
  }
}

extension THPointPositionPartValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THPointPositionPart, $Out> {
  THPointPositionPartCopyWith<$R, THPointPositionPart, $Out>
      get $asTHPointPositionPart =>
          $base.as((v, t, t2) => _THPointPositionPartCopyWithImpl(v, t, t2));
}

abstract class THPointPositionPartCopyWith<$R, $In extends THPointPositionPart,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {double? x, double? y, int? xDecimalPositions, int? yDecimalPositions});
  THPointPositionPartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THPointPositionPartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THPointPositionPart, $Out>
    implements THPointPositionPartCopyWith<$R, THPointPositionPart, $Out> {
  _THPointPositionPartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THPointPositionPart> $mapper =
      THPointPositionPartMapper.ensureInitialized();
  @override
  $R call(
          {double? x,
          double? y,
          int? xDecimalPositions,
          int? yDecimalPositions}) =>
      $apply(FieldCopyWithData({
        if (x != null) #x: x,
        if (y != null) #y: y,
        if (xDecimalPositions != null) #xDecimalPositions: xDecimalPositions,
        if (yDecimalPositions != null) #yDecimalPositions: yDecimalPositions
      }));
  @override
  THPointPositionPart $make(CopyWithData data) => THPointPositionPart(
      data.get(#x, or: $value.x),
      data.get(#y, or: $value.y),
      data.get(#xDecimalPositions, or: $value.xDecimalPositions),
      data.get(#yDecimalPositions, or: $value.yDecimalPositions));

  @override
  THPointPositionPartCopyWith<$R2, THPointPositionPart, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THPointPositionPartCopyWithImpl($value, $cast, t);
}
