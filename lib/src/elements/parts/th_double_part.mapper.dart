// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_double_part.dart';

class THDoublePartMapper extends ClassMapperBase<THDoublePart> {
  THDoublePartMapper._();

  static THDoublePartMapper? _instance;
  static THDoublePartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THDoublePartMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THDoublePart';

  static double _$value(THDoublePart v) => v.value;
  static const Field<THDoublePart, double> _f$value = Field('value', _$value);
  static int _$decimalPositions(THDoublePart v) => v.decimalPositions;
  static const Field<THDoublePart, int> _f$decimalPositions =
      Field('decimalPositions', _$decimalPositions);

  @override
  final MappableFields<THDoublePart> fields = const {
    #value: _f$value,
    #decimalPositions: _f$decimalPositions,
  };

  static THDoublePart _instantiate(DecodingData data) {
    return THDoublePart(data.dec(_f$value), data.dec(_f$decimalPositions));
  }

  @override
  final Function instantiate = _instantiate;

  static THDoublePart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THDoublePart>(map);
  }

  static THDoublePart fromJson(String json) {
    return ensureInitialized().decodeJson<THDoublePart>(json);
  }
}

mixin THDoublePartMappable {
  String toJson() {
    return THDoublePartMapper.ensureInitialized()
        .encodeJson<THDoublePart>(this as THDoublePart);
  }

  Map<String, dynamic> toMap() {
    return THDoublePartMapper.ensureInitialized()
        .encodeMap<THDoublePart>(this as THDoublePart);
  }

  THDoublePartCopyWith<THDoublePart, THDoublePart, THDoublePart> get copyWith =>
      _THDoublePartCopyWithImpl(this as THDoublePart, $identity, $identity);
  @override
  String toString() {
    return THDoublePartMapper.ensureInitialized()
        .stringifyValue(this as THDoublePart);
  }

  @override
  bool operator ==(Object other) {
    return THDoublePartMapper.ensureInitialized()
        .equalsValue(this as THDoublePart, other);
  }

  @override
  int get hashCode {
    return THDoublePartMapper.ensureInitialized()
        .hashValue(this as THDoublePart);
  }
}

extension THDoublePartValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THDoublePart, $Out> {
  THDoublePartCopyWith<$R, THDoublePart, $Out> get $asTHDoublePart =>
      $base.as((v, t, t2) => _THDoublePartCopyWithImpl(v, t, t2));
}

abstract class THDoublePartCopyWith<$R, $In extends THDoublePart, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({double? value, int? decimalPositions});
  THDoublePartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THDoublePartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THDoublePart, $Out>
    implements THDoublePartCopyWith<$R, THDoublePart, $Out> {
  _THDoublePartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THDoublePart> $mapper =
      THDoublePartMapper.ensureInitialized();
  @override
  $R call({double? value, int? decimalPositions}) => $apply(FieldCopyWithData({
        if (value != null) #value: value,
        if (decimalPositions != null) #decimalPositions: decimalPositions
      }));
  @override
  THDoublePart $make(CopyWithData data) => THDoublePart(
      data.get(#value, or: $value.value),
      data.get(#decimalPositions, or: $value.decimalPositions));

  @override
  THDoublePartCopyWith<$R2, THDoublePart, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THDoublePartCopyWithImpl($value, $cast, t);
}
