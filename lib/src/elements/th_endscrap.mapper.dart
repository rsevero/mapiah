// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_endscrap.dart';

class THEndscrapMapper extends ClassMapperBase<THEndscrap> {
  THEndscrapMapper._();

  static THEndscrapMapper? _instance;
  static THEndscrapMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THEndscrapMapper._());
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THEndscrap';

  static int _$mapiahID(THEndscrap v) => v.mapiahID;
  static const Field<THEndscrap, int> _f$mapiahID =
      Field('mapiahID', _$mapiahID);
  static int _$parentMapiahID(THEndscrap v) => v.parentMapiahID;
  static const Field<THEndscrap, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String? _$sameLineComment(THEndscrap v) => v.sameLineComment;
  static const Field<THEndscrap, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment);

  @override
  final MappableFields<THEndscrap> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THEndscrap _instantiate(DecodingData data) {
    return THEndscrap.notAddToParent(data.dec(_f$mapiahID),
        data.dec(_f$parentMapiahID), data.dec(_f$sameLineComment));
  }

  @override
  final Function instantiate = _instantiate;

  static THEndscrap fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THEndscrap>(map);
  }

  static THEndscrap fromJson(String json) {
    return ensureInitialized().decodeJson<THEndscrap>(json);
  }
}

mixin THEndscrapMappable {
  String toJson() {
    return THEndscrapMapper.ensureInitialized()
        .encodeJson<THEndscrap>(this as THEndscrap);
  }

  Map<String, dynamic> toMap() {
    return THEndscrapMapper.ensureInitialized()
        .encodeMap<THEndscrap>(this as THEndscrap);
  }

  THEndscrapCopyWith<THEndscrap, THEndscrap, THEndscrap> get copyWith =>
      _THEndscrapCopyWithImpl(this as THEndscrap, $identity, $identity);
  @override
  String toString() {
    return THEndscrapMapper.ensureInitialized()
        .stringifyValue(this as THEndscrap);
  }

  @override
  bool operator ==(Object other) {
    return THEndscrapMapper.ensureInitialized()
        .equalsValue(this as THEndscrap, other);
  }

  @override
  int get hashCode {
    return THEndscrapMapper.ensureInitialized().hashValue(this as THEndscrap);
  }
}

extension THEndscrapValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THEndscrap, $Out> {
  THEndscrapCopyWith<$R, THEndscrap, $Out> get $asTHEndscrap =>
      $base.as((v, t, t2) => _THEndscrapCopyWithImpl(v, t, t2));
}

abstract class THEndscrapCopyWith<$R, $In extends THEndscrap, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  @override
  $R call({int? mapiahID, int? parentMapiahID, String? sameLineComment});
  THEndscrapCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THEndscrapCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THEndscrap, $Out>
    implements THEndscrapCopyWith<$R, THEndscrap, $Out> {
  _THEndscrapCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THEndscrap> $mapper =
      THEndscrapMapper.ensureInitialized();
  @override
  $R call(
          {int? mapiahID,
          int? parentMapiahID,
          Object? sameLineComment = $none}) =>
      $apply(FieldCopyWithData({
        if (mapiahID != null) #mapiahID: mapiahID,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (sameLineComment != $none) #sameLineComment: sameLineComment
      }));
  @override
  THEndscrap $make(CopyWithData data) => THEndscrap.notAddToParent(
      data.get(#mapiahID, or: $value.mapiahID),
      data.get(#parentMapiahID, or: $value.parentMapiahID),
      data.get(#sameLineComment, or: $value.sameLineComment));

  @override
  THEndscrapCopyWith<$R2, THEndscrap, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THEndscrapCopyWithImpl($value, $cast, t);
}
