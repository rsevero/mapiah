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

  static int _$mapiahID(THEncoding v) => v.mapiahID;
  static const Field<THEncoding, int> _f$mapiahID =
      Field('mapiahID', _$mapiahID);
  static int _$parentMapiahID(THEncoding v) => v.parentMapiahID;
  static const Field<THEncoding, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String? _$sameLineComment(THEncoding v) => v.sameLineComment;
  static const Field<THEncoding, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment);
  static String _$encoding(THEncoding v) => v.encoding;
  static const Field<THEncoding, String> _f$encoding =
      Field('encoding', _$encoding);

  @override
  final MappableFields<THEncoding> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
    #encoding: _f$encoding,
  };

  static THEncoding _instantiate(DecodingData data) {
    return THEncoding.notAddToParent(
        data.dec(_f$mapiahID),
        data.dec(_f$parentMapiahID),
        data.dec(_f$sameLineComment),
        data.dec(_f$encoding));
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
  $R call(
      {int? mapiahID,
      int? parentMapiahID,
      String? sameLineComment,
      String? encoding});
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
  $R call(
          {int? mapiahID,
          int? parentMapiahID,
          Object? sameLineComment = $none,
          String? encoding}) =>
      $apply(FieldCopyWithData({
        if (mapiahID != null) #mapiahID: mapiahID,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (sameLineComment != $none) #sameLineComment: sameLineComment,
        if (encoding != null) #encoding: encoding
      }));
  @override
  THEncoding $make(CopyWithData data) => THEncoding.notAddToParent(
      data.get(#mapiahID, or: $value.mapiahID),
      data.get(#parentMapiahID, or: $value.parentMapiahID),
      data.get(#sameLineComment, or: $value.sameLineComment),
      data.get(#encoding, or: $value.encoding));

  @override
  THEncodingCopyWith<$R2, THEncoding, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THEncodingCopyWithImpl($value, $cast, t);
}
