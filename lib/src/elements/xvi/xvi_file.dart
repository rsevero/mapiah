import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';
import 'package:mapiah/src/elements/xvi/xvi_grid.dart';
import 'package:mapiah/src/elements/xvi/xvi_shot.dart';
import 'package:mapiah/src/elements/xvi/xvi_station.dart';

class XVIFile {
  String filename = '';
  late double gridStartX;
  late THLengthUnitPart gridStartUnit;
  List<XVIStation> stations = [];
  List<XVIShot> shots = [];
  late XVIGrid grid;
}
