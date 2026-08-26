// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';

void main() {
  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.thProjectController.closeProject();
  });

  tearDown(() {
    mpLocator.thProjectController.closeProject();
  });

  group('THProjectController compiler diagnostics', () {
    test('applyTherionRunDiagnostics replaces, not appends', () {
      mpLocator.thProjectController.applyTherionRunDiagnostics(
        const <THProjectParseError>[
          THProjectParseError(
            message: 'first run error',
            severity: THProjectParseErrorSeverity.error,
            filePath: '/tmp/cave.th',
            lineNumber: 1,
          ),
        ],
      );

      expect(mpLocator.thProjectController.compilerErrors, hasLength(1));

      mpLocator.thProjectController.applyTherionRunDiagnostics(
        const <THProjectParseError>[
          THProjectParseError(
            message: 'second run warning',
            severity: THProjectParseErrorSeverity.warning,
            filePath: '/tmp/cave.th',
            lineNumber: 2,
          ),
        ],
      );

      expect(mpLocator.thProjectController.compilerErrors, hasLength(1));
      expect(
        mpLocator.thProjectController.compilerErrors.single.message,
        'second run warning',
      );
    });

    test('allDiagnostics merges projectErrors and compilerErrors', () {
      mpLocator.thProjectController.projectErrors.add(
        const THProjectParseError(
          message: 'parse error',
          severity: THProjectParseErrorSeverity.error,
          filePath: '/tmp/thconfig',
          lineNumber: 3,
        ),
      );
      mpLocator.thProjectController.applyTherionRunDiagnostics(
        const <THProjectParseError>[
          THProjectParseError(
            message: 'compiler error',
            severity: THProjectParseErrorSeverity.error,
            filePath: '/tmp/cave.th',
            lineNumber: 4,
          ),
        ],
      );

      final List<String> messages = mpLocator
          .thProjectController
          .allDiagnostics
          .map((THProjectParseError error) => error.message)
          .toList();

      expect(messages, containsAll(<String>['parse error', 'compiler error']));
      expect(messages, hasLength(2));
    });

    test('compilerErrorsForPath filters by canonical path', () {
      mpLocator.thProjectController.applyTherionRunDiagnostics(
        const <THProjectParseError>[
          THProjectParseError(
            message: 'in cave.th',
            severity: THProjectParseErrorSeverity.error,
            filePath: '/tmp/cave.th',
            lineNumber: 1,
          ),
          THProjectParseError(
            message: 'in thconfig',
            severity: THProjectParseErrorSeverity.error,
            filePath: '/tmp/thconfig',
            lineNumber: 1,
          ),
        ],
      );

      final List<THProjectParseError> caveErrors = mpLocator
          .thProjectController
          .compilerErrorsForPath('/tmp/cave.th');

      expect(caveErrors, hasLength(1));
      expect(caveErrors.single.message, 'in cave.th');
    });

    test('closeProject clears compilerErrors', () {
      mpLocator.thProjectController.applyTherionRunDiagnostics(
        const <THProjectParseError>[
          THProjectParseError(
            message: 'lingering error',
            severity: THProjectParseErrorSeverity.error,
            filePath: '/tmp/cave.th',
            lineNumber: 1,
          ),
        ],
      );

      expect(mpLocator.thProjectController.compilerErrors, isNotEmpty);

      mpLocator.thProjectController.closeProject();

      expect(mpLocator.thProjectController.compilerErrors, isEmpty);
    });
  });
}
