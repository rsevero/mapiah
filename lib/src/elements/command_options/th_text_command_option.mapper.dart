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
      THFileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THTextCommandOption';

  static THFile _$thFile(THTextCommandOption v) => v.thFile;
  static const Field<THTextCommandOption, THFile> _f$thFile =
      Field('thFile', _$thFile);
  static int _$parentMapiahID(THTextCommandOption v) => v.parentMapiahID;
  static const Field<THTextCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THTextCommandOption v) => v.optionType;
  static const Field<THTextCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static String _$text(THTextCommandOption v) => v.text;
  static const Field<THTextCommandOption, String> _f$text =
      Field('text', _$text);

  @override
  final MappableFields<THTextCommandOption> fields = const {
    #thFile: _f$thFile,
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #text: _f$text,
  };

  static THTextCommandOption _instantiate(DecodingData data) {
    return THTextCommandOption.withExplicitOptionType(
        data.dec(_f$thFile),
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$text));
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
  THFileCopyWith<$R, THFile, THFile> get thFile;
  @override
  $R call(
      {THFile? thFile, int? parentMapiahID, String? optionType, String? text});
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
  THFileCopyWith<$R, THFile, THFile> get thFile =>
      $value.thFile.copyWith.$chain((v) => call(thFile: v));
  @override
  $R call(
          {THFile? thFile,
          int? parentMapiahID,
          String? optionType,
          String? text}) =>
      $apply(FieldCopyWithData({
        if (thFile != null) #thFile: thFile,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (text != null) #text: text
      }));
  @override
  THTextCommandOption $make(CopyWithData data) =>
      THTextCommandOption.withExplicitOptionType(
          data.get(#thFile, or: $value.thFile),
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#text, or: $value.text));

  @override
  THTextCommandOptionCopyWith<$R2, THTextCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THTextCommandOptionCopyWithImpl($value, $cast, t);
}
