// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_date_value_command_option.dart';

class THDateValueCommandOptionMapper
    extends ClassMapperBase<THDateValueCommandOption> {
  THDateValueCommandOptionMapper._();

  static THDateValueCommandOptionMapper? _instance;
  static THDateValueCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THDateValueCommandOptionMapper._());
      THDatetimePartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THDateValueCommandOption';

  static int _$parentMapiahID(THDateValueCommandOption v) => v.parentMapiahID;
  static dynamic _arg$parentMapiahID(f) => f<int>();
  static const Field<THDateValueCommandOption, dynamic> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, arg: _arg$parentMapiahID);
  static String _$optionType(THDateValueCommandOption v) => v.optionType;
  static dynamic _arg$optionType(f) => f<String>();
  static const Field<THDateValueCommandOption, dynamic> _f$optionType =
      Field('optionType', _$optionType, arg: _arg$optionType);
  static THDatetimePart _$date(THDateValueCommandOption v) => v.date;
  static const Field<THDateValueCommandOption, THDatetimePart> _f$date =
      Field('date', _$date);

  @override
  final MappableFields<THDateValueCommandOption> fields = const {
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #date: _f$date,
  };

  static THDateValueCommandOption _instantiate(DecodingData data) {
    return THDateValueCommandOption.withExplicitParameters(
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$date));
  }

  @override
  final Function instantiate = _instantiate;

  static THDateValueCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THDateValueCommandOption>(map);
  }

  static THDateValueCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THDateValueCommandOption>(json);
  }
}

mixin THDateValueCommandOptionMappable {
  String toJson() {
    return THDateValueCommandOptionMapper.ensureInitialized()
        .encodeJson<THDateValueCommandOption>(this as THDateValueCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THDateValueCommandOptionMapper.ensureInitialized()
        .encodeMap<THDateValueCommandOption>(this as THDateValueCommandOption);
  }

  THDateValueCommandOptionCopyWith<THDateValueCommandOption,
          THDateValueCommandOption, THDateValueCommandOption>
      get copyWith => _THDateValueCommandOptionCopyWithImpl(
          this as THDateValueCommandOption, $identity, $identity);
  @override
  String toString() {
    return THDateValueCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THDateValueCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THDateValueCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THDateValueCommandOption, other);
  }

  @override
  int get hashCode {
    return THDateValueCommandOptionMapper.ensureInitialized()
        .hashValue(this as THDateValueCommandOption);
  }
}

extension THDateValueCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THDateValueCommandOption, $Out> {
  THDateValueCommandOptionCopyWith<$R, THDateValueCommandOption, $Out>
      get $asTHDateValueCommandOption => $base
          .as((v, t, t2) => _THDateValueCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THDateValueCommandOptionCopyWith<
    $R,
    $In extends THDateValueCommandOption,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  THDatetimePartCopyWith<$R, THDatetimePart, THDatetimePart> get date;
  $R call({dynamic parentMapiahID, dynamic optionType, THDatetimePart? date});
  THDateValueCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THDateValueCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THDateValueCommandOption, $Out>
    implements
        THDateValueCommandOptionCopyWith<$R, THDateValueCommandOption, $Out> {
  _THDateValueCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THDateValueCommandOption> $mapper =
      THDateValueCommandOptionMapper.ensureInitialized();
  @override
  THDatetimePartCopyWith<$R, THDatetimePart, THDatetimePart> get date =>
      $value.date.copyWith.$chain((v) => call(date: v));
  @override
  $R call(
          {Object? parentMapiahID = $none,
          Object? optionType = $none,
          THDatetimePart? date}) =>
      $apply(FieldCopyWithData({
        if (parentMapiahID != $none) #parentMapiahID: parentMapiahID,
        if (optionType != $none) #optionType: optionType,
        if (date != null) #date: date
      }));
  @override
  THDateValueCommandOption $make(CopyWithData data) =>
      THDateValueCommandOption.withExplicitParameters(
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#date, or: $value.date));

  @override
  THDateValueCommandOptionCopyWith<$R2, THDateValueCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THDateValueCommandOptionCopyWithImpl($value, $cast, t);
}
