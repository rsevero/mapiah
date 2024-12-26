// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_string_part.dart';

class THStringPartMapper extends ClassMapperBase<THStringPart> {
  THStringPartMapper._();

  static THStringPartMapper? _instance;
  static THStringPartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THStringPartMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THStringPart';

  static String _$content(THStringPart v) => v.content;
  static const Field<THStringPart, String> _f$content =
      Field('content', _$content, opt: true, def: '');

  @override
  final MappableFields<THStringPart> fields = const {
    #content: _f$content,
  };

  static THStringPart _instantiate(DecodingData data) {
    return THStringPart(data.dec(_f$content));
  }

  @override
  final Function instantiate = _instantiate;

  static THStringPart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THStringPart>(map);
  }

  static THStringPart fromJson(String json) {
    return ensureInitialized().decodeJson<THStringPart>(json);
  }
}

mixin THStringPartMappable {
  String toJson() {
    return THStringPartMapper.ensureInitialized()
        .encodeJson<THStringPart>(this as THStringPart);
  }

  Map<String, dynamic> toMap() {
    return THStringPartMapper.ensureInitialized()
        .encodeMap<THStringPart>(this as THStringPart);
  }

  THStringPartCopyWith<THStringPart, THStringPart, THStringPart> get copyWith =>
      _THStringPartCopyWithImpl(this as THStringPart, $identity, $identity);
  @override
  String toString() {
    return THStringPartMapper.ensureInitialized()
        .stringifyValue(this as THStringPart);
  }

  @override
  bool operator ==(Object other) {
    return THStringPartMapper.ensureInitialized()
        .equalsValue(this as THStringPart, other);
  }

  @override
  int get hashCode {
    return THStringPartMapper.ensureInitialized()
        .hashValue(this as THStringPart);
  }
}

extension THStringPartValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THStringPart, $Out> {
  THStringPartCopyWith<$R, THStringPart, $Out> get $asTHStringPart =>
      $base.as((v, t, t2) => _THStringPartCopyWithImpl(v, t, t2));
}

abstract class THStringPartCopyWith<$R, $In extends THStringPart, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? content});
  THStringPartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THStringPartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THStringPart, $Out>
    implements THStringPartCopyWith<$R, THStringPart, $Out> {
  _THStringPartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THStringPart> $mapper =
      THStringPartMapper.ensureInitialized();
  @override
  $R call({String? content}) =>
      $apply(FieldCopyWithData({if (content != null) #content: content}));
  @override
  THStringPart $make(CopyWithData data) =>
      THStringPart(data.get(#content, or: $value.content));

  @override
  THStringPartCopyWith<$R2, THStringPart, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THStringPartCopyWithImpl($value, $cast, t);
}
