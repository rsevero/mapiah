// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_cs_command_option.dart';

class THCSCommandOptionMapper extends ClassMapperBase<THCSCommandOption> {
  THCSCommandOptionMapper._();

  static THCSCommandOptionMapper? _instance;
  static THCSCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THCSCommandOptionMapper._());
      THCSPartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THCSCommandOption';

  static int _$parentMapiahID(THCSCommandOption v) => v.parentMapiahID;
  static dynamic _arg$parentMapiahID(f) => f<int>();
  static const Field<THCSCommandOption, dynamic> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, arg: _arg$parentMapiahID);
  static String _$optionType(THCSCommandOption v) => v.optionType;
  static dynamic _arg$optionType(f) => f<String>();
  static const Field<THCSCommandOption, dynamic> _f$optionType =
      Field('optionType', _$optionType, arg: _arg$optionType);
  static THCSPart _$cs(THCSCommandOption v) => v.cs;
  static const Field<THCSCommandOption, THCSPart> _f$cs = Field('cs', _$cs);

  @override
  final MappableFields<THCSCommandOption> fields = const {
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #cs: _f$cs,
  };

  static THCSCommandOption _instantiate(DecodingData data) {
    return THCSCommandOption.withExplicitParameters(
        data.dec(_f$parentMapiahID), data.dec(_f$optionType), data.dec(_f$cs));
  }

  @override
  final Function instantiate = _instantiate;

  static THCSCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THCSCommandOption>(map);
  }

  static THCSCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THCSCommandOption>(json);
  }
}

mixin THCSCommandOptionMappable {
  String toJson() {
    return THCSCommandOptionMapper.ensureInitialized()
        .encodeJson<THCSCommandOption>(this as THCSCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THCSCommandOptionMapper.ensureInitialized()
        .encodeMap<THCSCommandOption>(this as THCSCommandOption);
  }

  THCSCommandOptionCopyWith<THCSCommandOption, THCSCommandOption,
          THCSCommandOption>
      get copyWith => _THCSCommandOptionCopyWithImpl(
          this as THCSCommandOption, $identity, $identity);
  @override
  String toString() {
    return THCSCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THCSCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THCSCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THCSCommandOption, other);
  }

  @override
  int get hashCode {
    return THCSCommandOptionMapper.ensureInitialized()
        .hashValue(this as THCSCommandOption);
  }
}

extension THCSCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THCSCommandOption, $Out> {
  THCSCommandOptionCopyWith<$R, THCSCommandOption, $Out>
      get $asTHCSCommandOption =>
          $base.as((v, t, t2) => _THCSCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THCSCommandOptionCopyWith<$R, $In extends THCSCommandOption,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  THCSPartCopyWith<$R, THCSPart, THCSPart> get cs;
  $R call({dynamic parentMapiahID, dynamic optionType, THCSPart? cs});
  THCSCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THCSCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THCSCommandOption, $Out>
    implements THCSCommandOptionCopyWith<$R, THCSCommandOption, $Out> {
  _THCSCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THCSCommandOption> $mapper =
      THCSCommandOptionMapper.ensureInitialized();
  @override
  THCSPartCopyWith<$R, THCSPart, THCSPart> get cs =>
      $value.cs.copyWith.$chain((v) => call(cs: v));
  @override
  $R call(
          {Object? parentMapiahID = $none,
          Object? optionType = $none,
          THCSPart? cs}) =>
      $apply(FieldCopyWithData({
        if (parentMapiahID != $none) #parentMapiahID: parentMapiahID,
        if (optionType != $none) #optionType: optionType,
        if (cs != null) #cs: cs
      }));
  @override
  THCSCommandOption $make(CopyWithData data) =>
      THCSCommandOption.withExplicitParameters(
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#cs, or: $value.cs));

  @override
  THCSCommandOptionCopyWith<$R2, THCSCommandOption, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THCSCommandOptionCopyWithImpl($value, $cast, t);
}
