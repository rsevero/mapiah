// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_scrap.dart';

class THScrapMapper extends ClassMapperBase<THScrap> {
  THScrapMapper._();

  static THScrapMapper? _instance;
  static THScrapMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THScrapMapper._());
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THScrap';

  static THParent _$parent(THScrap v) => v.parent;
  static const Field<THScrap, THParent> _f$parent = Field('parent', _$parent);
  static String _$_thID(THScrap v) => v._thID;
  static const Field<THScrap, String> _f$_thID =
      Field('_thID', _$_thID, key: 'thID');
  static int _$parentMapiahID(THScrap v) => v.parentMapiahID;
  static const Field<THScrap, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, mode: FieldMode.member);
  static String? _$sameLineComment(THScrap v) => v.sameLineComment;
  static const Field<THScrap, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THScrap> fields = const {
    #parent: _f$parent,
    #_thID: _f$_thID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THScrap _instantiate(DecodingData data) {
    return THScrap(data.dec(_f$parent), data.dec(_f$_thID));
  }

  @override
  final Function instantiate = _instantiate;

  static THScrap fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THScrap>(map);
  }

  static THScrap fromJson(String json) {
    return ensureInitialized().decodeJson<THScrap>(json);
  }
}

mixin THScrapMappable {
  String toJson() {
    return THScrapMapper.ensureInitialized()
        .encodeJson<THScrap>(this as THScrap);
  }

  Map<String, dynamic> toMap() {
    return THScrapMapper.ensureInitialized()
        .encodeMap<THScrap>(this as THScrap);
  }

  THScrapCopyWith<THScrap, THScrap, THScrap> get copyWith =>
      _THScrapCopyWithImpl(this as THScrap, $identity, $identity);
  @override
  String toString() {
    return THScrapMapper.ensureInitialized().stringifyValue(this as THScrap);
  }

  @override
  bool operator ==(Object other) {
    return THScrapMapper.ensureInitialized()
        .equalsValue(this as THScrap, other);
  }

  @override
  int get hashCode {
    return THScrapMapper.ensureInitialized().hashValue(this as THScrap);
  }
}

extension THScrapValueCopy<$R, $Out> on ObjectCopyWith<$R, THScrap, $Out> {
  THScrapCopyWith<$R, THScrap, $Out> get $asTHScrap =>
      $base.as((v, t, t2) => _THScrapCopyWithImpl(v, t, t2));
}

abstract class THScrapCopyWith<$R, $In extends THScrap, $Out>
    implements
        THElementCopyWith<$R, $In, $Out>,
        THHasTHIDCopyWith<$R, $In, $Out> {
  @override
  $R call({THParent? parent, String? thID});
  THScrapCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THScrapCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THScrap, $Out>
    implements THScrapCopyWith<$R, THScrap, $Out> {
  _THScrapCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THScrap> $mapper =
      THScrapMapper.ensureInitialized();
  @override
  $R call({THParent? parent, String? thID}) => $apply(FieldCopyWithData(
      {if (parent != null) #parent: parent, if (thID != null) #thID: thID}));
  @override
  THScrap $make(CopyWithData data) => THScrap(
      data.get(#parent, or: $value.parent), data.get(#thID, or: $value._thID));

  @override
  THScrapCopyWith<$R2, THScrap, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _THScrapCopyWithImpl($value, $cast, t);
}
