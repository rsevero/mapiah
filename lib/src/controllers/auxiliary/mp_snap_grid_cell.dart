class MPSnapGridCell {
  final int x;
  final int y;

  const MPSnapGridCell(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MPSnapGridCell && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}
