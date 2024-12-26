// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_clino_unit_part.dart';

class THClinoUnitMapper extends EnumMapper<THClinoUnit> {
  THClinoUnitMapper._();

  static THClinoUnitMapper? _instance;
  static THClinoUnitMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THClinoUnitMapper._());
    }
    return _instance!;
  }

  static THClinoUnit fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  THClinoUnit decode(dynamic value) {
    switch (value) {
      case 'degree':
        return THClinoUnit.degree;
      case 'grad':
        return THClinoUnit.grad;
      case 'mil':
        return THClinoUnit.mil;
      case 'minute':
        return THClinoUnit.minute;
      case 'percent':
        return THClinoUnit.percent;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(THClinoUnit self) {
    switch (self) {
      case THClinoUnit.degree:
        return 'degree';
      case THClinoUnit.grad:
        return 'grad';
      case THClinoUnit.mil:
        return 'mil';
      case THClinoUnit.minute:
        return 'minute';
      case THClinoUnit.percent:
        return 'percent';
    }
  }
}

extension THClinoUnitMapperExtension on THClinoUnit {
  String toValue() {
    THClinoUnitMapper.ensureInitialized();
    return MapperContainer.globals.toValue<THClinoUnit>(this) as String;
  }
}

class THClinoUnitPartMapper extends ClassMapperBase<THClinoUnitPart> {
  THClinoUnitPartMapper._();

  static THClinoUnitPartMapper? _instance;
  static THClinoUnitPartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THClinoUnitPartMapper._());
      THClinoUnitMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THClinoUnitPart';

  static THClinoUnit _$unit(THClinoUnitPart v) => v.unit;
  static const Field<THClinoUnitPart, THClinoUnit> _f$unit =
      Field('unit', _$unit);

  @override
  final MappableFields<THClinoUnitPart> fields = const {
    #unit: _f$unit,
  };

  static THClinoUnitPart _instantiate(DecodingData data) {
    return THClinoUnitPart(data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static THClinoUnitPart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THClinoUnitPart>(map);
  }

  static THClinoUnitPart fromJson(String json) {
    return ensureInitialized().decodeJson<THClinoUnitPart>(json);
  }
}

mixin THClinoUnitPartMappable {
  String toJson() {
    return THClinoUnitPartMapper.ensureInitialized()
        .encodeJson<THClinoUnitPart>(this as THClinoUnitPart);
  }

  Map<String, dynamic> toMap() {
    return THClinoUnitPartMapper.ensureInitialized()
        .encodeMap<THClinoUnitPart>(this as THClinoUnitPart);
  }

  THClinoUnitPartCopyWith<THClinoUnitPart, THClinoUnitPart, THClinoUnitPart>
      get copyWith => _THClinoUnitPartCopyWithImpl(
          this as THClinoUnitPart, $identity, $identity);
  @override
  String toString() {
    return THClinoUnitPartMapper.ensureInitialized()
        .stringifyValue(this as THClinoUnitPart);
  }

  @override
  bool operator ==(Object other) {
    return THClinoUnitPartMapper.ensureInitialized()
        .equalsValue(this as THClinoUnitPart, other);
  }

  @override
  int get hashCode {
    return THClinoUnitPartMapper.ensureInitialized()
        .hashValue(this as THClinoUnitPart);
  }
}

extension THClinoUnitPartValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THClinoUnitPart, $Out> {
  THClinoUnitPartCopyWith<$R, THClinoUnitPart, $Out> get $asTHClinoUnitPart =>
      $base.as((v, t, t2) => _THClinoUnitPartCopyWithImpl(v, t, t2));
}

abstract class THClinoUnitPartCopyWith<$R, $In extends THClinoUnitPart, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({THClinoUnit? unit});
  THClinoUnitPartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THClinoUnitPartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THClinoUnitPart, $Out>
    implements THClinoUnitPartCopyWith<$R, THClinoUnitPart, $Out> {
  _THClinoUnitPartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THClinoUnitPart> $mapper =
      THClinoUnitPartMapper.ensureInitialized();
  @override
  $R call({THClinoUnit? unit}) =>
      $apply(FieldCopyWithData({if (unit != null) #unit: unit}));
  @override
  THClinoUnitPart $make(CopyWithData data) =>
      THClinoUnitPart(data.get(#unit, or: $value.unit));

  @override
  THClinoUnitPartCopyWith<$R2, THClinoUnitPart, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THClinoUnitPartCopyWithImpl($value, $cast, t);
}
