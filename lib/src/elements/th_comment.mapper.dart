// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_comment.dart';

class THCommentMapper extends ClassMapperBase<THComment> {
  THCommentMapper._();

  static THCommentMapper? _instance;
  static THCommentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THCommentMapper._());
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THComment';

  static int _$mapiahID(THComment v) => v.mapiahID;
  static const Field<THComment, int> _f$mapiahID =
      Field('mapiahID', _$mapiahID);
  static int _$parentMapiahID(THComment v) => v.parentMapiahID;
  static const Field<THComment, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String? _$sameLineComment(THComment v) => v.sameLineComment;
  static const Field<THComment, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment);
  static String _$content(THComment v) => v.content;
  static const Field<THComment, String> _f$content =
      Field('content', _$content);

  @override
  final MappableFields<THComment> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
    #content: _f$content,
  };

  static THComment _instantiate(DecodingData data) {
    return THComment.notAddToParent(
        data.dec(_f$mapiahID),
        data.dec(_f$parentMapiahID),
        data.dec(_f$sameLineComment),
        data.dec(_f$content));
  }

  @override
  final Function instantiate = _instantiate;

  static THComment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THComment>(map);
  }

  static THComment fromJson(String json) {
    return ensureInitialized().decodeJson<THComment>(json);
  }
}

mixin THCommentMappable {
  String toJson() {
    return THCommentMapper.ensureInitialized()
        .encodeJson<THComment>(this as THComment);
  }

  Map<String, dynamic> toMap() {
    return THCommentMapper.ensureInitialized()
        .encodeMap<THComment>(this as THComment);
  }

  THCommentCopyWith<THComment, THComment, THComment> get copyWith =>
      _THCommentCopyWithImpl(this as THComment, $identity, $identity);
  @override
  String toString() {
    return THCommentMapper.ensureInitialized()
        .stringifyValue(this as THComment);
  }

  @override
  bool operator ==(Object other) {
    return THCommentMapper.ensureInitialized()
        .equalsValue(this as THComment, other);
  }

  @override
  int get hashCode {
    return THCommentMapper.ensureInitialized().hashValue(this as THComment);
  }
}

extension THCommentValueCopy<$R, $Out> on ObjectCopyWith<$R, THComment, $Out> {
  THCommentCopyWith<$R, THComment, $Out> get $asTHComment =>
      $base.as((v, t, t2) => _THCommentCopyWithImpl(v, t, t2));
}

abstract class THCommentCopyWith<$R, $In extends THComment, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  @override
  $R call(
      {int? mapiahID,
      int? parentMapiahID,
      String? sameLineComment,
      String? content});
  THCommentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THCommentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THComment, $Out>
    implements THCommentCopyWith<$R, THComment, $Out> {
  _THCommentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THComment> $mapper =
      THCommentMapper.ensureInitialized();
  @override
  $R call(
          {int? mapiahID,
          int? parentMapiahID,
          Object? sameLineComment = $none,
          String? content}) =>
      $apply(FieldCopyWithData({
        if (mapiahID != null) #mapiahID: mapiahID,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (sameLineComment != $none) #sameLineComment: sameLineComment,
        if (content != null) #content: content
      }));
  @override
  THComment $make(CopyWithData data) => THComment.notAddToParent(
      data.get(#mapiahID, or: $value.mapiahID),
      data.get(#parentMapiahID, or: $value.parentMapiahID),
      data.get(#sameLineComment, or: $value.sameLineComment),
      data.get(#content, or: $value.content));

  @override
  THCommentCopyWith<$R2, THComment, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THCommentCopyWithImpl($value, $cast, t);
}
