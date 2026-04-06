// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_element_edit_aux.dart';

void main() {
  group('MPElementEditAux.isExtKeyword', () {
    test('valid simple cases', () {
      expect(MPElementEditAux.isExtKeyword('a'), isTrue);
      expect(MPElementEditAux.isExtKeyword('_'), isTrue);
      expect(
        MPElementEditAux.isExtKeyword('-'),
        isTrue,
      ); // allowed as first char
      expect(MPElementEditAux.isExtKeyword('/abc'), isTrue);
      expect(MPElementEditAux.isExtKeyword('A1_b-2/3'), isTrue);
    });

    test('valid with extended chars after first', () {
      expect(MPElementEditAux.isExtKeyword("a'b"), isTrue);
      expect(MPElementEditAux.isExtKeyword('a.b'), isTrue);
      expect(MPElementEditAux.isExtKeyword('a+b'), isTrue);
      expect(MPElementEditAux.isExtKeyword('a*b'), isTrue);
      expect(MPElementEditAux.isExtKeyword('a,b'), isTrue);
      expect(MPElementEditAux.isExtKeyword("-.'+,*/A"), isTrue);
    });

    test('invalid cases', () {
      expect(MPElementEditAux.isExtKeyword(''), isFalse);
      expect(MPElementEditAux.isExtKeyword(' '), isFalse);
      expect(MPElementEditAux.isExtKeyword('@abc'), isFalse);
      expect(MPElementEditAux.isExtKeyword('a@b'), isFalse);
      expect(MPElementEditAux.isExtKeyword('\$money'), isFalse);
    });
  });

  group('MPElementEditAux.isKeyword', () {
    test('valid cases', () {
      expect(MPElementEditAux.isKeyword('abc'), isTrue);
      expect(MPElementEditAux.isKeyword('A1'), isTrue);
      expect(MPElementEditAux.isKeyword('_start'), isTrue);
      expect(MPElementEditAux.isKeyword('a_b-1'), isTrue);
    });

    test('invalid cases', () {
      expect(MPElementEditAux.isKeyword(''), isFalse);
      expect(
        MPElementEditAux.isKeyword('-abc'),
        isFalse,
      ); // cannot start with '-'
      expect(MPElementEditAux.isKeyword('a.b'), isFalse);
      expect(MPElementEditAux.isKeyword('a+b'), isFalse);
      expect(MPElementEditAux.isKeyword("a'b"), isFalse);
      expect(MPElementEditAux.isKeyword('a/b'), isFalse);
      expect(MPElementEditAux.isKeyword('a*b'), isFalse);
      expect(MPElementEditAux.isKeyword('@abc'), isFalse);
    });
  });
}
