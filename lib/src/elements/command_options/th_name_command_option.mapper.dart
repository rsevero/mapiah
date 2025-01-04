// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_name_command_option.dart';

class THNameCommandOptionMapper extends ClassMapperBase<THNameCommandOption> {
  THNameCommandOptionMapper._();

  static THNameCommandOptionMapper? _instance;
  static THNameCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THNameCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THNameCommandOption';

  static THHasOptions _$optionParent(THNameCommandOption v) => v.optionParent;
  static const Field<THNameCommandOption, THHasOptions> _f$optionParent =
      Field('optionParent', _$optionParent);
  static String _$optionType(THNameCommandOption v) => v.optionType;
  static const Field<THNameCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static String _$reference(THNameCommandOption v) => v.reference;
  static const Field<THNameCommandOption, String> _f$reference =
      Field('reference', _$reference);

  @override
  final MappableFields<THNameCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #optionType: _f$optionType,
    #reference: _f$reference,
  };

  static THNameCommandOption _instantiate(DecodingData data) {
    return THNameCommandOption.withExplicitOptionType(data.dec(_f$optionParent),
        data.dec(_f$optionType), data.dec(_f$reference));
  }

  @override
  final Function instantiate = _instantiate;

  static THNameCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THNameCommandOption>(map);
  }

  static THNameCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THNameCommandOption>(json);
  }
}

mixin THNameCommandOptionMappable {
  String toJson() {
    return THNameCommandOptionMapper.ensureInitialized()
        .encodeJson<THNameCommandOption>(this as THNameCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THNameCommandOptionMapper.ensureInitialized()
        .encodeMap<THNameCommandOption>(this as THNameCommandOption);
  }

  THNameCommandOptionCopyWith<THNameCommandOption, THNameCommandOption,
          THNameCommandOption>
      get copyWith => _THNameCommandOptionCopyWithImpl(
          this as THNameCommandOption, $identity, $identity);
  @override
  String toString() {
    return THNameCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THNameCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THNameCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THNameCommandOption, other);
  }

  @override
  int get hashCode {
    return THNameCommandOptionMapper.ensureInitialized()
        .hashValue(this as THNameCommandOption);
  }
}

extension THNameCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THNameCommandOption, $Out> {
  THNameCommandOptionCopyWith<$R, THNameCommandOption, $Out>
      get $asTHNameCommandOption =>
          $base.as((v, t, t2) => _THNameCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THNameCommandOptionCopyWith<$R, $In extends THNameCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  $R call({THHasOptions? optionParent, String? optionType, String? reference});
  THNameCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THNameCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THNameCommandOption, $Out>
    implements THNameCommandOptionCopyWith<$R, THNameCommandOption, $Out> {
  _THNameCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THNameCommandOption> $mapper =
      THNameCommandOptionMapper.ensureInitialized();
  @override
  $R call(
          {THHasOptions? optionParent,
          String? optionType,
          String? reference}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (optionType != null) #optionType: optionType,
        if (reference != null) #reference: reference
      }));
  @override
  THNameCommandOption $make(CopyWithData data) =>
      THNameCommandOption.withExplicitOptionType(
          data.get(#optionParent, or: $value.optionParent),
          data.get(#optionType, or: $value.optionType),
          data.get(#reference, or: $value.reference));

  @override
  THNameCommandOptionCopyWith<$R2, THNameCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THNameCommandOptionCopyWithImpl($value, $cast, t);
}
