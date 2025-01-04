// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_explored_command_option.dart';

class THExploredCommandOptionMapper
    extends ClassMapperBase<THExploredCommandOption> {
  THExploredCommandOptionMapper._();

  static THExploredCommandOptionMapper? _instance;
  static THExploredCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THExploredCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THDoublePartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THExploredCommandOption';

  static THHasOptions _$optionParent(THExploredCommandOption v) =>
      v.optionParent;
  static const Field<THExploredCommandOption, THHasOptions> _f$optionParent =
      Field('optionParent', _$optionParent);
  static String _$optionType(THExploredCommandOption v) => v.optionType;
  static const Field<THExploredCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static THDoublePart _$length(THExploredCommandOption v) => v.length;
  static const Field<THExploredCommandOption, THDoublePart> _f$length =
      Field('length', _$length);
  static String _$unit(THExploredCommandOption v) => v.unit;
  static const Field<THExploredCommandOption, String> _f$unit =
      Field('unit', _$unit, opt: true);

  @override
  final MappableFields<THExploredCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #optionType: _f$optionType,
    #length: _f$length,
    #unit: _f$unit,
  };

  static THExploredCommandOption _instantiate(DecodingData data) {
    return THExploredCommandOption.withExplicitOptionType(
        data.dec(_f$optionParent),
        data.dec(_f$optionType),
        data.dec(_f$length),
        data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static THExploredCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THExploredCommandOption>(map);
  }

  static THExploredCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THExploredCommandOption>(json);
  }
}

mixin THExploredCommandOptionMappable {
  String toJson() {
    return THExploredCommandOptionMapper.ensureInitialized()
        .encodeJson<THExploredCommandOption>(this as THExploredCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THExploredCommandOptionMapper.ensureInitialized()
        .encodeMap<THExploredCommandOption>(this as THExploredCommandOption);
  }

  THExploredCommandOptionCopyWith<THExploredCommandOption,
          THExploredCommandOption, THExploredCommandOption>
      get copyWith => _THExploredCommandOptionCopyWithImpl(
          this as THExploredCommandOption, $identity, $identity);
  @override
  String toString() {
    return THExploredCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THExploredCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THExploredCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THExploredCommandOption, other);
  }

  @override
  int get hashCode {
    return THExploredCommandOptionMapper.ensureInitialized()
        .hashValue(this as THExploredCommandOption);
  }
}

extension THExploredCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THExploredCommandOption, $Out> {
  THExploredCommandOptionCopyWith<$R, THExploredCommandOption, $Out>
      get $asTHExploredCommandOption => $base
          .as((v, t, t2) => _THExploredCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THExploredCommandOptionCopyWith<
    $R,
    $In extends THExploredCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get length;
  @override
  $R call(
      {THHasOptions? optionParent,
      String? optionType,
      THDoublePart? length,
      String? unit});
  THExploredCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THExploredCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THExploredCommandOption, $Out>
    implements
        THExploredCommandOptionCopyWith<$R, THExploredCommandOption, $Out> {
  _THExploredCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THExploredCommandOption> $mapper =
      THExploredCommandOptionMapper.ensureInitialized();
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get length =>
      $value.length.copyWith.$chain((v) => call(length: v));
  @override
  $R call(
          {THHasOptions? optionParent,
          String? optionType,
          THDoublePart? length,
          Object? unit = $none}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (optionType != null) #optionType: optionType,
        if (length != null) #length: length,
        if (unit != $none) #unit: unit
      }));
  @override
  THExploredCommandOption $make(CopyWithData data) =>
      THExploredCommandOption.withExplicitOptionType(
          data.get(#optionParent, or: $value.optionParent),
          data.get(#optionType, or: $value.optionType),
          data.get(#length, or: $value.length),
          data.get(#unit, or: $value.unit));

  @override
  THExploredCommandOptionCopyWith<$R2, THExploredCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THExploredCommandOptionCopyWithImpl($value, $cast, t);
}
