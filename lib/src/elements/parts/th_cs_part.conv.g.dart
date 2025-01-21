// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unused_field, unused_import, public_member_api_docs, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

import 'dart:core';
import 'package:dogs_core/dogs_core.dart' as gen;
import 'package:lyell/lyell.dart' as gen;
import 'dart:core' as gen0;
import 'package:mapiah/src/elements/parts/th_cs_part.dart' as gen1;
import 'package:mapiah/src/elements/parts/th_cs_part.dart';

class THCSPartConverter extends gen.DefaultStructureConverter<gen1.THCSPart> {
  THCSPartConverter()
      : super(
            struct: const gen.DogStructure<gen1.THCSPart>(
                'THCSPart',
                gen.StructureConformity.dataclass,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'name', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.bool>(), gen.TypeToken<gen0.bool>(), null, gen.IterableKind.none, 'forOutputOnly', false, false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen1.THCSPart>(_activator, [_$name, _$forOutputOnly], _values, _hash, _equals)));

  static dynamic _$name(gen1.THCSPart obj) => obj.name;

  static dynamic _$forOutputOnly(gen1.THCSPart obj) => obj.forOutputOnly;

  static List<dynamic> _values(gen1.THCSPart obj) => [obj.name, obj.forOutputOnly];

  static gen1.THCSPart _activator(List list) {
    return gen1.THCSPart(name: list[0], forOutputOnly: list[1]);
  }

  static int _hash(gen1.THCSPart obj) => obj.name.hashCode ^ obj.forOutputOnly.hashCode;

  static bool _equals(
    gen1.THCSPart a,
    gen1.THCSPart b,
  ) =>
      (a.name == b.name && a.forOutputOnly == b.forOutputOnly);
}

class THCSPartBuilder {
  THCSPartBuilder([gen1.THCSPart? $src]) {
    if ($src == null) {
      $values = List.filled(2, null);
    } else {
      $values = THCSPartConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen1.THCSPart? $src;

  set name(gen0.String value) {
    $values[0] = value;
  }

  gen0.String get name => $values[0];

  set forOutputOnly(gen0.bool value) {
    $values[1] = value;
  }

  gen0.bool get forOutputOnly => $values[1];

  gen1.THCSPart build() {
    var instance = THCSPartConverter._activator($values);

    return instance;
  }
}

extension THCSPartDogsExtension on gen1.THCSPart {
  gen1.THCSPart rebuild(Function(THCSPartBuilder b) f) {
    var builder = THCSPartBuilder(this);
    f(builder);
    return builder.build();
  }

  THCSPartBuilder toBuilder() {
    return THCSPartBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen1.THCSPart);
  }
}
