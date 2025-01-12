// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_line_scale_command_option.dart';

class THLineScaleCommandOptionTypeMapper
    extends EnumMapper<THLineScaleCommandOptionType> {
  THLineScaleCommandOptionTypeMapper._();

  static THLineScaleCommandOptionTypeMapper? _instance;
  static THLineScaleCommandOptionTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THLineScaleCommandOptionTypeMapper._());
    }
    return _instance!;
  }

  static THLineScaleCommandOptionType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  THLineScaleCommandOptionType decode(dynamic value) {
    switch (value) {
      case 'multiplechoice':
        return THLineScaleCommandOptionType.multiplechoice;
      case 'text':
        return THLineScaleCommandOptionType.text;
      case 'numeric':
        return THLineScaleCommandOptionType.numeric;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(THLineScaleCommandOptionType self) {
    switch (self) {
      case THLineScaleCommandOptionType.multiplechoice:
        return 'multiplechoice';
      case THLineScaleCommandOptionType.text:
        return 'text';
      case THLineScaleCommandOptionType.numeric:
        return 'numeric';
    }
  }
}

extension THLineScaleCommandOptionTypeMapperExtension
    on THLineScaleCommandOptionType {
  String toValue() {
    THLineScaleCommandOptionTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<THLineScaleCommandOptionType>(this)
        as String;
  }
}

class THLineScaleCommandOptionMapper
    extends ClassMapperBase<THLineScaleCommandOption> {
  THLineScaleCommandOptionMapper._();

  static THLineScaleCommandOptionMapper? _instance;
  static THLineScaleCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THLineScaleCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THFileMapper.ensureInitialized();
      THMultipleChoicePartMapper.ensureInitialized();
      THDoublePartMapper.ensureInitialized();
      THLineScaleCommandOptionTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THLineScaleCommandOption';

  static THFile _$thFile(THLineScaleCommandOption v) => v.thFile;
  static const Field<THLineScaleCommandOption, THFile> _f$thFile =
      Field('thFile', _$thFile);
  static int _$parentMapiahID(THLineScaleCommandOption v) => v.parentMapiahID;
  static const Field<THLineScaleCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THLineScaleCommandOption v) => v.optionType;
  static const Field<THLineScaleCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static THMultipleChoicePart _$multipleChoiceSize(
          THLineScaleCommandOption v) =>
      v.multipleChoiceSize;
  static const Field<THLineScaleCommandOption, THMultipleChoicePart>
      _f$multipleChoiceSize = Field('multipleChoiceSize', _$multipleChoiceSize);
  static THDoublePart _$numericSize(THLineScaleCommandOption v) =>
      v.numericSize;
  static const Field<THLineScaleCommandOption, THDoublePart> _f$numericSize =
      Field('numericSize', _$numericSize);
  static THLineScaleCommandOptionType _$type(THLineScaleCommandOption v) =>
      v.type;
  static const Field<THLineScaleCommandOption, THLineScaleCommandOptionType>
      _f$type = Field('type', _$type);
  static String _$textSize(THLineScaleCommandOption v) => v.textSize;
  static const Field<THLineScaleCommandOption, String> _f$textSize =
      Field('textSize', _$textSize);

  @override
  final MappableFields<THLineScaleCommandOption> fields = const {
    #thFile: _f$thFile,
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #multipleChoiceSize: _f$multipleChoiceSize,
    #numericSize: _f$numericSize,
    #type: _f$type,
    #textSize: _f$textSize,
  };

  static THLineScaleCommandOption _instantiate(DecodingData data) {
    return THLineScaleCommandOption.withExplicitOptionType(
        data.dec(_f$thFile),
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$multipleChoiceSize),
        data.dec(_f$numericSize),
        data.dec(_f$type),
        data.dec(_f$textSize));
  }

  @override
  final Function instantiate = _instantiate;

  static THLineScaleCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THLineScaleCommandOption>(map);
  }

  static THLineScaleCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THLineScaleCommandOption>(json);
  }
}

mixin THLineScaleCommandOptionMappable {
  String toJson() {
    return THLineScaleCommandOptionMapper.ensureInitialized()
        .encodeJson<THLineScaleCommandOption>(this as THLineScaleCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THLineScaleCommandOptionMapper.ensureInitialized()
        .encodeMap<THLineScaleCommandOption>(this as THLineScaleCommandOption);
  }

  THLineScaleCommandOptionCopyWith<THLineScaleCommandOption,
          THLineScaleCommandOption, THLineScaleCommandOption>
      get copyWith => _THLineScaleCommandOptionCopyWithImpl(
          this as THLineScaleCommandOption, $identity, $identity);
  @override
  String toString() {
    return THLineScaleCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THLineScaleCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THLineScaleCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THLineScaleCommandOption, other);
  }

  @override
  int get hashCode {
    return THLineScaleCommandOptionMapper.ensureInitialized()
        .hashValue(this as THLineScaleCommandOption);
  }
}

extension THLineScaleCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THLineScaleCommandOption, $Out> {
  THLineScaleCommandOptionCopyWith<$R, THLineScaleCommandOption, $Out>
      get $asTHLineScaleCommandOption => $base
          .as((v, t, t2) => _THLineScaleCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THLineScaleCommandOptionCopyWith<
    $R,
    $In extends THLineScaleCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile;
  THMultipleChoicePartCopyWith<$R, THMultipleChoicePart, THMultipleChoicePart>
      get multipleChoiceSize;
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get numericSize;
  @override
  $R call(
      {THFile? thFile,
      int? parentMapiahID,
      String? optionType,
      THMultipleChoicePart? multipleChoiceSize,
      THDoublePart? numericSize,
      THLineScaleCommandOptionType? type,
      String? textSize});
  THLineScaleCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THLineScaleCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THLineScaleCommandOption, $Out>
    implements
        THLineScaleCommandOptionCopyWith<$R, THLineScaleCommandOption, $Out> {
  _THLineScaleCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THLineScaleCommandOption> $mapper =
      THLineScaleCommandOptionMapper.ensureInitialized();
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile =>
      $value.thFile.copyWith.$chain((v) => call(thFile: v));
  @override
  THMultipleChoicePartCopyWith<$R, THMultipleChoicePart, THMultipleChoicePart>
      get multipleChoiceSize => $value.multipleChoiceSize.copyWith
          .$chain((v) => call(multipleChoiceSize: v));
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get numericSize =>
      $value.numericSize.copyWith.$chain((v) => call(numericSize: v));
  @override
  $R call(
          {THFile? thFile,
          int? parentMapiahID,
          String? optionType,
          THMultipleChoicePart? multipleChoiceSize,
          THDoublePart? numericSize,
          THLineScaleCommandOptionType? type,
          String? textSize}) =>
      $apply(FieldCopyWithData({
        if (thFile != null) #thFile: thFile,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (multipleChoiceSize != null) #multipleChoiceSize: multipleChoiceSize,
        if (numericSize != null) #numericSize: numericSize,
        if (type != null) #type: type,
        if (textSize != null) #textSize: textSize
      }));
  @override
  THLineScaleCommandOption $make(CopyWithData data) =>
      THLineScaleCommandOption.withExplicitOptionType(
          data.get(#thFile, or: $value.thFile),
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#multipleChoiceSize, or: $value.multipleChoiceSize),
          data.get(#numericSize, or: $value.numericSize),
          data.get(#type, or: $value.type),
          data.get(#textSize, or: $value.textSize));

  @override
  THLineScaleCommandOptionCopyWith<$R2, THLineScaleCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THLineScaleCommandOptionCopyWithImpl($value, $cast, t);
}
