// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_endline.dart';

class THEndlineMapper extends ClassMapperBase<THEndline> {
  THEndlineMapper._();

  static THEndlineMapper? _instance;
  static THEndlineMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THEndlineMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THEndline';

  static int _$mapiahID(THEndline v) => v.mapiahID;
  static dynamic _arg$mapiahID(f) => f<int>();
  static const Field<THEndline, dynamic> _f$mapiahID =
      Field('mapiahID', _$mapiahID, arg: _arg$mapiahID);
  static int _$parentMapiahID(THEndline v) => v.parentMapiahID;
  static dynamic _arg$parentMapiahID(f) => f<int>();
  static const Field<THEndline, dynamic> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, arg: _arg$parentMapiahID);
  static String? _$sameLineComment(THEndline v) => v.sameLineComment;
  static dynamic _arg$sameLineComment(f) => f<String>();
  static const Field<THEndline, dynamic> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, arg: _arg$sameLineComment);

  @override
  final MappableFields<THEndline> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THEndline _instantiate(DecodingData data) {
    return THEndline.notAddToParent(data.dec(_f$mapiahID),
        data.dec(_f$parentMapiahID), data.dec(_f$sameLineComment));
  }

  @override
  final Function instantiate = _instantiate;

  static THEndline fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THEndline>(map);
  }

  static THEndline fromJson(String json) {
    return ensureInitialized().decodeJson<THEndline>(json);
  }
}

mixin THEndlineMappable {
  String toJson() {
    return THEndlineMapper.ensureInitialized()
        .encodeJson<THEndline>(this as THEndline);
  }

  Map<String, dynamic> toMap() {
    return THEndlineMapper.ensureInitialized()
        .encodeMap<THEndline>(this as THEndline);
  }

  THEndlineCopyWith<THEndline, THEndline, THEndline> get copyWith =>
      _THEndlineCopyWithImpl(this as THEndline, $identity, $identity);
  @override
  String toString() {
    return THEndlineMapper.ensureInitialized()
        .stringifyValue(this as THEndline);
  }

  @override
  bool operator ==(Object other) {
    return THEndlineMapper.ensureInitialized()
        .equalsValue(this as THEndline, other);
  }

  @override
  int get hashCode {
    return THEndlineMapper.ensureInitialized().hashValue(this as THEndline);
  }
}

extension THEndlineValueCopy<$R, $Out> on ObjectCopyWith<$R, THEndline, $Out> {
  THEndlineCopyWith<$R, THEndline, $Out> get $asTHEndline =>
      $base.as((v, t, t2) => _THEndlineCopyWithImpl(v, t, t2));
}

abstract class THEndlineCopyWith<$R, $In extends THEndline, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({dynamic mapiahID, dynamic parentMapiahID, dynamic sameLineComment});
  THEndlineCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THEndlineCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THEndline, $Out>
    implements THEndlineCopyWith<$R, THEndline, $Out> {
  _THEndlineCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THEndline> $mapper =
      THEndlineMapper.ensureInitialized();
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
  THEndline $make(CopyWithData data) => THEndline.notAddToParent(
      data.get(#mapiahID, or: $value.mapiahID),
      data.get(#parentMapiahID, or: $value.parentMapiahID),
      data.get(#sameLineComment, or: $value.sameLineComment));

  @override
  THEndlineCopyWith<$R2, THEndline, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THEndlineCopyWithImpl($value, $cast, t);
}
