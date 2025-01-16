// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_context_command_option.dart';

class THContextCommandOptionMapper
    extends ClassMapperBase<THContextCommandOption> {
  THContextCommandOptionMapper._();

  static THContextCommandOptionMapper? _instance;
  static THContextCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THContextCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THContextCommandOption';

  static int _$parentMapiahID(THContextCommandOption v) => v.parentMapiahID;
  static const Field<THContextCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THContextCommandOption v) => v.optionType;
  static const Field<THContextCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static String _$elementType(THContextCommandOption v) => v.elementType;
  static const Field<THContextCommandOption, String> _f$elementType =
      Field('elementType', _$elementType);
  static String _$symbolType(THContextCommandOption v) => v.symbolType;
  static const Field<THContextCommandOption, String> _f$symbolType =
      Field('symbolType', _$symbolType);

  @override
  final MappableFields<THContextCommandOption> fields = const {
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #elementType: _f$elementType,
    #symbolType: _f$symbolType,
  };

  static THContextCommandOption _instantiate(DecodingData data) {
    return THContextCommandOption.withExplicitParameters(
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$elementType),
        data.dec(_f$symbolType));
  }

  @override
  final Function instantiate = _instantiate;

  static THContextCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THContextCommandOption>(map);
  }

  static THContextCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THContextCommandOption>(json);
  }
}

mixin THContextCommandOptionMappable {
  String toJson() {
    return THContextCommandOptionMapper.ensureInitialized()
        .encodeJson<THContextCommandOption>(this as THContextCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THContextCommandOptionMapper.ensureInitialized()
        .encodeMap<THContextCommandOption>(this as THContextCommandOption);
  }

  THContextCommandOptionCopyWith<THContextCommandOption, THContextCommandOption,
          THContextCommandOption>
      get copyWith => _THContextCommandOptionCopyWithImpl(
          this as THContextCommandOption, $identity, $identity);
  @override
  String toString() {
    return THContextCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THContextCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THContextCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THContextCommandOption, other);
  }

  @override
  int get hashCode {
    return THContextCommandOptionMapper.ensureInitialized()
        .hashValue(this as THContextCommandOption);
  }
}

extension THContextCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THContextCommandOption, $Out> {
  THContextCommandOptionCopyWith<$R, THContextCommandOption, $Out>
      get $asTHContextCommandOption =>
          $base.as((v, t, t2) => _THContextCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THContextCommandOptionCopyWith<
    $R,
    $In extends THContextCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {int? parentMapiahID,
      String? optionType,
      String? elementType,
      String? symbolType});
  THContextCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THContextCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THContextCommandOption, $Out>
    implements
        THContextCommandOptionCopyWith<$R, THContextCommandOption, $Out> {
  _THContextCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THContextCommandOption> $mapper =
      THContextCommandOptionMapper.ensureInitialized();
  @override
  $R call(
          {int? parentMapiahID,
          String? optionType,
          String? elementType,
          String? symbolType}) =>
      $apply(FieldCopyWithData({
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (elementType != null) #elementType: elementType,
        if (symbolType != null) #symbolType: symbolType
      }));
  @override
  THContextCommandOption $make(CopyWithData data) =>
      THContextCommandOption.withExplicitParameters(
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#elementType, or: $value.elementType),
          data.get(#symbolType, or: $value.symbolType));

  @override
  THContextCommandOptionCopyWith<$R2, THContextCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THContextCommandOptionCopyWithImpl($value, $cast, t);
}
