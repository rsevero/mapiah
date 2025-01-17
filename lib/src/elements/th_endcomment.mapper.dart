// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_endcomment.dart';

class THEndcommentMapper extends ClassMapperBase<THEndcomment> {
  THEndcommentMapper._();

  static THEndcommentMapper? _instance;
  static THEndcommentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THEndcommentMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THEndcomment';

  static int _$mapiahID(THEndcomment v) => v.mapiahID;
  static dynamic _arg$mapiahID(f) => f<int>();
  static const Field<THEndcomment, dynamic> _f$mapiahID =
      Field('mapiahID', _$mapiahID, arg: _arg$mapiahID);
  static int _$parentMapiahID(THEndcomment v) => v.parentMapiahID;
  static dynamic _arg$parentMapiahID(f) => f<int>();
  static const Field<THEndcomment, dynamic> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, arg: _arg$parentMapiahID);
  static String? _$sameLineComment(THEndcomment v) => v.sameLineComment;
  static dynamic _arg$sameLineComment(f) => f<String>();
  static const Field<THEndcomment, dynamic> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, arg: _arg$sameLineComment);

  @override
  final MappableFields<THEndcomment> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THEndcomment _instantiate(DecodingData data) {
    return THEndcomment.notAddToParent(data.dec(_f$mapiahID),
        data.dec(_f$parentMapiahID), data.dec(_f$sameLineComment));
  }

  @override
  final Function instantiate = _instantiate;

  static THEndcomment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THEndcomment>(map);
  }

  static THEndcomment fromJson(String json) {
    return ensureInitialized().decodeJson<THEndcomment>(json);
  }
}

mixin THEndcommentMappable {
  String toJson() {
    return THEndcommentMapper.ensureInitialized()
        .encodeJson<THEndcomment>(this as THEndcomment);
  }

  Map<String, dynamic> toMap() {
    return THEndcommentMapper.ensureInitialized()
        .encodeMap<THEndcomment>(this as THEndcomment);
  }

  THEndcommentCopyWith<THEndcomment, THEndcomment, THEndcomment> get copyWith =>
      _THEndcommentCopyWithImpl(this as THEndcomment, $identity, $identity);
  @override
  String toString() {
    return THEndcommentMapper.ensureInitialized()
        .stringifyValue(this as THEndcomment);
  }

  @override
  bool operator ==(Object other) {
    return THEndcommentMapper.ensureInitialized()
        .equalsValue(this as THEndcomment, other);
  }

  @override
  int get hashCode {
    return THEndcommentMapper.ensureInitialized()
        .hashValue(this as THEndcomment);
  }
}

extension THEndcommentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THEndcomment, $Out> {
  THEndcommentCopyWith<$R, THEndcomment, $Out> get $asTHEndcomment =>
      $base.as((v, t, t2) => _THEndcommentCopyWithImpl(v, t, t2));
}

abstract class THEndcommentCopyWith<$R, $In extends THEndcomment, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({dynamic mapiahID, dynamic parentMapiahID, dynamic sameLineComment});
  THEndcommentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THEndcommentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THEndcomment, $Out>
    implements THEndcommentCopyWith<$R, THEndcomment, $Out> {
  _THEndcommentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THEndcomment> $mapper =
      THEndcommentMapper.ensureInitialized();
  @override
  $R call(
          {Object? mapiahID = $none,
          Object? parentMapiahID = $none,
          Object? sameLineComment = $none}) =>
      $apply(FieldCopyWithData({
        if (mapiahID != $none) #mapiahID: mapiahID,
        if (parentMapiahID != $none) #parentMapiahID: parentMapiahID,
        if (sameLineComment != $none) #sameLineComment: sameLineComment
      }));
  @override
  THEndcomment $make(CopyWithData data) => THEndcomment.notAddToParent(
      data.get(#mapiahID, or: $value.mapiahID),
      data.get(#parentMapiahID, or: $value.parentMapiahID),
      data.get(#sameLineComment, or: $value.sameLineComment));

  @override
  THEndcommentCopyWith<$R2, THEndcomment, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THEndcommentCopyWithImpl($value, $cast, t);
}
