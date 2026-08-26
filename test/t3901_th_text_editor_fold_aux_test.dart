// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_fold_aux.dart';

void main() {
  group('buildFoldRegions', () {
    test('folds a single balanced block', () {
      const String content = 'survey one\nendsurvey';
      final List<THTextEditorFoldRegion> regions = buildFoldRegions(content);

      expect(regions, <THTextEditorFoldRegion>[
        const THTextEditorFoldRegion(startLine: 0, endLine: 1),
      ]);
    });

    test('folds each of the five block kinds', () {
      const String content =
          'survey s\nendsurvey\n'
          'centreline c\nendcentreline\n'
          'map m\nendmap\n'
          'scrap sc\nendscrap\n'
          'layout l\nendlayout';
      final List<THTextEditorFoldRegion> regions = buildFoldRegions(content);

      expect(regions, hasLength(5));
    });

    test('folds nested blocks independently', () {
      const String content =
          'survey outer\ncentreline c\nendcentreline\nendsurvey';
      final List<THTextEditorFoldRegion> regions = buildFoldRegions(content);

      expect(regions, <THTextEditorFoldRegion>[
        const THTextEditorFoldRegion(startLine: 0, endLine: 3),
        const THTextEditorFoldRegion(startLine: 1, endLine: 2),
      ]);
    });

    test('an unterminated block produces no fold region', () {
      const String content = 'survey one\ncentreline c\nendcentreline';
      final List<THTextEditorFoldRegion> regions = buildFoldRegions(content);

      expect(regions, <THTextEditorFoldRegion>[
        const THTextEditorFoldRegion(startLine: 1, endLine: 2),
      ]);
    });

    test('empty input produces no fold regions', () {
      expect(buildFoldRegions(''), isEmpty);
    });

    test('expanding a folded block does not mutate the source text', () {
      const String content = 'survey one\nendsurvey\n';

      buildFoldRegions(content);

      expect(content, 'survey one\nendsurvey\n');
    });
  });
}
