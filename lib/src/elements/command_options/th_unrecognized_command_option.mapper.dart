// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_unrecognized_command_option.dart';

class THUnrecognizedCommandOptionMapper
    extends ClassMapperBase<THUnrecognizedCommandOption> {
  THUnrecognizedCommandOptionMapper._();

  static THUnrecognizedCommandOptionMapper? _instance;
  static THUnrecognizedCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THUnrecognizedCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THFileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THUnrecognizedCommandOption';

  static THFile _$thFile(THUnrecognizedCommandOption v) => v.thFile;
  static const Field<THUnrecognizedCommandOption, THFile> _f$thFile =
      Field('thFile', _$thFile);
  static int _$parentMapiahID(THUnrecognizedCommandOption v) =>
      v.parentMapiahID;
  static const Field<THUnrecognizedCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THUnrecognizedCommandOption v) => v.optionType;
  static const Field<THUnrecognizedCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static String? _$value(THUnrecognizedCommandOption v) => v.value;
  static const Field<THUnrecognizedCommandOption, String> _f$value =
      Field('value', _$value);

  @override
  final MappableFields<THUnrecognizedCommandOption> fields = const {
    #thFile: _f$thFile,
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #value: _f$value,
  };

  static THUnrecognizedCommandOption _instantiate(DecodingData data) {
    return THUnrecognizedCommandOption.withExplicitParameters(
        data.dec(_f$thFile),
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$value));
  }

  @override
  final Function instantiate = _instantiate;

  static THUnrecognizedCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THUnrecognizedCommandOption>(map);
  }

  static THUnrecognizedCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THUnrecognizedCommandOption>(json);
  }
}

mixin THUnrecognizedCommandOptionMappable {
  String toJson() {
    return THUnrecognizedCommandOptionMapper.ensureInitialized()
        .encodeJson<THUnrecognizedCommandOption>(
            this as THUnrecognizedCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THUnrecognizedCommandOptionMapper.ensureInitialized()
        .encodeMap<THUnrecognizedCommandOption>(
            this as THUnrecognizedCommandOption);
  }

  THUnrecognizedCommandOptionCopyWith<THUnrecognizedCommandOption,
          THUnrecognizedCommandOption, THUnrecognizedCommandOption>
      get copyWith => _THUnrecognizedCommandOptionCopyWithImpl(
          this as THUnrecognizedCommandOption, $identity, $identity);
  @override
  String toString() {
    return THUnrecognizedCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THUnrecognizedCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THUnrecognizedCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THUnrecognizedCommandOption, other);
  }

  @override
  int get hashCode {
    return THUnrecognizedCommandOptionMapper.ensureInitialized()
        .hashValue(this as THUnrecognizedCommandOption);
  }
}

extension THUnrecognizedCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THUnrecognizedCommandOption, $Out> {
  THUnrecognizedCommandOptionCopyWith<$R, THUnrecognizedCommandOption, $Out>
      get $asTHUnrecognizedCommandOption => $base
          .as((v, t, t2) => _THUnrecognizedCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THUnrecognizedCommandOptionCopyWith<
    $R,
    $In extends THUnrecognizedCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile;
  @override
  $R call(
      {THFile? thFile, int? parentMapiahID, String? optionType, String? value});
  THUnrecognizedCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THUnrecognizedCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THUnrecognizedCommandOption, $Out>
    implements
        THUnrecognizedCommandOptionCopyWith<$R, THUnrecognizedCommandOption,
            $Out> {
  _THUnrecognizedCommandOptionCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THUnrecognizedCommandOption> $mapper =
      THUnrecognizedCommandOptionMapper.ensureInitialized();
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile =>
      $value.thFile.copyWith.$chain((v) => call(thFile: v));
  @override
  $R call(
          {THFile? thFile,
          int? parentMapiahID,
          String? optionType,
          Object? value = $none}) =>
      $apply(FieldCopyWithData({
        if (thFile != null) #thFile: thFile,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (value != $none) #value: value
      }));
  @override
  THUnrecognizedCommandOption $make(CopyWithData data) =>
      THUnrecognizedCommandOption.withExplicitParameters(
          data.get(#thFile, or: $value.thFile),
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#value, or: $value.value));

  @override
  THUnrecognizedCommandOptionCopyWith<$R2, THUnrecognizedCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THUnrecognizedCommandOptionCopyWithImpl($value, $cast, t);
}
