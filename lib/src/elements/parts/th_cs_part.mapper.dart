// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_cs_part.dart';

class THCSPartMapper extends ClassMapperBase<THCSPart> {
  THCSPartMapper._();

  static THCSPartMapper? _instance;
  static THCSPartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THCSPartMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THCSPart';

  static String _$name(THCSPart v) => v.name;
  static const Field<THCSPart, String> _f$name = Field('name', _$name);
  static bool _$forOutputOnly(THCSPart v) => v.forOutputOnly;
  static const Field<THCSPart, bool> _f$forOutputOnly =
      Field('forOutputOnly', _$forOutputOnly);

  @override
  final MappableFields<THCSPart> fields = const {
    #name: _f$name,
    #forOutputOnly: _f$forOutputOnly,
  };

  static THCSPart _instantiate(DecodingData data) {
    return THCSPart(data.dec(_f$name), data.dec(_f$forOutputOnly));
  }

  @override
  final Function instantiate = _instantiate;

  static THCSPart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THCSPart>(map);
  }

  static THCSPart fromJson(String json) {
    return ensureInitialized().decodeJson<THCSPart>(json);
  }
}

mixin THCSPartMappable {
  String toJson() {
    return THCSPartMapper.ensureInitialized()
        .encodeJson<THCSPart>(this as THCSPart);
  }

  Map<String, dynamic> toMap() {
    return THCSPartMapper.ensureInitialized()
        .encodeMap<THCSPart>(this as THCSPart);
  }

  THCSPartCopyWith<THCSPart, THCSPart, THCSPart> get copyWith =>
      _THCSPartCopyWithImpl(this as THCSPart, $identity, $identity);
  @override
  String toString() {
    return THCSPartMapper.ensureInitialized().stringifyValue(this as THCSPart);
  }

  @override
  bool operator ==(Object other) {
    return THCSPartMapper.ensureInitialized()
        .equalsValue(this as THCSPart, other);
  }

  @override
  int get hashCode {
    return THCSPartMapper.ensureInitialized().hashValue(this as THCSPart);
  }
}

extension THCSPartValueCopy<$R, $Out> on ObjectCopyWith<$R, THCSPart, $Out> {
  THCSPartCopyWith<$R, THCSPart, $Out> get $asTHCSPart =>
      $base.as((v, t, t2) => _THCSPartCopyWithImpl(v, t, t2));
}

abstract class THCSPartCopyWith<$R, $In extends THCSPart, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? name, bool? forOutputOnly});
  THCSPartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THCSPartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THCSPart, $Out>
    implements THCSPartCopyWith<$R, THCSPart, $Out> {
  _THCSPartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THCSPart> $mapper =
      THCSPartMapper.ensureInitialized();
  @override
  $R call({String? name, bool? forOutputOnly}) => $apply(FieldCopyWithData({
        if (name != null) #name: name,
        if (forOutputOnly != null) #forOutputOnly: forOutputOnly
      }));
  @override
  THCSPart $make(CopyWithData data) => THCSPart(
      data.get(#name, or: $value.name),
      data.get(#forOutputOnly, or: $value.forOutputOnly));

  @override
  THCSPartCopyWith<$R2, THCSPart, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THCSPartCopyWithImpl($value, $cast, t);
}
