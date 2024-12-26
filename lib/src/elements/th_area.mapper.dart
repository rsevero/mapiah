// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_area.dart';

class THAreaMapper extends ClassMapperBase<THArea> {
  THAreaMapper._();

  static THAreaMapper? _instance;
  static THAreaMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THAreaMapper._());
      THElementMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THArea';

  static THParent _$parent(THArea v) => v.parent;
  static const Field<THArea, THParent> _f$parent = Field('parent', _$parent);
  static String _$_areaType(THArea v) => v._areaType;
  static const Field<THArea, String> _f$_areaType =
      Field('_areaType', _$_areaType, key: 'areaType');
  static String? _$sameLineComment(THArea v) => v.sameLineComment;
  static const Field<THArea, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THArea> fields = const {
    #parent: _f$parent,
    #_areaType: _f$_areaType,
    #sameLineComment: _f$sameLineComment,
  };

  static THArea _instantiate(DecodingData data) {
    return THArea(data.dec(_f$parent), data.dec(_f$_areaType));
  }

  @override
  final Function instantiate = _instantiate;

  static THArea fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THArea>(map);
  }

  static THArea fromJson(String json) {
    return ensureInitialized().decodeJson<THArea>(json);
  }
}

mixin THAreaMappable {
  String toJson() {
    return THAreaMapper.ensureInitialized().encodeJson<THArea>(this as THArea);
  }

  Map<String, dynamic> toMap() {
    return THAreaMapper.ensureInitialized().encodeMap<THArea>(this as THArea);
  }

  THAreaCopyWith<THArea, THArea, THArea> get copyWith =>
      _THAreaCopyWithImpl(this as THArea, $identity, $identity);
  @override
  String toString() {
    return THAreaMapper.ensureInitialized().stringifyValue(this as THArea);
  }

  @override
  bool operator ==(Object other) {
    return THAreaMapper.ensureInitialized().equalsValue(this as THArea, other);
  }

  @override
  int get hashCode {
    return THAreaMapper.ensureInitialized().hashValue(this as THArea);
  }
}

extension THAreaValueCopy<$R, $Out> on ObjectCopyWith<$R, THArea, $Out> {
  THAreaCopyWith<$R, THArea, $Out> get $asTHArea =>
      $base.as((v, t, t2) => _THAreaCopyWithImpl(v, t, t2));
}

abstract class THAreaCopyWith<$R, $In extends THArea, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  @override
  $R call({THParent? parent, String? areaType});
  THAreaCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THAreaCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, THArea, $Out>
    implements THAreaCopyWith<$R, THArea, $Out> {
  _THAreaCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THArea> $mapper = THAreaMapper.ensureInitialized();
  @override
  $R call({THParent? parent, String? areaType}) => $apply(FieldCopyWithData({
        if (parent != null) #parent: parent,
        if (areaType != null) #areaType: areaType
      }));
  @override
  THArea $make(CopyWithData data) => THArea(
      data.get(#parent, or: $value.parent),
      data.get(#areaType, or: $value._areaType));

  @override
  THAreaCopyWith<$R2, THArea, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _THAreaCopyWithImpl($value, $cast, t);
}
