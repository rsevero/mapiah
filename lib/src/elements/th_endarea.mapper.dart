// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_endarea.dart';

class THEndareaMapper extends ClassMapperBase<THEndarea> {
  THEndareaMapper._();

  static THEndareaMapper? _instance;
  static THEndareaMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THEndareaMapper._());
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THEndarea';

  static THParent _$parent(THEndarea v) => v.parent;
  static const Field<THEndarea, THParent> _f$parent = Field('parent', _$parent);
  static int _$parentMapiahID(THEndarea v) => v.parentMapiahID;
  static const Field<THEndarea, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, mode: FieldMode.member);
  static String? _$sameLineComment(THEndarea v) => v.sameLineComment;
  static const Field<THEndarea, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THEndarea> fields = const {
    #parent: _f$parent,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THEndarea _instantiate(DecodingData data) {
    return THEndarea(data.dec(_f$parent));
  }

  @override
  final Function instantiate = _instantiate;

  static THEndarea fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THEndarea>(map);
  }

  static THEndarea fromJson(String json) {
    return ensureInitialized().decodeJson<THEndarea>(json);
  }
}

mixin THEndareaMappable {
  String toJson() {
    return THEndareaMapper.ensureInitialized()
        .encodeJson<THEndarea>(this as THEndarea);
  }

  Map<String, dynamic> toMap() {
    return THEndareaMapper.ensureInitialized()
        .encodeMap<THEndarea>(this as THEndarea);
  }

  THEndareaCopyWith<THEndarea, THEndarea, THEndarea> get copyWith =>
      _THEndareaCopyWithImpl(this as THEndarea, $identity, $identity);
  @override
  String toString() {
    return THEndareaMapper.ensureInitialized()
        .stringifyValue(this as THEndarea);
  }

  @override
  bool operator ==(Object other) {
    return THEndareaMapper.ensureInitialized()
        .equalsValue(this as THEndarea, other);
  }

  @override
  int get hashCode {
    return THEndareaMapper.ensureInitialized().hashValue(this as THEndarea);
  }
}

extension THEndareaValueCopy<$R, $Out> on ObjectCopyWith<$R, THEndarea, $Out> {
  THEndareaCopyWith<$R, THEndarea, $Out> get $asTHEndarea =>
      $base.as((v, t, t2) => _THEndareaCopyWithImpl(v, t, t2));
}

abstract class THEndareaCopyWith<$R, $In extends THEndarea, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  @override
  $R call({THParent? parent});
  THEndareaCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THEndareaCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THEndarea, $Out>
    implements THEndareaCopyWith<$R, THEndarea, $Out> {
  _THEndareaCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THEndarea> $mapper =
      THEndareaMapper.ensureInitialized();
  @override
  $R call({THParent? parent}) =>
      $apply(FieldCopyWithData({if (parent != null) #parent: parent}));
  @override
  THEndarea $make(CopyWithData data) =>
      THEndarea(data.get(#parent, or: $value.parent));

  @override
  THEndareaCopyWith<$R2, THEndarea, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THEndareaCopyWithImpl($value, $cast, t);
}
