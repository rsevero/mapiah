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
    }
    return _instance!;
  }

  @override
  final String id = 'THArea';

  static int _$mapiahID(THArea v) => v.mapiahID;
  static dynamic _arg$mapiahID(f) => f<int>();
  static const Field<THArea, dynamic> _f$mapiahID =
      Field('mapiahID', _$mapiahID, arg: _arg$mapiahID);
  static int _$parentMapiahID(THArea v) => v.parentMapiahID;
  static dynamic _arg$parentMapiahID(f) => f<int>();
  static const Field<THArea, dynamic> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, arg: _arg$parentMapiahID);
  static String? _$sameLineComment(THArea v) => v.sameLineComment;
  static dynamic _arg$sameLineComment(f) => f<String>();
  static const Field<THArea, dynamic> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, arg: _arg$sameLineComment);
  static String _$areaType(THArea v) => v.areaType;
  static const Field<THArea, String> _f$areaType =
      Field('areaType', _$areaType);
  static LinkedHashMap<String, THCommandOption> _$optionsMap(THArea v) =>
      v.optionsMap;
  static const Field<THArea, LinkedHashMap<String, THCommandOption>>
      _f$optionsMap = Field('optionsMap', _$optionsMap);

  @override
  final MappableFields<THArea> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
    #areaType: _f$areaType,
    #optionsMap: _f$optionsMap,
  };

  static THArea _instantiate(DecodingData data) {
    return THArea.notAddedToParent(
        data.dec(_f$mapiahID),
        data.dec(_f$parentMapiahID),
        data.dec(_f$sameLineComment),
        data.dec(_f$areaType),
        data.dec(_f$optionsMap));
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
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {dynamic mapiahID,
      dynamic parentMapiahID,
      dynamic sameLineComment,
      String? areaType,
      LinkedHashMap<String, THCommandOption>? optionsMap});
  THAreaCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THAreaCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, THArea, $Out>
    implements THAreaCopyWith<$R, THArea, $Out> {
  _THAreaCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THArea> $mapper = THAreaMapper.ensureInitialized();
  @override
  $R call(
          {Object? mapiahID = $none,
          Object? parentMapiahID = $none,
          Object? sameLineComment = $none,
          String? areaType,
          LinkedHashMap<String, THCommandOption>? optionsMap}) =>
      $apply(FieldCopyWithData({
        if (mapiahID != $none) #mapiahID: mapiahID,
        if (parentMapiahID != $none) #parentMapiahID: parentMapiahID,
        if (sameLineComment != $none) #sameLineComment: sameLineComment,
        if (areaType != null) #areaType: areaType,
        if (optionsMap != null) #optionsMap: optionsMap
      }));
  @override
  THArea $make(CopyWithData data) => THArea.notAddedToParent(
      data.get(#mapiahID, or: $value.mapiahID),
      data.get(#parentMapiahID, or: $value.parentMapiahID),
      data.get(#sameLineComment, or: $value.sameLineComment),
      data.get(#areaType, or: $value.areaType),
      data.get(#optionsMap, or: $value.optionsMap));

  @override
  THAreaCopyWith<$R2, THArea, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _THAreaCopyWithImpl($value, $cast, t);
}
