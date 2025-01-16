// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_dist_command_option.dart';

class THDistCommandOptionMapper extends ClassMapperBase<THDistCommandOption> {
  THDistCommandOptionMapper._();

  static THDistCommandOptionMapper? _instance;
  static THDistCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THDistCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THDoublePartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THDistCommandOption';

  static int _$parentMapiahID(THDistCommandOption v) => v.parentMapiahID;
  static const Field<THDistCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THDistCommandOption v) => v.optionType;
  static const Field<THDistCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static THDoublePart _$length(THDistCommandOption v) => v.length;
  static const Field<THDistCommandOption, THDoublePart> _f$length =
      Field('length', _$length);
  static String _$unit(THDistCommandOption v) => v.unit;
  static const Field<THDistCommandOption, String> _f$unit =
      Field('unit', _$unit, opt: true);

  @override
  final MappableFields<THDistCommandOption> fields = const {
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #length: _f$length,
    #unit: _f$unit,
  };

  static THDistCommandOption _instantiate(DecodingData data) {
    return THDistCommandOption.withExplicitParameters(
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$length),
        data.dec(_f$unit));
  }

  @override
  final Function instantiate = _instantiate;

  static THDistCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THDistCommandOption>(map);
  }

  static THDistCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THDistCommandOption>(json);
  }
}

mixin THDistCommandOptionMappable {
  String toJson() {
    return THDistCommandOptionMapper.ensureInitialized()
        .encodeJson<THDistCommandOption>(this as THDistCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THDistCommandOptionMapper.ensureInitialized()
        .encodeMap<THDistCommandOption>(this as THDistCommandOption);
  }

  THDistCommandOptionCopyWith<THDistCommandOption, THDistCommandOption,
          THDistCommandOption>
      get copyWith => _THDistCommandOptionCopyWithImpl(
          this as THDistCommandOption, $identity, $identity);
  @override
  String toString() {
    return THDistCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THDistCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THDistCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THDistCommandOption, other);
  }

  @override
  int get hashCode {
    return THDistCommandOptionMapper.ensureInitialized()
        .hashValue(this as THDistCommandOption);
  }
}

extension THDistCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THDistCommandOption, $Out> {
  THDistCommandOptionCopyWith<$R, THDistCommandOption, $Out>
      get $asTHDistCommandOption =>
          $base.as((v, t, t2) => _THDistCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THDistCommandOptionCopyWith<$R, $In extends THDistCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get length;
  @override
  $R call(
      {int? parentMapiahID,
      String? optionType,
      THDoublePart? length,
      String? unit});
  THDistCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THDistCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THDistCommandOption, $Out>
    implements THDistCommandOptionCopyWith<$R, THDistCommandOption, $Out> {
  _THDistCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THDistCommandOption> $mapper =
      THDistCommandOptionMapper.ensureInitialized();
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get length =>
      $value.length.copyWith.$chain((v) => call(length: v));
  @override
  $R call(
          {int? parentMapiahID,
          String? optionType,
          THDoublePart? length,
          Object? unit = $none}) =>
      $apply(FieldCopyWithData({
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (length != null) #length: length,
        if (unit != $none) #unit: unit
      }));
  @override
  THDistCommandOption $make(CopyWithData data) =>
      THDistCommandOption.withExplicitParameters(
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#length, or: $value.length),
          data.get(#unit, or: $value.unit));

  @override
  THDistCommandOptionCopyWith<$R2, THDistCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THDistCommandOptionCopyWithImpl($value, $cast, t);
}
