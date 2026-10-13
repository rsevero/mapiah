// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_apply_session.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_endings_aux.dart';
import 'package:mapiah/src/auxiliary/th2_text_normalization_analyzer.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';

import 'auxiliary/th2_text_test_session.dart';
import 'th2_text_apply_test_aux.dart';
import 'th_test_aux.dart';

typedef _Marker = (TH2TextDiagnosticKind, int, int?, String?);

const String _baseText =
    'encoding utf-8\n'
    'scrap s0\n'
    '  point 9 9 station\n'
    'endscrap\n';

void main() {
  THTestAux.ensureTestEnvironment();

  final MPLocator mpLocator = MPLocator();

  setUp(() async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    await mpLocator.mpSettingsController.initialized;
    mpLocator.mpGeneralController.reset();
  });

  tearDown(() {
    TH2TextNormalizationAnalyzer.onUnrecordedRewriteForTesting = null;
    mpLocator.mpGeneralController.reset();
  });

  List<_Marker> markersOf(TH2TextValidationResult result) => <_Marker>[
    for (final TH2TextDiagnostic diagnostic in result.diagnostics)
      if (diagnostic.severity == TH2TextDiagnosticSeverity.information)
        (
          diagnostic.kind,
          diagnostic.line!,
          diagnostic.destinationLine,
          diagnostic.detail,
        ),
  ];

  List<int> mappedLines(TH2TextValidationResult result, String text) {
    final int lineCount = TH2TextLineEndingsAux.lineStartOffsets(text).length;

    return <int>[
      for (int line = 0; line < lineCount; line++)
        result.cursorMapper.mapRawLine(line),
    ];
  }

  /// Validates [text] against a live file loaded from [baseText], checks
  /// its markers and cursor mapping, applies it and checks that the live
  /// model writes N(T).
  Future<TH2TextValidationResult> check(
    String text, {
    required List<_Marker> markers,
    required List<int> mapping,
    String baseText = _baseText,
  }) async {
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      baseText,
    );
    final TH2TextTestSession session = TH2TextTestSession.of(controller);
    final TH2TextValidationResult result = await session.validationCache
        .validate(
          text,
          filename: controller.th2File.filename,
          th2FileMPID: controller.th2File.mpID,
          lineEnding: controller.th2File.lineEnding,
        );

    expect(result.isValid, isTrue, reason: result.diagnostics.join('\n'));
    expect(markersOf(result), unorderedEquals(markers));
    expect(mappedLines(result, text), mapping);

    session.content = text;

    final TH2TextApplyResult applyResult = await controller.applyTextContent(
      text,
      session: session,
    );

    if (result.normalizedText == session.initialContent) {
      expect(applyResult, isA<TH2TextApplyUnchanged>());
    } else {
      expect(applyResult, isA<TH2TextApplyApplied>());
    }
    expect(controller.serializeForTextMode().$1, result.normalizedText);

    return result;
  }

  test('a duplicate line point gets only its removal marker', () async {
    final TH2TextValidationResult result = await check(
      'encoding utf-8\n'
      'scrap s1\n'
      '  line wall\n'
      '    1 1\n'
      '    2 2\n'
      '    2 2\n'
      '    3 3\n'
      '  endline\n'
      'endscrap\n',
      markers: <_Marker>[
        (TH2TextDiagnosticKind.removedDuplicateLinePoint, 5, null, null),
      ],
      mapping: <int>[0, 1, 2, 3, 4, 4, 5, 6, 7],
    );

    expect(
      result.normalizedText,
      'encoding utf-8\n'
      'scrap s1\n'
      '  line wall\n'
      '    1 1\n'
      '    2 2\n'
      '    3 3\n'
      '  endline\n'
      'endscrap\n',
    );
  });

  test('a short line gets its removal marker on every line', () async {
    await check(
      'encoding utf-8\n'
      'scrap s1\n'
      '  point 0 0 station\n'
      '  line wall\n'
      '    1 1\n'
      '  endline\n'
      'endscrap\n',
      markers: <_Marker>[
        (TH2TextDiagnosticKind.removedShortLine, 3, null, null),
        (TH2TextDiagnosticKind.removedShortLine, 4, null, null),
        (TH2TextDiagnosticKind.removedShortLine, 5, null, null),
      ],
      mapping: <int>[0, 1, 2, 2, 2, 2, 3],
    );
  });

  test('a short border line is removed while the other border survives', () async {
    await check(
      'encoding utf-8\n'
      'scrap s1\n'
      '  line border -id b1 -close on\n'
      '    0 0\n'
      '    10 0\n'
      '    10 10\n'
      '    0 0\n'
      '  endline\n'
      '  line border -id b2\n'
      '    5 5\n'
      '  endline\n'
      '  area water\n'
      '    b1\n'
      '    b2\n'
      '  endarea\n'
      'endscrap\n',
      markers: <_Marker>[
        (TH2TextDiagnosticKind.removedShortLine, 8, null, null),
        (TH2TextDiagnosticKind.removedShortLine, 9, null, null),
        (TH2TextDiagnosticKind.removedShortLine, 10, null, null),
        (TH2TextDiagnosticKind.removedBorderOfShortLine, 13, null, null),
      ],
      mapping: <int>[0, 1, 2, 3, 4, 5, 6, 7, 7, 7, 7, 8, 9, 9, 10, 11],
    );

    final TH2FileEditController live = mpLocator.mpGeneralController
        .getTH2FileEditController(filename: TH2TextApplyTestAux.defaultFilename);
    final THArea area = live.th2File.getAreas().single;
    final List<int> borderMPIDs = area.getAreaBorderTHIDMPIDs(live.th2File);

    expect(borderMPIDs, hasLength(1));
    expect(
      live.th2File.areaBorderTHIDByMPID(borderMPIDs.single).thID,
      'b1',
    );
    expect(live.th2File.elementByTHID('b1'), isA<THLine>());
  });

  test('an area left with no border is removed', () async {
    await check(
      'encoding utf-8\n'
      'scrap s1\n'
      '  line border -id b2\n'
      '    5 5\n'
      '  endline\n'
      '  area water\n'
      '    b2\n'
      '  endarea\n'
      'endscrap\n',
      markers: <_Marker>[
        (TH2TextDiagnosticKind.removedShortLine, 2, null, null),
        (TH2TextDiagnosticKind.removedShortLine, 3, null, null),
        (TH2TextDiagnosticKind.removedShortLine, 4, null, null),
        (TH2TextDiagnosticKind.removedEmptyArea, 5, null, null),
        (TH2TextDiagnosticKind.removedBorderOfShortLine, 6, null, null),
        (TH2TextDiagnosticKind.removedEmptyArea, 7, null, null),
      ],
      mapping: <int>[0, 1, 1, 1, 1, 1, 1, 1, 2],
    );
  });

  test('a rewritten scrap header and a line option on its own line', () async {
    await check(
      'encoding utf-8\n'
      'scrap my scrap -projection plan\n'
      '  line wall\n'
      '    close on\n'
      '    1 1\n'
      '    2 2\n'
      '  endline\n'
      'endscrap\n',
      markers: <_Marker>[
        (TH2TextDiagnosticKind.rewrittenLine, 1, null, null),
        (TH2TextDiagnosticKind.rewrittenLine, 2, null, null),
        (TH2TextDiagnosticKind.rewrittenLine, 3, null, null),
      ],
      mapping: <int>[0, 1, 2, 2, 3, 4, 5, 6],
    );
  });

  test('a repaired border reference is rewritten', () async {
    final TH2TextValidationResult result = await check(
      'encoding utf-8\n'
      'scrap s1\n'
      '  line border -id b@1 -close on\n'
      '    0 0\n'
      '    10 0\n'
      '    10 10\n'
      '    0 0\n'
      '  endline\n'
      '  area water\n'
      '    b@1\n'
      '  endarea\n'
      'endscrap\n',
      markers: <_Marker>[
        (TH2TextDiagnosticKind.rewrittenLine, 2, null, null),
        (TH2TextDiagnosticKind.rewrittenLine, 9, null, null),
      ],
      mapping: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
    );

    expect(result.normalizedText, contains('    b_1\n'));
  });

  test('a deleted encoding line is added back', () async {
    await check(
      'scrap s1\n'
      '  point 1 1 station\n'
      'endscrap\n',
      markers: <_Marker>[
        (TH2TextDiagnosticKind.addedLine, 0, null, 'encoding UTF-8'),
      ],
      mapping: <int>[1, 2, 3],
    );
  });

  test('an empty buffer is valid and applies to a file with no scraps', () async {
    final TH2TextValidationResult result = await check(
      '',
      markers: <_Marker>[
        (TH2TextDiagnosticKind.addedLine, 0, null, 'encoding UTF-8'),
      ],
      mapping: <int>[],
    );

    expect(result.cursorMapper.mapRawLine(0), 0);

    final TH2FileEditController live = mpLocator.mpGeneralController
        .getTH2FileEditController(filename: TH2TextApplyTestAux.defaultFilename);

    expect(live.th2File.scrapMPIDs, isEmpty);
  });

  group('moved settings', () {
    test('a setting typed after a scrap moves up', () async {
      await check(
        'encoding utf-8\n'
        '##XTHERION## xth_me_area_adjust 0 0 100 100\n'
        '# a comment\n'
        '\n'
        'scrap s1\n'
        '  point 1 1 station\n'
        'endscrap\n'
        '##XTHERION## xth_me_area_zoom_to 100\n',
        markers: <_Marker>[
          (TH2TextDiagnosticKind.movedSetting, 7, 3, null),
        ],
        mapping: <int>[0, 1, 2, 4, 5, 6, 7, 3],
      );
    });

    test('several settings after a shorter drawing block', () async {
      await check(
        'encoding utf-8\n'
        '##XTHERION## xth_me_area_adjust 0 0 100 100\n'
        'scrap s1\n'
        'endscrap\n'
        '##XTHERION## xth_me_area_zoom_to 100\n'
        '##XTHERION## xth_me_image_insert {0 1 1.0} {0 {}} "a.png" 0 {}\n',
        markers: <_Marker>[
          (TH2TextDiagnosticKind.movedSetting, 4, 2, null),
          (TH2TextDiagnosticKind.movedSetting, 5, 3, null),
        ],
        mapping: <int>[0, 1, 4, 5, 2, 3],
      );
    });

    test('a setting separated only by comments and empty lines stays', () async {
      await check(
        'encoding utf-8\n'
        '##XTHERION## xth_me_area_adjust 0 0 100 100\n'
        '# comment\n'
        '\n'
        '##XTHERION## xth_me_area_zoom_to 100\n'
        'scrap s1\n'
        'endscrap\n',
        markers: <_Marker>[],
        mapping: <int>[0, 1, 2, 3, 4, 5, 6],
      );
    });

    test('a settings-looking line inside a scrap is a comment', () async {
      final TH2TextValidationResult result = await check(
        'encoding utf-8\n'
        'scrap s1\n'
        '##XTHERION## xth_me_area_zoom_to 100\n'
        'endscrap\n',
        markers: <_Marker>[],
        mapping: <int>[0, 1, 2, 3],
      );

      final int commentMPID = result.parserMap.ownerOfLine(2)!;

      expect(result.detachedFile.elementByMPID(commentMPID), isA<THComment>());
    });

    test('an unterminated last setting that moves up', () async {
      await check(
        'encoding utf-8\n'
        '##XTHERION## xth_me_area_adjust 0 0 100 100\n'
        'scrap s1\n'
        'endscrap\n'
        '##XTHERION## xth_me_area_zoom_to 100',
        markers: <_Marker>[
          (TH2TextDiagnosticKind.movedSetting, 4, 2, null),
          (TH2TextDiagnosticKind.addedEnding, 4, null, null),
        ],
        mapping: <int>[0, 1, 3, 4, 2],
      );
    });
  });

  test('a representable ##MAPIAH## image is a generic rewrite', () async {
    final List<THElement> logged = <THElement>[];

    TH2TextNormalizationAnalyzer.onUnrecordedRewriteForTesting = logged.add;

    await check(
      'encoding utf-8\n'
      '##MAPIAH## image_insert_v1 {format=raster;filename=images%2Fphoto.png;'
      'xx=10;yy=20;xScale=1;yScale=1;rotationCenterDx=0;rotationCenterDy=0;'
      'rotationDeg=0;pivotSet=false}\n'
      'scrap s1\n'
      'endscrap\n',
      markers: <_Marker>[
        (TH2TextDiagnosticKind.genericRewrite, 1, null, null),
      ],
      mapping: <int>[0, 1, 2, 3],
    );

    expect(logged, isEmpty);
  });

  test('lines shifted by added or removed neighbors get no marker', () async {
    await check(
      'encoding utf-8\n'
      'scrap s0\n'
      '  point 1 1 station\n'
      '  point 2 2 station\n'
      '  point 9 9 station\n'
      'endscrap\n',
      baseText: _baseText,
      markers: <_Marker>[],
      mapping: <int>[0, 1, 2, 3, 4, 5],
    );
  });

  test('a cursor maps through its owner or the nearest owner above', () async {
    await check(
      '\n'
      '\n'
      'encoding utf-8\n'
      'scrap s1\n'
      '  line wall\n'
      '    close on\n'
      '    1 1\n'
      '    1 1\n'
      '    2 2\n'
      '  endline\n'
      'endscrap\n'
      '##XTHERION## xth_me_area_zoom_to 100\n',
      markers: <_Marker>[
        (TH2TextDiagnosticKind.rewrittenLine, 4, null, null),
        (TH2TextDiagnosticKind.rewrittenLine, 5, null, null),
        (TH2TextDiagnosticKind.removedDuplicateLinePoint, 7, null, null),
        (TH2TextDiagnosticKind.movedSetting, 11, 1, null),
      ],
      mapping: <int>[0, 0, 0, 2, 3, 3, 4, 4, 5, 6, 7, 1],
    );
  });

  test('a final text that normalizes to the initial text adds no step', () async {
    final TH2FileEditController controller = await TH2TextApplyTestAux.load(
      _baseText,
    );
    final TH2TextTestSession session = TH2TextTestSession.of(controller);
    final int undoCount = controller.undoRedoController.undoCount;
    const String text =
        'encoding utf-8\n'
        'scrap s0\n'
        '  point 9 9 station\n'
        'endscrap\n'
        '\n';

    session.content = text;

    final TH2TextApplyResult result = await controller.applyTextContent(
      text,
      session: session,
    );

    expect(result, isA<TH2TextApplyApplied>());
    expect(controller.undoRedoController.undoCount, undoCount + 1);

    session.restartFrom(controller);

    const String backToInitial = _baseText;

    session.content = backToInitial;

    final TH2TextApplyResult second = await controller.applyTextContent(
      backToInitial,
      session: session,
    );

    expect(second, isA<TH2TextApplyApplied>());

    session.restartFrom(controller);

    const String duplicatePoint =
        'encoding utf-8\n'
        'scrap s0\n'
        '  line wall\n'
        '    1 1\n'
        '    2 2\n'
        '  endline\n'
        'endscrap\n';

    session.content = duplicatePoint;
    await controller.applyTextContent(duplicatePoint, session: session);
    session.restartFrom(controller);

    final int stepsBefore = controller.undoRedoController.undoCount;
    final String withDuplicate = duplicatePoint.replaceFirst(
      '    2 2\n',
      '    2 2\n    2 2\n',
    );

    session.content = withDuplicate;

    final TH2TextApplyResult unchanged = await controller.applyTextContent(
      withDuplicate,
      session: session,
    );

    expect(unchanged, isA<TH2TextApplyUnchanged>());
    expect(controller.undoRedoController.undoCount, stepsBefore);
  });
}
