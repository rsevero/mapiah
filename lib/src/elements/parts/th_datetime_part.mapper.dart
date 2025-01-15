// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_datetime_part.dart';

class THDatetimePartMapper extends ClassMapperBase<THDatetimePart> {
  THDatetimePartMapper._();

  static THDatetimePartMapper? _instance;
  static THDatetimePartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THDatetimePartMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THDatetimePart';

  static String _$datetime(THDatetimePart v) => v.datetime;
  static const Field<THDatetimePart, String> _f$datetime =
      Field('datetime', _$datetime);
  static bool _$isRange(THDatetimePart v) => v.isRange;
  static const Field<THDatetimePart, bool> _f$isRange =
      Field('isRange', _$isRange);
  static bool _$isEmpty(THDatetimePart v) => v.isEmpty;
  static const Field<THDatetimePart, bool> _f$isEmpty =
      Field('isEmpty', _$isEmpty);

  @override
  final MappableFields<THDatetimePart> fields = const {
    #datetime: _f$datetime,
    #isRange: _f$isRange,
    #isEmpty: _f$isEmpty,
  };

  static THDatetimePart _instantiate(DecodingData data) {
    return THDatetimePart.withExplicitParameters(
        data.dec(_f$datetime), data.dec(_f$isRange), data.dec(_f$isEmpty));
  }

  @override
  final Function instantiate = _instantiate;

  static THDatetimePart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THDatetimePart>(map);
  }

  static THDatetimePart fromJson(String json) {
    return ensureInitialized().decodeJson<THDatetimePart>(json);
  }
}

mixin THDatetimePartMappable {
  String toJson() {
    return THDatetimePartMapper.ensureInitialized()
        .encodeJson<THDatetimePart>(this as THDatetimePart);
  }

  Map<String, dynamic> toMap() {
    return THDatetimePartMapper.ensureInitialized()
        .encodeMap<THDatetimePart>(this as THDatetimePart);
  }

  THDatetimePartCopyWith<THDatetimePart, THDatetimePart, THDatetimePart>
      get copyWith => _THDatetimePartCopyWithImpl(
          this as THDatetimePart, $identity, $identity);
  @override
  String toString() {
    return THDatetimePartMapper.ensureInitialized()
        .stringifyValue(this as THDatetimePart);
  }

  @override
  bool operator ==(Object other) {
    return THDatetimePartMapper.ensureInitialized()
        .equalsValue(this as THDatetimePart, other);
  }

  @override
  int get hashCode {
    return THDatetimePartMapper.ensureInitialized()
        .hashValue(this as THDatetimePart);
  }
}

extension THDatetimePartValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THDatetimePart, $Out> {
  THDatetimePartCopyWith<$R, THDatetimePart, $Out> get $asTHDatetimePart =>
      $base.as((v, t, t2) => _THDatetimePartCopyWithImpl(v, t, t2));
}

abstract class THDatetimePartCopyWith<$R, $In extends THDatetimePart, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? datetime, bool? isRange, bool? isEmpty});
  THDatetimePartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THDatetimePartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THDatetimePart, $Out>
    implements THDatetimePartCopyWith<$R, THDatetimePart, $Out> {
  _THDatetimePartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THDatetimePart> $mapper =
      THDatetimePartMapper.ensureInitialized();
  @override
  $R call({String? datetime, bool? isRange, bool? isEmpty}) =>
      $apply(FieldCopyWithData({
        if (datetime != null) #datetime: datetime,
        if (isRange != null) #isRange: isRange,
        if (isEmpty != null) #isEmpty: isEmpty
      }));
  @override
  THDatetimePart $make(CopyWithData data) =>
      THDatetimePart.withExplicitParameters(
          data.get(#datetime, or: $value.datetime),
          data.get(#isRange, or: $value.isRange),
          data.get(#isEmpty, or: $value.isEmpty));

  @override
  THDatetimePartCopyWith<$R2, THDatetimePart, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THDatetimePartCopyWithImpl($value, $cast, t);
}
