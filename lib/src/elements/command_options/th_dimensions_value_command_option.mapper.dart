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
      THDoublePartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THDimensionsValueCommandOption';

  static THHasOptions _$optionParent(THDimensionsValueCommandOption v) =>
      v.optionParent;
  static const Field<THDimensionsValueCommandOption, THHasOptions>
      _f$optionParent = Field('optionParent', _$optionParent);
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
    #optionParent: _f$optionParent,
    #above: _f$above,
    #below: _f$below,
    #unit: _f$unit,
    #unitSet: _f$unitSet,
  };

  static THDimensionsValueCommandOption _instantiate(DecodingData data) {
    return THDimensionsValueCommandOption(data.dec(_f$optionParent),
        data.dec(_f$above), data.dec(_f$below), data.dec(_f$unit));
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
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get above;
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get below;
  @override
  $R call(
      {THHasOptions? optionParent,
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
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get above =>
      $value.above.copyWith.$chain((v) => call(above: v));
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get below =>
      $value.below.copyWith.$chain((v) => call(below: v));
  @override
  $R call(
          {THHasOptions? optionParent,
          THDoublePart? above,
          THDoublePart? below,
          Object? unit = $none}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (above != null) #above: above,
        if (below != null) #below: below,
        if (unit != $none) #unit: unit
      }));
  @override
  THDimensionsValueCommandOption $make(CopyWithData data) =>
      THDimensionsValueCommandOption(
          data.get(#optionParent, or: $value.optionParent),
          data.get(#above, or: $value.above),
          data.get(#below, or: $value.below),
          data.get(#unit, or: $value.unit));

  @override
  THDimensionsValueCommandOptionCopyWith<$R2, THDimensionsValueCommandOption,
      $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THDimensionsValueCommandOptionCopyWithImpl($value, $cast, t);
}
