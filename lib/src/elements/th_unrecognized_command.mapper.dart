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
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THUnrecognizedCommand';

  static THParent _$parent(THUnrecognizedCommand v) => v.parent;
  static const Field<THUnrecognizedCommand, THParent> _f$parent =
      Field('parent', _$parent);
  static List<dynamic> _$_value(THUnrecognizedCommand v) => v._value;
  static const Field<THUnrecognizedCommand, List<dynamic>> _f$_value =
      Field('_value', _$_value, key: 'value');
  static String? _$sameLineComment(THUnrecognizedCommand v) =>
      v.sameLineComment;
  static const Field<THUnrecognizedCommand, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THUnrecognizedCommand> fields = const {
    #parent: _f$parent,
    #_value: _f$_value,
    #sameLineComment: _f$sameLineComment,
  };

  static THUnrecognizedCommand _instantiate(DecodingData data) {
    return THUnrecognizedCommand(data.dec(_f$parent), data.dec(_f$_value));
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
    $Out> implements THElementCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>> get _value;
  @override
  $R call({THParent? parent, List<dynamic>? value});
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
  ListCopyWith<$R, dynamic, ObjectCopyWith<$R, dynamic, dynamic>> get _value =>
      ListCopyWith($value._value, (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(value: v));
  @override
  $R call({THParent? parent, List<dynamic>? value}) => $apply(FieldCopyWithData(
      {if (parent != null) #parent: parent, if (value != null) #value: value}));
  @override
  THUnrecognizedCommand $make(CopyWithData data) => THUnrecognizedCommand(
      data.get(#parent, or: $value.parent),
      data.get(#value, or: $value._value));

  @override
  THUnrecognizedCommandCopyWith<$R2, THUnrecognizedCommand, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THUnrecognizedCommandCopyWithImpl($value, $cast, t);
}
