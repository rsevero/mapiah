// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_mark_command_option.dart';

class THMarkCommandOptionMapper extends ClassMapperBase<THMarkCommandOption> {
  THMarkCommandOptionMapper._();

  static THMarkCommandOptionMapper? _instance;
  static THMarkCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THMarkCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THMarkCommandOption';

  static THHasOptions _$optionParent(THMarkCommandOption v) => v.optionParent;
  static const Field<THMarkCommandOption, THHasOptions> _f$optionParent =
      Field('optionParent', _$optionParent);
  static String _$mark(THMarkCommandOption v) => v.mark;
  static const Field<THMarkCommandOption, String> _f$mark =
      Field('mark', _$mark);

  @override
  final MappableFields<THMarkCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #mark: _f$mark,
  };

  static THMarkCommandOption _instantiate(DecodingData data) {
    return THMarkCommandOption(data.dec(_f$optionParent), data.dec(_f$mark));
  }

  @override
  final Function instantiate = _instantiate;

  static THMarkCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THMarkCommandOption>(map);
  }

  static THMarkCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THMarkCommandOption>(json);
  }
}

mixin THMarkCommandOptionMappable {
  String toJson() {
    return THMarkCommandOptionMapper.ensureInitialized()
        .encodeJson<THMarkCommandOption>(this as THMarkCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THMarkCommandOptionMapper.ensureInitialized()
        .encodeMap<THMarkCommandOption>(this as THMarkCommandOption);
  }

  THMarkCommandOptionCopyWith<THMarkCommandOption, THMarkCommandOption,
          THMarkCommandOption>
      get copyWith => _THMarkCommandOptionCopyWithImpl(
          this as THMarkCommandOption, $identity, $identity);
  @override
  String toString() {
    return THMarkCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THMarkCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THMarkCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THMarkCommandOption, other);
  }

  @override
  int get hashCode {
    return THMarkCommandOptionMapper.ensureInitialized()
        .hashValue(this as THMarkCommandOption);
  }
}

extension THMarkCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THMarkCommandOption, $Out> {
  THMarkCommandOptionCopyWith<$R, THMarkCommandOption, $Out>
      get $asTHMarkCommandOption =>
          $base.as((v, t, t2) => _THMarkCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THMarkCommandOptionCopyWith<$R, $In extends THMarkCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  @override
  $R call({THHasOptions? optionParent, String? mark});
  THMarkCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THMarkCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THMarkCommandOption, $Out>
    implements THMarkCommandOptionCopyWith<$R, THMarkCommandOption, $Out> {
  _THMarkCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THMarkCommandOption> $mapper =
      THMarkCommandOptionMapper.ensureInitialized();
  @override
  $R call({THHasOptions? optionParent, String? mark}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (mark != null) #mark: mark
      }));
  @override
  THMarkCommandOption $make(CopyWithData data) => THMarkCommandOption(
      data.get(#optionParent, or: $value.optionParent),
      data.get(#mark, or: $value.mark));

  @override
  THMarkCommandOptionCopyWith<$R2, THMarkCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THMarkCommandOptionCopyWithImpl($value, $cast, t);
}
