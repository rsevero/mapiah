// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_from_command_option.dart';

class THFromCommandOptionMapper extends ClassMapperBase<THFromCommandOption> {
  THFromCommandOptionMapper._();

  static THFromCommandOptionMapper? _instance;
  static THFromCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THFromCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THFileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THFromCommandOption';

  static THFile _$thFile(THFromCommandOption v) => v.thFile;
  static const Field<THFromCommandOption, THFile> _f$thFile =
      Field('thFile', _$thFile);
  static int _$parentMapiahID(THFromCommandOption v) => v.parentMapiahID;
  static const Field<THFromCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THFromCommandOption v) => v.optionType;
  static const Field<THFromCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static String _$station(THFromCommandOption v) => v.station;
  static const Field<THFromCommandOption, String> _f$station =
      Field('station', _$station);

  @override
  final MappableFields<THFromCommandOption> fields = const {
    #thFile: _f$thFile,
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #station: _f$station,
  };

  static THFromCommandOption _instantiate(DecodingData data) {
    return THFromCommandOption.withExplicitParameters(
        data.dec(_f$thFile),
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$station));
  }

  @override
  final Function instantiate = _instantiate;

  static THFromCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THFromCommandOption>(map);
  }

  static THFromCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THFromCommandOption>(json);
  }
}

mixin THFromCommandOptionMappable {
  String toJson() {
    return THFromCommandOptionMapper.ensureInitialized()
        .encodeJson<THFromCommandOption>(this as THFromCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THFromCommandOptionMapper.ensureInitialized()
        .encodeMap<THFromCommandOption>(this as THFromCommandOption);
  }

  THFromCommandOptionCopyWith<THFromCommandOption, THFromCommandOption,
          THFromCommandOption>
      get copyWith => _THFromCommandOptionCopyWithImpl(
          this as THFromCommandOption, $identity, $identity);
  @override
  String toString() {
    return THFromCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THFromCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THFromCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THFromCommandOption, other);
  }

  @override
  int get hashCode {
    return THFromCommandOptionMapper.ensureInitialized()
        .hashValue(this as THFromCommandOption);
  }
}

extension THFromCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THFromCommandOption, $Out> {
  THFromCommandOptionCopyWith<$R, THFromCommandOption, $Out>
      get $asTHFromCommandOption =>
          $base.as((v, t, t2) => _THFromCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THFromCommandOptionCopyWith<$R, $In extends THFromCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile;
  @override
  $R call(
      {THFile? thFile,
      int? parentMapiahID,
      String? optionType,
      String? station});
  THFromCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THFromCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THFromCommandOption, $Out>
    implements THFromCommandOptionCopyWith<$R, THFromCommandOption, $Out> {
  _THFromCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THFromCommandOption> $mapper =
      THFromCommandOptionMapper.ensureInitialized();
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile =>
      $value.thFile.copyWith.$chain((v) => call(thFile: v));
  @override
  $R call(
          {THFile? thFile,
          int? parentMapiahID,
          String? optionType,
          String? station}) =>
      $apply(FieldCopyWithData({
        if (thFile != null) #thFile: thFile,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (station != null) #station: station
      }));
  @override
  THFromCommandOption $make(CopyWithData data) =>
      THFromCommandOption.withExplicitParameters(
          data.get(#thFile, or: $value.thFile),
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#station, or: $value.station));

  @override
  THFromCommandOptionCopyWith<$R2, THFromCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THFromCommandOptionCopyWithImpl($value, $cast, t);
}
