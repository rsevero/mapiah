// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_line.dart';

class THLineMapper extends ClassMapperBase<THLine> {
  THLineMapper._();

  static THLineMapper? _instance;
  static THLineMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THLineMapper._());
      THElementMapper.ensureInitialized();
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THLine';

  static int _$mapiahID(THLine v) => v.mapiahID;
  static const Field<THLine, int> _f$mapiahID = Field('mapiahID', _$mapiahID);
  static int _$parentMapiahID(THLine v) => v.parentMapiahID;
  static const Field<THLine, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID, key: 'parentMapiaID');
  static String? _$sameLineComment(THLine v) => v.sameLineComment;
  static const Field<THLine, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment);
  static String _$lineType(THLine v) => v.lineType;
  static const Field<THLine, String> _f$lineType =
      Field('lineType', _$lineType);
  static List<int> _$childrenMapiahID(THLine v) => v.childrenMapiahID;
  static const Field<THLine, List<int>> _f$childrenMapiahID =
      Field('childrenMapiahID', _$childrenMapiahID);
  static LinkedHashMap<String, THCommandOption> _$optionsMap(THLine v) =>
      v.optionsMap;
  static const Field<THLine, LinkedHashMap<String, THCommandOption>>
      _f$optionsMap = Field('optionsMap', _$optionsMap);

  @override
  final MappableFields<THLine> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
    #lineType: _f$lineType,
    #childrenMapiahID: _f$childrenMapiahID,
    #optionsMap: _f$optionsMap,
  };

  static THLine _instantiate(DecodingData data) {
    return THLine.notAddedToParent(
        data.dec(_f$mapiahID),
        data.dec(_f$parentMapiahID),
        data.dec(_f$sameLineComment),
        data.dec(_f$lineType),
        data.dec(_f$childrenMapiahID),
        data.dec(_f$optionsMap));
  }

  @override
  final Function instantiate = _instantiate;

  static THLine fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THLine>(map);
  }

  static THLine fromJson(String json) {
    return ensureInitialized().decodeJson<THLine>(json);
  }
}

mixin THLineMappable {
  String toJson() {
    return THLineMapper.ensureInitialized().encodeJson<THLine>(this as THLine);
  }

  Map<String, dynamic> toMap() {
    return THLineMapper.ensureInitialized().encodeMap<THLine>(this as THLine);
  }

  THLineCopyWith<THLine, THLine, THLine> get copyWith =>
      _THLineCopyWithImpl(this as THLine, $identity, $identity);
  @override
  String toString() {
    return THLineMapper.ensureInitialized().stringifyValue(this as THLine);
  }

  @override
  bool operator ==(Object other) {
    return THLineMapper.ensureInitialized().equalsValue(this as THLine, other);
  }

  @override
  int get hashCode {
    return THLineMapper.ensureInitialized().hashValue(this as THLine);
  }
}

extension THLineValueCopy<$R, $Out> on ObjectCopyWith<$R, THLine, $Out> {
  THLineCopyWith<$R, THLine, $Out> get $asTHLine =>
      $base.as((v, t, t2) => _THLineCopyWithImpl(v, t, t2));
}

abstract class THLineCopyWith<$R, $In extends THLine, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get childrenMapiahID;
  @override
  $R call(
      {int? mapiahID,
      int? parentMapiahID,
      String? sameLineComment,
      String? lineType,
      List<int>? childrenMapiahID,
      LinkedHashMap<String, THCommandOption>? optionsMap});
  THLineCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THLineCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, THLine, $Out>
    implements THLineCopyWith<$R, THLine, $Out> {
  _THLineCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THLine> $mapper = THLineMapper.ensureInitialized();
  @override
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get childrenMapiahID =>
      ListCopyWith(
          $value.childrenMapiahID,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(childrenMapiahID: v));
  @override
  $R call(
          {int? mapiahID,
          int? parentMapiahID,
          Object? sameLineComment = $none,
          String? lineType,
          List<int>? childrenMapiahID,
          LinkedHashMap<String, THCommandOption>? optionsMap}) =>
      $apply(FieldCopyWithData({
        if (mapiahID != null) #mapiahID: mapiahID,
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (sameLineComment != $none) #sameLineComment: sameLineComment,
        if (lineType != null) #lineType: lineType,
        if (childrenMapiahID != null) #childrenMapiahID: childrenMapiahID,
        if (optionsMap != null) #optionsMap: optionsMap
      }));
  @override
  THLine $make(CopyWithData data) => THLine.notAddedToParent(
      data.get(#mapiahID, or: $value.mapiahID),
      data.get(#parentMapiahID, or: $value.parentMapiahID),
      data.get(#sameLineComment, or: $value.sameLineComment),
      data.get(#lineType, or: $value.lineType),
      data.get(#childrenMapiahID, or: $value.childrenMapiahID),
      data.get(#optionsMap, or: $value.optionsMap));

  @override
  THLineCopyWith<$R2, THLine, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _THLineCopyWithImpl($value, $cast, t);
}
