import "package:mapiah/src/th_parts/th_double_part.dart";

class THPointPart {
  late double x;
  late double y;
  late double decimalPositionsX;
  late double decimalPositionsY;

  THPointPart(this.x, this.y, this.decimalPositionsX, this.decimalPositionsY);

  THPointPart.fromStrings(String aXAsString, String aYAsString) {}
}
