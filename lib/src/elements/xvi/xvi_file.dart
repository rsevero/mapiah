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
