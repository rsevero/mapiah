// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_passage_height_value_command_option.dart';

class THPassageHeightModesMapper extends EnumMapper<THPassageHeightModes> {
  THPassageHeightModesMapper._();

  static THPassageHeightModesMapper? _instance;
  static THPassageHeightModesMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THPassageHeightModesMapper._());
    }
    return _instance!;
  }

  static THPassageHeightModes fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  THPassageHeightModes decode(dynamic value) {
    switch (value) {
      case 'height':
        return THPassageHeightModes.height;
      case 'depth':
        return THPassageHeightModes.depth;
      case 'distanceBetweenFloorAndCeiling':
        return THPassageHeightModes.distanceBetweenFloorAndCeiling;
      case 'distanceToCeilingAndDistanceToFloor':
        return THPassageHeightModes.distanceToCeilingAndDistanceToFloor;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(THPassageHeightModes self) {
    switch (self) {
      case THPassageHeightModes.height:
        return 'height';
      case THPassageHeightModes.depth:
        return 'depth';
      case THPassageHeightModes.distanceBetweenFloorAndCeiling:
        return 'distanceBetweenFloorAndCeiling';
      case THPassageHeightModes.distanceToCeilingAndDistanceToFloor:
        return 'distanceToCeilingAndDistanceToFloor';
    }
  }
}

extension THPassageHeightModesMapperExtension on THPassageHeightModes {
  String toValue() {
    THPassageHeightModesMapper.ensureInitialized();
    return MapperContainer.globals.toValue<THPassageHeightModes>(this)
        as String;
  }
}

class THPassageHeightValueCommandOptionMapper
    extends ClassMapperBase<THPassageHeightValueCommandOption> {
  THPassageHeightValueCommandOptionMapper._();

  static THPassageHeightValueCommandOptionMapper? _instance;
  static THPassageHeightValueCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THPassageHeightValueCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THDoublePartMapper.ensureInitialized();
      THPassageHeightModesMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THPassageHeightValueCommandOption';

  static int _$parentMapiahID(THPassageHeightValueCommandOption v) =>
      v.parentMapiahID;
  static const Field<THPassageHeightValueCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THPassageHeightValueCommandOption v) =>
      v.optionType;
  static const Field<THPassageHeightValueCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static THDoublePart? _$plusNumber(THPassageHeightValueCommandOption v) =>
      v.plusNumber;
  static const Field<THPassageHeightValueCommandOption, THDoublePart>
      _f$plusNumber = Field('plusNumber', _$plusNumber);
  static THDoublePart? _$minusNumber(THPassageHeightValueCommandOption v) =>
      v.minusNumber;
  static const Field<THPassageHeightValueCommandOption, THDoublePart>
      _f$minusNumber = Field('minusNumber', _$minusNumber);
  static THPassageHeightModes _$mode(THPassageHeightValueCommandOption v) =>
      v.mode;
  static const Field<THPassageHeightValueCommandOption, THPassageHeightModes>
      _f$mode = Field('mode', _$mode);
  static bool _$plusHasSign(THPassageHeightValueCommandOption v) =>
      v.plusHasSign;
  static const Field<THPassageHeightValueCommandOption, bool> _f$plusHasSign =
      Field('plusHasSign', _$plusHasSign);

  @override
  final MappableFields<THPassageHeightValueCommandOption> fields = const {
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #plusNumber: _f$plusNumber,
    #minusNumber: _f$minusNumber,
    #mode: _f$mode,
    #plusHasSign: _f$plusHasSign,
  };

  static THPassageHeightValueCommandOption _instantiate(DecodingData data) {
    return THPassageHeightValueCommandOption.withExplicitParameters(
        data.dec(_f$parentMapiahID),
        data.dec(_f$optionType),
        data.dec(_f$plusNumber),
        data.dec(_f$minusNumber),
        data.dec(_f$mode),
        data.dec(_f$plusHasSign));
  }

  @override
  final Function instantiate = _instantiate;

  static THPassageHeightValueCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized()
        .decodeMap<THPassageHeightValueCommandOption>(map);
  }

  static THPassageHeightValueCommandOption fromJson(String json) {
    return ensureInitialized()
        .decodeJson<THPassageHeightValueCommandOption>(json);
  }
}

mixin THPassageHeightValueCommandOptionMappable {
  String toJson() {
    return THPassageHeightValueCommandOptionMapper.ensureInitialized()
        .encodeJson<THPassageHeightValueCommandOption>(
            this as THPassageHeightValueCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THPassageHeightValueCommandOptionMapper.ensureInitialized()
        .encodeMap<THPassageHeightValueCommandOption>(
            this as THPassageHeightValueCommandOption);
  }

  THPassageHeightValueCommandOptionCopyWith<THPassageHeightValueCommandOption,
          THPassageHeightValueCommandOption, THPassageHeightValueCommandOption>
      get copyWith => _THPassageHeightValueCommandOptionCopyWithImpl(
          this as THPassageHeightValueCommandOption, $identity, $identity);
  @override
  String toString() {
    return THPassageHeightValueCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THPassageHeightValueCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THPassageHeightValueCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THPassageHeightValueCommandOption, other);
  }

  @override
  int get hashCode {
    return THPassageHeightValueCommandOptionMapper.ensureInitialized()
        .hashValue(this as THPassageHeightValueCommandOption);
  }
}

extension THPassageHeightValueCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THPassageHeightValueCommandOption, $Out> {
  THPassageHeightValueCommandOptionCopyWith<$R,
          THPassageHeightValueCommandOption, $Out>
      get $asTHPassageHeightValueCommandOption => $base.as((v, t, t2) =>
          _THPassageHeightValueCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THPassageHeightValueCommandOptionCopyWith<
    $R,
    $In extends THPassageHeightValueCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart>? get plusNumber;
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart>? get minusNumber;
  @override
  $R call(
      {int? parentMapiahID,
      String? optionType,
      THDoublePart? plusNumber,
      THDoublePart? minusNumber,
      THPassageHeightModes? mode,
      bool? plusHasSign});
  THPassageHeightValueCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THPassageHeightValueCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THPassageHeightValueCommandOption, $Out>
    implements
        THPassageHeightValueCommandOptionCopyWith<$R,
            THPassageHeightValueCommandOption, $Out> {
  _THPassageHeightValueCommandOptionCopyWithImpl(
      super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THPassageHeightValueCommandOption> $mapper =
      THPassageHeightValueCommandOptionMapper.ensureInitialized();
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart>? get plusNumber =>
      $value.plusNumber?.copyWith.$chain((v) => call(plusNumber: v));
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart>? get minusNumber =>
      $value.minusNumber?.copyWith.$chain((v) => call(minusNumber: v));
  @override
  $R call(
          {int? parentMapiahID,
          String? optionType,
          Object? plusNumber = $none,
          Object? minusNumber = $none,
          THPassageHeightModes? mode,
          bool? plusHasSign}) =>
      $apply(FieldCopyWithData({
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (plusNumber != $none) #plusNumber: plusNumber,
        if (minusNumber != $none) #minusNumber: minusNumber,
        if (mode != null) #mode: mode,
        if (plusHasSign != null) #plusHasSign: plusHasSign
      }));
  @override
  THPassageHeightValueCommandOption $make(CopyWithData data) =>
      THPassageHeightValueCommandOption.withExplicitParameters(
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#plusNumber, or: $value.plusNumber),
          data.get(#minusNumber, or: $value.minusNumber),
          data.get(#mode, or: $value.mode),
          data.get(#plusHasSign, or: $value.plusHasSign));

  @override
  THPassageHeightValueCommandOptionCopyWith<$R2,
      THPassageHeightValueCommandOption, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _THPassageHeightValueCommandOptionCopyWithImpl($value, $cast, t);
}
