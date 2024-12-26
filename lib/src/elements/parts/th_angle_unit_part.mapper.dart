// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_angle_unit_part.dart';

class THAngleUnitMapper extends EnumMapper<THAngleUnit> {
  THAngleUnitMapper._();

  static THAngleUnitMapper? _instance;
  static THAngleUnitMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THAngleUnitMapper._());
    }
    return _instance!;
  }

  static THAngleUnit fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  THAngleUnit decode(dynamic value) {
    switch (value) {
      case 'degree':
        return THAngleUnit.degree;
      case 'grad':
        return THAngleUnit.grad;
      case 'mil':
        return THAngleUnit.mil;
      case 'minute':
        return THAngleUnit.minute;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(THAngleUnit self) {
    switch (self) {
      case THAngleUnit.degree:
        return 'degree';
      case THAngleUnit.grad:
        return 'grad';
      case THAngleUnit.mil:
        return 'mil';
      case THAngleUnit.minute:
        return 'minute';
    }
  }
}

extension THAngleUnitMapperExtension on THAngleUnit {
  String toValue() {
    THAngleUnitMapper.ensureInitialized();
    return MapperContainer.globals.toValue<THAngleUnit>(this) as String;
  }
}

class THAngleUnitPartMapper extends ClassMapperBase<THAngleUnitPart> {
  THAngleUnitPartMapper._();

  static THAngleUnitPartMapper? _instance;
  static THAngleUnitPartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THAngleUnitPartMapper._());
      THAngleUnitMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THAngleUnitPart';

  static THAngleUnit _$unit(THAngleUnitPart v) => v.unit;
  static const Field<THAngleUnitPart, THAngleUnit> _f$unit =
      Field('unit', _$unit);

  @override
  final MappableFields<THAngleUnitPart> fields = const {
    #unit: _f$unit,
  };

  static THAngleUnitPart _instantiate(DecodingData data) {
    return THAngleUnitPart(data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static THAngleUnitPart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THAngleUnitPart>(map);
  }

  static THAngleUnitPart fromJson(String json) {
    return ensureInitialized().decodeJson<THAngleUnitPart>(json);
  }
}

mixin THAngleUnitPartMappable {
  String toJson() {
    return THAngleUnitPartMapper.ensureInitialized()
        .encodeJson<THAngleUnitPart>(this as THAngleUnitPart);
  }

  Map<String, dynamic> toMap() {
    return THAngleUnitPartMapper.ensureInitialized()
        .encodeMap<THAngleUnitPart>(this as THAngleUnitPart);
  }

  THAngleUnitPartCopyWith<THAngleUnitPart, THAngleUnitPart, THAngleUnitPart>
      get copyWith => _THAngleUnitPartCopyWithImpl(
          this as THAngleUnitPart, $identity, $identity);
  @override
  String toString() {
    return THAngleUnitPartMapper.ensureInitialized()
        .stringifyValue(this as THAngleUnitPart);
  }

  @override
  bool operator ==(Object other) {
    return THAngleUnitPartMapper.ensureInitialized()
        .equalsValue(this as THAngleUnitPart, other);
  }

  @override
  int get hashCode {
    return THAngleUnitPartMapper.ensureInitialized()
        .hashValue(this as THAngleUnitPart);
  }
}

extension THAngleUnitPartValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THAngleUnitPart, $Out> {
  THAngleUnitPartCopyWith<$R, THAngleUnitPart, $Out> get $asTHAngleUnitPart =>
      $base.as((v, t, t2) => _THAngleUnitPartCopyWithImpl(v, t, t2));
}

abstract class THAngleUnitPartCopyWith<$R, $In extends THAngleUnitPart, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({THAngleUnit? unit});
  THAngleUnitPartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THAngleUnitPartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THAngleUnitPart, $Out>
    implements THAngleUnitPartCopyWith<$R, THAngleUnitPart, $Out> {
  _THAngleUnitPartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THAngleUnitPart> $mapper =
      THAngleUnitPartMapper.ensureInitialized();
  @override
  $R call({THAngleUnit? unit}) =>
      $apply(FieldCopyWithData({if (unit != null) #unit: unit}));
  @override
  THAngleUnitPart $make(CopyWithData data) =>
      THAngleUnitPart(data.get(#unit, or: $value.unit));

  @override
  THAngleUnitPartCopyWith<$R2, THAngleUnitPart, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THAngleUnitPartCopyWithImpl($value, $cast, t);
}
