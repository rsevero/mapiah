// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_clip_command_option.dart';

class THClipCommandOptionMapper extends ClassMapperBase<THClipCommandOption> {
  THClipCommandOptionMapper._();

  static THClipCommandOptionMapper? _instance;
  static THClipCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THClipCommandOptionMapper._());
      THMultipleChoiceCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THClipCommandOption';

  static THHasOptions _$optionParent(THClipCommandOption v) => v.optionParent;
  static const Field<THClipCommandOption, THHasOptions> _f$optionParent =
      Field('optionParent', _$optionParent);
  static String _$optionType(THClipCommandOption v) => v.optionType;
  static const Field<THClipCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static String _$choice(THClipCommandOption v) => v.choice;
  static const Field<THClipCommandOption, String> _f$choice =
      Field('choice', _$choice);

  @override
  final MappableFields<THClipCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #optionType: _f$optionType,
    #choice: _f$choice,
  };

  static THClipCommandOption _instantiate(DecodingData data) {
    return THClipCommandOption(data.dec(_f$optionParent),
        data.dec(_f$optionType), data.dec(_f$choice));
  }

  @override
  final Function instantiate = _instantiate;

  static THClipCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THClipCommandOption>(map);
  }

  static THClipCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THClipCommandOption>(json);
  }
}

mixin THClipCommandOptionMappable {
  String toJson() {
    return THClipCommandOptionMapper.ensureInitialized()
        .encodeJson<THClipCommandOption>(this as THClipCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THClipCommandOptionMapper.ensureInitialized()
        .encodeMap<THClipCommandOption>(this as THClipCommandOption);
  }

  THClipCommandOptionCopyWith<THClipCommandOption, THClipCommandOption,
          THClipCommandOption>
      get copyWith => _THClipCommandOptionCopyWithImpl(
          this as THClipCommandOption, $identity, $identity);
  @override
  String toString() {
    return THClipCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THClipCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THClipCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THClipCommandOption, other);
  }

  @override
  int get hashCode {
    return THClipCommandOptionMapper.ensureInitialized()
        .hashValue(this as THClipCommandOption);
  }
}

extension THClipCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THClipCommandOption, $Out> {
  THClipCommandOptionCopyWith<$R, THClipCommandOption, $Out>
      get $asTHClipCommandOption =>
          $base.as((v, t, t2) => _THClipCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THClipCommandOptionCopyWith<$R, $In extends THClipCommandOption,
    $Out> implements THMultipleChoiceCommandOptionCopyWith<$R, $In, $Out> {
  @override
  $R call({THHasOptions? optionParent, String? optionType, String? choice});
  THClipCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THClipCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THClipCommandOption, $Out>
    implements THClipCommandOptionCopyWith<$R, THClipCommandOption, $Out> {
  _THClipCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THClipCommandOption> $mapper =
      THClipCommandOptionMapper.ensureInitialized();
  @override
  $R call({THHasOptions? optionParent, String? optionType, String? choice}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (optionType != null) #optionType: optionType,
        if (choice != null) #choice: choice
      }));
  @override
  THClipCommandOption $make(CopyWithData data) => THClipCommandOption(
      data.get(#optionParent, or: $value.optionParent),
      data.get(#optionType, or: $value.optionType),
      data.get(#choice, or: $value.choice));

  @override
  THClipCommandOptionCopyWith<$R2, THClipCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THClipCommandOptionCopyWithImpl($value, $cast, t);
}
