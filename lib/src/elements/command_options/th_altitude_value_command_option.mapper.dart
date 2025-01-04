// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_altitude_value_command_option.dart';

class THAltitudeValueCommandOptionMapper
    extends ClassMapperBase<THAltitudeValueCommandOption> {
  THAltitudeValueCommandOptionMapper._();

  static THAltitudeValueCommandOptionMapper? _instance;
  static THAltitudeValueCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THAltitudeValueCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THDoublePartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THAltitudeValueCommandOption';

  static THHasOptions _$optionParent(THAltitudeValueCommandOption v) =>
      v.optionParent;
  static const Field<THAltitudeValueCommandOption, THHasOptions>
      _f$optionParent = Field('optionParent', _$optionParent);
  static String _$optionType(THAltitudeValueCommandOption v) => v.optionType;
  static const Field<THAltitudeValueCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static THDoublePart _$length(THAltitudeValueCommandOption v) => v.length;
  static const Field<THAltitudeValueCommandOption, THDoublePart> _f$length =
      Field('length', _$length);
  static bool _$isFix(THAltitudeValueCommandOption v) => v.isFix;
  static const Field<THAltitudeValueCommandOption, bool> _f$isFix =
      Field('isFix', _$isFix);
  static String _$unit(THAltitudeValueCommandOption v) => v.unit;
  static const Field<THAltitudeValueCommandOption, String> _f$unit =
      Field('unit', _$unit, opt: true);

  @override
  final MappableFields<THAltitudeValueCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #optionType: _f$optionType,
    #length: _f$length,
    #isFix: _f$isFix,
    #unit: _f$unit,
  };

  static THAltitudeValueCommandOption _instantiate(DecodingData data) {
    return THAltitudeValueCommandOption.withExplicitOptionType(
        data.dec(_f$optionParent),
        data.dec(_f$optionType),
        data.dec(_f$length),
        data.dec(_f$isFix),
        data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static THAltitudeValueCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THAltitudeValueCommandOption>(map);
  }

  static THAltitudeValueCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THAltitudeValueCommandOption>(json);
  }
}

mixin THAltitudeValueCommandOptionMappable {
  String toJson() {
    return THAltitudeValueCommandOptionMapper.ensureInitialized()
        .encodeJson<THAltitudeValueCommandOption>(
            this as THAltitudeValueCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THAltitudeValueCommandOptionMapper.ensureInitialized()
        .encodeMap<THAltitudeValueCommandOption>(
            this as THAltitudeValueCommandOption);
  }

  THAltitudeValueCommandOptionCopyWith<THAltitudeValueCommandOption,
          THAltitudeValueCommandOption, THAltitudeValueCommandOption>
      get copyWith => _THAltitudeValueCommandOptionCopyWithImpl(
          this as THAltitudeValueCommandOption, $identity, $identity);
  @override
  String toString() {
    return THAltitudeValueCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THAltitudeValueCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THAltitudeValueCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THAltitudeValueCommandOption, other);
  }

  @override
  int get hashCode {
    return THAltitudeValueCommandOptionMapper.ensureInitialized()
        .hashValue(this as THAltitudeValueCommandOption);
  }
}

extension THAltitudeValueCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THAltitudeValueCommandOption, $Out> {
  THAltitudeValueCommandOptionCopyWith<$R, THAltitudeValueCommandOption, $Out>
      get $asTHAltitudeValueCommandOption => $base.as(
          (v, t, t2) => _THAltitudeValueCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THAltitudeValueCommandOptionCopyWith<
    $R,
    $In extends THAltitudeValueCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get length;
  @override
  $R call(
      {THHasOptions? optionParent,
      String? optionType,
      THDoublePart? length,
      bool? isFix,
      String? unit});
  THAltitudeValueCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THAltitudeValueCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THAltitudeValueCommandOption, $Out>
    implements
        THAltitudeValueCommandOptionCopyWith<$R, THAltitudeValueCommandOption,
            $Out> {
  _THAltitudeValueCommandOptionCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THAltitudeValueCommandOption> $mapper =
      THAltitudeValueCommandOptionMapper.ensureInitialized();
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get length =>
      $value.length.copyWith.$chain((v) => call(length: v));
  @override
  $R call(
          {THHasOptions? optionParent,
          String? optionType,
          THDoublePart? length,
          bool? isFix,
          Object? unit = $none}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (optionType != null) #optionType: optionType,
        if (length != null) #length: length,
        if (isFix != null) #isFix: isFix,
        if (unit != $none) #unit: unit
      }));
  @override
  THAltitudeValueCommandOption $make(CopyWithData data) =>
      THAltitudeValueCommandOption.withExplicitOptionType(
          data.get(#optionParent, or: $value.optionParent),
          data.get(#optionType, or: $value.optionType),
          data.get(#length, or: $value.length),
          data.get(#isFix, or: $value.isFix),
          data.get(#unit, or: $value.unit));

  @override
  THAltitudeValueCommandOptionCopyWith<$R2, THAltitudeValueCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THAltitudeValueCommandOptionCopyWithImpl($value, $cast, t);
}
