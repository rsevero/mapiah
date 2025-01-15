// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_scrap_scale_command_option.dart';

class THScrapScaleCommandOptionMapper
    extends ClassMapperBase<THScrapScaleCommandOption> {
  THScrapScaleCommandOptionMapper._();

  static THScrapScaleCommandOptionMapper? _instance;
  static THScrapScaleCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THScrapScaleCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THFileMapper.ensureInitialized();
      THDoublePartMapper.ensureInitialized();
      THLengthUnitPartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THScrapScaleCommandOption';

  static THFile _$thFile(THScrapScaleCommandOption v) => v.thFile;
  static const Field<THScrapScaleCommandOption, THFile> _f$thFile =
      Field('thFile', _$thFile);
  static int _$parentMapiahID(THScrapScaleCommandOption v) => v.parentMapiahID;
  static const Field<THScrapScaleCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THScrapScaleCommandOption v) => v.optionType;
  static const Field<THScrapScaleCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static List<THDoublePart> _$_numericSpecifications(
          THScrapScaleCommandOption v) =>
      v._numericSpecifications;
  static const Field<THScrapScaleCommandOption, List<THDoublePart>>
      _f$_numericSpecifications = Field(
          '_numericSpecifications', _$_numericSpecifications,
          key: 'numericSpecifications');
  static THLengthUnitPart? _$unit(THScrapScaleCommandOption v) => v.unit;
  static const Field<THScrapScaleCommandOption, THLengthUnitPart> _f$unit =
      Field('unit', _$unit, opt: true);

  @override
  final MappableFields<THScrapScaleCommandOption> fields = const {
    #thFile: _f$thFile,
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #_numericSpecifications: _f$_numericSpecifications,
    #unit: _f$unit,
  };

  static THScrapScaleCommandOption _instantiate(DecodingData data) {
    return THScrapScaleCommandOption.withExplicitParameters(
        data.dec(_f$thFile),
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$_numericSpecifications),
        data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static THScrapScaleCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THScrapScaleCommandOption>(map);
  }

  static THScrapScaleCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THScrapScaleCommandOption>(json);
  }
}

mixin THScrapScaleCommandOptionMappable {
  String toJson() {
    return THScrapScaleCommandOptionMapper.ensureInitialized()
        .encodeJson<THScrapScaleCommandOption>(
            this as THScrapScaleCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THScrapScaleCommandOptionMapper.ensureInitialized()
        .encodeMap<THScrapScaleCommandOption>(
            this as THScrapScaleCommandOption);
  }

  THScrapScaleCommandOptionCopyWith<THScrapScaleCommandOption,
          THScrapScaleCommandOption, THScrapScaleCommandOption>
      get copyWith => _THScrapScaleCommandOptionCopyWithImpl(
          this as THScrapScaleCommandOption, $identity, $identity);
  @override
  String toString() {
    return THScrapScaleCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THScrapScaleCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THScrapScaleCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THScrapScaleCommandOption, other);
  }

  @override
  int get hashCode {
    return THScrapScaleCommandOptionMapper.ensureInitialized()
        .hashValue(this as THScrapScaleCommandOption);
  }
}

extension THScrapScaleCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THScrapScaleCommandOption, $Out> {
  THScrapScaleCommandOptionCopyWith<$R, THScrapScaleCommandOption, $Out>
      get $asTHScrapScaleCommandOption => $base
          .as((v, t, t2) => _THScrapScaleCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THScrapScaleCommandOptionCopyWith<
    $R,
    $In extends THScrapScaleCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile;
  ListCopyWith<$R, THDoublePart,
          THDoublePartCopyWith<$R, THDoublePart, THDoublePart>>
      get _numericSpecifications;
  THLengthUnitPartCopyWith<$R, THLengthUnitPart, THLengthUnitPart>? get unit;
  @override
  $R call(
      {THFile? thFile,
      int? parentMapiahID,
      String? optionType,
      List<THDoublePart>? numericSpecifications,
      THLengthUnitPart? unit});
  THScrapScaleCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THScrapScaleCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THScrapScaleCommandOption, $Out>
    implements
        THScrapScaleCommandOptionCopyWith<$R, THScrapScaleCommandOption, $Out> {
  _THScrapScaleCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THScrapScaleCommandOption> $mapper =
      THScrapScaleCommandOptionMapper.ensureInitialized();
  @override
  THFileCopyWith<$R, THFile, THFile> get thFile =>
      $value.thFile.copyWith.$chain((v) => call(thFile: v));
  @override
  ListCopyWith<$R, THDoublePart,
          THDoublePartCopyWith<$R, THDoublePart, THDoublePart>>
      get _numericSpecifications => ListCopyWith(
          $value._numericSpecifications,
          (v, t) => v.copyWith.$chain(t),
          (v) => call(numericSpecifications: v));
  @override
  THLengthUnitPartCopyWith<$R, THLengthUnitPart, THLengthUnitPart>? get unit =>
      $value.unit?.copyWith.$chain((v) => call(unit: v));
  @override
  $R call(
          {THFile? thFile,
          int? parentMapiahID,
          String? optionType,
          List<THDoublePart>? numericSpecifications,
          Object? unit = $none}) =>
      $apply(FieldCopyWithData({
        if (thFile != null) #thFile: thFile,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (numericSpecifications != null)
          #numericSpecifications: numericSpecifications,
        if (unit != $none) #unit: unit
      }));
  @override
  THScrapScaleCommandOption $make(CopyWithData data) =>
      THScrapScaleCommandOption.withExplicitParameters(
          data.get(#thFile, or: $value.thFile),
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#numericSpecifications, or: $value._numericSpecifications),
          data.get(#unit, or: $value.unit));

  @override
  THScrapScaleCommandOptionCopyWith<$R2, THScrapScaleCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THScrapScaleCommandOptionCopyWithImpl($value, $cast, t);
}
