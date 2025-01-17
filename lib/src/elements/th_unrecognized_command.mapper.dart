// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_unrecognized_command.dart';

class THUnrecognizedCommandMapper
    extends ClassMapperBase<THUnrecognizedCommand> {
  THUnrecognizedCommandMapper._();

  static THUnrecognizedCommandMapper? _instance;
  static THUnrecognizedCommandMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THUnrecognizedCommandMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THUnrecognizedCommand';

  static int _$mapiahID(THUnrecognizedCommand v) => v.mapiahID;
  static dynamic _arg$mapiahID(f) => f<int>();
  static const Field<THUnrecognizedCommand, dynamic> _f$mapiahID =
      Field('mapiahID', _$mapiahID, arg: _arg$mapiahID);
  static int _$parentMapiahID(THUnrecognizedCommand v) => v.parentMapiahID;
  static dynamic _arg$parentMapiahID(f) => f<int>();
  static const Field<THUnrecognizedCommand, dynamic> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, arg: _arg$parentMapiahID);
  static String? _$sameLineComment(THUnrecognizedCommand v) =>
      v.sameLineComment;
  static dynamic _arg$sameLineComment(f) => f<String>();
  static const Field<THUnrecognizedCommand, dynamic> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, arg: _arg$sameLineComment);
  static dynamic _$value(THUnrecognizedCommand v) => v.value;
  static dynamic _arg$value(f) => f<dynamic>();
  static const Field<THUnrecognizedCommand, List<dynamic>> _f$value =
      Field('value', _$value, arg: _arg$value);

  @override
  final MappableFields<THUnrecognizedCommand> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
    #value: _f$value,
  };

  static THUnrecognizedCommand _instantiate(DecodingData data) {
    return THUnrecognizedCommand.notAddToParent(
        data.dec(_f$mapiahID),
        data.dec(_f$parentMapiahID),
        data.dec(_f$sameLineComment),
        data.dec(_f$value));
  }

  @override
  final Function instantiate = _instantiate;

  static THUnrecognizedCommand fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THUnrecognizedCommand>(map);
  }

  static THUnrecognizedCommand fromJson(String json) {
    return ensureInitialized().decodeJson<THUnrecognizedCommand>(json);
  }
}

mixin THUnrecognizedCommandMappable {
  String toJson() {
    return THUnrecognizedCommandMapper.ensureInitialized()
        .encodeJson<THUnrecognizedCommand>(this as THUnrecognizedCommand);
  }

  Map<String, dynamic> toMap() {
    return THUnrecognizedCommandMapper.ensureInitialized()
        .encodeMap<THUnrecognizedCommand>(this as THUnrecognizedCommand);
  }

  THUnrecognizedCommandCopyWith<THUnrecognizedCommand, THUnrecognizedCommand,
          THUnrecognizedCommand>
      get copyWith => _THUnrecognizedCommandCopyWithImpl(
          this as THUnrecognizedCommand, $identity, $identity);
  @override
  String toString() {
    return THUnrecognizedCommandMapper.ensureInitialized()
        .stringifyValue(this as THUnrecognizedCommand);
  }

  @override
  bool operator ==(Object other) {
    return THUnrecognizedCommandMapper.ensureInitialized()
        .equalsValue(this as THUnrecognizedCommand, other);
  }

  @override
  int get hashCode {
    return THUnrecognizedCommandMapper.ensureInitialized()
        .hashValue(this as THUnrecognizedCommand);
  }
}

extension THUnrecognizedCommandValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THUnrecognizedCommand, $Out> {
  THUnrecognizedCommandCopyWith<$R, THUnrecognizedCommand, $Out>
      get $asTHUnrecognizedCommand =>
          $base.as((v, t, t2) => _THUnrecognizedCommandCopyWithImpl(v, t, t2));
}

abstract class THUnrecognizedCommandCopyWith<
    $R,
    $In extends THUnrecognizedCommand,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>> get value;
  $R call(
      {dynamic mapiahID,
      dynamic parentMapiahID,
      dynamic sameLineComment,
      List<dynamic>? value});
  THUnrecognizedCommandCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THUnrecognizedCommandCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THUnrecognizedCommand, $Out>
    implements THUnrecognizedCommandCopyWith<$R, THUnrecognizedCommand, $Out> {
  _THUnrecognizedCommandCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THUnrecognizedCommand> $mapper =
      THUnrecognizedCommandMapper.ensureInitialized();
  @override
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>> get value =>
      ListCopyWith($value.value, (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(value: v));
  @override
  $R call(
          {Object? mapiahID = $none,
          Object? parentMapiahID = $none,
          Object? sameLineComment = $none,
          List<dynamic>? value}) =>
      $apply(FieldCopyWithData({
        if (mapiahID != $none) #mapiahID: mapiahID,
        if (parentMapiahID != $none) #parentMapiahID: parentMapiahID,
        if (sameLineComment != $none) #sameLineComment: sameLineComment,
        if (value != null) #value: value
      }));
  @override
  THUnrecognizedCommand $make(CopyWithData data) =>
      THUnrecognizedCommand.notAddToParent(
          data.get(#mapiahID, or: $value.mapiahID),
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#sameLineComment, or: $value.sameLineComment),
          data.get(#value, or: $value.value));

  @override
  THUnrecognizedCommandCopyWith<$R2, THUnrecognizedCommand, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THUnrecognizedCommandCopyWithImpl($value, $cast, t);
}
