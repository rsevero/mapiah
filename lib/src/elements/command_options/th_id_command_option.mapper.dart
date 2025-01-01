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
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THIDCommandOption';

  static THHasOptions _$optionParent(THIDCommandOption v) => v.optionParent;
  static const Field<THIDCommandOption, THHasOptions> _f$optionParent =
      Field('optionParent', _$optionParent);
  static String _$_thID(THIDCommandOption v) => v._thID;
  static const Field<THIDCommandOption, String> _f$_thID =
      Field('_thID', _$_thID, key: 'thID');

  @override
  final MappableFields<THIDCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #_thID: _f$_thID,
  };

  static THIDCommandOption _instantiate(DecodingData data) {
    return THIDCommandOption(data.dec(_f$optionParent), data.dec(_f$_thID));
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
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  $R call({THHasOptions? optionParent, String? thID});
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
  $R call({THHasOptions? optionParent, String? thID}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (thID != null) #thID: thID
      }));
  @override
  THIDCommandOption $make(CopyWithData data) => THIDCommandOption(
      data.get(#optionParent, or: $value.optionParent),
      data.get(#thID, or: $value._thID));

  @override
  THIDCommandOptionCopyWith<$R2, THIDCommandOption, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THIDCommandOptionCopyWithImpl($value, $cast, t);
}
