// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_point_part.dart';

class THPointPartMapper extends ClassMapperBase<THPointPart> {
  THPointPartMapper._();

  static THPointPartMapper? _instance;
  static THPointPartMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THPointPartMapper._());
      THDoublePartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THPointPart';

  static THDoublePart _$x(THPointPart v) => v.x;
  static const Field<THPointPart, THDoublePart> _f$x = Field('x', _$x);
  static THDoublePart _$y(THPointPart v) => v.y;
  static const Field<THPointPart, THDoublePart> _f$y = Field('y', _$y);

  @override
  final MappableFields<THPointPart> fields = const {
    #x: _f$x,
    #y: _f$y,
  };

  static THPointPart _instantiate(DecodingData data) {
    return THPointPart.fromTHDoubleParts(data.dec(_f$x), data.dec(_f$y));
  }

  @override
  final Function instantiate = _instantiate;

  static THPointPart fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THPointPart>(map);
  }

  static THPointPart fromJson(String json) {
    return ensureInitialized().decodeJson<THPointPart>(json);
  }
}

mixin THPointPartMappable {
  String toJson() {
    return THPointPartMapper.ensureInitialized()
        .encodeJson<THPointPart>(this as THPointPart);
  }

  Map<String, dynamic> toMap() {
    return THPointPartMapper.ensureInitialized()
        .encodeMap<THPointPart>(this as THPointPart);
  }

  THPointPartCopyWith<THPointPart, THPointPart, THPointPart> get copyWith =>
      _THPointPartCopyWithImpl(this as THPointPart, $identity, $identity);
  @override
  String toString() {
    return THPointPartMapper.ensureInitialized()
        .stringifyValue(this as THPointPart);
  }

  @override
  bool operator ==(Object other) {
    return THPointPartMapper.ensureInitialized()
        .equalsValue(this as THPointPart, other);
  }

  @override
  int get hashCode {
    return THPointPartMapper.ensureInitialized().hashValue(this as THPointPart);
  }
}

extension THPointPartValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THPointPart, $Out> {
  THPointPartCopyWith<$R, THPointPart, $Out> get $asTHPointPart =>
      $base.as((v, t, t2) => _THPointPartCopyWithImpl(v, t, t2));
}

abstract class THPointPartCopyWith<$R, $In extends THPointPart, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get x;
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get y;
  $R call({THDoublePart? x, THDoublePart? y});
  THPointPartCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _THPointPartCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THPointPart, $Out>
    implements THPointPartCopyWith<$R, THPointPart, $Out> {
  _THPointPartCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THPointPart> $mapper =
      THPointPartMapper.ensureInitialized();
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get x =>
      $value.x.copyWith.$chain((v) => call(x: v));
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart> get y =>
      $value.y.copyWith.$chain((v) => call(y: v));
  @override
  $R call({THDoublePart? x, THDoublePart? y}) =>
      $apply(FieldCopyWithData({if (x != null) #x: x, if (y != null) #y: y}));
  @override
  THPointPart $make(CopyWithData data) => THPointPart.fromTHDoubleParts(
      data.get(#x, or: $value.x), data.get(#y, or: $value.y));

  @override
  THPointPartCopyWith<$R2, THPointPart, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THPointPartCopyWithImpl($value, $cast, t);
}
