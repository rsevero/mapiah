import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/parts/th_length_unit_part.dart';

// scale <specification> . is used to pre-scale (convert coordinates from pixels to
// meters) the scrap data. If scrap projection is none, this is the only transformation that
// is done with coordinates. The <specification> has four forms:
// 1. <number> . <number> meters per drawing unit.
// 2. [<number> <length units>] . <number> <length units> per drawing unit.
// 3. [<num1> <num2> <length units>] . <num1> drawing units corresponds to <num2>
// <length units> in reality.
// 4. [<num1> ... <num8> [<length units>]] . this is the most general format, where
// you specify, in order, the x and y coordinates of two points in the scrap and two points
// in reality. Optionally, you can also specify units for the coordinates of the ‘points in
// reality’. This form allows you to apply both scaling and rotation to the scrap.
class THScrapScaleCommandOption extends THCommandOption {
  final List<THDoublePart> _numericSpecifications;
  final THLengthUnitPart? unit;

  THScrapScaleCommandOption({
    required super.parentMapiahID,
    required List<THDoublePart> numericSpecifications,
    this.unit,
  })  : _numericSpecifications = numericSpecifications,
        super();

  THScrapScaleCommandOption.addToOptionParent({
    required super.optionParent,
    required List<THDoublePart> numericSpecifications,
    this.unit,
  })  : _numericSpecifications = numericSpecifications,
        super.addToOptionParent();

  @override
  THCommandOptionType get optionType => THCommandOptionType.scrapScale;

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'numericSpecifications':
          _numericSpecifications.map((e) => e.toMap()).toList(),
      'unit': unit?.toMap(),
    };
  }

  factory THScrapScaleCommandOption.fromMap(Map<String, dynamic> map) {
    return THScrapScaleCommandOption(
      parentMapiahID: map['parentMapiahID'],
      numericSpecifications: List<THDoublePart>.from(
          map['numericSpecifications'].map((e) => THDoublePart.fromMap(e))),
      unit: map['unit'] != null ? THLengthUnitPart.fromMap(map['unit']) : null,
    );
  }

  factory THScrapScaleCommandOption.fromJson(String jsonString) {
    return THScrapScaleCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THScrapScaleCommandOption copyWith({
    int? parentMapiahID,
    List<THDoublePart>? numericSpecifications,
    THLengthUnitPart? unit,
    bool makeUnitNull = false,
  }) {
    return THScrapScaleCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      numericSpecifications: numericSpecifications ?? _numericSpecifications,
      unit: makeUnitNull ? null : (unit ?? this.unit),
    );
  }

  @override
  bool operator ==(covariant THScrapScaleCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other._numericSpecifications == _numericSpecifications &&
        other.unit == unit;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        _numericSpecifications,
        unit,
      );

  @override
  String specToFile() {
    String asString = '';

    for (var aValue in _numericSpecifications) {
      asString += ' ${aValue.toString()}';
    }

    if (unit != null) {
      asString += ' ${unit.toString()}';
    }

    asString = asString.trim();

    if (asString.contains(' ')) {
      asString = '[ $asString ]';
    }

    return asString;
  }
}
