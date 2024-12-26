// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_has_id.dart';

class THHasTHIDMapper extends ClassMapperBase<THHasTHID> {
  THHasTHIDMapper._();

  static THHasTHIDMapper? _instance;
  static THHasTHIDMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THHasTHIDMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THHasTHID';

  @override
  final MappableFields<THHasTHID> fields = const {};

  static THHasTHID _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('THHasTHID');
  }

  @override
  final Function instantiate = _instantiate;

  static THHasTHID fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THHasTHID>(map);
  }

  static THHasTHID fromJson(String json) {
    return ensureInitialized().decodeJson<THHasTHID>(json);
  }
}

mixin THHasTHIDMappable {
  String toJson();
  Map<String, dynamic> toMap();
  THHasTHIDCopyWith<THHasTHID, THHasTHID, THHasTHID> get copyWith;
}

abstract class THHasTHIDCopyWith<$R, $In extends THHasTHID, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  THHasTHIDCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}
