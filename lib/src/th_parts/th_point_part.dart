import "package:mapiah/src/th_parts/th_double_part.dart";

class THPointPart {
  late final THDoublePart x;
  late final THDoublePart y;

  THPointPart(aX, aY, aXDecimalPositions, aYDecimalPositions) {
    x = THDoublePart(aX, aXDecimalPositions);
    y = THDoublePart(aY, aYDecimalPositions);
  }

  THPointPart.fromStrings(String aXAsString, String aYAsString) {
    x = THDoublePart.fromString(aXAsString);
    y = THDoublePart.fromString(aYAsString);
  }
}
