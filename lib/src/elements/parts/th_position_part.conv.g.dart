// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unused_field, unused_import, public_member_api_docs, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

import 'dart:core';
import 'package:dogs_core/dogs_core.dart' as gen;
import 'package:lyell/lyell.dart' as gen;
import 'dart:ui' as gen0;
import 'dart:core' as gen1;
import 'package:mapiah/src/elements/parts/th_position_part.dart' as gen2;
import 'package:mapiah/src/elements/parts/th_position_part.dart';

class THPositionPartConverter extends gen.DefaultStructureConverter<gen2.THPositionPart> {
  THPositionPartConverter()
      : super(
            struct: const gen.DogStructure<gen2.THPositionPart>(
                'THPositionPart',
                gen.StructureConformity.dataclass,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.Offset>(), gen.TypeToken<gen0.Offset>(), null, gen.IterableKind.none, 'coordinates', false, true, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen1.int>(), gen.TypeToken<gen1.int>(), null, gen.IterableKind.none, 'decimalPositions', false, false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen2.THPositionPart>(_activator, [_$coordinates, _$decimalPositions], _values, _hash, _equals)));

  static dynamic _$coordinates(gen2.THPositionPart obj) => obj.coordinates;

  static dynamic _$decimalPositions(gen2.THPositionPart obj) => obj.decimalPositions;

  static List<dynamic> _values(gen2.THPositionPart obj) => [obj.coordinates, obj.decimalPositions];

  static gen2.THPositionPart _activator(List list) {
    return gen2.THPositionPart(coordinates: list[0], decimalPositions: list[1]);
  }

  static int _hash(gen2.THPositionPart obj) => obj.coordinates.hashCode ^ obj.decimalPositions.hashCode;

  static bool _equals(
    gen2.THPositionPart a,
    gen2.THPositionPart b,
  ) =>
      (a.coordinates == b.coordinates && a.decimalPositions == b.decimalPositions);
}

class THPositionPartBuilder {
  THPositionPartBuilder([gen2.THPositionPart? $src]) {
    if ($src == null) {
      $values = List.filled(2, null);
    } else {
      $values = THPositionPartConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen2.THPositionPart? $src;

  set coordinates(gen0.Offset value) {
    $values[0] = value;
  }

  gen0.Offset get coordinates => $values[0];

  set decimalPositions(gen1.int value) {
    $values[1] = value;
  }

  gen1.int get decimalPositions => $values[1];

  gen2.THPositionPart build() {
    var instance = THPositionPartConverter._activator($values);

    return instance;
  }
}

extension THPositionPartDogsExtension on gen2.THPositionPart {
  gen2.THPositionPart rebuild(Function(THPositionPartBuilder b) f) {
    var builder = THPositionPartBuilder(this);
    f(builder);
    return builder.build();
  }

  THPositionPartBuilder toBuilder() {
    return THPositionPartBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen2.THPositionPart);
  }
}
