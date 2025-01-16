// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_xtherion_config.dart';

class THXTherionConfigMapper extends ClassMapperBase<THXTherionConfig> {
  THXTherionConfigMapper._();

  static THXTherionConfigMapper? _instance;
  static THXTherionConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THXTherionConfigMapper._());
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THXTherionConfig';

  static int _$mapiahID(THXTherionConfig v) => v.mapiahID;
  static const Field<THXTherionConfig, int> _f$mapiahID =
      Field('mapiahID', _$mapiahID);
  static int _$parentMapiahID(THXTherionConfig v) => v.parentMapiahID;
  static const Field<THXTherionConfig, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String? _$sameLineComment(THXTherionConfig v) => v.sameLineComment;
  static const Field<THXTherionConfig, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment);
  static String _$name(THXTherionConfig v) => v.name;
  static const Field<THXTherionConfig, String> _f$name = Field('name', _$name);
  static String _$value(THXTherionConfig v) => v.value;
  static const Field<THXTherionConfig, String> _f$value =
      Field('value', _$value);

  @override
  final MappableFields<THXTherionConfig> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
    #name: _f$name,
    #value: _f$value,
  };

  static THXTherionConfig _instantiate(DecodingData data) {
    return THXTherionConfig.notAddToParent(
        data.dec(_f$mapiahID),
        data.dec(_f$parentMapiahID),
        data.dec(_f$sameLineComment),
        data.dec(_f$name),
        data.dec(_f$value));
  }

  @override
  final Function instantiate = _instantiate;

  static THXTherionConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THXTherionConfig>(map);
  }

  static THXTherionConfig fromJson(String json) {
    return ensureInitialized().decodeJson<THXTherionConfig>(json);
  }
}

mixin THXTherionConfigMappable {
  String toJson() {
    return THXTherionConfigMapper.ensureInitialized()
        .encodeJson<THXTherionConfig>(this as THXTherionConfig);
  }

  Map<String, dynamic> toMap() {
    return THXTherionConfigMapper.ensureInitialized()
        .encodeMap<THXTherionConfig>(this as THXTherionConfig);
  }

  THXTherionConfigCopyWith<THXTherionConfig, THXTherionConfig, THXTherionConfig>
      get copyWith => _THXTherionConfigCopyWithImpl(
          this as THXTherionConfig, $identity, $identity);
  @override
  String toString() {
    return THXTherionConfigMapper.ensureInitialized()
        .stringifyValue(this as THXTherionConfig);
  }

  @override
  bool operator ==(Object other) {
    return THXTherionConfigMapper.ensureInitialized()
        .equalsValue(this as THXTherionConfig, other);
  }

  @override
  int get hashCode {
    return THXTherionConfigMapper.ensureInitialized()
        .hashValue(this as THXTherionConfig);
  }
}

extension THXTherionConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THXTherionConfig, $Out> {
  THXTherionConfigCopyWith<$R, THXTherionConfig, $Out>
      get $asTHXTherionConfig =>
          $base.as((v, t, t2) => _THXTherionConfigCopyWithImpl(v, t, t2));
}

abstract class THXTherionConfigCopyWith<$R, $In extends THXTherionConfig, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {int? mapiahID,
      int? parentMapiahID,
      String? sameLineComment,
      String? name,
      String? value});
  THXTherionConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THXTherionConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THXTherionConfig, $Out>
    implements THXTherionConfigCopyWith<$R, THXTherionConfig, $Out> {
  _THXTherionConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THXTherionConfig> $mapper =
      THXTherionConfigMapper.ensureInitialized();
  @override
  $R call(
          {int? mapiahID,
          int? parentMapiahID,
          Object? sameLineComment = $none,
          String? name,
          String? value}) =>
      $apply(FieldCopyWithData({
        if (mapiahID != null) #mapiahID: mapiahID,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (sameLineComment != $none) #sameLineComment: sameLineComment,
        if (name != null) #name: name,
        if (value != null) #value: value
      }));
  @override
  THXTherionConfig $make(CopyWithData data) => THXTherionConfig.notAddToParent(
      data.get(#mapiahID, or: $value.mapiahID),
      data.get(#parentMapiahID, or: $value.parentMapiahID),
      data.get(#sameLineComment, or: $value.sameLineComment),
      data.get(#name, or: $value.name),
      data.get(#value, or: $value.value));

  @override
  THXTherionConfigCopyWith<$R2, THXTherionConfig, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THXTherionConfigCopyWithImpl($value, $cast, t);
}
