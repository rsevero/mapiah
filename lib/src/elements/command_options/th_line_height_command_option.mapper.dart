// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_line_height_command_option.dart';

class THLineHeightCommandOptionMapper
    extends ClassMapperBase<THLineHeightCommandOption> {
  THLineHeightCommandOptionMapper._();

  static THLineHeightCommandOptionMapper? _instance;
  static THLineHeightCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THLineHeightCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THDoublePartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THLineHeightCommandOption';

  static THHasOptions _$optionParent(THLineHeightCommandOption v) =>
      v.optionParent;
  static const Field<THLineHeightCommandOption, THHasOptions> _f$optionParent =
      Field('optionParent', _$optionParent);
  static String _$optionType(THLineHeightCommandOption v) => v.optionType;
  static const Field<THLineHeightCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static THDoublePart _$height(THLineHeightCommandOption v) => v.height;
  static const Field<THLineHeightCommandOption, THDoublePart> _f$height =
      Field('height', _$height);

  @override
  final MappableFields<THLineHeightCommandOption> fields = const {
    #optionParent: _f$optionParent,
    #optionType: _f$optionType,
    #height: _f$height,
  };

  static THLineHeightCommandOption _instantiate(DecodingData data) {
    return THLineHeightCommandOption.withExplicitOptionType(
        data.dec(_f$optionParent),
        data.dec(_f$optionType),
        data.dec(_f$height));
  }

  @override
  final Function instantiate = _instantiate;

  static THLineHeightCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THLineHeightCommandOption>(map);
  }

  static THLineHeightCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THLineHeightCommandOption>(json);
  }
}

mixin THLineHeightCommandOptionMappable {
  String toJson() {
    return THLineHeightCommandOptionMapper.ensureInitialized()
        .encodeJson<THLineHeightCommandOption>(
            this as THLineHeightCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THLineHeightCommandOptionMapper.ensureInitialized()
        .encodeMap<THLineHeightCommandOption>(
            this as THLineHeightCommandOption);
  }

  THLineHeightCommandOptionCopyWith<THLineHeightCommandOption,
          THLineHeightCommandOption, THLineHeightCommandOption>
      get copyWith => _THLineHeightCommandOptionCopyWithImpl(
          this as THLineHeightCommandOption, $identity, $identity);
  @override
  String toString() {
    return THLineHeightCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THLineHeightCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THLineHeightCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THLineHeightCommandOption, other);
  }

  @override
  int get hashCode {
    return THLineHeightCommandOptionMapper.ensureInitialized()
        .hashValue(this as THLineHeightCommandOption);
  }
}

extension THLineHeightCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THLineHeightCommandOption, $Out> {
  THLineHeightCommandOptionCopyWith<$R, THLineHeightCommandOption, $Out>
      get $asTHLineHeightCommandOption => $base
          .as((v, t, t2) => _THLineHeightCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THLineHeightCommandOptionCopyWith<
    $R,
    $In extends THLineHeightCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get height;
  @override
  $R call(
      {THHasOptions? optionParent, String? optionType, THDoublePart? height});
  THLineHeightCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THLineHeightCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THLineHeightCommandOption, $Out>
    implements
        THLineHeightCommandOptionCopyWith<$R, THLineHeightCommandOption, $Out> {
  _THLineHeightCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THLineHeightCommandOption> $mapper =
      THLineHeightCommandOptionMapper.ensureInitialized();
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get height =>
      $value.height.copyWith.$chain((v) => call(height: v));
  @override
  $R call(
          {THHasOptions? optionParent,
          String? optionType,
          THDoublePart? height}) =>
      $apply(FieldCopyWithData({
        if (optionParent != null) #optionParent: optionParent,
        if (optionType != null) #optionType: optionType,
        if (height != null) #height: height
      }));
  @override
  THLineHeightCommandOption $make(CopyWithData data) =>
      THLineHeightCommandOption.withExplicitOptionType(
          data.get(#optionParent, or: $value.optionParent),
          data.get(#optionType, or: $value.optionType),
          data.get(#height, or: $value.height));

  @override
  THLineHeightCommandOptionCopyWith<$R2, THLineHeightCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THLineHeightCommandOptionCopyWithImpl($value, $cast, t);
}
