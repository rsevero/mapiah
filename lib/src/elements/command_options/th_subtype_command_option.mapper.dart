// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_subtype_command_option.dart';

class THSubtypeCommandOptionMapper
    extends ClassMapperBase<THSubtypeCommandOption> {
  THSubtypeCommandOptionMapper._();

  static THSubtypeCommandOptionMapper? _instance;
  static THSubtypeCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THSubtypeCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THSubtypeCommandOption';

  static THHasOptions _$optionParent(THSubtypeCommandOption v) =>
      v.optionParent;
  static const Field<THSubtypeCommandOption, THHasOptions> _f$optionParent =
      Field('optionParent', _$optionParent);
  static String _$optionType(THSubtypeCommandOption v) => v.optionType;
  static const Field<THSubtypeCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static String _$subtype(THSubtypeCommandOption v) => v.subtype;
  static const Field<THSubtypeCommandOption, String> _f$subtype =
      Field('subtype', _$subtype);

  @override
  final MappableFields<THSubtypeCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #optionType: _f$optionType,
    #subtype: _f$subtype,
  };

  static THSubtypeCommandOption _instantiate(DecodingData data) {
    return THSubtypeCommandOption.withExplicitOptionType(
        data.dec(_f$optionParent),
        data.dec(_f$optionType),
        data.dec(_f$subtype));
  }

  @override
  final Function instantiate = _instantiate;

  static THSubtypeCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THSubtypeCommandOption>(map);
  }

  static THSubtypeCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THSubtypeCommandOption>(json);
  }
}

mixin THSubtypeCommandOptionMappable {
  String toJson() {
    return THSubtypeCommandOptionMapper.ensureInitialized()
        .encodeJson<THSubtypeCommandOption>(this as THSubtypeCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THSubtypeCommandOptionMapper.ensureInitialized()
        .encodeMap<THSubtypeCommandOption>(this as THSubtypeCommandOption);
  }

  THSubtypeCommandOptionCopyWith<THSubtypeCommandOption, THSubtypeCommandOption,
          THSubtypeCommandOption>
      get copyWith => _THSubtypeCommandOptionCopyWithImpl(
          this as THSubtypeCommandOption, $identity, $identity);
  @override
  String toString() {
    return THSubtypeCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THSubtypeCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THSubtypeCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THSubtypeCommandOption, other);
  }

  @override
  int get hashCode {
    return THSubtypeCommandOptionMapper.ensureInitialized()
        .hashValue(this as THSubtypeCommandOption);
  }
}

extension THSubtypeCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THSubtypeCommandOption, $Out> {
  THSubtypeCommandOptionCopyWith<$R, THSubtypeCommandOption, $Out>
      get $asTHSubtypeCommandOption =>
          $base.as((v, t, t2) => _THSubtypeCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THSubtypeCommandOptionCopyWith<
    $R,
    $In extends THSubtypeCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  $R call({THHasOptions? optionParent, String? optionType, String? subtype});
  THSubtypeCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THSubtypeCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THSubtypeCommandOption, $Out>
    implements
        THSubtypeCommandOptionCopyWith<$R, THSubtypeCommandOption, $Out> {
  _THSubtypeCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THSubtypeCommandOption> $mapper =
      THSubtypeCommandOptionMapper.ensureInitialized();
  @override
  $R call({THHasOptions? optionParent, String? optionType, String? subtype}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (optionType != null) #optionType: optionType,
        if (subtype != null) #subtype: subtype
      }));
  @override
  THSubtypeCommandOption $make(CopyWithData data) =>
      THSubtypeCommandOption.withExplicitOptionType(
          data.get(#optionParent, or: $value.optionParent),
          data.get(#optionType, or: $value.optionType),
          data.get(#subtype, or: $value.subtype));

  @override
  THSubtypeCommandOptionCopyWith<$R2, THSubtypeCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THSubtypeCommandOptionCopyWithImpl($value, $cast, t);
}
