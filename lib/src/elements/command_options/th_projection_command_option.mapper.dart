// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'th_projection_command_option.dart';

class THProjectionTypesMapper extends EnumMapper<THProjectionTypes> {
  THProjectionTypesMapper._();

  static THProjectionTypesMapper? _instance;
  static THProjectionTypesMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = THProjectionTypesMapper._());
    }
    return _instance!;
  }

  static THProjectionTypes fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  THProjectionTypes decode(dynamic value) {
    switch (value) {
      case 'elevation':
        return THProjectionTypes.elevation;
      case 'extended':
        return THProjectionTypes.extended;
      case 'none':
        return THProjectionTypes.none;
      case 'plan':
        return THProjectionTypes.plan;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(THProjectionTypes self) {
    switch (self) {
      case THProjectionTypes.elevation:
        return 'elevation';
      case THProjectionTypes.extended:
        return 'extended';
      case THProjectionTypes.none:
        return 'none';
      case THProjectionTypes.plan:
        return 'plan';
    }
  }
}

extension THProjectionTypesMapperExtension on THProjectionTypes {
  String toValue() {
    THProjectionTypesMapper.ensureInitialized();
    return MapperContainer.globals.toValue<THProjectionTypes>(this) as String;
  }
}

class THProjectionCommandOptionMapper
    extends ClassMapperBase<THProjectionCommandOption> {
  THProjectionCommandOptionMapper._();

  static THProjectionCommandOptionMapper? _instance;
  static THProjectionCommandOptionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = THProjectionCommandOptionMapper._());
      THCommandOptionMapper.ensureInitialized();
      THProjectionTypesMapper.ensureInitialized();
      THDoublePartMapper.ensureInitialized();
      THAngleUnitPartMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'THProjectionCommandOption';

  static int _$parentMapiahID(THProjectionCommandOption v) => v.parentMapiahID;
  static const Field<THProjectionCommandOption, int> _f$parentMapiahID =
      Field('parentMapiahID', _$parentMapiahID);
  static String _$optionType(THProjectionCommandOption v) => v.optionType;
  static const Field<THProjectionCommandOption, String> _f$optionType =
      Field('optionType', _$optionType);
  static THProjectionTypes _$type(THProjectionCommandOption v) => v.type;
  static const Field<THProjectionCommandOption, THProjectionTypes> _f$type =
      Field('type', _$type);
  static String _$index(THProjectionCommandOption v) => v.index;
  static const Field<THProjectionCommandOption, String> _f$index =
      Field('index', _$index, opt: true, def: '');
  static THDoublePart? _$elevationAngle(THProjectionCommandOption v) =>
      v.elevationAngle;
  static const Field<THProjectionCommandOption, THDoublePart>
      _f$elevationAngle = Field('elevationAngle', _$elevationAngle, opt: true);
  static THAngleUnitPart? _$elevationUnit(THProjectionCommandOption v) =>
      v.elevationUnit;
  static const Field<THProjectionCommandOption, THAngleUnitPart>
      _f$elevationUnit = Field('elevationUnit', _$elevationUnit, opt: true);

  @override
  final MappableFields<THProjectionCommandOption> fields = const {
    #parentMapiahID: _f$parentMapiahID,
    #optionType: _f$optionType,
    #type: _f$type,
    #index: _f$index,
    #elevationAngle: _f$elevationAngle,
    #elevationUnit: _f$elevationUnit,
  };

  static THProjectionCommandOption _instantiate(DecodingData data) {
    return THProjectionCommandOption.withExplicitParameters(
        data.dec(_f$parentMapiahID), data.dec(_f$optionType), data.dec(_f$type),
        index: data.dec(_f$index),
        elevationAngle: data.dec(_f$elevationAngle),
        elevationUnit: data.dec(_f$elevationUnit));
  }

  @override
  final Function instantiate = _instantiate;

  static THProjectionCommandOption fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<THProjectionCommandOption>(map);
  }

  static THProjectionCommandOption fromJson(String json) {
    return ensureInitialized().decodeJson<THProjectionCommandOption>(json);
  }
}

mixin THProjectionCommandOptionMappable {
  String toJson() {
    return THProjectionCommandOptionMapper.ensureInitialized()
        .encodeJson<THProjectionCommandOption>(
            this as THProjectionCommandOption);
  }

  Map<String, dynamic> toMap() {
    return THProjectionCommandOptionMapper.ensureInitialized()
        .encodeMap<THProjectionCommandOption>(
            this as THProjectionCommandOption);
  }

  THProjectionCommandOptionCopyWith<THProjectionCommandOption,
          THProjectionCommandOption, THProjectionCommandOption>
      get copyWith => _THProjectionCommandOptionCopyWithImpl(
          this as THProjectionCommandOption, $identity, $identity);
  @override
  String toString() {
    return THProjectionCommandOptionMapper.ensureInitialized()
        .stringifyValue(this as THProjectionCommandOption);
  }

  @override
  bool operator ==(Object other) {
    return THProjectionCommandOptionMapper.ensureInitialized()
        .equalsValue(this as THProjectionCommandOption, other);
  }

  @override
  int get hashCode {
    return THProjectionCommandOptionMapper.ensureInitialized()
        .hashValue(this as THProjectionCommandOption);
  }
}

extension THProjectionCommandOptionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, THProjectionCommandOption, $Out> {
  THProjectionCommandOptionCopyWith<$R, THProjectionCommandOption, $Out>
      get $asTHProjectionCommandOption => $base
          .as((v, t, t2) => _THProjectionCommandOptionCopyWithImpl(v, t, t2));
}

abstract class THProjectionCommandOptionCopyWith<
    $R,
    $In extends THProjectionCommandOption,
    $Out> implements THCommandOptionCopyWith<$R, $In, $Out> {
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart>? get elevationAngle;
  THAngleUnitPartCopyWith<$R, THAngleUnitPart, THAngleUnitPart>?
      get elevationUnit;
  @override
  $R call(
      {int? parentMapiahID,
      String? optionType,
      THProjectionTypes? type,
      String? index,
      THDoublePart? elevationAngle,
      THAngleUnitPart? elevationUnit});
  THProjectionCommandOptionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _THProjectionCommandOptionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, THProjectionCommandOption, $Out>
    implements
        THProjectionCommandOptionCopyWith<$R, THProjectionCommandOption, $Out> {
  _THProjectionCommandOptionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<THProjectionCommandOption> $mapper =
      THProjectionCommandOptionMapper.ensureInitialized();
  @override
  THDoublePartCopyWith<$R, THDoublePart, THDoublePart>? get elevationAngle =>
      $value.elevationAngle?.copyWith.$chain((v) => call(elevationAngle: v));
  @override
  THAngleUnitPartCopyWith<$R, THAngleUnitPart, THAngleUnitPart>?
      get elevationUnit =>
          $value.elevationUnit?.copyWith.$chain((v) => call(elevationUnit: v));
  @override
  $R call(
          {int? parentMapiahID,
          String? optionType,
          THProjectionTypes? type,
          String? index,
          Object? elevationAngle = $none,
          Object? elevationUnit = $none}) =>
      $apply(FieldCopyWithData({
        if (parentMapiahID != null) #parentMapiahID: parentMapiahID,
        if (optionType != null) #optionType: optionType,
        if (type != null) #type: type,
        if (index != null) #index: index,
        if (elevationAngle != $none) #elevationAngle: elevationAngle,
        if (elevationUnit != $none) #elevationUnit: elevationUnit
      }));
  @override
  THProjectionCommandOption $make(CopyWithData data) =>
      THProjectionCommandOption.withExplicitParameters(
          data.get(#parentMapiahID, or: $value.parentMapiahID),
          data.get(#optionType, or: $value.optionType),
          data.get(#type, or: $value.type),
          index: data.get(#index, or: $value.index),
          elevationAngle: data.get(#elevationAngle, or: $value.elevationAngle),
          elevationUnit: data.get(#elevationUnit, or: $value.elevationUnit));

  @override
  THProjectionCommandOptionCopyWith<$R2, THProjectionCommandOption, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _THProjectionCommandOptionCopyWithImpl($value, $cast, t);
}
