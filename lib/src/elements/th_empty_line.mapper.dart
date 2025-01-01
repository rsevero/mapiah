// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_empty_line.dart';

class THEmptyLineMapper extends ClassMapperBase<THEmptyLine> {
  THEmptyLineMapper._();

  static THEmptyLineMapper? _instance;
  static THEmptyLineMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THEmptyLineMapper._());
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THEmptyLine';

  static THParent _$parent(THEmptyLine v) => v.parent;
  static const Field<THEmptyLine, THParent> _f$parent =
      Field('parent', _$parent);
  static int _$parentMapiahID(THEmptyLine v) => v.parentMapiahID;
  static const Field<THEmptyLine, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, mode: FieldMode.member);
  static String? _$sameLineComment(THEmptyLine v) => v.sameLineComment;
  static const Field<THEmptyLine, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THEmptyLine> fields = const {
    #parent: _f$parent,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THEmptyLine _instantiate(DecodingData data) {
    return THEmptyLine(data.dec(_f$parent));
  }

  @override
  final Function instantiate = _instantiate;

  static THEmptyLine fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THEmptyLine>(map);
  }

  static THEmptyLine fromJson(String json) {
    return ensureInitialized().decodeJson<THEmptyLine>(json);
  }
}

mixin THEmptyLineMappable {
  String toJson() {
    return THEmptyLineMapper.ensureInitialized()
        .encodeJson<THEmptyLine>(this as THEmptyLine);
  }

  Map<String, dynamic> toMap() {
    return THEmptyLineMapper.ensureInitialized()
        .encodeMap<THEmptyLine>(this as THEmptyLine);
  }

  THEmptyLineCopyWith<THEmptyLine, THEmptyLine, THEmptyLine> get copyWith =>
      _THEmptyLineCopyWithImpl(this as THEmptyLine, $identity, $identity);
  @override
  String toString() {
    return THEmptyLineMapper.ensureInitialized()
        .stringifyValue(this as THEmptyLine);
  }

  @override
  bool operator ==(Object other) {
    return THEmptyLineMapper.ensureInitialized()
        .equalsValue(this as THEmptyLine, other);
  }

  @override
  int get hashCode {
    return THEmptyLineMapper.ensureInitialized().hashValue(this as THEmptyLine);
  }
}

extension THEmptyLineValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THEmptyLine, $Out> {
  THEmptyLineCopyWith<$R, THEmptyLine, $Out> get $asTHEmptyLine =>
      $base.as((v, t, t2) => _THEmptyLineCopyWithImpl(v, t, t2));
}

abstract class THEmptyLineCopyWith<$R, $In extends THEmptyLine, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  @override
  $R call({THParent? parent});
  THEmptyLineCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THEmptyLineCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THEmptyLine, $Out>
    implements THEmptyLineCopyWith<$R, THEmptyLine, $Out> {
  _THEmptyLineCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THEmptyLine> $mapper =
      THEmptyLineMapper.ensureInitialized();
  @override
  $R call({THParent? parent}) =>
      $apply(FieldCopyWithData({if (parent != null) #parent: parent}));
  @override
  THEmptyLine $make(CopyWithData data) =>
      THEmptyLine(data.get(#parent, or: $value.parent));

  @override
  THEmptyLineCopyWith<$R2, THEmptyLine, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THEmptyLineCopyWithImpl($value, $cast, t);
}
