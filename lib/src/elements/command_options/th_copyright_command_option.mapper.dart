// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_copyright_command_option.dart';

class THCopyrightCommandOptionMapper
    extends ClassMapperBase<THCopyrightCommandOption> {
  THCopyrightCommandOptionMapper._();

  static THCopyrightCommandOptionMapper? _instance;
  static THCopyrightCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THCopyrightCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THFileMapper.ensureInitialized();
      THDatetimePartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THCopyrightCommandOption';

  static THFile _$thFile(THCopyrightCommandOption v) => v.thFile;
  static const Field<THCopyrightCommandOption, THFile> _f$thFile =
      Field('thFile', _$thFile);
  static int _$parentMapiahID(THCopyrightCommandOption v) => v.parentMapiahID;
  static const Field<THCopyrightCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THCopyrightCommandOption v) => v.optionType;
  static const Field<THCopyrightCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static THDatetimePart _$datetime(THCopyrightCommandOption v) => v.datetime;
  static const Field<THCopyrightCommandOption, THDatetimePart> _f$datetime =
      Field('datetime', _$datetime);
  static String _$copyrightMessage(THCopyrightCommandOption v) =>
      v.copyrightMessage;
  static const Field<THCopyrightCommandOption, String> _f$copyrightMessage =
      Field('copyrightMessage', _$copyrightMessage);

  @override
  final MappableFields<THCopyrightCommandOption> fields = const {
    #thFile: _f$thFile,
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #datetime: _f$datetime,
    #copyrightMessage: _f$copyrightMessage,
  };

  static THCopyrightCommandOption _instantiate(DecodingData data) {
    return THCopyrightCommandOption.withExplicitOptionType(
        data.dec(_f$thFile),
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$datetime),
        data.dec(_f$copyrightMessage));
  }

  @override
  final Function instantiate = _instantiate;

  static THCopyrightCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THCopyrightCommandOption>(map);
  }

  static THCopyrightCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THCopyrightCommandOption>(json);
  }
}

mixin THCopyrightCommandOptionMappable {
  String toJson() {
    return THCopyrightCommandOptionMapper.ensureInitialized()
        .encodeJson<THCopyrightCommandOption>(this as THCopyrightCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THCopyrightCommandOptionMapper.ensureInitialized()
        .encodeMap<THCopyrightCommandOption>(this as THCopyrightCommandOption);
  }

  THCopyrightCommandOptionCopyWith<THCopyrightCommandOption,
          THCopyrightCommandOption, THCopyrightCommandOption>
      get copyWith => _THCopyrightCommandOptionCopyWithImpl(
          this as THCopyrightCommandOption, $identity, $identity);
  @override
  String toString() {
    return THCopyrightCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THCopyrightCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THCopyrightCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THCopyrightCommandOption, other);
  }

  @override
  int get hashCode {
    return THCopyrightCommandOptionMapper.ensureInitialized()
        .hashValue(this as THCopyrightCommandOption);
  }
}

extension THCopyrightCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THCopyrightCommandOption, $Out> {
  THCopyrightCommandOptionCopyWith<$R, THCopyrightCommandOption, $Out>
      get $asTHCopyrightCommandOption => $base
          .as((v, t, t2) => _THCopyrightCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THCopyrightCommandOptionCopyWith<
    $R,
    $In extends THCopyrightCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile;
  THDatetimePartCopyWith<$R, THDatetimePart, THDatetimePart> get datetime;
  @override
  $R call(
      {THFile? thFile,
      int? parentMapiahID,
      String? optionType,
      THDatetimePart? datetime,
      String? copyrightMessage});
  THCopyrightCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THCopyrightCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THCopyrightCommandOption, $Out>
    implements
        THCopyrightCommandOptionCopyWith<$R, THCopyrightCommandOption, $Out> {
  _THCopyrightCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THCopyrightCommandOption> $mapper =
      THCopyrightCommandOptionMapper.ensureInitialized();
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile =>
      $value.thFile.copyWith.$chain((v) => call(thFile: v));
  @override
  THDatetimePartCopyWith<$R, THDatetimePart, THDatetimePart> get datetime =>
      $value.datetime.copyWith.$chain((v) => call(datetime: v));
  @override
  $R call(
          {THFile? thFile,
          int? parentMapiahID,
          String? optionType,
          THDatetimePart? datetime,
          String? copyrightMessage}) =>
      $apply(FieldCopyWithData({
        if (thFile != null) #thFile: thFile,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (datetime != null) #datetime: datetime,
        if (copyrightMessage != null) #copyrightMessage: copyrightMessage
      }));
  @override
  THCopyrightCommandOption $make(CopyWithData data) =>
      THCopyrightCommandOption.withExplicitOptionType(
          data.get(#thFile, or: $value.thFile),
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#datetime, or: $value.datetime),
          data.get(#copyrightMessage, or: $value.copyrightMessage));

  @override
  THCopyrightCommandOptionCopyWith<$R2, THCopyrightCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THCopyrightCommandOptionCopyWithImpl($value, $cast, t);
}
