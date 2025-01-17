import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/command_options/th_has_length.dart';
import 'package:mapiah/src/elements/th_has_altitude.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';

// altitude <value> . can be specified only with the wall type. This option creates an
// altitude label on the wall. All altitudes are exported as a difference against grid Z
// origin (which is 0 by default). If the value is specified, it gives the altitude difference
// of the point on the wall relative to the nearest station. The value will be set to 0 if
// defined as ”-”, ”.”, ”nan”, ”NAN” or ”NaN”. The value can be prefixed by a keyword
// “fix”, then no nearest station is taken into consideration; the absolute given value is
// used instead. Units can follow the value. Examples: +4, [+4 m], [fix 1510 m].
class THAltitudeCommandOption extends THCommandOption
    with THHasLength, THHasAltitude {
  static const String _thisOptionType = 'altitude';

  THAltitudeCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required length,
    required bool isFix,
    String? unit,
  }) : super() {
    this.length = length;
    this.isFix = isFix;
    unitFromString(unit);
  }

  THAltitudeCommandOption.addToOptionParent({
    required super.optionParent,
    required THDoublePart length,
    required bool isFix,
    required String? unit,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    this.length = length;
    this.isFix = isFix;
    unitFromString(unit);
  }

  THAltitudeCommandOption.fromString({
    required super.optionParent,
    required String height,
    required bool isFix,
    required String? unit,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    length = THDoublePart.fromString(height);
    this.isFix = isFix;
    unitFromString(unit);
  }

  THAltitudeCommandOption.fromNan({required super.optionParent})
      : super.addToOptionParent(optionType: _thisOptionType) {
    length = THDoublePart.fromString('0');
    isNan = true;
    unitFromString('');
  }

  @override
  THAltitudeCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THDoublePart? length,
    bool? isFix,
    String? unit,
  }) {
    return THAltitudeCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      length: length ?? this.length,
      isFix: isFix ?? this.isFix,
      unit: unit ?? this.unit,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'length': length.toMap(),
      'isFix': isFix,
      'unit': unit,
    });
    return map;
  }

  @override
  bool operator ==(covariant THAltitudeCommandOption other) {
    if (identical(this, other)) return true;

    return super == other &&
        other.length == length &&
        other.isFix == isFix &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        length,
        isFix,
        unit,
      );
}
