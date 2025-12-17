import 'dart:convert';
import 'dart:ui';

import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/mixins/mp_bounding_box_mixin.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

/// The only really obscure data is XVIgrid. XVIgrid has 8 Values, e.g.
///
/// set XVIgrid {738.97637795 -109.842519685 39.3700787401 0.0 0.0 39.3700787401 84 93}
///
/// This seems to be:
/// * gx: minx (origin / bottom left x)
/// * gy: miny (origin / bottom left y)
/// * gxx: X increment for moving one step along the grid's X direction
/// * gxy: Y increment for moving one step along the grid's X direction (usually
///   0.0). It screws the grid in the vertical direction if not 0.0
/// * gyx: X increment for moving one step along the grid's Y direction (usually
///   0.0). It screws the grid in the horizontal direction if not 0.0.
/// * gyy: Y increment for moving one step along the grid's Y direction
/// * ngx: number of grid elements in x direction
/// * ngy: number of grid elements in y direction
class XVIGrid with MPBoundingBoxMixin {
  THDoublePart gx;
  THDoublePart gy;
  THDoublePart gxx;
  THDoublePart gxy;
  THDoublePart gyx;
  THDoublePart gyy;
  THDoublePart ngx;
  THDoublePart ngy;

  XVIGrid({
    THDoublePart? gx,
    THDoublePart? gy,
    THDoublePart? gxx,
    THDoublePart? gxy,
    THDoublePart? gyx,
    THDoublePart? gyy,
    THDoublePart? ngx,
    THDoublePart? ngy,
  }) : gx = gx ?? THDoublePart.fromString(valueString: '0.0'),
       gy = gy ?? THDoublePart.fromString(valueString: '0.0'),
       gxx = gxx ?? THDoublePart.fromString(valueString: '0.0'),
       gxy = gxy ?? THDoublePart.fromString(valueString: '0.0'),
       gyx = gyx ?? THDoublePart.fromString(valueString: '0.0'),
       gyy = gyy ?? THDoublePart.fromString(valueString: '0.0'),
       ngx = ngx ?? THDoublePart.fromString(valueString: '0.0'),
       ngy = ngy ?? THDoublePart.fromString(valueString: '0.0');

  XVIGrid.fromStringList(List<String> values)
    : gx = THDoublePart.fromString(valueString: values[0]),
      gy = THDoublePart.fromString(valueString: values[1]),
      gxx = THDoublePart.fromString(valueString: values[2]),
      gxy = THDoublePart.fromString(valueString: values[3]),
      gyx = THDoublePart.fromString(valueString: values[4]),
      gyy = THDoublePart.fromString(valueString: values[5]),
      ngx = THDoublePart.fromString(valueString: values[6]),
      ngy = THDoublePart.fromString(valueString: values[7]);

  XVIGrid.fromList(List<double> values)
    : gx = THDoublePart(value: values[0]),
      gy = THDoublePart(value: values[1]),
      gxx = THDoublePart(value: values[2]),
      gxy = THDoublePart(value: values[3]),
      gyx = THDoublePart(value: values[4]),
      gyy = THDoublePart(value: values[5]),
      ngx = THDoublePart(value: values[6]),
      ngy = THDoublePart(value: values[7]);

  /// Returns a map representation of this XVIGrid instance
  Map<String, dynamic> toMap() {
    return {
      'gx': gx.toMap(),
      'gy': gy.toMap(),
      'gxx': gxx.toMap(),
      'gxy': gxy.toMap(),
      'gyx': gyx.toMap(),
      'gyy': gyy.toMap(),
      'ngx': ngx.toMap(),
      'ngy': ngy.toMap(),
    };
  }

  /// Creates an XVIGrid instance from a map
  static XVIGrid fromMap(Map<String, dynamic> map) {
    return XVIGrid(
      gx: THDoublePart.fromMap(map['gx']),
      gy: THDoublePart.fromMap(map['gy']),
      gxx: THDoublePart.fromMap(map['gxx']),
      gxy: THDoublePart.fromMap(map['gxy']),
      gyx: THDoublePart.fromMap(map['gyx']),
      gyy: THDoublePart.fromMap(map['gyy']),
      ngx: THDoublePart.fromMap(map['ngx']),
      ngy: THDoublePart.fromMap(map['ngy']),
    );
  }

  /// Creates an XVIGrid instance from a JSON string
  static XVIGrid fromJson(String source) => fromMap(jsonDecode(source));

  /// Returns a JSON string representation of this XVIGrid instance
  String toJson() => jsonEncode(toMap());

  /// Creates a copy of this XVIGrid with the given fields replaced with new values
  XVIGrid copyWith({
    THDoublePart? gx,
    THDoublePart? gy,
    THDoublePart? gxx,
    THDoublePart? gxy,
    THDoublePart? gyx,
    THDoublePart? gyy,
    THDoublePart? ngx,
    THDoublePart? ngy,
  }) {
    return XVIGrid(
      gx: gx ?? this.gx,
      gy: gy ?? this.gy,
      gxx: gxx ?? this.gxx,
      gxy: gxy ?? this.gxy,
      gyx: gyx ?? this.gyx,
      gyy: gyy ?? this.gyy,
      ngx: ngx ?? this.ngx,
      ngy: ngy ?? this.ngy,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XVIGrid &&
          (gx == other.gx) &&
          (gy == other.gy) &&
          (gxx == other.gxx) &&
          (gxy == other.gxy) &&
          (gyx == other.gyx) &&
          (gyy == other.gyy) &&
          (ngx == other.ngx) &&
          (ngy == other.ngy));

  @override
  int get hashCode => Object.hash(gx, gy, gxx, gxy, gyx, gyy, ngx, ngy);

  @override
  String toString() {
    return 'XVIGrid(gx: $gx(${gx.decimalPositions}), gy: $gy(${gy.decimalPositions}), gxx: $gxx(${gxx.decimalPositions}), gxy: $gxy(${gxy.decimalPositions}), gyx: $gyx(${gyx.decimalPositions}), gyy: $gyy(${gyy.decimalPositions}), ngx: $ngx(${ngx.decimalPositions}), ngy: $ngy(${ngy.decimalPositions}))';
  }

  @override
  Rect calculateBoundingBox(TH2FileEditController th2FileEditController) {
    final double ox = gx.value;
    final double oy = gy.value;

    final double nx = ngx.value;
    final double ny = ngy.value;

    final double vxX = gxx.value;
    final double vxY = gxy.value;

    final double vyX = gyx.value;
    final double vyY = gyy.value;

    final double vxXnx = vxX * nx;
    final double vxYnx = vxY * nx;
    final double vyXny = vyX * ny;
    final double vyYny = vyY * ny;

    // Corner points of the (possibly skewed) grid parallelogram
    final double x0 = ox;
    final double y0 = oy;

    final double x1 = ox + vxXnx;
    final double y1 = oy + vxYnx;

    final double x2 = ox + vyXny;
    final double y2 = oy + vyYny;

    final double x3 = ox + vxXnx + vyXny;
    final double y3 = oy + vxYnx + vyYny;

    final double minX = [x0, x1, x2, x3].reduce((a, b) => a < b ? a : b);
    final double maxX = [x0, x1, x2, x3].reduce((a, b) => a > b ? a : b);
    final double minY = [y0, y1, y2, y3].reduce((a, b) => a < b ? a : b);
    final double maxY = [y0, y1, y2, y3].reduce((a, b) => a > b ? a : b);

    return MPNumericAux.orderedRectFromLTRB(
      left: minX,
      top: minY,
      right: maxX,
      bottom: maxY,
    );
  }

  List<Offset> calculateGridLineIntersections() {
    final List<Offset> intersections = [];

    final double ox = gx.value;
    final double oy = gy.value;

    final int nx = ngx.value.toInt();
    final int ny = ngy.value.toInt();

    final double vxX = gxx.value;
    final double vxY = gxy.value;

    final double vyX = gyx.value;
    final double vyY = gyy.value;

    for (int ix = 0; ix < nx; ix++) {
      for (int iy = 0; iy < ny; iy++) {
        final double x = ox + (vxX * ix) + (vyX * iy);
        final double y = oy + (vxY * ix) + (vyY * iy);

        intersections.add(Offset(x, y));
      }
    }

    return intersections;
  }

  /// Calculates the grid lines as line segments using a provided grid origin.
  ///
  /// The [origin] should be the canvas coordinate where the grid's (0,0)
  /// origin is placed. For example, when drawing an XVI image, this is
  /// typically the (xx, yy) position of the image, so lines are computed in
  /// canvas space directly.
  ///
  /// Returns a list of records with named fields (start, end), where each
  /// field is an Offset representing the endpoints of a grid line segment.
  List<({Offset start, Offset end})> calculateGridLines({
    required Offset origin,
  }) {
    final double gridX = origin.dx;
    final double gridY = origin.dy;

    // Grid increments and repetition counts
    final double gxxV = gxx.value;
    final double gxyV = gxy.value;
    final double gyxV = gyx.value;
    final double gyyV = gyy.value;
    final int nx = ngx.value.toInt();
    final int ny = ngy.value.toInt();

    // Total span along each axis for a full line
    final double xIncForHorizontalGridLine = nx * gxxV;
    final double yIncForHorizontalGridLine = nx * gxyV;
    final double xIncForVerticalGridLine = ny * gyxV;
    final double yIncForVerticalGridLine = ny * gyyV;

    final List<({Offset start, Offset end})> lines = [];

    // Horizontal grid lines (vary along Y axis)
    for (int i = 0; i <= ny; i++) {
      final double leftX = gridX + (i * gyxV);
      final double leftY = gridY + (i * gyyV);
      final double rightX = leftX + xIncForHorizontalGridLine;
      final double rightY = leftY + yIncForHorizontalGridLine;

      lines.add((start: Offset(leftX, leftY), end: Offset(rightX, rightY)));
    }

    // Vertical grid lines (vary along X axis)
    for (int j = 0; j <= nx; j++) {
      final double topX = gridX + (j * gxxV);
      final double topY = gridY + (j * gxyV);
      final double bottomX = topX + xIncForVerticalGridLine;
      final double bottomY = topY + yIncForVerticalGridLine;

      lines.add((start: Offset(topX, topY), end: Offset(bottomX, bottomY)));
    }

    return lines;
  }
}
