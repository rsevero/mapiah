// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_altitude_command_option.dart';

class THAltitudeCommandOptionMapper
    extends ClassMapperBase<THAltitudeCommandOption> {
  THAltitudeCommandOptionMapper._();

  static THAltitudeCommandOptionMapper? _instance;
  static THAltitudeCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THAltitudeCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THAltitudeCommandOption';

  static THHasOptions _$optionParent(THAltitudeCommandOption v) =>
      v.optionParent;
  static const Field<THAltitudeCommandOption, THHasOptions> _f$optionParent =
      Field('optionParent', _$optionParent);
  static String _$optionType(THAltitudeCommandOption v) => v.optionType;
  static const Field<THAltitudeCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static THDoublePart _$length(THAltitudeCommandOption v) => v.length;
  static dynamic _arg$length(f) => f<THDoublePart>();
  static const Field<THAltitudeCommandOption, dynamic> _f$length =
      Field('length', _$length, arg: _arg$length);
  static bool _$isFix(THAltitudeCommandOption v) => v.isFix;
  static const Field<THAltitudeCommandOption, bool> _f$isFix =
      Field('isFix', _$isFix);
  static String _$unit(THAltitudeCommandOption v) => v.unit;
  static const Field<THAltitudeCommandOption, String> _f$unit =
      Field('unit', _$unit, opt: true);

  @override
  final MappableFields<THAltitudeCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #optionType: _f$optionType,
    #length: _f$length,
    #isFix: _f$isFix,
    #unit: _f$unit,
  };

  static THAltitudeCommandOption _instantiate(DecodingData data) {
    return THAltitudeCommandOption.withExplicitOptionType(
        data.dec(_f$optionParent),
        data.dec(_f$optionType),
        data.dec(_f$length),
        data.dec(_f$isFix),
        data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static THAltitudeCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THAltitudeCommandOption>(map);
  }

  static THAltitudeCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THAltitudeCommandOption>(json);
  }
}

mixin THAltitudeCommandOptionMappable {
  String toJson() {
    return THAltitudeCommandOptionMapper.ensureInitialized()
        .encodeJson<THAltitudeCommandOption>(this as THAltitudeCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THAltitudeCommandOptionMapper.ensureInitialized()
        .encodeMap<THAltitudeCommandOption>(this as THAltitudeCommandOption);
  }

  THAltitudeCommandOptionCopyWith<THAltitudeCommandOption,
          THAltitudeCommandOption, THAltitudeCommandOption>
      get copyWith => _THAltitudeCommandOptionCopyWithImpl(
          this as THAltitudeCommandOption, $identity, $identity);
  @override
  String toString() {
    return THAltitudeCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THAltitudeCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THAltitudeCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THAltitudeCommandOption, other);
  }

  @override
  int get hashCode {
    return THAltitudeCommandOptionMapper.ensureInitialized()
        .hashValue(this as THAltitudeCommandOption);
  }
}

extension THAltitudeCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THAltitudeCommandOption, $Out> {
  THAltitudeCommandOptionCopyWith<$R, THAltitudeCommandOption, $Out>
      get $asTHAltitudeCommandOption => $base
          .as((v, t, t2) => _THAltitudeCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THAltitudeCommandOptionCopyWith<
    $R,
    $In extends THAltitudeCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {THHasOptions? optionParent,
      String? optionType,
      dynamic length,
      bool? isFix,
      String? unit});
  THAltitudeCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THAltitudeCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THAltitudeCommandOption, $Out>
    implements
        THAltitudeCommandOptionCopyWith<$R, THAltitudeCommandOption, $Out> {
  _THAltitudeCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THAltitudeCommandOption> $mapper =
      THAltitudeCommandOptionMapper.ensureInitialized();
  @override
  $R call(
          {THHasOptions? optionParent,
          String? optionType,
          Object? length = $none,
          bool? isFix,
          Object? unit = $none}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (optionType != null) #optionType: optionType,
        if (length != $none) #length: length,
        if (isFix != null) #isFix: isFix,
        if (unit != $none) #unit: unit
      }));
  @override
  THAltitudeCommandOption $make(CopyWithData data) =>
      THAltitudeCommandOption.withExplicitOptionType(
          data.get(#optionParent, or: $value.optionParent),
          data.get(#optionType, or: $value.optionType),
          data.get(#length, or: $value.length),
          data.get(#isFix, or: $value.isFix),
          data.get(#unit, or: $value.unit));

  @override
  THAltitudeCommandOptionCopyWith<$R2, THAltitudeCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THAltitudeCommandOptionCopyWithImpl($value, $cast, t);
}
