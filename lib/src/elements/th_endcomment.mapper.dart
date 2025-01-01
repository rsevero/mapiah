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
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THEndcomment';

  static THParent _$parent(THEndcomment v) => v.parent;
  static const Field<THEndcomment, THParent> _f$parent =
      Field('parent', _$parent);
  static int _$parentMapiahID(THEndcomment v) => v.parentMapiahID;
  static const Field<THEndcomment, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, mode: FieldMode.member);
  static String? _$sameLineComment(THEndcomment v) => v.sameLineComment;
  static const Field<THEndcomment, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THEndcomment> fields = const {
    #parent: _f$parent,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THEndcomment _instantiate(DecodingData data) {
    return THEndcomment(data.dec(_f$parent));
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
    implements THElementCopyWith<$R, $In, $Out> {
  @override
  $R call({THParent? parent});
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
  $R call({THParent? parent}) =>
      $apply(FieldCopyWithData({if (parent != null) #parent: parent}));
  @override
  THEndcomment $make(CopyWithData data) =>
      THEndcomment(data.get(#parent, or: $value.parent));

  @override
  THEndcommentCopyWith<$R2, THEndcomment, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THEndcommentCopyWithImpl($value, $cast, t);
}
