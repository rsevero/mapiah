// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_length_unit_part.dart';

class THLengthUnitMapper extends EnumMapper<THLengthUnit> {
  THLengthUnitMapper._();

  static THLengthUnitMapper? _instance;
  static THLengthUnitMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THLengthUnitMapper._());
    }
    return _instance!;
  }

  static THLengthUnit fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  THLengthUnit decode(dynamic value) {
    switch (value) {
      case 'centimeter':
        return THLengthUnit.centimeter;
      case 'feet':
        return THLengthUnit.feet;
      case 'inch':
        return THLengthUnit.inch;
      case 'meter':
        return THLengthUnit.meter;
      case 'yard':
        return THLengthUnit.yard;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(THLengthUnit self) {
    switch (self) {
      case THLengthUnit.centimeter:
        return 'centimeter';
      case THLengthUnit.feet:
        return 'feet';
      case THLengthUnit.inch:
        return 'inch';
      case THLengthUnit.meter:
        return 'meter';
      case THLengthUnit.yard:
        return 'yard';
    }
  }
}

extension THLengthUnitMapperExtension on THLengthUnit {
  String toValue() {
    THLengthUnitMapper.ensureInitialized();
    return MapperContainer.globals.toValue<THLengthUnit>(this) as String;
  }
}

class THLengthUnitPartMapper extends ClassMapperBase<THLengthUnitPart> {
  THLengthUnitPartMapper._();

  static THLengthUnitPartMapper? _instance;
  static THLengthUnitPartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THLengthUnitPartMapper._());
      THLengthUnitMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THLengthUnitPart';

  static THLengthUnit _$unit(THLengthUnitPart v) => v.unit;
  static const Field<THLengthUnitPart, THLengthUnit> _f$unit =
      Field('unit', _$unit);

  @override
  final MappableFields<THLengthUnitPart> fields = const {
    #unit: _f$unit,
  };

  static THLengthUnitPart _instantiate(DecodingData data) {
    return THLengthUnitPart(data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static THLengthUnitPart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THLengthUnitPart>(map);
  }

  static THLengthUnitPart fromJson(String json) {
    return ensureInitialized().decodeJson<THLengthUnitPart>(json);
  }
}

mixin THLengthUnitPartMappable {
  String toJson() {
    return THLengthUnitPartMapper.ensureInitialized()
        .encodeJson<THLengthUnitPart>(this as THLengthUnitPart);
  }

  Map<String, dynamic> toMap() {
    return THLengthUnitPartMapper.ensureInitialized()
        .encodeMap<THLengthUnitPart>(this as THLengthUnitPart);
  }

  THLengthUnitPartCopyWith<THLengthUnitPart, THLengthUnitPart, THLengthUnitPart>
      get copyWith => _THLengthUnitPartCopyWithImpl(
          this as THLengthUnitPart, $identity, $identity);
  @override
  String toString() {
    return THLengthUnitPartMapper.ensureInitialized()
        .stringifyValue(this as THLengthUnitPart);
  }

  @override
  bool operator ==(Object other) {
    return THLengthUnitPartMapper.ensureInitialized()
        .equalsValue(this as THLengthUnitPart, other);
  }

  @override
  int get hashCode {
    return THLengthUnitPartMapper.ensureInitialized()
        .hashValue(this as THLengthUnitPart);
  }
}

extension THLengthUnitPartValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THLengthUnitPart, $Out> {
  THLengthUnitPartCopyWith<$R, THLengthUnitPart, $Out>
      get $asTHLengthUnitPart =>
          $base.as((v, t, t2) => _THLengthUnitPartCopyWithImpl(v, t, t2));
}

abstract class THLengthUnitPartCopyWith<$R, $In extends THLengthUnitPart, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({THLengthUnit? unit});
  THLengthUnitPartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THLengthUnitPartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THLengthUnitPart, $Out>
    implements THLengthUnitPartCopyWith<$R, THLengthUnitPart, $Out> {
  _THLengthUnitPartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THLengthUnitPart> $mapper =
      THLengthUnitPartMapper.ensureInitialized();
  @override
  $R call({THLengthUnit? unit}) =>
      $apply(FieldCopyWithData({if (unit != null) #unit: unit}));
  @override
  THLengthUnitPart $make(CopyWithData data) =>
      THLengthUnitPart(data.get(#unit, or: $value.unit));

  @override
  THLengthUnitPartCopyWith<$R2, THLengthUnitPart, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THLengthUnitPartCopyWithImpl($value, $cast, t);
}
