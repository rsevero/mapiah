// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_area_border_thid.dart';

class THAreaBorderTHIDMapper extends ClassMapperBase<THAreaBorderTHID> {
  THAreaBorderTHIDMapper._();

  static THAreaBorderTHIDMapper? _instance;
  static THAreaBorderTHIDMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THAreaBorderTHIDMapper._());
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THAreaBorderTHID';

  static THParent _$parent(THAreaBorderTHID v) => v.parent;
  static const Field<THAreaBorderTHID, THParent> _f$parent =
      Field('parent', _$parent);
  static String _$id(THAreaBorderTHID v) => v.id;
  static const Field<THAreaBorderTHID, String> _f$id = Field('id', _$id);
  static int _$parentMapiahID(THAreaBorderTHID v) => v.parentMapiahID;
  static const Field<THAreaBorderTHID, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, mode: FieldMode.member);
  static String? _$sameLineComment(THAreaBorderTHID v) => v.sameLineComment;
  static const Field<THAreaBorderTHID, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THAreaBorderTHID> fields = const {
    #parent: _f$parent,
    #id: _f$id,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THAreaBorderTHID _instantiate(DecodingData data) {
    return THAreaBorderTHID(data.dec(_f$parent), data.dec(_f$id));
  }

  @override
  final Function instantiate = _instantiate;

  static THAreaBorderTHID fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THAreaBorderTHID>(map);
  }

  static THAreaBorderTHID fromJson(String json) {
    return ensureInitialized().decodeJson<THAreaBorderTHID>(json);
  }
}

mixin THAreaBorderTHIDMappable {
  String toJson() {
    return THAreaBorderTHIDMapper.ensureInitialized()
        .encodeJson<THAreaBorderTHID>(this as THAreaBorderTHID);
  }

  Map<String, dynamic> toMap() {
    return THAreaBorderTHIDMapper.ensureInitialized()
        .encodeMap<THAreaBorderTHID>(this as THAreaBorderTHID);
  }

  THAreaBorderTHIDCopyWith<THAreaBorderTHID, THAreaBorderTHID, THAreaBorderTHID>
      get copyWith => _THAreaBorderTHIDCopyWithImpl(
          this as THAreaBorderTHID, $identity, $identity);
  @override
  String toString() {
    return THAreaBorderTHIDMapper.ensureInitialized()
        .stringifyValue(this as THAreaBorderTHID);
  }

  @override
  bool operator ==(Object other) {
    return THAreaBorderTHIDMapper.ensureInitialized()
        .equalsValue(this as THAreaBorderTHID, other);
  }

  @override
  int get hashCode {
    return THAreaBorderTHIDMapper.ensureInitialized()
        .hashValue(this as THAreaBorderTHID);
  }
}

extension THAreaBorderTHIDValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THAreaBorderTHID, $Out> {
  THAreaBorderTHIDCopyWith<$R, THAreaBorderTHID, $Out>
      get $asTHAreaBorderTHID =>
          $base.as((v, t, t2) => _THAreaBorderTHIDCopyWithImpl(v, t, t2));
}

abstract class THAreaBorderTHIDCopyWith<$R, $In extends THAreaBorderTHID, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  @override
  $R call({THParent? parent, String? id});
  THAreaBorderTHIDCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THAreaBorderTHIDCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THAreaBorderTHID, $Out>
    implements THAreaBorderTHIDCopyWith<$R, THAreaBorderTHID, $Out> {
  _THAreaBorderTHIDCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THAreaBorderTHID> $mapper =
      THAreaBorderTHIDMapper.ensureInitialized();
  @override
  $R call({THParent? parent, String? id}) => $apply(FieldCopyWithData(
      {if (parent != null) #parent: parent, if (id != null) #id: id}));
  @override
  THAreaBorderTHID $make(CopyWithData data) => THAreaBorderTHID(
      data.get(#parent, or: $value.parent), data.get(#id, or: $value.id));

  @override
  THAreaBorderTHIDCopyWith<$R2, THAreaBorderTHID, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THAreaBorderTHIDCopyWithImpl($value, $cast, t);
}
