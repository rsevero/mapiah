import 'dart:convert';

class XVIGrid {
  double gx;
  double gy;
  double gxx;
  double gxy;
  double gyx;
  double gyy;
  double ngx;
  double ngy;

  XVIGrid({
    this.gx = 0.0,
    this.gy = 0.0,
    this.gxx = 0.0,
    this.gxy = 0.0,
    this.gyx = 0.0,
    this.gyy = 0.0,
    this.ngx = 0.0,
    this.ngy = 0.0,
  });

  XVIGrid.fromList(List<double> values)
      : gx = values[0],
        gy = values[1],
        gxx = values[2],
        gxy = values[3],
        gyx = values[4],
        gyy = values[5],
        ngx = values[6],
        ngy = values[7];

  /// Returns a map representation of this XVIGrid instance
  Map<String, dynamic> toMap() {
    return {
      'gx': gx,
      'gy': gy,
      'gxx': gxx,
      'gxy': gxy,
      'gyx': gyx,
      'gyy': gyy,
      'ngx': ngx,
      'ngy': ngy,
    };
  }

  /// Creates an XVIGrid instance from a map
  static XVIGrid fromMap(Map<String, dynamic> map) {
    return XVIGrid(
      gx: map['gx']?.toDouble() ?? 0.0,
      gy: map['gy']?.toDouble() ?? 0.0,
      gxx: map['gxx']?.toDouble() ?? 0.0,
      gxy: map['gxy']?.toDouble() ?? 0.0,
      gyx: map['gyx']?.toDouble() ?? 0.0,
      gyy: map['gyy']?.toDouble() ?? 0.0,
      ngx: map['ngx']?.toDouble() ?? 0.0,
      ngy: map['ngy']?.toDouble() ?? 0.0,
    );
  }

  /// Creates an XVIGrid instance from a JSON string
  static XVIGrid fromJson(String source) => fromMap(jsonDecode(source));

  /// Returns a JSON string representation of this XVIGrid instance
  String toJson() => jsonEncode(toMap());

  /// Creates a copy of this XVIGrid with the given fields replaced with new values
  XVIGrid copyWith({
    double? gx,
    double? gy,
    double? gxx,
    double? gxy,
    double? gyx,
    double? gyy,
    double? ngx,
    double? ngy,
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
      other is XVIGrid &&
          gx == other.gx &&
          gy == other.gy &&
          gxx == other.gxx &&
          gxy == other.gxy &&
          gyx == other.gyx &&
          gyy == other.gyy &&
          ngx == other.ngx &&
          ngy == other.ngy;

  @override
  int get hashCode => Object.hash(
        gx,
        gy,
        gxx,
        gxy,
        gyx,
        gyy,
        ngx,
        ngy,
      );
}
