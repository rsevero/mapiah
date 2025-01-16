// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_element.dart';

class THElementMapper extends ClassMapperBase<THElement> {
  THElementMapper._();

  static THElementMapper? _instance;
  static THElementMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THElementMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'THElement';

  static int _$mapiahID(THElement v) => v.mapiahID;
  static const Field<THElement, int> _f$mapiahID =
      Field('mapiahID', _$mapiahID);
  static int _$parentMapiahID(THElement v) => v.parentMapiahID;
  static const Field<THElement, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String? _$sameLineComment(THElement v) => v.sameLineComment;
  static const Field<THElement, String> _f$sameLineComment =
      Field('sameLineComment', _$sameLineComment);

  @override
  final MappableFields<THElement> fields = const {
    #mapiahID: _f$mapiahID,
    #parentMapiahID: _f$parentMapiahID,
    #sameLineComment: _f$sameLineComment,
  };

  static THElement _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('THElement');
  }

  @override
  final Function instantiate = _instantiate;

  static THElement fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THElement>(map);
  }

  static THElement fromJson(String json) {
    return ensureInitialized().decodeJson<THElement>(json);
  }
}

mixin THElementMappable {
  String toJson();
  Map<String, dynamic> toMap();
  THElementCopyWith<THElement, THElement, THElement> get copyWith;
}

abstract class THElementCopyWith<$R, $In extends THElement, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? mapiahID, int? parentMapiahID, String? sameLineComment});
  THElementCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}
