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
    }
    return _instance!;
  }

  @override
  final String id = 'THEmptyLine';

  static int _$mapiahID(THEmptyLine v) => v.mapiahID;
  static dynamic _arg$mapiahID(f) => f<int>();
  static const Field<THEmptyLine, dynamic> _f$mapiahID =
      Field('mapiahID', _$mapiahID, arg: _arg$mapiahID);
  static int _$parentMapiahID(THEmptyLine v) => v.parentMapiahID;
  static dynamic _arg$parentMapiahID(f) => f<int>();
  static const Field<THEmptyLine, dynamic> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, arg: _arg$parentMapiahID);
  static String? _$sameLineComment(THEmptyLine v) => v.sameLineComment;
  static dynamic _arg$sameLineComment(f) => f<String>();
  static const Field<THEmptyLine, dynamic> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, arg: _arg$sameLineComment);

  @override
  final MappableFields<THEmptyLine> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THEmptyLine _instantiate(DecodingData data) {
    return THEmptyLine.notAddToParent(data.dec(_f$mapiahID),
        data.dec(_f$parentMapiahID), data.dec(_f$sameLineComment));
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
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({dynamic mapiahID, dynamic parentMapiahID, dynamic sameLineComment});
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
  THEmptyLine $make(CopyWithData data) => THEmptyLine.notAddToParent(
      data.get(#mapiahID, or: $value.mapiahID),
      data.get(#parentMapiahID, or: $value.parentMapiahID),
      data.get(#sameLineComment, or: $value.sameLineComment));

  @override
  THEmptyLineCopyWith<$R2, THEmptyLine, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THEmptyLineCopyWithImpl($value, $cast, t);
}
