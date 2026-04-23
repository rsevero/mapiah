// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';

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
}
