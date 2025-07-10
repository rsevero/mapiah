import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/xvi/xvi_grid.dart';
import 'package:mapiah/src/elements/xvi/xvi_shot.dart';
import 'package:mapiah/src/elements/xvi/xvi_sketchline.dart';
import 'package:mapiah/src/elements/xvi/xvi_station.dart';

class XVIFile {
  String filename;
  double gridSizeLength;
  THLengthUnitPart gridSizeUnit;
  List<XVIStation> stations;
  List<XVIShot> shots;
  List<XVISketchLine> sketchLines;
  XVIGrid grid;

  XVIFile({
    this.filename = '',
    this.gridSizeLength = 0.0,
    THLengthUnitPart? gridSizeUnit,
    this.stations = const [],
    this.shots = const [],
    this.sketchLines = const [],
    XVIGrid? grid,
  })  : gridSizeUnit = gridSizeUnit ??
            THLengthUnitPart(
              unit: THLengthUnitType.meter,
            ),
        grid = grid ?? XVIGrid();

  /// Returns a map representation of this XVIFile instance
  Map<String, dynamic> toMap() {
    return {
      'filename': filename,
      'gridSizeLength': gridSizeLength,
      'gridSizeUnit': gridSizeUnit.toMap(),
      'stations': stations.map((station) => station.toMap()).toList(),
      'shots': shots.map((shot) => shot.toMap()).toList(),
      'sketchLines':
          sketchLines.map((sketchLine) => sketchLine.toMap()).toList(),
      'grid': grid.toMap(),
    };
  }

  /// Creates an XVIFile instance from a map
  static XVIFile fromMap(Map<String, dynamic> map) {
    return XVIFile(
      filename: map['filename'] ?? '',
      gridSizeLength: map['gridSizeLength']?.toDouble() ?? 0.0,
      gridSizeUnit: map['gridSizeUnit'] != null
          ? THLengthUnitPart.fromMap(map['gridSizeUnit'])
          : null,
      stations: map['stations'] != null
          ? (map['stations'] as List<dynamic>)
              .map((station) => XVIStation.fromMap(station))
              .toList()
          : const [],
      shots: map['shots'] != null
          ? (map['shots'] as List<dynamic>)
              .map((shot) => XVIShot.fromMap(shot))
              .toList()
          : const [],
      sketchLines: map['sketchLines'] != null
          ? (map['sketchLines'] as List<dynamic>)
              .map((sketchLine) => XVISketchLine.fromMap(sketchLine))
              .toList()
          : const [],
      grid: map['grid'] != null ? XVIGrid.fromMap(map['grid']) : null,
    );
  }

  /// Creates an XVIFile instance from a JSON string
  static XVIFile fromJson(String source) => fromMap(jsonDecode(source));

  /// Returns a JSON string representation of this XVIFile instance
  String toJson() => jsonEncode(toMap());

  /// Creates a copy of this XVIFile with the given fields replaced with new values
  XVIFile copyWith({
    String? filename,
    double? gridSizeLength,
    THLengthUnitPart? gridSizeUnit,
    bool makeGridSizeUnitNull = false,
    List<XVIStation>? stations,
    List<XVIShot>? shots,
    List<XVISketchLine>? sketchLines,
    XVIGrid? grid,
    bool makeGridNull = false,
  }) {
    return XVIFile(
      filename: filename ?? this.filename,
      gridSizeLength: gridSizeLength ?? this.gridSizeLength,
      gridSizeUnit:
          makeGridSizeUnitNull ? null : (gridSizeUnit ?? this.gridSizeUnit),
      stations: stations ?? this.stations,
      shots: shots ?? this.shots,
      sketchLines: sketchLines ?? this.sketchLines,
      grid: makeGridNull ? null : (grid ?? this.grid),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is XVIFile &&
        filename == other.filename &&
        gridSizeLength == other.gridSizeLength &&
        gridSizeUnit == other.gridSizeUnit &&
        const ListEquality().equals(stations, other.stations) &&
        const ListEquality().equals(shots, other.shots) &&
        const ListEquality().equals(sketchLines, other.sketchLines) &&
        grid == other.grid;
  }

  @override
  int get hashCode => Object.hash(
        filename,
        gridSizeLength,
        gridSizeUnit,
        const ListEquality().hash(stations),
        const ListEquality().hash(shots),
        const ListEquality().hash(sketchLines),
        grid,
      );
}
