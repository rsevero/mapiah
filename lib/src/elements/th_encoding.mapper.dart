// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_encoding.dart';

class THEncodingMapper extends ClassMapperBase<THEncoding> {
  THEncodingMapper._();

  static THEncodingMapper? _instance;
  static THEncodingMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THEncodingMapper._());
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THEncoding';

  static THParent _$parent(THEncoding v) => v.parent;
  static const Field<THEncoding, THParent> _f$parent =
      Field('parent', _$parent);
  static int _$parentMapiahID(THEncoding v) => v.parentMapiahID;
  static const Field<THEncoding, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, mode: FieldMode.member);
  static String? _$sameLineComment(THEncoding v) => v.sameLineComment;
  static const Field<THEncoding, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THEncoding> fields = const {
    #parent: _f$parent,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THEncoding _instantiate(DecodingData data) {
    return THEncoding(data.dec(_f$parent));
  }

  @override
  final Function instantiate = _instantiate;

  static THEncoding fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THEncoding>(map);
  }

  static THEncoding fromJson(String json) {
    return ensureInitialized().decodeJson<THEncoding>(json);
  }
}

mixin THEncodingMappable {
  String toJson() {
    return THEncodingMapper.ensureInitialized()
        .encodeJson<THEncoding>(this as THEncoding);
  }

  Map<String, dynamic> toMap() {
    return THEncodingMapper.ensureInitialized()
        .encodeMap<THEncoding>(this as THEncoding);
  }

  THEncodingCopyWith<THEncoding, THEncoding, THEncoding> get copyWith =>
      _THEncodingCopyWithImpl(this as THEncoding, $identity, $identity);
  @override
  String toString() {
    return THEncodingMapper.ensureInitialized()
        .stringifyValue(this as THEncoding);
  }

  @override
  bool operator ==(Object other) {
    return THEncodingMapper.ensureInitialized()
        .equalsValue(this as THEncoding, other);
  }

  @override
  int get hashCode {
    return THEncodingMapper.ensureInitialized().hashValue(this as THEncoding);
  }
}

extension THEncodingValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THEncoding, $Out> {
  THEncodingCopyWith<$R, THEncoding, $Out> get $asTHEncoding =>
      $base.as((v, t, t2) => _THEncodingCopyWithImpl(v, t, t2));
}

abstract class THEncodingCopyWith<$R, $In extends THEncoding, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  @override
  $R call({THParent? parent});
  THEncodingCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THEncodingCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THEncoding, $Out>
    implements THEncodingCopyWith<$R, THEncoding, $Out> {
  _THEncodingCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THEncoding> $mapper =
      THEncodingMapper.ensureInitialized();
  @override
  $R call({THParent? parent}) =>
      $apply(FieldCopyWithData({if (parent != null) #parent: parent}));
  @override
  THEncoding $make(CopyWithData data) =>
      THEncoding(data.get(#parent, or: $value.parent));

  @override
  THEncodingCopyWith<$R2, THEncoding, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THEncodingCopyWithImpl($value, $cast, t);
}
