// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_point_scale_command_option.dart';

class THPointScaleCommandOptionMapper
    extends ClassMapperBase<THPointScaleCommandOption> {
  THPointScaleCommandOptionMapper._();

  static THPointScaleCommandOptionMapper? _instance;
  static THPointScaleCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THPointScaleCommandOptionMapper._());
      THMultipleChoicePartMapper.ensureInitialized();
      THDoublePartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THPointScaleCommandOption';

  static int _$parentMapiahID(THPointScaleCommandOption v) => v.parentMapiahID;
  static dynamic _arg$parentMapiahID(f) => f<int>();
  static const Field<THPointScaleCommandOption, dynamic> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, arg: _arg$parentMapiahID);
  static String _$optionType(THPointScaleCommandOption v) => v.optionType;
  static dynamic _arg$optionType(f) => f<String>();
  static const Field<THPointScaleCommandOption, dynamic> _f$optionType =
      Field('optionType', _$optionType, arg: _arg$optionType);
  static THMultipleChoicePart _$_multipleChoiceSize(
          THPointScaleCommandOption v) =>
      v._multipleChoiceSize;
  static const Field<THPointScaleCommandOption, THMultipleChoicePart>
      _f$_multipleChoiceSize = Field(
          '_multipleChoiceSize', _$_multipleChoiceSize,
          key: 'multipleChoiceSize');
  static THDoublePart _$_numericSize(THPointScaleCommandOption v) =>
      v._numericSize;
  static const Field<THPointScaleCommandOption, THDoublePart> _f$_numericSize =
      Field('_numericSize', _$_numericSize, key: 'numericSize');
  static bool _$_isNumeric(THPointScaleCommandOption v) => v._isNumeric;
  static const Field<THPointScaleCommandOption, bool> _f$_isNumeric =
      Field('_isNumeric', _$_isNumeric, key: 'isNumeric');

  @override
  final MappableFields<THPointScaleCommandOption> fields = const {
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #_multipleChoiceSize: _f$_multipleChoiceSize,
    #_numericSize: _f$_numericSize,
    #_isNumeric: _f$_isNumeric,
  };

  static THPointScaleCommandOption _instantiate(DecodingData data) {
    return THPointScaleCommandOption.withExplicitParameters(
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$_multipleChoiceSize),
        data.dec(_f$_numericSize),
        data.dec(_f$_isNumeric));
  }

  @override
  final Function instantiate = _instantiate;

  static THPointScaleCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THPointScaleCommandOption>(map);
  }

  static THPointScaleCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THPointScaleCommandOption>(json);
  }
}

mixin THPointScaleCommandOptionMappable {
  String toJson() {
    return THPointScaleCommandOptionMapper.ensureInitialized()
        .encodeJson<THPointScaleCommandOption>(
            this as THPointScaleCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THPointScaleCommandOptionMapper.ensureInitialized()
        .encodeMap<THPointScaleCommandOption>(
            this as THPointScaleCommandOption);
  }

  THPointScaleCommandOptionCopyWith<THPointScaleCommandOption,
          THPointScaleCommandOption, THPointScaleCommandOption>
      get copyWith => _THPointScaleCommandOptionCopyWithImpl(
          this as THPointScaleCommandOption, $identity, $identity);
  @override
  String toString() {
    return THPointScaleCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THPointScaleCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THPointScaleCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THPointScaleCommandOption, other);
  }

  @override
  int get hashCode {
    return THPointScaleCommandOptionMapper.ensureInitialized()
        .hashValue(this as THPointScaleCommandOption);
  }
}

extension THPointScaleCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THPointScaleCommandOption, $Out> {
  THPointScaleCommandOptionCopyWith<$R, THPointScaleCommandOption, $Out>
      get $asTHPointScaleCommandOption => $base
          .as((v, t, t2) => _THPointScaleCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THPointScaleCommandOptionCopyWith<
    $R,
    $In extends THPointScaleCommandOption,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  THMultipleChoicePartCopyWith<$R, THMultipleChoicePart, THMultipleChoicePart>
      get _multipleChoiceSize;
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get _numericSize;
  $R call(
      {dynamic parentMapiahID,
      dynamic optionType,
      THMultipleChoicePart? multipleChoiceSize,
      THDoublePart? numericSize,
      bool? isNumeric});
  THPointScaleCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THPointScaleCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THPointScaleCommandOption, $Out>
    implements
        THPointScaleCommandOptionCopyWith<$R, THPointScaleCommandOption, $Out> {
  _THPointScaleCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THPointScaleCommandOption> $mapper =
      THPointScaleCommandOptionMapper.ensureInitialized();
  @override
  THMultipleChoicePartCopyWith<$R, THMultipleChoicePart, THMultipleChoicePart>
      get _multipleChoiceSize => $value._multipleChoiceSize.copyWith
          .$chain((v) => call(multipleChoiceSize: v));
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get _numericSize =>
      $value._numericSize.copyWith.$chain((v) => call(numericSize: v));
  @override
  $R call(
          {Object? parentMapiahID = $none,
          Object? optionType = $none,
          THMultipleChoicePart? multipleChoiceSize,
          THDoublePart? numericSize,
          bool? isNumeric}) =>
      $apply(FieldCopyWithData({
        if (parentMapiahID != $none) #parentMapiahID: parentMapiahID,
        if (optionType != $none) #optionType: optionType,
        if (multipleChoiceSize != null) #multipleChoiceSize: multipleChoiceSize,
        if (numericSize != null) #numericSize: numericSize,
        if (isNumeric != null) #isNumeric: isNumeric
      }));
  @override
  THPointScaleCommandOption $make(CopyWithData data) =>
      THPointScaleCommandOption.withExplicitParameters(
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#multipleChoiceSize, or: $value._multipleChoiceSize),
          data.get(#numericSize, or: $value._numericSize),
          data.get(#isNumeric, or: $value._isNumeric));

  @override
  THPointScaleCommandOptionCopyWith<$R2, THPointScaleCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THPointScaleCommandOptionCopyWithImpl($value, $cast, t);
}
