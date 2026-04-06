// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_element_edit_aux.dart';

void main() {
  group('MPElementEditAux.getNextStationName', () {
    test('returns zero for empty names and one for empty unique parts', () {
      expect(MPElementEditAux.getNextStationName(''), '0');
      expect(MPElementEditAux.getNextStationName('@survey'), '1@survey');
    });

    test('increments trailing numeric parts preserving zero padding', () {
      expect(MPElementEditAux.getNextStationName('1'), '2');
      expect(MPElementEditAux.getNextStationName('009'), '010');
      expect(MPElementEditAux.getNextStationName('A-099'), 'A-100');
      expect(MPElementEditAux.getNextStationName('A-99'), 'A-100');
    });

    test('increments trailing alphabetic parts with rollover', () {
      expect(MPElementEditAux.getNextStationName('A'), 'B');
      expect(MPElementEditAux.getNextStationName('Z'), 'ZA');
      expect(MPElementEditAux.getNextStationName('z'), 'za');
      expect(MPElementEditAux.getNextStationName('sec-az'), 'sec-aza');
      expect(MPElementEditAux.getNextStationName('001-TRZ'), '001-TRZA');
    });

    test(
      'appends one when the unique part ends with non-incrementable chars',
      () {
        expect(MPElementEditAux.getNextStationName('A12-'), 'A12-1');
        expect(MPElementEditAux.getNextStationName('foo-009.'), 'foo-009.1');
      },
    );

    test('appends one when unique part has no incrementable token', () {
      expect(MPElementEditAux.getNextStationName('--'), '--1');
      expect(MPElementEditAux.getNextStationName('..@branch'), '..1@branch');
    });

    test('preserves the survey suffix when present', () {
      expect(MPElementEditAux.getNextStationName('A12@main'), 'A13@main');
      expect(MPElementEditAux.getNextStationName('Z@survey'), 'ZA@survey');
      expect(
        MPElementEditAux.getNextStationName('foo-009.@branch'),
        'foo-009.1@branch',
      );
    });
  });

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
