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
