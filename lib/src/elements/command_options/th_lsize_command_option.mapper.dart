// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_lsize_command_option.dart';

class THLSizeCommandOptionMapper extends ClassMapperBase<THLSizeCommandOption> {
  THLSizeCommandOptionMapper._();

  static THLSizeCommandOptionMapper? _instance;
  static THLSizeCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THLSizeCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THDoublePartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THLSizeCommandOption';

  static THHasOptions _$optionParent(THLSizeCommandOption v) => v.optionParent;
  static const Field<THLSizeCommandOption, THHasOptions> _f$optionParent =
      Field('optionParent', _$optionParent);
  static THDoublePart _$number(THLSizeCommandOption v) => v.number;
  static const Field<THLSizeCommandOption, THDoublePart> _f$number =
      Field('number', _$number);

  @override
  final MappableFields<THLSizeCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #number: _f$number,
  };

  static THLSizeCommandOption _instantiate(DecodingData data) {
    return THLSizeCommandOption(data.dec(_f$optionParent), data.dec(_f$number));
  }

  @override
  final Function instantiate = _instantiate;

  static THLSizeCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THLSizeCommandOption>(map);
  }

  static THLSizeCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THLSizeCommandOption>(json);
  }
}

mixin THLSizeCommandOptionMappable {
  String toJson() {
    return THLSizeCommandOptionMapper.ensureInitialized()
        .encodeJson<THLSizeCommandOption>(this as THLSizeCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THLSizeCommandOptionMapper.ensureInitialized()
        .encodeMap<THLSizeCommandOption>(this as THLSizeCommandOption);
  }

  THLSizeCommandOptionCopyWith<THLSizeCommandOption, THLSizeCommandOption,
          THLSizeCommandOption>
      get copyWith => _THLSizeCommandOptionCopyWithImpl(
          this as THLSizeCommandOption, $identity, $identity);
  @override
  String toString() {
    return THLSizeCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THLSizeCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THLSizeCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THLSizeCommandOption, other);
  }

  @override
  int get hashCode {
    return THLSizeCommandOptionMapper.ensureInitialized()
        .hashValue(this as THLSizeCommandOption);
  }
}

extension THLSizeCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THLSizeCommandOption, $Out> {
  THLSizeCommandOptionCopyWith<$R, THLSizeCommandOption, $Out>
      get $asTHLSizeCommandOption =>
          $base.as((v, t, t2) => _THLSizeCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THLSizeCommandOptionCopyWith<
    $R,
    $In extends THLSizeCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get number;
  @override
  $R call({THHasOptions? optionParent, THDoublePart? number});
  THLSizeCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THLSizeCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THLSizeCommandOption, $Out>
    implements THLSizeCommandOptionCopyWith<$R, THLSizeCommandOption, $Out> {
  _THLSizeCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THLSizeCommandOption> $mapper =
      THLSizeCommandOptionMapper.ensureInitialized();
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get number =>
      $value.number.copyWith.$chain((v) => call(number: v));
  @override
  $R call({THHasOptions? optionParent, THDoublePart? number}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (number != null) #number: number
      }));
  @override
  THLSizeCommandOption $make(CopyWithData data) => THLSizeCommandOption(
      data.get(#optionParent, or: $value.optionParent),
      data.get(#number, or: $value.number));

  @override
  THLSizeCommandOptionCopyWith<$R2, THLSizeCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THLSizeCommandOptionCopyWithImpl($value, $cast, t);
}
