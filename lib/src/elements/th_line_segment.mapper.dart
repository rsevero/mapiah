// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_line_segment.dart';

class THLineSegmentMapper extends ClassMapperBase<THLineSegment> {
  THLineSegmentMapper._();

  static THLineSegmentMapper? _instance;
  static THLineSegmentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THLineSegmentMapper._());
      THElementMapper.ensureInitialized();
      THPositionPartMapper.ensureInitialized();
      THCommandOptionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THLineSegment';

  static int _$mapiahID(THLineSegment v) => v.mapiahID;
  static const Field<THLineSegment, int> _f$mapiahID =
      Field('mapiahID', _$mapiahID);
  static int _$parentMapiahID(THLineSegment v) => v.parentMapiahID;
  static const Field<THLineSegment, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String? _$sameLineComment(THLineSegment v) => v.sameLineComment;
  static const Field<THLineSegment, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment);
  static THPositionPart _$endPoint(THLineSegment v) => v.endPoint;
  static const Field<THLineSegment, THPositionPart> _f$endPoint =
      Field('endPoint', _$endPoint);
  static LinkedHashMap<String, THCommandOption> _$optionsMap(THLineSegment v) =>
      v.optionsMap;
  static const Field<THLineSegment, LinkedHashMap<String, THCommandOption>>
      _f$optionsMap = Field('optionsMap', _$optionsMap);

  @override
  final MappableFields<THLineSegment> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
    #endPoint: _f$endPoint,
    #optionsMap: _f$optionsMap,
  };

  static THLineSegment _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('THLineSegment');
  }

  @override
  final Function instantiate = _instantiate;

  static THLineSegment fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THLineSegment>(map);
  }

  static THLineSegment fromJson(String json) {
    return ensureInitialized().decodeJson<THLineSegment>(json);
  }
}

mixin THLineSegmentMappable {
  String toJson();
  Map<String, dynamic> toMap();
  THLineSegmentCopyWith<THLineSegment, THLineSegment, THLineSegment>
      get copyWith;
}

abstract class THLineSegmentCopyWith<$R, $In extends THLineSegment, $Out>
    implements THElementCopyWith<$R, $In, $Out> {
  THPositionPartCopyWith<$R, THPositionPart, THPositionPart> get endPoint;
  @override
  $R call(
      {int? mapiahID,
      int? parentMapiahID,
      String? sameLineComment,
      THPositionPart? endPoint,
      LinkedHashMap<String, THCommandOption>? optionsMap});
  THLineSegmentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}
