// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_multiple_choice_part.dart';

class THMultipleChoicePartMapper extends ClassMapperBase<THMultipleChoicePart> {
  THMultipleChoicePartMapper._();

  static THMultipleChoicePartMapper? _instance;
  static THMultipleChoicePartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THMultipleChoicePartMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THMultipleChoicePart';

  static String _$multipleChoiceName(THMultipleChoicePart v) =>
      v.multipleChoiceName;
  static const Field<THMultipleChoicePart, String> _f$multipleChoiceName =
      Field('multipleChoiceName', _$multipleChoiceName);
  static String _$choice(THMultipleChoicePart v) => v.choice;
  static const Field<THMultipleChoicePart, String> _f$choice =
      Field('choice', _$choice);

  @override
  final MappableFields<THMultipleChoicePart> fields = const {
    #multipleChoiceName: _f$multipleChoiceName,
    #choice: _f$choice,
  };

  static THMultipleChoicePart _instantiate(DecodingData data) {
    return THMultipleChoicePart(
        data.dec(_f$multipleChoiceName), data.dec(_f$choice));
  }

  @override
  final Function instantiate = _instantiate;

  static THMultipleChoicePart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THMultipleChoicePart>(map);
  }

  static THMultipleChoicePart fromJson(String json) {
    return ensureInitialized().decodeJson<THMultipleChoicePart>(json);
  }
}

mixin THMultipleChoicePartMappable {
  String toJson() {
    return THMultipleChoicePartMapper.ensureInitialized()
        .encodeJson<THMultipleChoicePart>(this as THMultipleChoicePart);
  }

  Map<String, dynamic> toMap() {
    return THMultipleChoicePartMapper.ensureInitialized()
        .encodeMap<THMultipleChoicePart>(this as THMultipleChoicePart);
  }

  THMultipleChoicePartCopyWith<THMultipleChoicePart, THMultipleChoicePart,
          THMultipleChoicePart>
      get copyWith => _THMultipleChoicePartCopyWithImpl(
          this as THMultipleChoicePart, $identity, $identity);
  @override
  String toString() {
    return THMultipleChoicePartMapper.ensureInitialized()
        .stringifyValue(this as THMultipleChoicePart);
  }

  @override
  bool operator ==(Object other) {
    return THMultipleChoicePartMapper.ensureInitialized()
        .equalsValue(this as THMultipleChoicePart, other);
  }

  @override
  int get hashCode {
    return THMultipleChoicePartMapper.ensureInitialized()
        .hashValue(this as THMultipleChoicePart);
  }
}

extension THMultipleChoicePartValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THMultipleChoicePart, $Out> {
  THMultipleChoicePartCopyWith<$R, THMultipleChoicePart, $Out>
      get $asTHMultipleChoicePart =>
          $base.as((v, t, t2) => _THMultipleChoicePartCopyWithImpl(v, t, t2));
}

abstract class THMultipleChoicePartCopyWith<
    $R,
    $In extends THMultipleChoicePart,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? multipleChoiceName, String? choice});
  THMultipleChoicePartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THMultipleChoicePartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THMultipleChoicePart, $Out>
    implements THMultipleChoicePartCopyWith<$R, THMultipleChoicePart, $Out> {
  _THMultipleChoicePartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THMultipleChoicePart> $mapper =
      THMultipleChoicePartMapper.ensureInitialized();
  @override
  $R call({String? multipleChoiceName, String? choice}) =>
      $apply(FieldCopyWithData({
        if (multipleChoiceName != null) #multipleChoiceName: multipleChoiceName,
        if (choice != null) #choice: choice
      }));
  @override
  THMultipleChoicePart $make(CopyWithData data) => THMultipleChoicePart(
      data.get(#multipleChoiceName, or: $value.multipleChoiceName),
      data.get(#choice, or: $value.choice));

  @override
  THMultipleChoicePartCopyWith<$R2, THMultipleChoicePart, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THMultipleChoicePartCopyWithImpl($value, $cast, t);
}
