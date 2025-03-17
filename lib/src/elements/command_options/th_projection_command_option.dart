part of 'th_command_option.dart';

enum THProjectionTypes {
  elevation,
  extended,
  none,
  plan,
}

// projection <specification> . specifies the drawing projection. Each projection is
// identified by a type and optionally by an index in the form type[:index]. The index
// can be any keyword. The following projection types are supported:
// 1. none . no projection, used for cross sections or maps that are independent of survey
// data (e.g. digitization of old maps where no centreline data are available). No index is
// allowed for this projection.
// 2. plan . basic plan projection (default).
// 3. elevation . orthogonal projection (a.k.a. projected profile) which optionally takes
// a view direction as an argument (e.g. [elevation 10] or [elevation 10 deg]).
// 4. extended . extended elevation (a.k.a. extended profile).
class THProjectionCommandOption extends THCommandOption {
  final THProjectionTypes projectionType;
  final String index;
  late final THDoublePart? elevationAngle;
  late final THAngleUnitPart? elevationUnit;

  THProjectionCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.projectionType,
    required this.index,
    this.elevationAngle,
    this.elevationUnit,
  }) : super.forCWJM();

  THProjectionCommandOption.fromString({
    required super.optionParent,
    required String projectionType,
    this.index = '',
    String? elevationAngle,
    String? elevationUnit,
    super.originalLineInTH2File = '',
  })  : projectionType = THProjectionTypes.values.byName(projectionType),
        super() {
    if (elevationAngle == null) {
      this.elevationAngle = null;
    } else {
      this.elevationAngle =
          THDoublePart.fromString(valueString: elevationAngle);
    }
    if (elevationUnit == null) {
      this.elevationUnit = null;
    } else {
      this.elevationUnit =
          THAngleUnitPart.fromString(unitString: elevationUnit);
    }
  }

  @override
  THCommandOptionType get type => THCommandOptionType.projection;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'projectionType': projectionType.name,
      'index': index,
    });

    if (elevationAngle != null) {
      map['elevationAngle'] = elevationAngle!.toMap();
    }
    if (elevationUnit != null) {
      map['elevationUnit'] = elevationUnit!.toMap();
    }

    return map;
  }

  factory THProjectionCommandOption.fromMap(Map<String, dynamic> map) {
    return THProjectionCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      projectionType: THProjectionTypes.values.byName(map['projectionType']),
      index: map['index'],
      elevationAngle: map.containsKey('elevationAngle')
          ? THDoublePart.fromMap(map['elevationAngle'])
          : null,
      elevationUnit: map.containsKey('elevationUnit')
          ? THAngleUnitPart.fromMap(map['elevationUnit'])
          : null,
    );
  }

  factory THProjectionCommandOption.fromJson(String jsonString) {
    return THProjectionCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THProjectionCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THProjectionTypes? projectionType,
    String? index,
    THDoublePart? elevationAngle,
    makeElevationAngleNull = false,
    THAngleUnitPart? elevationUnit,
    makeElevationUnitNull = false,
  }) {
    return THProjectionCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      projectionType: projectionType ?? this.projectionType,
      index: index ?? this.index,
      elevationAngle: makeElevationAngleNull
          ? null
          : (elevationAngle ?? this.elevationAngle),
      elevationUnit:
          makeElevationUnitNull ? null : (elevationUnit ?? this.elevationUnit),
    );
  }

  @override
  bool operator ==(covariant THProjectionCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.projectionType == projectionType &&
        other.index == index &&
        other.elevationAngle == elevationAngle &&
        other.elevationUnit == elevationUnit;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        projectionType,
        index,
        elevationAngle,
        elevationUnit,
      );

  @override
  String specToFile() {
    String asString = '';

    asString += projectionType.name;

    if (index.isNotEmpty && index.trim().isNotEmpty) {
      asString += ':${index.trim()}';
    }

    if (projectionType == THProjectionTypes.elevation) {
      if (elevationAngle != null) {
        asString += " ${elevationAngle.toString()}";
        if (elevationUnit != null) {
          asString += " ${elevationUnit.toString()}";
        }
      }
    }

    asString = asString.trim();

    if (asString.contains(' ')) {
      asString = "[ $asString ]";
    }

    return asString;
  }
}
