// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_id_command_option.dart';

class THIDCommandOptionMapper extends ClassMapperBase<THIDCommandOption> {
  THIDCommandOptionMapper._();

  static THIDCommandOptionMapper? _instance;
  static THIDCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THIDCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THFileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THIDCommandOption';

  static THFile _$thFile(THIDCommandOption v) => v.thFile;
  static const Field<THIDCommandOption, THFile> _f$thFile =
      Field('thFile', _$thFile);
  static int _$parentMapiahID(THIDCommandOption v) => v.parentMapiahID;
  static const Field<THIDCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THIDCommandOption v) => v.optionType;
  static const Field<THIDCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static String _$_thID(THIDCommandOption v) => v._thID;
  static const Field<THIDCommandOption, String> _f$_thID =
      Field('_thID', _$_thID, key: 'thID');

  @override
  final MappableFields<THIDCommandOption> fields = const {
    #thFile: _f$thFile,
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #_thID: _f$_thID,
  };

  static THIDCommandOption _instantiate(DecodingData data) {
    return THIDCommandOption.withExplicitOptionType(
        data.dec(_f$thFile),
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$_thID));
  }

  @override
  final Function instantiate = _instantiate;

  static THIDCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THIDCommandOption>(map);
  }

  static THIDCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THIDCommandOption>(json);
  }
}

mixin THIDCommandOptionMappable {
  String toJson() {
    return THIDCommandOptionMapper.ensureInitialized()
        .encodeJson<THIDCommandOption>(this as THIDCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THIDCommandOptionMapper.ensureInitialized()
        .encodeMap<THIDCommandOption>(this as THIDCommandOption);
  }

  THIDCommandOptionCopyWith<THIDCommandOption, THIDCommandOption,
          THIDCommandOption>
      get copyWith => _THIDCommandOptionCopyWithImpl(
          this as THIDCommandOption, $identity, $identity);
  @override
  String toString() {
    return THIDCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THIDCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THIDCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THIDCommandOption, other);
  }

  @override
  int get hashCode {
    return THIDCommandOptionMapper.ensureInitialized()
        .hashValue(this as THIDCommandOption);
  }
}

extension THIDCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THIDCommandOption, $Out> {
  THIDCommandOptionCopyWith<$R, THIDCommandOption, $Out>
      get $asTHIDCommandOption =>
          $base.as((v, t, t2) => _THIDCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THIDCommandOptionCopyWith<$R, $In extends THIDCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile;
  @override
  $R call(
      {THFile? thFile, int? parentMapiahID, String? optionType, String? thID});
  THIDCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THIDCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THIDCommandOption, $Out>
    implements THIDCommandOptionCopyWith<$R, THIDCommandOption, $Out> {
  _THIDCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THIDCommandOption> $mapper =
      THIDCommandOptionMapper.ensureInitialized();
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile =>
      $value.thFile.copyWith.$chain((v) => call(thFile: v));
  @override
  $R call(
          {THFile? thFile,
          int? parentMapiahID,
          String? optionType,
          String? thID}) =>
      $apply(FieldCopyWithData({
        if (thFile != null) #thFile: thFile,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (thID != null) #thID: thID
      }));
  @override
  THIDCommandOption $make(CopyWithData data) =>
      THIDCommandOption.withExplicitOptionType(
          data.get(#thFile, or: $value.thFile),
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#thID, or: $value._thID));

  @override
  THIDCommandOptionCopyWith<$R2, THIDCommandOption, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THIDCommandOptionCopyWithImpl($value, $cast, t);
}
