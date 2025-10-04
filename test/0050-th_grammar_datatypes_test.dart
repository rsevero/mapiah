import 'package:flutter_test/flutter_test.dart';
import 'package:petitparser/petitparser.dart';

import 'package:mapiah/src/mp_file_read_write/th_grammar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('comment', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.endLineComment()).end();

    const successes = [
      '# comment',
      ' # comment with leading space',
      '  # comment with leading and trailing spaces ',
    ];

    for (var success in successes) {
      test(success, () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value[1], success.trim());
      });
    }

    const failures = [
      '-point',
      '_secret*Keywork49/',
      '/st+range39',
      '099.92',
      'cmy,k-rgb',
      "OSGB'",
    ];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });

  group('keyword', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.keyword()).end();

    const successes = [
      'point',
      '_secretKeywork49/',
      '  /strange39',
      '09992  ',
      ' cmyk-rgb  ',
    ];

    for (var success in successes) {
      test(success, () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, success.trim());
      });
    }

    const failures = [
      '-point',
      '_secret*Keywork49/',
      '/st+range39',
      '099.92',
      'cmy,k-rgb',
      "OSGB'",
    ];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });

  group('extkeyword', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.extKeyword()).end();

    const successes = [
      'point',
      '_secretKeywork49/',
      '/strange39',
      '09992',
      ' cmyk-rgb',
      '_secret*Keywork49/  ',
      '/st+range39',
      '099.92',
      'cmy,k-rgb',
      "OSGB'",
    ];

    for (var success in successes) {
      test(success, () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, success.trim());
      });
    }

    const failures = [
      '-point',
      '+secret*Keywork49/',
      '.st+range39',
      ',099.92',
      "'cmy,k-rgb",
      "*OSGB'",
    ];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });

  group('noDate', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.noDateTime()).end();

    const successes = {'-': '-'};

    for (var success in successes.keys) {
      test(success, () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, successes[success]);
      });
    }

    const failures = ['+', '.', ',', "'", "*"];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });

  group('singleDateTime', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.singleDateTime().end());

    const successes = {
      '2021.02': '2021.02',
      '2022.02.13@11:27:32': '2022.02.13@11:27:32',
      '2022.02.13@11:58:00.32': '2022.02.13@11:58:00.32',
    };

    for (var success in successes.keys) {
      test(success, () {
        final result = parser.parse(success);
        // trace(parser).parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, successes[success]);
      });
    }

    const failures = [
      '2022.',
      '2022:02.9',
      '2022.02.13.11',
      '2022.02.13@',
      '2022.2.5',
      '2022.02.9@2:30',
      '2021.12.23@8:30:1',
      '22.02.09@02:30:07',
      '2022.02.13@11:27:32 - 2022.02.13@11:58:00',
      '2021.12.23@08:30:01 - 2022.02.09@02:30:07',
    ];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });

  group('dateTime', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(
      grammar.dateTimeRange().flatten().trim().end(),
    );
    const successes = {
      '2022.02.13@11:27:32 - 2022.02.13@11:58:00':
          '2022.02.13@11:27:32 - 2022.02.13@11:58:00',
      '2022.02.13@11:27:32-2022.02.13@11:58:00':
          '2022.02.13@11:27:32-2022.02.13@11:58:00',
      '2021.12.23@08:30:01 - 2022.02.09@02:30:07':
          '2021.12.23@08:30:01 - 2022.02.09@02:30:07',
      '2021.12.23 - 2022.02.09@02:30 ': '2021.12.23 - 2022.02.09@02:30',
    };

    var id = 1;
    for (var success in successes.keys) {
      test("$id - $success", () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, successes[success]);
      });
      id++;
    }

    const failures = [
      '2021.12.23@8:30:1',
      '22.02.09@02:30:7',
      '2021.02',
      '2022.02.13@11:27:32',
      '2022.02.13@11:58:00.32',
    ];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });

  group('dateTime empty', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.dateTimeAllVariations().end());

    const successes = {'-': '-'};

    for (var success in successes.keys) {
      test(success, () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, successes[success]);
      });
    }

    const failures = ['+', '.', ',', "'", "*"];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });

  group('dateTime with data', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.dateTimeAllVariations().end());

    const mapSuccesses = {
      '2021.12.23@08:30:01': '2021.12.23@08:30:01',
      '2022.02.09@02:30:07  ': '2022.02.09@02:30:07',
      '2021.02': '2021.02',
      '2022.02.13@11:27:32': '2022.02.13@11:27:32',
      '2022.02.13@11:58:00.32': '2022.02.13@11:58:00.32',
      '2022.02.13@11:27:32 - 2022.02.13@11:58:00':
          '2022.02.13@11:27:32 - 2022.02.13@11:58:00',
      '2021.12.23@08:30:01 - 2022.02.09@02:30:07':
          '2021.12.23@08:30:01 - 2022.02.09@02:30:07',
      '2021.12.23 - 2022.02.09@02:30 ': '2021.12.23 - 2022.02.09@02:30',
    };

    int id = 1;
    for (var success in mapSuccesses.keys) {
      test("$id - $success", () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, mapSuccesses[success]);
      });
      id++;
    }
  });

  group('quotedString', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.quotedString()).end();

    const successes = {
      '"blaus"': 'blaus',
      '""': '',
      '"""Obs"" hein?"': '""Obs"" hein?',
    };

    for (var success in successes.keys) {
      test(success, () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, successes[success]);
      });
    }

    const failures = ['"""Obs"" hein?', 'blaus"', '"blaus'];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });

  group('bracketString', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.bracketStringGeneral().end());

    const successes = {
      '[blaus]': 'blaus',
      '[]': '',
      '[""Obs"" hein?]': '""Obs"" hein?',
    };

    for (var success in successes.keys) {
      test(success, () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, successes[success]);
      });
    }

    const failures = ['"""Obs"" hein?', 'blaus"', '"blaus'];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });

  group('length units', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.lengthUnit()).end();

    const successes = [
      'meter',
      'meters',
      'metre',
      'metres',
      'm',
      'M',
      'centimeter',
      'centimeters',
      'CENTIMETRE',
      'cEnTiMeTrEs',
      'cm',
      'inch',
      'inches',
      'in',
      'feet',
      'feets',
      'ft',
      'yard',
      'yards',
      'yd',
    ];

    for (var success in successes) {
      test(success, () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, success.trim());
      });
    }

    const failures = ['inchs'];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });

  group('angle units', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.angleUnit()).end();

    const successes = [
      'degree',
      'degrees',
      'deg',
      'minute',
      'minutes',
      'min',
      'grad',
      'grads',
      'mil',
      'mils',
    ];

    for (var success in successes) {
      test(success, () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, success.trim());
      });
    }

    const failures = ['degre', 'M', 'percent', 'percentage'];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });

  group('clino units', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.clinoUnit()).end();

    const successes = [
      'degree',
      'degrees',
      'deg',
      'minute',
      'minutes',
      'min',
      'grad',
      'grads',
      'mil',
      'mils',
      'percent',
      'percentage',
    ];

    for (var success in successes) {
      test(success, () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, success.trim());
      });
    }

    const failures = ['degre', 'M'];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });

  group('coordinate systems', () {
    final grammar = THGrammar();
    final parser = grammar.buildFrom(grammar.csSpecs()).end();

    const successes = [
      'UTM23',
      'UTM2',
      'UTM47S',
      'UTM9S',
      'UTM51N',
      'UTM7N',
      'lat-long',
      'long-lat',
      'EPSG:4258',
      'EPSG:25837',
      'ESRI:4322',
      'ETRS31',
      'iJTSK03',
      'JTSK',
      'OSGB:TA',
      'OSGB:HL',
    ];

    for (var success in successes) {
      test(success, () {
        final result = parser.parse(success);
        expect(result.runtimeType.toString(), contains('Success'));
        expect(result.value, success.trim());
      });
    }

    const failures = ['EPSP-43356', 'OSGB:HI', 'JTSK,', 'ETRS21', 'ETRS43'];

    for (var failure in failures) {
      test(failure, () {
        final result = parser.parse(failure);
        expect(result.runtimeType.toString(), 'Failure');
      });
    }
  });
}
