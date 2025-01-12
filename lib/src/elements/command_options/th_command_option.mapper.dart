// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_command_option.dart';

class THCommandOptionMapper extends ClassMapperBase<THCommandOption> {
  THCommandOptionMapper._();

  static THCommandOptionMapper? _instance;
  static THCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THCommandOptionMapper._());
      THFileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THCommandOption';

  static THFile _$thFile(THCommandOption v) => v.thFile;
  static const Field<THCommandOption, THFile> _f$thFile =
      Field('thFile', _$thFile);
  static int _$parentMapiahID(THCommandOption v) => v.parentMapiahID;
  static const Field<THCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THCommandOption v) => v.optionType;
  static const Field<THCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);

  @override
  final MappableFields<THCommandOption> fields = const {
    #thFile: _f$thFile,
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
  };

  static THCommandOption _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('THCommandOption');
  }

  @override
  final Function instantiate = _instantiate;

  static THCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THCommandOption>(map);
  }

  static THCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THCommandOption>(json);
  }
}

mixin THCommandOptionMappable {
  String toJson();
  Map<String, dynamic> toMap();
  THCommandOptionCopyWith<THCommandOption, THCommandOption, THCommandOption>
      get copyWith;
}

abstract class THCommandOptionCopyWith<$R, $In extends THCommandOption, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  THFileCopyWith<$R, THFile, THFile> get thFile;
  $R call({THFile? thFile, int? parentMapiahID, String? optionType});
  THCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}
