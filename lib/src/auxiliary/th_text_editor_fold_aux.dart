// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/th2_text_editor_lexer.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_lexical_types.dart';

export 'package:mapiah/src/auxiliary/th_text_editor_lexical_types.dart';

const Set<String> _thTextEditorFoldableBlocks = <String>{
  'survey',
  'centreline',
  'map',
  'scrap',
  'layout',
};

final RegExp _thTextEditorFoldLineWordRegExp = RegExp(r'^\s*([A-Za-z]+)\b');

/// Builds fold regions for balanced `survey`/`centreline`/`map`/`scrap`/
/// `layout` blocks and their matching `end...` lines.
///
/// This is a line scanner with a stack, not indentation-based folding.
/// Blocks may nest (e.g. `survey` containing `centreline`). An opening
/// keyword with no matching `end...` before end of input produces no fold
/// region for that block.
///
/// For [THTextEditorLanguage.th2], the regions are balanced `scrap`, `line`,
/// `area` and `comment` blocks of logical lines, as [scanTH2EditorText]
/// computes them.
List<THTextEditorFoldRegion> buildFoldRegions(
  String content, {
  THTextEditorLanguage language = THTextEditorLanguage.therion,
}) {
  if (language == THTextEditorLanguage.th2) {
    return scanTH2EditorText(content).foldRegions;
  }

  final List<String> lines = content.split('\n');
  final List<MapEntry<String, int>> openStack = <MapEntry<String, int>>[];
  final List<THTextEditorFoldRegion> regions = <THTextEditorFoldRegion>[];

  for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    final RegExpMatch? match = _thTextEditorFoldLineWordRegExp.firstMatch(
      lines[lineIndex],
    );

    if (match == null) {
      continue;
    }

    final String word = match.group(1)!.toLowerCase();

    if (_thTextEditorFoldableBlocks.contains(word)) {
      openStack.add(MapEntry<String, int>(word, lineIndex));

      continue;
    }

    if (word.startsWith('end') && word.length > 3) {
      final String blockName = word.substring(3);

      if (!_thTextEditorFoldableBlocks.contains(blockName)) {
        continue;
      }

      final int matchingOpenIndex = openStack.lastIndexWhere(
        (MapEntry<String, int> entry) => entry.key == blockName,
      );

      if (matchingOpenIndex == -1) {
        continue;
      }

      final int startLine = openStack[matchingOpenIndex].value;

      openStack.removeRange(matchingOpenIndex, openStack.length);
      regions.add(
        THTextEditorFoldRegion(startLine: startLine, endLine: lineIndex),
      );
    }
  }

  regions.sort(
    (THTextEditorFoldRegion a, THTextEditorFoldRegion b) =>
        a.startLine.compareTo(b.startLine),
  );

  return regions;
}

const Set<String> _th2TextEditorBlockOpeners = <String>{
  'scrap',
  'line',
  'area',
  'comment',
};

/// The first words of a line after which Enter indents one more level.
Set<String> thTextEditorBlockOpeners(THTextEditorLanguage language) {
  return switch (language) {
    THTextEditorLanguage.therion => _thTextEditorFoldableBlocks,
    THTextEditorLanguage.th2 => _th2TextEditorBlockOpeners,
  };
}
