// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// One foldable, balanced `block ... endblock` region, as zero-based,
/// inclusive line numbers.
class THTextEditorFoldRegion {
  final int startLine;

  final int endLine;

  const THTextEditorFoldRegion({
    required this.startLine,
    required this.endLine,
  });

  @override
  bool operator ==(Object other) =>
      other is THTextEditorFoldRegion &&
      other.startLine == startLine &&
      other.endLine == endLine;

  @override
  int get hashCode => Object.hash(startLine, endLine);

  @override
  String toString() => 'THTextEditorFoldRegion($startLine, $endLine)';
}

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
List<THTextEditorFoldRegion> buildFoldRegions(String content) {
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
