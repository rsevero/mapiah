// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_scrap_command_option.dart';

class THScrapCommandOptionMapper extends ClassMapperBase<THScrapCommandOption> {
  THScrapCommandOptionMapper._();

  static THScrapCommandOptionMapper? _instance;
  static THScrapCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THScrapCommandOptionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THScrapCommandOption';

  static int _$parentMapiahID(THScrapCommandOption v) => v.parentMapiahID;
  static dynamic _arg$parentMapiahID(f) => f<int>();
  static const Field<THScrapCommandOption, dynamic> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, arg: _arg$parentMapiahID);
  static String _$optionType(THScrapCommandOption v) => v.optionType;
  static dynamic _arg$optionType(f) => f<String>();
  static const Field<THScrapCommandOption, dynamic> _f$optionType =
      Field('optionType', _$optionType, arg: _arg$optionType);
  static String _$reference(THScrapCommandOption v) => v.reference;
  static const Field<THScrapCommandOption, String> _f$reference =
      Field('reference', _$reference);

  @override
  final MappableFields<THScrapCommandOption> fields = const {
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #reference: _f$reference,
  };

  static THScrapCommandOption _instantiate(DecodingData data) {
    return THScrapCommandOption.withExplicitParameters(
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$reference));
  }

  @override
  final Function instantiate = _instantiate;

  static THScrapCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THScrapCommandOption>(map);
  }

  static THScrapCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THScrapCommandOption>(json);
  }
}

mixin THScrapCommandOptionMappable {
  String toJson() {
    return THScrapCommandOptionMapper.ensureInitialized()
        .encodeJson<THScrapCommandOption>(this as THScrapCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THScrapCommandOptionMapper.ensureInitialized()
        .encodeMap<THScrapCommandOption>(this as THScrapCommandOption);
  }

  THScrapCommandOptionCopyWith<THScrapCommandOption, THScrapCommandOption,
          THScrapCommandOption>
      get copyWith => _THScrapCommandOptionCopyWithImpl(
          this as THScrapCommandOption, $identity, $identity);
  @override
  String toString() {
    return THScrapCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THScrapCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THScrapCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THScrapCommandOption, other);
  }

  @override
  int get hashCode {
    return THScrapCommandOptionMapper.ensureInitialized()
        .hashValue(this as THScrapCommandOption);
  }
}

extension THScrapCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THScrapCommandOption, $Out> {
  THScrapCommandOptionCopyWith<$R, THScrapCommandOption, $Out>
      get $asTHScrapCommandOption =>
          $base.as((v, t, t2) => _THScrapCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THScrapCommandOptionCopyWith<
    $R,
    $In extends THScrapCommandOption,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({dynamic parentMapiahID, dynamic optionType, String? reference});
  THScrapCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THScrapCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THScrapCommandOption, $Out>
    implements THScrapCommandOptionCopyWith<$R, THScrapCommandOption, $Out> {
  _THScrapCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THScrapCommandOption> $mapper =
      THScrapCommandOptionMapper.ensureInitialized();
  @override
  $R call(
          {Object? parentMapiahID = $none,
          Object? optionType = $none,
          String? reference}) =>
      $apply(FieldCopyWithData({
        if (parentMapiahID != $none) #parentMapiahID: parentMapiahID,
        if (optionType != $none) #optionType: optionType,
        if (reference != null) #reference: reference
      }));
  @override
  THScrapCommandOption $make(CopyWithData data) =>
      THScrapCommandOption.withExplicitParameters(
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#reference, or: $value.reference));

  @override
  THScrapCommandOptionCopyWith<$R2, THScrapCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THScrapCommandOptionCopyWithImpl($value, $cast, t);
}
