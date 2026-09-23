// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:path/path.dart' as p;

void main() {
  group('MPDirectoryAux.rebaseRelativePath', () {
    test(
      'keeps imported SVG pointing to the same file after SaveAs moves TH2',
      () {
        final String rebasedPath = MPDirectoryAux.rebaseRelativePath(
          oldReferencePath: '/work/maps/original/croqui.th2',
          newReferencePath: '/work/maps/exported/croqui-copy.th2',
          filename: './assets/plan.svg',
        );

        expect(rebasedPath, '../original/assets/plan.svg');
      },
    );

    test('preserves absolute asset paths', () {
      final String rebasedPath = MPDirectoryAux.rebaseRelativePath(
        oldReferencePath: '/work/maps/original/croqui.th2',
        newReferencePath: '/work/maps/exported/croqui-copy.th2',
        filename: '/shared/assets/plan.svg',
      );

      expect(rebasedPath, '/shared/assets/plan.svg');
    });

    test('converts absolute asset paths to relative during first SaveAs', () {
      final String rebasedPath = MPDirectoryAux.rebaseRelativePath(
        oldReferencePath: 'new_file_42',
        newReferencePath: '/home/rodrigo/temp/project/croqui.th2',
        filename: '/home/rodrigo/temp/croqui.jpg',
      );

      expect(rebasedPath, '../croqui.jpg');
    });

    test('rebases malformed relative paths created before first SaveAs', () {
      final String rebasedPath = MPDirectoryAux.relativePathFromReferencePath(
        referencePath: '/home/rodrigo/temp/project/croqui.th2',
        targetPath: '/home/rodrigo/temp/croqui.jpg',
      );

      expect(rebasedPath, '../croqui.jpg');
    });
  });

  group('MPDirectoryAux with a Windows path context', () {
    final p.Context windowsContext = p.Context(
      style: p.Style.windows,
      current: r'C:\Users\Caver',
    );

    test('preserves absolute asset paths verbatim, including letter case', () {
      const String filename = r'D:\Scans\Plan View.PNG';
      final String rebasedPath = MPDirectoryAux.rebaseRelativePath(
        oldReferencePath: r'C:\Caves\Maps\Orig\Croqui.th2',
        newReferencePath: r'C:\Caves\Maps\Export\Copy.th2',
        filename: filename,
        pathContext: windowsContext,
      );

      expect(rebasedPath, filename);
    });

    test('rebases relative asset paths keeping letter case', () {
      final String rebasedPath = MPDirectoryAux.rebaseRelativePath(
        oldReferencePath: r'C:\Caves\Maps\Orig\Croqui.th2',
        newReferencePath: r'C:\Caves\Maps\Export\Copy.th2',
        filename: './Assets/Plan.SVG',
        pathContext: windowsContext,
      );

      expect(rebasedPath, '../Orig/Assets/Plan.SVG');
    });

    test('rebases relative asset paths when directory case differs', () {
      final String rebasedPath = MPDirectoryAux.rebaseRelativePath(
        oldReferencePath: r'C:\Caves\Maps\Orig\Croqui.th2',
        newReferencePath: r'c:\caves\maps\export\Copy.th2',
        filename: './Assets/Plan.SVG',
        pathContext: windowsContext,
      );

      expect(rebasedPath, '../Orig/Assets/Plan.SVG');
    });

    test('keeps the absolute path when the new file is on another drive', () {
      final String rebasedPath = MPDirectoryAux.rebaseRelativePath(
        oldReferencePath: r'C:\Caves\Orig\Croqui.th2',
        newReferencePath: r'D:\Other\Copy.th2',
        filename: './Assets/Plan.SVG',
        pathContext: windowsContext,
      );

      expect(rebasedPath, r'C:\Caves\Orig\Assets\Plan.SVG');
    });

    test('converts absolute asset paths to relative during first SaveAs', () {
      final String rebasedPath = MPDirectoryAux.rebaseRelativePath(
        oldReferencePath: 'new_file_42',
        newReferencePath: r'C:\Caves\Project\Croqui.th2',
        filename: r'C:\Caves\Scans\Plan View.JPG',
        pathContext: windowsContext,
      );

      expect(rebasedPath, '../Scans/Plan View.JPG');
    });

    test('resolves paths without changing letter case', () {
      final String resolvedPath = MPDirectoryAux.getResolvedPath(
        r'C:\Caves\Maps\Orig\Croqui.th2',
        './Assets/../Scans/Plan.PNG',
        pathContext: windowsContext,
      );

      expect(resolvedPath, r'C:\Caves\Maps\Orig\Scans\Plan.PNG');
    });
  });
}
