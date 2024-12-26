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
    }
    return _instance!;
  }

  @override
  final String id = 'THLine';

  static THParent _$parent(THLine v) => v.parent;
  static const Field<THLine, THParent> _f$parent = Field('parent', _$parent);
  static String _$lineType(THLine v) => v.lineType;
  static const Field<THLine, String> _f$lineType =
      Field('lineType', _$lineType);
  static String? _$sameLineComment(THLine v) => v.sameLineComment;
  static const Field<THLine, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment, mode: FieldMode.member);

  @override
  final MappableFields<THLine> fields = const {
    #parent: _f$parent,
    #lineType: _f$lineType,
    #sameLineComment: _f$sameLineComment,
  };

  static THLine _instantiate(DecodingData data) {
    return THLine(data.dec(_f$parent), data.dec(_f$lineType));
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
  @override
  $R call({THParent? parent, String? lineType});
  THLineCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THLineCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, THLine, $Out>
    implements THLineCopyWith<$R, THLine, $Out> {
  _THLineCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THLine> $mapper = THLineMapper.ensureInitialized();
  @override
  $R call({THParent? parent, String? lineType}) => $apply(FieldCopyWithData({
        if (parent != null) #parent: parent,
        if (lineType != null) #lineType: lineType
      }));
  @override
  THLine $make(CopyWithData data) => THLine(
      data.get(#parent, or: $value.parent),
      data.get(#lineType, or: $value.lineType));

  @override
  THLineCopyWith<$R2, THLine, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _THLineCopyWithImpl($value, $cast, t);
}
