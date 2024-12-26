// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_stations_command_option.dart';

class THStationsCommandOptionMapper
    extends ClassMapperBase<THStationsCommandOption> {
  THStationsCommandOptionMapper._();

  static THStationsCommandOptionMapper? _instance;
  static THStationsCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THStationsCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THStationsCommandOption';

  static THHasOptions _$optionParent(THStationsCommandOption v) =>
      v.optionParent;
  static const Field<THStationsCommandOption, THHasOptions> _f$optionParent =
      Field('optionParent', _$optionParent, key: 'parent');
  static List<String> _$stations(THStationsCommandOption v) => v.stations;
  static const Field<THStationsCommandOption, List<String>> _f$stations =
      Field('stations', _$stations);

  @override
  final MappableFields<THStationsCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #stations: _f$stations,
  };

  static THStationsCommandOption _instantiate(DecodingData data) {
    return THStationsCommandOption(
        data.dec(_f$optionParent), data.dec(_f$stations));
  }

  @override
  final Function instantiate = _instantiate;

  static THStationsCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THStationsCommandOption>(map);
  }

  static THStationsCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THStationsCommandOption>(json);
  }
}

mixin THStationsCommandOptionMappable {
  String toJson() {
    return THStationsCommandOptionMapper.ensureInitialized()
        .encodeJson<THStationsCommandOption>(this as THStationsCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THStationsCommandOptionMapper.ensureInitialized()
        .encodeMap<THStationsCommandOption>(this as THStationsCommandOption);
  }

  THStationsCommandOptionCopyWith<THStationsCommandOption,
          THStationsCommandOption, THStationsCommandOption>
      get copyWith => _THStationsCommandOptionCopyWithImpl(
          this as THStationsCommandOption, $identity, $identity);
  @override
  String toString() {
    return THStationsCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THStationsCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THStationsCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THStationsCommandOption, other);
  }

  @override
  int get hashCode {
    return THStationsCommandOptionMapper.ensureInitialized()
        .hashValue(this as THStationsCommandOption);
  }
}

extension THStationsCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THStationsCommandOption, $Out> {
  THStationsCommandOptionCopyWith<$R, THStationsCommandOption, $Out>
      get $asTHStationsCommandOption => $base
          .as((v, t, t2) => _THStationsCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THStationsCommandOptionCopyWith<
    $R,
    $In extends THStationsCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get stations;
  @override
  $R call({THHasOptions? optionParent, List<String>? stations});
  THStationsCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THStationsCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THStationsCommandOption, $Out>
    implements
        THStationsCommandOptionCopyWith<$R, THStationsCommandOption, $Out> {
  _THStationsCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THStationsCommandOption> $mapper =
      THStationsCommandOptionMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get stations =>
      ListCopyWith($value.stations, (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(stations: v));
  @override
  $R call({THHasOptions? optionParent, List<String>? stations}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (stations != null) #stations: stations
      }));
  @override
  THStationsCommandOption $make(CopyWithData data) => THStationsCommandOption(
      data.get(#optionParent, or: $value.optionParent),
      data.get(#stations, or: $value.stations));

  @override
  THStationsCommandOptionCopyWith<$R2, THStationsCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THStationsCommandOptionCopyWithImpl($value, $cast, t);
}
