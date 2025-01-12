// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_title_command_option.dart';

class THTitleCommandOptionMapper extends ClassMapperBase<THTitleCommandOption> {
  THTitleCommandOptionMapper._();

  static THTitleCommandOptionMapper? _instance;
  static THTitleCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THTitleCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THFileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THTitleCommandOption';

  static THFile _$thFile(THTitleCommandOption v) => v.thFile;
  static const Field<THTitleCommandOption, THFile> _f$thFile =
      Field('thFile', _$thFile);
  static int _$parentMapiahID(THTitleCommandOption v) => v.parentMapiahID;
  static const Field<THTitleCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THTitleCommandOption v) => v.optionType;
  static const Field<THTitleCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static String _$text(THTitleCommandOption v) => v.text;
  static const Field<THTitleCommandOption, String> _f$text =
      Field('text', _$text);

  @override
  final MappableFields<THTitleCommandOption> fields = const {
    #thFile: _f$thFile,
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #text: _f$text,
  };

  static THTitleCommandOption _instantiate(DecodingData data) {
    return THTitleCommandOption.withExplicitOptionType(
        data.dec(_f$thFile),
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$text));
  }

  @override
  final Function instantiate = _instantiate;

  static THTitleCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THTitleCommandOption>(map);
  }

  static THTitleCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THTitleCommandOption>(json);
  }
}

mixin THTitleCommandOptionMappable {
  String toJson() {
    return THTitleCommandOptionMapper.ensureInitialized()
        .encodeJson<THTitleCommandOption>(this as THTitleCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THTitleCommandOptionMapper.ensureInitialized()
        .encodeMap<THTitleCommandOption>(this as THTitleCommandOption);
  }

  THTitleCommandOptionCopyWith<THTitleCommandOption, THTitleCommandOption,
          THTitleCommandOption>
      get copyWith => _THTitleCommandOptionCopyWithImpl(
          this as THTitleCommandOption, $identity, $identity);
  @override
  String toString() {
    return THTitleCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THTitleCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THTitleCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THTitleCommandOption, other);
  }

  @override
  int get hashCode {
    return THTitleCommandOptionMapper.ensureInitialized()
        .hashValue(this as THTitleCommandOption);
  }
}

extension THTitleCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THTitleCommandOption, $Out> {
  THTitleCommandOptionCopyWith<$R, THTitleCommandOption, $Out>
      get $asTHTitleCommandOption =>
          $base.as((v, t, t2) => _THTitleCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THTitleCommandOptionCopyWith<
    $R,
    $In extends THTitleCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile;
  @override
  $R call(
      {THFile? thFile, int? parentMapiahID, String? optionType, String? text});
  THTitleCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THTitleCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THTitleCommandOption, $Out>
    implements THTitleCommandOptionCopyWith<$R, THTitleCommandOption, $Out> {
  _THTitleCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THTitleCommandOption> $mapper =
      THTitleCommandOptionMapper.ensureInitialized();
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
  THTitleCommandOption $make(CopyWithData data) =>
      THTitleCommandOption.withExplicitOptionType(
          data.get(#thFile, or: $value.thFile),
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#text, or: $value.text));

  @override
  THTitleCommandOptionCopyWith<$R2, THTitleCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THTitleCommandOptionCopyWithImpl($value, $cast, t);
}
