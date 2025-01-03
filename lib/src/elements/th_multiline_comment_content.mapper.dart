// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_multiline_comment_content.dart';

class THMultilineCommentContentMapper
    extends ClassMapperBase<THMultilineCommentContent> {
  THMultilineCommentContentMapper._();

  static THMultilineCommentContentMapper? _instance;
  static THMultilineCommentContentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THMultilineCommentContentMapper._());
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THMultilineCommentContent';

  static THParent _$parent(THMultilineCommentContent v) => v.parent;
  static const Field<THMultilineCommentContent, THParent> _f$parent =
      Field('parent', _$parent);
  static String _$content(THMultilineCommentContent v) => v.content;
  static const Field<THMultilineCommentContent, String> _f$content =
      Field('content', _$content);
  static int _$parentMapiahID(THMultilineCommentContent v) => v.parentMapiahID;
  static const Field<THMultilineCommentContent, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, mode: FieldMode.member);
  static String? _$sameLineComment(THMultilineCommentContent v) =>
      v.sameLineComment;
  static const Field<THMultilineCommentContent, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THMultilineCommentContent> fields = const {
    #parent: _f$parent,
    #content: _f$content,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THMultilineCommentContent _instantiate(DecodingData data) {
    return THMultilineCommentContent(data.dec(_f$parent), data.dec(_f$content));
  }

  @override
  final Function instantiate = _instantiate;

  static THMultilineCommentContent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THMultilineCommentContent>(map);
  }

  static THMultilineCommentContent fromJson(String json) {
    return ensureInitialized().decodeJson<THMultilineCommentContent>(json);
  }
}

mixin THMultilineCommentContentMappable {
  String toJson() {
    return THMultilineCommentContentMapper.ensureInitialized()
        .encodeJson<THMultilineCommentContent>(
            this as THMultilineCommentContent);
  }

  Map<String, dynamic> toMap() {
    return THMultilineCommentContentMapper.ensureInitialized()
        .encodeMap<THMultilineCommentContent>(
            this as THMultilineCommentContent);
  }

  THMultilineCommentContentCopyWith<THMultilineCommentContent,
          THMultilineCommentContent, THMultilineCommentContent>
      get copyWith => _THMultilineCommentContentCopyWithImpl(
          this as THMultilineCommentContent, $identity, $identity);
  @override
  String toString() {
    return THMultilineCommentContentMapper.ensureInitialized()
        .stringifyValue(this as THMultilineCommentContent);
  }

  @override
  bool operator ==(Object other) {
    return THMultilineCommentContentMapper.ensureInitialized()
        .equalsValue(this as THMultilineCommentContent, other);
  }

  @override
  int get hashCode {
    return THMultilineCommentContentMapper.ensureInitialized()
        .hashValue(this as THMultilineCommentContent);
  }
}

extension THMultilineCommentContentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THMultilineCommentContent, $Out> {
  THMultilineCommentContentCopyWith<$R, THMultilineCommentContent, $Out>
      get $asTHMultilineCommentContent => $base
          .as((v, t, t2) => _THMultilineCommentContentCopyWithImpl(v, t, t2));
}

abstract class THMultilineCommentContentCopyWith<
    $R,
    $In extends THMultilineCommentContent,
    $Out> implements THElementCopyWith<$R, $In, $Out> {
  @override
  $R call({THParent? parent, String? content});
  THMultilineCommentContentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THMultilineCommentContentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THMultilineCommentContent, $Out>
    implements
        THMultilineCommentContentCopyWith<$R, THMultilineCommentContent, $Out> {
  _THMultilineCommentContentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THMultilineCommentContent> $mapper =
      THMultilineCommentContentMapper.ensureInitialized();
  @override
  $R call({THParent? parent, String? content}) => $apply(FieldCopyWithData({
        if (parent != null) #parent: parent,
        if (content != null) #content: content
      }));
  @override
  THMultilineCommentContent $make(CopyWithData data) =>
      THMultilineCommentContent(data.get(#parent, or: $value.parent),
          data.get(#content, or: $value.content));

  @override
  THMultilineCommentContentCopyWith<$R2, THMultilineCommentContent, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THMultilineCommentContentCopyWithImpl($value, $cast, t);
}
