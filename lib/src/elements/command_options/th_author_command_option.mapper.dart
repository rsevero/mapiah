// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_author_command_option.dart';

class THAuthorCommandOptionMapper
    extends ClassMapperBase<THAuthorCommandOption> {
  THAuthorCommandOptionMapper._();

  static THAuthorCommandOptionMapper? _instance;
  static THAuthorCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THAuthorCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THDatetimePartMapper.ensureInitialized();
      THPersonPartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THAuthorCommandOption';

  static int _$parentMapiahID(THAuthorCommandOption v) => v.parentMapiahID;
  static const Field<THAuthorCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THAuthorCommandOption v) => v.optionType;
  static const Field<THAuthorCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static THDatetimePart _$datetime(THAuthorCommandOption v) => v.datetime;
  static const Field<THAuthorCommandOption, THDatetimePart> _f$datetime =
      Field('datetime', _$datetime);
  static THPersonPart _$person(THAuthorCommandOption v) => v.person;
  static const Field<THAuthorCommandOption, THPersonPart> _f$person =
      Field('person', _$person);

  @override
  final MappableFields<THAuthorCommandOption> fields = const {
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #datetime: _f$datetime,
    #person: _f$person,
  };

  static THAuthorCommandOption _instantiate(DecodingData data) {
    return THAuthorCommandOption.withExplicitParameters(
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$datetime),
        data.dec(_f$person));
  }

  @override
  final Function instantiate = _instantiate;

  static THAuthorCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THAuthorCommandOption>(map);
  }

  static THAuthorCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THAuthorCommandOption>(json);
  }
}

mixin THAuthorCommandOptionMappable {
  String toJson() {
    return THAuthorCommandOptionMapper.ensureInitialized()
        .encodeJson<THAuthorCommandOption>(this as THAuthorCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THAuthorCommandOptionMapper.ensureInitialized()
        .encodeMap<THAuthorCommandOption>(this as THAuthorCommandOption);
  }

  THAuthorCommandOptionCopyWith<THAuthorCommandOption, THAuthorCommandOption,
          THAuthorCommandOption>
      get copyWith => _THAuthorCommandOptionCopyWithImpl(
          this as THAuthorCommandOption, $identity, $identity);
  @override
  String toString() {
    return THAuthorCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THAuthorCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THAuthorCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THAuthorCommandOption, other);
  }

  @override
  int get hashCode {
    return THAuthorCommandOptionMapper.ensureInitialized()
        .hashValue(this as THAuthorCommandOption);
  }
}

extension THAuthorCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THAuthorCommandOption, $Out> {
  THAuthorCommandOptionCopyWith<$R, THAuthorCommandOption, $Out>
      get $asTHAuthorCommandOption =>
          $base.as((v, t, t2) => _THAuthorCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THAuthorCommandOptionCopyWith<
    $R,
    $In extends THAuthorCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  THDatetimePartCopyWith<$R, THDatetimePart, THDatetimePart> get datetime;
  THPersonPartCopyWith<$R, THPersonPart, THPersonPart> get person;
  @override
  $R call(
      {int? parentMapiahID,
      String? optionType,
      THDatetimePart? datetime,
      THPersonPart? person});
  THAuthorCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THAuthorCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THAuthorCommandOption, $Out>
    implements THAuthorCommandOptionCopyWith<$R, THAuthorCommandOption, $Out> {
  _THAuthorCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THAuthorCommandOption> $mapper =
      THAuthorCommandOptionMapper.ensureInitialized();
  @override
  THDatetimePartCopyWith<$R, THDatetimePart, THDatetimePart> get datetime =>
      $value.datetime.copyWith.$chain((v) => call(datetime: v));
  @override
  THPersonPartCopyWith<$R, THPersonPart, THPersonPart> get person =>
      $value.person.copyWith.$chain((v) => call(person: v));
  @override
  $R call(
          {int? parentMapiahID,
          String? optionType,
          THDatetimePart? datetime,
          THPersonPart? person}) =>
      $apply(FieldCopyWithData({
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (datetime != null) #datetime: datetime,
        if (person != null) #person: person
      }));
  @override
  THAuthorCommandOption $make(CopyWithData data) =>
      THAuthorCommandOption.withExplicitParameters(
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#datetime, or: $value.datetime),
          data.get(#person, or: $value.person));

  @override
  THAuthorCommandOptionCopyWith<$R2, THAuthorCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THAuthorCommandOptionCopyWithImpl($value, $cast, t);
}
