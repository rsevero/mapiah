import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
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
    required this.gridSizeLength,
    required this.gridSizeUnit,
    required this.stations,
    required this.shots,
    required this.sketchLines,
    required this.grid,
  });
}
