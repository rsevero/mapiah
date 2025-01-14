// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_position_part.dart';

class THPositionPartMapper extends ClassMapperBase<THPositionPart> {
  THPositionPartMapper._();

  static THPositionPartMapper? _instance;
  static THPositionPartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THPositionPartMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THPositionPart';

  static Offset _$coordinates(THPositionPart v) => v.coordinates;
  static const Field<THPositionPart, Offset> _f$coordinates =
      Field('coordinates', _$coordinates);
  static int _$decimalPositions(THPositionPart v) => v.decimalPositions;
  static const Field<THPositionPart, int> _f$decimalPositions =
      Field('decimalPositions', _$decimalPositions);

  @override
  final MappableFields<THPositionPart> fields = const {
    #coordinates: _f$coordinates,
    #decimalPositions: _f$decimalPositions,
  };

  static THPositionPart _instantiate(DecodingData data) {
    return THPositionPart(
        data.dec(_f$coordinates), data.dec(_f$decimalPositions));
  }

  @override
  final Function instantiate = _instantiate;

  static THPositionPart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THPositionPart>(map);
  }

  static THPositionPart fromJson(String json) {
    return ensureInitialized().decodeJson<THPositionPart>(json);
  }
}

mixin THPositionPartMappable {
  String toJson() {
    return THPositionPartMapper.ensureInitialized()
        .encodeJson<THPositionPart>(this as THPositionPart);
  }

  Map<String, dynamic> toMap() {
    return THPositionPartMapper.ensureInitialized()
        .encodeMap<THPositionPart>(this as THPositionPart);
  }

  THPositionPartCopyWith<THPositionPart, THPositionPart, THPositionPart>
      get copyWith => _THPositionPartCopyWithImpl(
          this as THPositionPart, $identity, $identity);
  @override
  String toString() {
    return THPositionPartMapper.ensureInitialized()
        .stringifyValue(this as THPositionPart);
  }

  @override
  bool operator ==(Object other) {
    return THPositionPartMapper.ensureInitialized()
        .equalsValue(this as THPositionPart, other);
  }

  @override
  int get hashCode {
    return THPositionPartMapper.ensureInitialized()
        .hashValue(this as THPositionPart);
  }
}

extension THPositionPartValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THPositionPart, $Out> {
  THPositionPartCopyWith<$R, THPositionPart, $Out> get $asTHPositionPart =>
      $base.as((v, t, t2) => _THPositionPartCopyWithImpl(v, t, t2));
}

abstract class THPositionPartCopyWith<$R, $In extends THPositionPart, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({Offset? coordinates, int? decimalPositions});
  THPositionPartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THPositionPartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THPositionPart, $Out>
    implements THPositionPartCopyWith<$R, THPositionPart, $Out> {
  _THPositionPartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THPositionPart> $mapper =
      THPositionPartMapper.ensureInitialized();
  @override
  $R call({Offset? coordinates, int? decimalPositions}) =>
      $apply(FieldCopyWithData({
        if (coordinates != null) #coordinates: coordinates,
        if (decimalPositions != null) #decimalPositions: decimalPositions
      }));
  @override
  THPositionPart $make(CopyWithData data) => THPositionPart(
      data.get(#coordinates, or: $value.coordinates),
      data.get(#decimalPositions, or: $value.decimalPositions));

  @override
  THPositionPartCopyWith<$R2, THPositionPart, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THPositionPartCopyWithImpl($value, $cast, t);
}
