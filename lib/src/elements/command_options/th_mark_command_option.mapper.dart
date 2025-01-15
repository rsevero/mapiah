// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_mark_command_option.dart';

class THMarkCommandOptionMapper extends ClassMapperBase<THMarkCommandOption> {
  THMarkCommandOptionMapper._();

  static THMarkCommandOptionMapper? _instance;
  static THMarkCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THMarkCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THFileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THMarkCommandOption';

  static THFile _$thFile(THMarkCommandOption v) => v.thFile;
  static const Field<THMarkCommandOption, THFile> _f$thFile =
      Field('thFile', _$thFile);
  static int _$parentMapiahID(THMarkCommandOption v) => v.parentMapiahID;
  static const Field<THMarkCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THMarkCommandOption v) => v.optionType;
  static const Field<THMarkCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static String _$mark(THMarkCommandOption v) => v.mark;
  static const Field<THMarkCommandOption, String> _f$mark =
      Field('mark', _$mark);

  @override
  final MappableFields<THMarkCommandOption> fields = const {
    #thFile: _f$thFile,
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #mark: _f$mark,
  };

  static THMarkCommandOption _instantiate(DecodingData data) {
    return THMarkCommandOption.withExplicitParameters(
        data.dec(_f$thFile),
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$mark));
  }

  @override
  final Function instantiate = _instantiate;

  static THMarkCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THMarkCommandOption>(map);
  }

  static THMarkCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THMarkCommandOption>(json);
  }
}

mixin THMarkCommandOptionMappable {
  String toJson() {
    return THMarkCommandOptionMapper.ensureInitialized()
        .encodeJson<THMarkCommandOption>(this as THMarkCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THMarkCommandOptionMapper.ensureInitialized()
        .encodeMap<THMarkCommandOption>(this as THMarkCommandOption);
  }

  THMarkCommandOptionCopyWith<THMarkCommandOption, THMarkCommandOption,
          THMarkCommandOption>
      get copyWith => _THMarkCommandOptionCopyWithImpl(
          this as THMarkCommandOption, $identity, $identity);
  @override
  String toString() {
    return THMarkCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THMarkCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THMarkCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THMarkCommandOption, other);
  }

  @override
  int get hashCode {
    return THMarkCommandOptionMapper.ensureInitialized()
        .hashValue(this as THMarkCommandOption);
  }
}

extension THMarkCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THMarkCommandOption, $Out> {
  THMarkCommandOptionCopyWith<$R, THMarkCommandOption, $Out>
      get $asTHMarkCommandOption =>
          $base.as((v, t, t2) => _THMarkCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THMarkCommandOptionCopyWith<$R, $In extends THMarkCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile;
  @override
  $R call(
      {THFile? thFile, int? parentMapiahID, String? optionType, String? mark});
  THMarkCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THMarkCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THMarkCommandOption, $Out>
    implements THMarkCommandOptionCopyWith<$R, THMarkCommandOption, $Out> {
  _THMarkCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THMarkCommandOption> $mapper =
      THMarkCommandOptionMapper.ensureInitialized();
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile =>
      $value.thFile.copyWith.$chain((v) => call(thFile: v));
  @override
  $R call(
          {THFile? thFile,
          int? parentMapiahID,
          String? optionType,
          String? mark}) =>
      $apply(FieldCopyWithData({
        if (thFile != null) #thFile: thFile,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (mark != null) #mark: mark
      }));
  @override
  THMarkCommandOption $make(CopyWithData data) =>
      THMarkCommandOption.withExplicitParameters(
          data.get(#thFile, or: $value.thFile),
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#mark, or: $value.mark));

  @override
  THMarkCommandOptionCopyWith<$R2, THMarkCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THMarkCommandOptionCopyWithImpl($value, $cast, t);
}
