// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_id_command_option.dart';

class THIDCommandOptionMapper extends ClassMapperBase<THIDCommandOption> {
  THIDCommandOptionMapper._();

  static THIDCommandOptionMapper? _instance;
  static THIDCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THIDCommandOptionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THIDCommandOption';

  static int _$parentMapiahID(THIDCommandOption v) => v.parentMapiahID;
  static dynamic _arg$parentMapiahID(f) => f<int>();
  static const Field<THIDCommandOption, dynamic> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, arg: _arg$parentMapiahID);
  static String _$optionType(THIDCommandOption v) => v.optionType;
  static dynamic _arg$optionType(f) => f<String>();
  static const Field<THIDCommandOption, dynamic> _f$optionType =
      Field('optionType', _$optionType, arg: _arg$optionType);
  static String _$thID(THIDCommandOption v) => v.thID;
  static const Field<THIDCommandOption, String> _f$thID = Field('thID', _$thID);

  @override
  final MappableFields<THIDCommandOption> fields = const {
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #thID: _f$thID,
  };

  static THIDCommandOption _instantiate(DecodingData data) {
    return THIDCommandOption.withExplicitParameters(data.dec(_f$parentMapiahID),
        data.dec(_f$optionType), data.dec(_f$thID));
  }

  @override
  final Function instantiate = _instantiate;

  static THIDCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THIDCommandOption>(map);
  }

  static THIDCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THIDCommandOption>(json);
  }
}

mixin THIDCommandOptionMappable {
  String toJson() {
    return THIDCommandOptionMapper.ensureInitialized()
        .encodeJson<THIDCommandOption>(this as THIDCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THIDCommandOptionMapper.ensureInitialized()
        .encodeMap<THIDCommandOption>(this as THIDCommandOption);
  }

  THIDCommandOptionCopyWith<THIDCommandOption, THIDCommandOption,
          THIDCommandOption>
      get copyWith => _THIDCommandOptionCopyWithImpl(
          this as THIDCommandOption, $identity, $identity);
  @override
  String toString() {
    return THIDCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THIDCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THIDCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THIDCommandOption, other);
  }

  @override
  int get hashCode {
    return THIDCommandOptionMapper.ensureInitialized()
        .hashValue(this as THIDCommandOption);
  }
}

extension THIDCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THIDCommandOption, $Out> {
  THIDCommandOptionCopyWith<$R, THIDCommandOption, $Out>
      get $asTHIDCommandOption =>
          $base.as((v, t, t2) => _THIDCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THIDCommandOptionCopyWith<$R, $In extends THIDCommandOption,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({dynamic parentMapiahID, dynamic optionType, String? thID});
  THIDCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THIDCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THIDCommandOption, $Out>
    implements THIDCommandOptionCopyWith<$R, THIDCommandOption, $Out> {
  _THIDCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THIDCommandOption> $mapper =
      THIDCommandOptionMapper.ensureInitialized();
  @override
  $R call(
          {Object? parentMapiahID = $none,
          Object? optionType = $none,
          String? thID}) =>
      $apply(FieldCopyWithData({
        if (parentMapiahID != $none) #parentMapiahID: parentMapiahID,
        if (optionType != $none) #optionType: optionType,
        if (thID != null) #thID: thID
      }));
  @override
  THIDCommandOption $make(CopyWithData data) =>
      THIDCommandOption.withExplicitParameters(
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#thID, or: $value.thID));

  @override
  THIDCommandOptionCopyWith<$R2, THIDCommandOption, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THIDCommandOptionCopyWithImpl($value, $cast, t);
}
