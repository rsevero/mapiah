// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_multiple_choice_command_option.dart';

class THMultipleChoiceCommandOptionMapper
    extends ClassMapperBase<THMultipleChoiceCommandOption> {
  THMultipleChoiceCommandOptionMapper._();

  static THMultipleChoiceCommandOptionMapper? _instance;
  static THMultipleChoiceCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THMultipleChoiceCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THMultipleChoiceCommandOption';

  static THHasOptions _$optionParent(THMultipleChoiceCommandOption v) =>
      v.optionParent;
  static const Field<THMultipleChoiceCommandOption, THHasOptions>
      _f$optionParent = Field('optionParent', _$optionParent);
  static String _$optionType(THMultipleChoiceCommandOption v) => v.optionType;
  static const Field<THMultipleChoiceCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static String _$choice(THMultipleChoiceCommandOption v) => v.choice;
  static const Field<THMultipleChoiceCommandOption, String> _f$choice =
      Field('choice', _$choice);

  @override
  final MappableFields<THMultipleChoiceCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #optionType: _f$optionType,
    #choice: _f$choice,
  };

  static THMultipleChoiceCommandOption _instantiate(DecodingData data) {
    return THMultipleChoiceCommandOption(data.dec(_f$optionParent),
        data.dec(_f$optionType), data.dec(_f$choice));
  }

  @override
  final Function instantiate = _instantiate;

  static THMultipleChoiceCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THMultipleChoiceCommandOption>(map);
  }

  static THMultipleChoiceCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THMultipleChoiceCommandOption>(json);
  }
}

mixin THMultipleChoiceCommandOptionMappable {
  String toJson() {
    return THMultipleChoiceCommandOptionMapper.ensureInitialized()
        .encodeJson<THMultipleChoiceCommandOption>(
            this as THMultipleChoiceCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THMultipleChoiceCommandOptionMapper.ensureInitialized()
        .encodeMap<THMultipleChoiceCommandOption>(
            this as THMultipleChoiceCommandOption);
  }

  THMultipleChoiceCommandOptionCopyWith<THMultipleChoiceCommandOption,
          THMultipleChoiceCommandOption, THMultipleChoiceCommandOption>
      get copyWith => _THMultipleChoiceCommandOptionCopyWithImpl(
          this as THMultipleChoiceCommandOption, $identity, $identity);
  @override
  String toString() {
    return THMultipleChoiceCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THMultipleChoiceCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THMultipleChoiceCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THMultipleChoiceCommandOption, other);
  }

  @override
  int get hashCode {
    return THMultipleChoiceCommandOptionMapper.ensureInitialized()
        .hashValue(this as THMultipleChoiceCommandOption);
  }
}

extension THMultipleChoiceCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THMultipleChoiceCommandOption, $Out> {
  THMultipleChoiceCommandOptionCopyWith<$R, THMultipleChoiceCommandOption, $Out>
      get $asTHMultipleChoiceCommandOption => $base.as(
          (v, t, t2) => _THMultipleChoiceCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THMultipleChoiceCommandOptionCopyWith<
    $R,
    $In extends THMultipleChoiceCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  $R call({THHasOptions? optionParent, String? optionType, String? choice});
  THMultipleChoiceCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THMultipleChoiceCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THMultipleChoiceCommandOption, $Out>
    implements
        THMultipleChoiceCommandOptionCopyWith<$R, THMultipleChoiceCommandOption,
            $Out> {
  _THMultipleChoiceCommandOptionCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THMultipleChoiceCommandOption> $mapper =
      THMultipleChoiceCommandOptionMapper.ensureInitialized();
  @override
  $R call({THHasOptions? optionParent, String? optionType, String? choice}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (optionType != null) #optionType: optionType,
        if (choice != null) #choice: choice
      }));
  @override
  THMultipleChoiceCommandOption $make(CopyWithData data) =>
      THMultipleChoiceCommandOption(
          data.get(#optionParent, or: $value.optionParent),
          data.get(#optionType, or: $value.optionType),
          data.get(#choice, or: $value.choice));

  @override
  THMultipleChoiceCommandOptionCopyWith<$R2, THMultipleChoiceCommandOption,
      $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THMultipleChoiceCommandOptionCopyWithImpl($value, $cast, t);
}
