// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_extend_command_option.dart';

class THExtendCommandOptionMapper
    extends ClassMapperBase<THExtendCommandOption> {
  THExtendCommandOptionMapper._();

  static THExtendCommandOptionMapper? _instance;
  static THExtendCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THExtendCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THExtendCommandOption';

  static int _$parentMapiahID(THExtendCommandOption v) => v.parentMapiahID;
  static const Field<THExtendCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THExtendCommandOption v) => v.optionType;
  static const Field<THExtendCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static String _$station(THExtendCommandOption v) => v.station;
  static const Field<THExtendCommandOption, String> _f$station =
      Field('station', _$station);

  @override
  final MappableFields<THExtendCommandOption> fields = const {
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #station: _f$station,
  };

  static THExtendCommandOption _instantiate(DecodingData data) {
    return THExtendCommandOption.withExplicitParameters(
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$station));
  }

  @override
  final Function instantiate = _instantiate;

  static THExtendCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THExtendCommandOption>(map);
  }

  static THExtendCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THExtendCommandOption>(json);
  }
}

mixin THExtendCommandOptionMappable {
  String toJson() {
    return THExtendCommandOptionMapper.ensureInitialized()
        .encodeJson<THExtendCommandOption>(this as THExtendCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THExtendCommandOptionMapper.ensureInitialized()
        .encodeMap<THExtendCommandOption>(this as THExtendCommandOption);
  }

  THExtendCommandOptionCopyWith<THExtendCommandOption, THExtendCommandOption,
          THExtendCommandOption>
      get copyWith => _THExtendCommandOptionCopyWithImpl(
          this as THExtendCommandOption, $identity, $identity);
  @override
  String toString() {
    return THExtendCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THExtendCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THExtendCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THExtendCommandOption, other);
  }

  @override
  int get hashCode {
    return THExtendCommandOptionMapper.ensureInitialized()
        .hashValue(this as THExtendCommandOption);
  }
}

extension THExtendCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THExtendCommandOption, $Out> {
  THExtendCommandOptionCopyWith<$R, THExtendCommandOption, $Out>
      get $asTHExtendCommandOption =>
          $base.as((v, t, t2) => _THExtendCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THExtendCommandOptionCopyWith<
    $R,
    $In extends THExtendCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  $R call({int? parentMapiahID, String? optionType, String? station});
  THExtendCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THExtendCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THExtendCommandOption, $Out>
    implements THExtendCommandOptionCopyWith<$R, THExtendCommandOption, $Out> {
  _THExtendCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THExtendCommandOption> $mapper =
      THExtendCommandOptionMapper.ensureInitialized();
  @override
  $R call({int? parentMapiahID, String? optionType, String? station}) =>
      $apply(FieldCopyWithData({
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (station != null) #station: station
      }));
  @override
  THExtendCommandOption $make(CopyWithData data) =>
      THExtendCommandOption.withExplicitParameters(
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#station, or: $value.station));

  @override
  THExtendCommandOptionCopyWith<$R2, THExtendCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THExtendCommandOptionCopyWithImpl($value, $cast, t);
}
