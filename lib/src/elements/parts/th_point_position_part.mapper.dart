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

  static Offset _$position(THPointPositionPart v) => v.position;
  static const Field<THPointPositionPart, Offset> _f$position =
      Field('position', _$position);
  static int _$decimalPositions(THPointPositionPart v) => v.decimalPositions;
  static const Field<THPointPositionPart, int> _f$decimalPositions =
      Field('decimalPositions', _$decimalPositions);

  @override
  final MappableFields<THPointPositionPart> fields = const {
    #position: _f$position,
    #decimalPositions: _f$decimalPositions,
  };

  static THPointPositionPart _instantiate(DecodingData data) {
    return THPointPositionPart(
        data.dec(_f$position), data.dec(_f$decimalPositions));
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
  $R call({Offset? position, int? decimalPositions});
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
  $R call({Offset? position, int? decimalPositions}) =>
      $apply(FieldCopyWithData({
        if (position != null) #position: position,
        if (decimalPositions != null) #decimalPositions: decimalPositions
      }));
  @override
  THPointPositionPart $make(CopyWithData data) => THPointPositionPart(
      data.get(#position, or: $value.position),
      data.get(#decimalPositions, or: $value.decimalPositions));

  @override
  THPointPositionPartCopyWith<$R2, THPointPositionPart, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THPointPositionPartCopyWithImpl($value, $cast, t);
}
