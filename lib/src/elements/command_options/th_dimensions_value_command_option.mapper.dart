// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_dimensions_value_command_option.dart';

class THDimensionsValueCommandOptionMapper
    extends ClassMapperBase<THDimensionsValueCommandOption> {
  THDimensionsValueCommandOptionMapper._();

  static THDimensionsValueCommandOptionMapper? _instance;
  static THDimensionsValueCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THDimensionsValueCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THFileMapper.ensureInitialized();
      THDoublePartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THDimensionsValueCommandOption';

  static THFile _$thFile(THDimensionsValueCommandOption v) => v.thFile;
  static const Field<THDimensionsValueCommandOption, THFile> _f$thFile =
      Field('thFile', _$thFile);
  static int _$parentMapiahID(THDimensionsValueCommandOption v) =>
      v.parentMapiahID;
  static const Field<THDimensionsValueCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THDimensionsValueCommandOption v) => v.optionType;
  static const Field<THDimensionsValueCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static THDoublePart _$above(THDimensionsValueCommandOption v) => v.above;
  static const Field<THDimensionsValueCommandOption, THDoublePart> _f$above =
      Field('above', _$above);
  static THDoublePart _$below(THDimensionsValueCommandOption v) => v.below;
  static const Field<THDimensionsValueCommandOption, THDoublePart> _f$below =
      Field('below', _$below);
  static String _$unit(THDimensionsValueCommandOption v) => v.unit;
  static const Field<THDimensionsValueCommandOption, String> _f$unit =
      Field('unit', _$unit, opt: true);
  static bool _$unitSet(THDimensionsValueCommandOption v) => v.unitSet;
  static const Field<THDimensionsValueCommandOption, bool> _f$unitSet =
      Field('unitSet', _$unitSet, mode: FieldMode.member);

  @override
  final MappableFields<THDimensionsValueCommandOption> fields = const {
    #thFile: _f$thFile,
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #above: _f$above,
    #below: _f$below,
    #unit: _f$unit,
    #unitSet: _f$unitSet,
  };

  static THDimensionsValueCommandOption _instantiate(DecodingData data) {
    return THDimensionsValueCommandOption.withExplicitParameters(
        data.dec(_f$thFile),
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$above),
        data.dec(_f$below),
        data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static THDimensionsValueCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THDimensionsValueCommandOption>(map);
  }

  static THDimensionsValueCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THDimensionsValueCommandOption>(json);
  }
}

mixin THDimensionsValueCommandOptionMappable {
  String toJson() {
    return THDimensionsValueCommandOptionMapper.ensureInitialized()
        .encodeJson<THDimensionsValueCommandOption>(
            this as THDimensionsValueCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THDimensionsValueCommandOptionMapper.ensureInitialized()
        .encodeMap<THDimensionsValueCommandOption>(
            this as THDimensionsValueCommandOption);
  }

  THDimensionsValueCommandOptionCopyWith<THDimensionsValueCommandOption,
          THDimensionsValueCommandOption, THDimensionsValueCommandOption>
      get copyWith => _THDimensionsValueCommandOptionCopyWithImpl(
          this as THDimensionsValueCommandOption, $identity, $identity);
  @override
  String toString() {
    return THDimensionsValueCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THDimensionsValueCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THDimensionsValueCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THDimensionsValueCommandOption, other);
  }

  @override
  int get hashCode {
    return THDimensionsValueCommandOptionMapper.ensureInitialized()
        .hashValue(this as THDimensionsValueCommandOption);
  }
}

extension THDimensionsValueCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THDimensionsValueCommandOption, $Out> {
  THDimensionsValueCommandOptionCopyWith<$R, THDimensionsValueCommandOption,
          $Out>
      get $asTHDimensionsValueCommandOption => $base.as(
          (v, t, t2) => _THDimensionsValueCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THDimensionsValueCommandOptionCopyWith<
    $R,
    $In extends THDimensionsValueCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile;
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get above;
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get below;
  @override
  $R call(
      {THFile? thFile,
      int? parentMapiahID,
      String? optionType,
      THDoublePart? above,
      THDoublePart? below,
      String? unit});
  THDimensionsValueCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THDimensionsValueCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THDimensionsValueCommandOption, $Out>
    implements
        THDimensionsValueCommandOptionCopyWith<$R,
            THDimensionsValueCommandOption, $Out> {
  _THDimensionsValueCommandOptionCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THDimensionsValueCommandOption> $mapper =
      THDimensionsValueCommandOptionMapper.ensureInitialized();
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile =>
      $value.thFile.copyWith.$chain((v) => call(thFile: v));
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get above =>
      $value.above.copyWith.$chain((v) => call(above: v));
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get below =>
      $value.below.copyWith.$chain((v) => call(below: v));
  @override
  $R call(
          {THFile? thFile,
          int? parentMapiahID,
          String? optionType,
          THDoublePart? above,
          THDoublePart? below,
          Object? unit = $none}) =>
      $apply(FieldCopyWithData({
        if (thFile != null) #thFile: thFile,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (above != null) #above: above,
        if (below != null) #below: below,
        if (unit != $none) #unit: unit
      }));
  @override
  THDimensionsValueCommandOption $make(CopyWithData data) =>
      THDimensionsValueCommandOption.withExplicitParameters(
          data.get(#thFile, or: $value.thFile),
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#above, or: $value.above),
          data.get(#below, or: $value.below),
          data.get(#unit, or: $value.unit));

  @override
  THDimensionsValueCommandOptionCopyWith<$R2, THDimensionsValueCommandOption,
      $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THDimensionsValueCommandOptionCopyWithImpl($value, $cast, t);
}
