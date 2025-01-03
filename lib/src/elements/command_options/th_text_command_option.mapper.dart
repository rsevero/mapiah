// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_text_command_option.dart';

class THTextCommandOptionMapper extends ClassMapperBase<THTextCommandOption> {
  THTextCommandOptionMapper._();

  static THTextCommandOptionMapper? _instance;
  static THTextCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THTextCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THTextCommandOption';

  static THHasOptions _$optionParent(THTextCommandOption v) => v.optionParent;
  static const Field<THTextCommandOption, THHasOptions> _f$optionParent =
      Field('optionParent', _$optionParent);
  static String _$text(THTextCommandOption v) => v.text;
  static const Field<THTextCommandOption, String> _f$text =
      Field('text', _$text);

  @override
  final MappableFields<THTextCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #text: _f$text,
  };

  static THTextCommandOption _instantiate(DecodingData data) {
    return THTextCommandOption(data.dec(_f$optionParent), data.dec(_f$text));
  }

  @override
  final Function instantiate = _instantiate;

  static THTextCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THTextCommandOption>(map);
  }

  static THTextCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THTextCommandOption>(json);
  }
}

mixin THTextCommandOptionMappable {
  String toJson() {
    return THTextCommandOptionMapper.ensureInitialized()
        .encodeJson<THTextCommandOption>(this as THTextCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THTextCommandOptionMapper.ensureInitialized()
        .encodeMap<THTextCommandOption>(this as THTextCommandOption);
  }

  THTextCommandOptionCopyWith<THTextCommandOption, THTextCommandOption,
          THTextCommandOption>
      get copyWith => _THTextCommandOptionCopyWithImpl(
          this as THTextCommandOption, $identity, $identity);
  @override
  String toString() {
    return THTextCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THTextCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THTextCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THTextCommandOption, other);
  }

  @override
  int get hashCode {
    return THTextCommandOptionMapper.ensureInitialized()
        .hashValue(this as THTextCommandOption);
  }
}

extension THTextCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THTextCommandOption, $Out> {
  THTextCommandOptionCopyWith<$R, THTextCommandOption, $Out>
      get $asTHTextCommandOption =>
          $base.as((v, t, t2) => _THTextCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THTextCommandOptionCopyWith<$R, $In extends THTextCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  $R call({THHasOptions? optionParent, String? text});
  THTextCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THTextCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THTextCommandOption, $Out>
    implements THTextCommandOptionCopyWith<$R, THTextCommandOption, $Out> {
  _THTextCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THTextCommandOption> $mapper =
      THTextCommandOptionMapper.ensureInitialized();
  @override
  $R call({THHasOptions? optionParent, String? text}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (text != null) #text: text
      }));
  @override
  THTextCommandOption $make(CopyWithData data) => THTextCommandOption(
      data.get(#optionParent, or: $value.optionParent),
      data.get(#text, or: $value.text));

  @override
  THTextCommandOptionCopyWith<$R2, THTextCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THTextCommandOptionCopyWithImpl($value, $cast, t);
}
