// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_point_height_value_command_option.dart';

class THPointHeightValueCommandOptionMapper
    extends ClassMapperBase<THPointHeightValueCommandOption> {
  THPointHeightValueCommandOptionMapper._();

  static THPointHeightValueCommandOptionMapper? _instance;
  static THPointHeightValueCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THPointHeightValueCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THDoublePartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THPointHeightValueCommandOption';

  static THHasOptions _$optionParent(THPointHeightValueCommandOption v) =>
      v.optionParent;
  static const Field<THPointHeightValueCommandOption, THHasOptions>
      _f$optionParent = Field('optionParent', _$optionParent);
  static THDoublePart _$length(THPointHeightValueCommandOption v) => v.length;
  static const Field<THPointHeightValueCommandOption, THDoublePart> _f$length =
      Field('length', _$length);
  static bool _$isPresumed(THPointHeightValueCommandOption v) => v.isPresumed;
  static const Field<THPointHeightValueCommandOption, bool> _f$isPresumed =
      Field('isPresumed', _$isPresumed);
  static String _$unit(THPointHeightValueCommandOption v) => v.unit;
  static const Field<THPointHeightValueCommandOption, String> _f$unit =
      Field('unit', _$unit, opt: true);

  @override
  final MappableFields<THPointHeightValueCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #length: _f$length,
    #isPresumed: _f$isPresumed,
    #unit: _f$unit,
  };

  static THPointHeightValueCommandOption _instantiate(DecodingData data) {
    return THPointHeightValueCommandOption(data.dec(_f$optionParent),
        data.dec(_f$length), data.dec(_f$isPresumed), data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static THPointHeightValueCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THPointHeightValueCommandOption>(map);
  }

  static THPointHeightValueCommandOption fromJson(String json) {
    return ensureInitialized()
        .decodeJson<THPointHeightValueCommandOption>(json);
  }
}

mixin THPointHeightValueCommandOptionMappable {
  String toJson() {
    return THPointHeightValueCommandOptionMapper.ensureInitialized()
        .encodeJson<THPointHeightValueCommandOption>(
            this as THPointHeightValueCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THPointHeightValueCommandOptionMapper.ensureInitialized()
        .encodeMap<THPointHeightValueCommandOption>(
            this as THPointHeightValueCommandOption);
  }

  THPointHeightValueCommandOptionCopyWith<THPointHeightValueCommandOption,
          THPointHeightValueCommandOption, THPointHeightValueCommandOption>
      get copyWith => _THPointHeightValueCommandOptionCopyWithImpl(
          this as THPointHeightValueCommandOption, $identity, $identity);
  @override
  String toString() {
    return THPointHeightValueCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THPointHeightValueCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THPointHeightValueCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THPointHeightValueCommandOption, other);
  }

  @override
  int get hashCode {
    return THPointHeightValueCommandOptionMapper.ensureInitialized()
        .hashValue(this as THPointHeightValueCommandOption);
  }
}

extension THPointHeightValueCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THPointHeightValueCommandOption, $Out> {
  THPointHeightValueCommandOptionCopyWith<$R, THPointHeightValueCommandOption,
          $Out>
      get $asTHPointHeightValueCommandOption => $base.as(
          (v, t, t2) => _THPointHeightValueCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THPointHeightValueCommandOptionCopyWith<
    $R,
    $In extends THPointHeightValueCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get length;
  @override
  $R call(
      {THHasOptions? optionParent,
      THDoublePart? length,
      bool? isPresumed,
      String? unit});
  THPointHeightValueCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THPointHeightValueCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THPointHeightValueCommandOption, $Out>
    implements
        THPointHeightValueCommandOptionCopyWith<$R,
            THPointHeightValueCommandOption, $Out> {
  _THPointHeightValueCommandOptionCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THPointHeightValueCommandOption> $mapper =
      THPointHeightValueCommandOptionMapper.ensureInitialized();
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get length =>
      $value.length.copyWith.$chain((v) => call(length: v));
  @override
  $R call(
          {THHasOptions? optionParent,
          THDoublePart? length,
          bool? isPresumed,
          Object? unit = $none}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (length != null) #length: length,
        if (isPresumed != null) #isPresumed: isPresumed,
        if (unit != $none) #unit: unit
      }));
  @override
  THPointHeightValueCommandOption $make(CopyWithData data) =>
      THPointHeightValueCommandOption(
          data.get(#optionParent, or: $value.optionParent),
          data.get(#length, or: $value.length),
          data.get(#isPresumed, or: $value.isPresumed),
          data.get(#unit, or: $value.unit));

  @override
  THPointHeightValueCommandOptionCopyWith<$R2, THPointHeightValueCommandOption,
      $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THPointHeightValueCommandOptionCopyWithImpl($value, $cast, t);
}
