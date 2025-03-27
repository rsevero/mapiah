part of 'th_command_option.dart';

mixin THHasLengthMixin on THCommandOption {
  late final THDoublePart length;
  late final THLengthUnitPart unit;
  late final bool unitSet;

  void unitFromString(String? unit) {
    if ((unit != null) && (unit.isNotEmpty)) {
      this.unit = THLengthUnitPart.fromString(unitString: unit);
      unitSet = true;
    } else {
      this.unit =
          THLengthUnitPart.fromString(unitString: thDefaultLengthUnitAsString);
      unitSet = false;
    }
  }

  @override
  String specToFile() {
    if (unitSet) {
      return "[ $length $unit ]";
    } else {
      return length.toString();
    }
  }
}
