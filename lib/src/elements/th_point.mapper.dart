// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_point.dart';

class THPointMapper extends ClassMapperBase<THPoint> {
  THPointMapper._();

  static THPointMapper? _instance;
  static THPointMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THPointMapper._());
      THElementMapper.ensureInitialized();
      THPositionPartMapper.ensureInitialized();
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THPoint';

  static int _$mapiahID(THPoint v) => v.mapiahID;
  static const Field<THPoint, int> _f$mapiahID = Field('mapiahID', _$mapiahID);
  static THParent _$parent(THPoint v) => v.parent;
  static const Field<THPoint, THParent> _f$parent = Field('parent', _$parent);
  static String? _$sameLineComment(THPoint v) => v.sameLineComment;
  static const Field<THPoint, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment);
  static THPositionPart _$position(THPoint v) => v.position;
  static const Field<THPoint, THPositionPart> _f$position =
      Field('position', _$position);
  static String _$pointType(THPoint v) => v.pointType;
  static const Field<THPoint, String> _f$pointType =
      Field('pointType', _$pointType);
  static List<String> _$optionsList(THPoint v) => v.optionsList;
  static const Field<THPoint, List<String>> _f$optionsList =
      Field('optionsList', _$optionsList);
  static Map<String, THCommandOption> _$optionsMap(THPoint v) => v.optionsMap;
  static const Field<THPoint, Map<String, THCommandOption>> _f$optionsMap =
      Field('optionsMap', _$optionsMap);
  static int _$parentMapiahID(THPoint v) => v.parentMapiahID;
  static const Field<THPoint, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, mode: FieldMode.member);

  @override
  final MappableFields<THPoint> fields = const {
    #mapiahID: _f$mapiahID,
    #parent: _f$parent,
    #sameLineComment: _f$sameLineComment,
    #position: _f$position,
    #pointType: _f$pointType,
    #optionsList: _f$optionsList,
    #optionsMap: _f$optionsMap,
    #parentMapiahID: _f$parentMapiahID,
  };

  static THPoint _instantiate(DecodingData data) {
    return THPoint.notAddedToParent(
        data.dec(_f$mapiahID),
        data.dec(_f$parent),
        data.dec(_f$sameLineComment),
        data.dec(_f$position),
        data.dec(_f$pointType),
        data.dec(_f$optionsList),
        data.dec(_f$optionsMap));
  }

  @override
  final Function instantiate = _instantiate;

  static THPoint fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THPoint>(map);
  }

  static THPoint fromJson(String json) {
    return ensureInitialized().decodeJson<THPoint>(json);
  }
}

mixin THPointMappable {
  String toJson() {
    return THPointMapper.ensureInitialized()
        .encodeJson<THPoint>(this as THPoint);
  }

  Map<String, dynamic> toMap() {
    return THPointMapper.ensureInitialized()
        .encodeMap<THPoint>(this as THPoint);
  }

  THPointCopyWith<THPoint, THPoint, THPoint> get copyWith =>
      _THPointCopyWithImpl(this as THPoint, $identity, $identity);
  @override
  String toString() {
    return THPointMapper.ensureInitialized().stringifyValue(this as THPoint);
  }

  @override
  bool operator ==(Object other) {
    return THPointMapper.ensureInitialized()
        .equalsValue(this as THPoint, other);
  }

  @override
  int get hashCode {
    return THPointMapper.ensureInitialized().hashValue(this as THPoint);
  }
}

extension THPointValueCopy<$R, $Out> on ObjectCopyWith<$R, THPoint, $Out> {
  THPointCopyWith<$R, THPoint, $Out> get $asTHPoint =>
      $base.as((v, t, t2) => _THPointCopyWithImpl(v, t, t2));
}

abstract class THPointCopyWith<$R, $In extends THPoint, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get position;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get optionsList;
  MapCopyWith<$R, String, THCommandOption,
      ObjectCopyWith<$R, THCommandOption, THCommandOption>> get optionsMap;
  @override
  $R call(
      {int? mapiahID,
      THParent? parent,
      String? sameLineComment,
      THPositionPart? position,
      String? pointType,
      List<String>? optionsList,
      Map<String, THCommandOption>? optionsMap});
  THPointCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THPointCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THPoint, $Out>
    implements THPointCopyWith<$R, THPoint, $Out> {
  _THPointCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THPoint> $mapper =
      THPointMapper.ensureInitialized();
  @override
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get position =>
      $value.position.copyWith.$chain((v) => call(position: v));
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
      get optionsList => ListCopyWith(
          $value.optionsList,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(optionsList: v));
  @override
  MapCopyWith<$R, String, THCommandOption,
          ObjectCopyWith<$R, THCommandOption, THCommandOption>>
      get optionsMap => MapCopyWith(
          $value.optionsMap,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(optionsMap: v));
  @override
  $R call(
          {int? mapiahID,
          THParent? parent,
          Object? sameLineComment = $none,
          THPositionPart? position,
          String? pointType,
          List<String>? optionsList,
          Map<String, THCommandOption>? optionsMap}) =>
      $apply(FieldCopyWithData({
        if (mapiahID != null) #mapiahID: mapiahID,
        if (parent != null) #parent: parent,
        if (sameLineComment != $none) #sameLineComment: sameLineComment,
        if (position != null) #position: position,
        if (pointType != null) #pointType: pointType,
        if (optionsList != null) #optionsList: optionsList,
        if (optionsMap != null) #optionsMap: optionsMap
      }));
  @override
  THPoint $make(CopyWithData data) => THPoint.notAddedToParent(
      data.get(#mapiahID, or: $value.mapiahID),
      data.get(#parent, or: $value.parent),
      data.get(#sameLineComment, or: $value.sameLineComment),
      data.get(#position, or: $value.position),
      data.get(#pointType, or: $value.pointType),
      data.get(#optionsList, or: $value.optionsList),
      data.get(#optionsMap, or: $value.optionsMap));

  @override
  THPointCopyWith<$R2, THPoint, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _THPointCopyWithImpl($value, $cast, t);
}
