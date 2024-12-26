// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_person_part.dart';

class THPersonPartMapper extends ClassMapperBase<THPersonPart> {
  THPersonPartMapper._();

  static THPersonPartMapper? _instance;
  static THPersonPartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THPersonPartMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THPersonPart';

  static String _$firstname(THPersonPart v) => v.firstname;
  static const Field<THPersonPart, String> _f$firstname =
      Field('firstname', _$firstname);
  static String _$surname(THPersonPart v) => v.surname;
  static const Field<THPersonPart, String> _f$surname =
      Field('surname', _$surname);

  @override
  final MappableFields<THPersonPart> fields = const {
    #firstname: _f$firstname,
    #surname: _f$surname,
  };

  static THPersonPart _instantiate(DecodingData data) {
    return THPersonPart(data.dec(_f$firstname), data.dec(_f$surname));
  }

  @override
  final Function instantiate = _instantiate;

  static THPersonPart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THPersonPart>(map);
  }

  static THPersonPart fromJson(String json) {
    return ensureInitialized().decodeJson<THPersonPart>(json);
  }
}

mixin THPersonPartMappable {
  String toJson() {
    return THPersonPartMapper.ensureInitialized()
        .encodeJson<THPersonPart>(this as THPersonPart);
  }

  Map<String, dynamic> toMap() {
    return THPersonPartMapper.ensureInitialized()
        .encodeMap<THPersonPart>(this as THPersonPart);
  }

  THPersonPartCopyWith<THPersonPart, THPersonPart, THPersonPart> get copyWith =>
      _THPersonPartCopyWithImpl(this as THPersonPart, $identity, $identity);
  @override
  String toString() {
    return THPersonPartMapper.ensureInitialized()
        .stringifyValue(this as THPersonPart);
  }

  @override
  bool operator ==(Object other) {
    return THPersonPartMapper.ensureInitialized()
        .equalsValue(this as THPersonPart, other);
  }

  @override
  int get hashCode {
    return THPersonPartMapper.ensureInitialized()
        .hashValue(this as THPersonPart);
  }
}

extension THPersonPartValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THPersonPart, $Out> {
  THPersonPartCopyWith<$R, THPersonPart, $Out> get $asTHPersonPart =>
      $base.as((v, t, t2) => _THPersonPartCopyWithImpl(v, t, t2));
}

abstract class THPersonPartCopyWith<$R, $In extends THPersonPart, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? firstname, String? surname});
  THPersonPartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THPersonPartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THPersonPart, $Out>
    implements THPersonPartCopyWith<$R, THPersonPart, $Out> {
  _THPersonPartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THPersonPart> $mapper =
      THPersonPartMapper.ensureInitialized();
  @override
  $R call({String? firstname, String? surname}) => $apply(FieldCopyWithData({
        if (firstname != null) #firstname: firstname,
        if (surname != null) #surname: surname
      }));
  @override
  THPersonPart $make(CopyWithData data) => THPersonPart(
      data.get(#firstname, or: $value.firstname),
      data.get(#surname, or: $value.surname));

  @override
  THPersonPartCopyWith<$R2, THPersonPart, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THPersonPartCopyWithImpl($value, $cast, t);
}
