// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'th_test_aux.dart';

void main() {
  THTestAux.ensureTestEnvironment();

  group('MPImageInsertConfig defaults', () {
    test('raster defaults match phase 1 plan', () {
      final MPRasterImageInsertConfig config = MPRasterImageInsertConfig(
        parentMPID: mpParentMPIDPlaceholder,
        filename: 'images/photo.png',
        xx: 10.0,
        yy: 20.0,
      );

      expect(config.xScale.toString(), '1');
      expect(config.yScale.toString(), '1');
      expect(config.rotationCenterDx.toString(), '0');
      expect(config.rotationCenterDy.toString(), '0');
      expect(config.rotationDeg.toString(), '0');
      expect(config.isVisible, isTrue);
    });

    test('fromString constructors apply string defaults', () {
      final MPRasterImageInsertConfig raster =
          MPRasterImageInsertConfig.fromString(
            parentMPID: mpParentMPIDPlaceholder,
            filename: 'images/photo.png',
            xx: '10',
            yy: '20',
          );
      final MPXVIImageInsertConfig xvi = MPXVIImageInsertConfig.fromString(
        parentMPID: mpParentMPIDPlaceholder,
        filename: 'images/survey.xvi',
        xx: '-36',
        yy: '28',
      );

      expect(raster.xScale.toString(), '1');
      expect(raster.rotationDeg.toString(), '0');
      expect(xvi.xScale.toString(), '1');
      expect(xvi.rotationDeg.toString(), '0');
      expect(xvi.isGridVisible, isTrue);
    });

    test('transform helpers keep runtime scaling and translation ready', () {
      final MPRasterImageInsertConfig config = MPRasterImageInsertConfig(
        parentMPID: mpParentMPIDPlaceholder,
        filename: 'images/photo.png',
        xx: 5.0,
        yy: 7.0,
        xScale: 2.0,
        yScale: 3.0,
      );

      expect(
        config.transformLocalRect(const Rect.fromLTWH(0.0, 0.0, 4.0, 5.0)),
        const Rect.fromLTRB(5.0, 7.0, 13.0, 22.0),
      );
      expect(config.scaledRotationCenter, Offset.zero);
    });
  });

  group('MPImageInsertConfig codec', () {
    test('raster metadata round-trips and does not persist visibility', () {
      final MPRasterImageInsertConfig original = MPRasterImageInsertConfig(
        parentMPID: mpParentMPIDPlaceholder,
        filename: 'images/photo 01;v1.png',
        xx: 10.5,
        yy: -20.0,
        xScale: 2.0,
        yScale: 3.0,
        rotationCenterDx: 4.0,
        rotationCenterDy: 5.0,
        rotationDeg: 6.0,
        isVisible: false,
      );

      final String metadata = original.toMetadataString();
      final MPImageInsertConfig decoded =
          MPImageInsertConfig.fromMetadataString(
            parentMPID: mpParentMPIDPlaceholder,
            metadata: metadata,
          );

      expect(decoded, isA<MPRasterImageInsertConfig>());
      expect(decoded.filename, original.filename);
      expect(decoded.xx, original.xx);
      expect(decoded.yy, original.yy);
      expect(decoded.xScale, original.xScale);
      expect(decoded.yScale, original.yScale);
      expect(decoded.rotationCenterDx, original.rotationCenterDx);
      expect(decoded.rotationCenterDy, original.rotationCenterDy);
      expect(decoded.rotationDeg, original.rotationDeg);
      expect(decoded.isVisible, isTrue);
      expect(
        decoded.toMetadataLine(),
        '$mpMapiahConfigID $mpMapiahImageInsertConfigID {$metadata}',
      );
    });

    test('xvi metadata round-trips through toMap and fromMap', () {
      final MPXVIImageInsertConfig original = MPXVIImageInsertConfig(
        parentMPID: mpParentMPIDPlaceholder,
        filename: 'images/survey.xvi',
        xx: -36.0,
        yy: 28.0,
        isGridVisible: false,
        xviRoot: 'station_A',
      );

      final MPImageInsertConfig fromMetadata =
          MPImageInsertConfig.fromMetadataString(
            parentMPID: mpParentMPIDPlaceholder,
            metadata: original.toMetadataString(),
          );
      final MPImageInsertConfig fromMap = MPImageInsertConfig.fromMap(
        original.toMap(),
      );

      expect(fromMetadata, isA<MPXVIImageInsertConfig>());
      expect(fromMetadata.filename, original.filename);
      expect(fromMetadata.xx.value, original.xx.value);
      expect(fromMetadata.yy.value, original.yy.value);
      expect(fromMetadata.xScale.value, original.xScale.value);
      expect(fromMetadata.yScale.value, original.yScale.value);
      expect(
        fromMetadata.rotationCenterDx.value,
        original.rotationCenterDx.value,
      );
      expect(
        fromMetadata.rotationCenterDy.value,
        original.rotationCenterDy.value,
      );
      expect(fromMetadata.rotationDeg.value, original.rotationDeg.value);
      expect(
        (fromMetadata as MPXVIImageInsertConfig).xviRoot,
        original.xviRoot,
      );
      expect((fromMap as MPXVIImageInsertConfig).isGridVisible, isFalse);
      expect(fromMap.toMap(), original.toMap());
    });
  });

  group('MPImageInsertConfig runtime preparation', () {
    test('TH2File image access includes XTherion and Mapiah image entries', () {
      final TH2File file = TH2File();
      final THXTherionImageInsertConfig xtherionImage =
          THXTherionImageInsertConfig(
            parentMPID: mpParentMPIDPlaceholder,
            filename: 'images/legacy.png',
            xx: THDoublePart(value: 1.0),
            yy: THDoublePart(value: 2.0),
          );
      final MPRasterImageInsertConfig mapiahImage = MPRasterImageInsertConfig(
        parentMPID: mpParentMPIDPlaceholder,
        filename: 'images/runtime.png',
        xx: 3.0,
        yy: 4.0,
      );

      file.addElement(xtherionImage);
      file.addElementToParent(
        xtherionImage,
        elementPositionInParent: mpAddChildAtEndOfParentChildrenList,
      );
      file.addElement(mapiahImage);
      file.addElementToParent(
        mapiahImage,
        elementPositionInParent: mpAddChildAtEndOfParentChildrenList,
      );

      expect(
        file.getImages().map((MPRuntimeImageInsertConfigMixin image) {
          return image.filename;
        }).toList(),
        <String>['images/legacy.png', 'images/runtime.png'],
      );

      file.reorderImageMPIDs(oldIndex: 0, newIndex: 1);

      expect(
        file.getImages().map((MPRuntimeImageInsertConfigMixin image) {
          return image.filename;
        }).toList(),
        <String>['images/runtime.png', 'images/legacy.png'],
      );
    });

    test('XVI descendants keep grid visibility in synced runtime cache', () {
      final MPXVIImageInsertConfig config = MPXVIImageInsertConfig(
        parentMPID: mpParentMPIDPlaceholder,
        filename: 'images/survey.xvi',
        xx: 0.0,
        yy: 0.0,
        isGridVisible: false,
      );
      final XVIFile xviFile = XVIFile();

      config.setXVIFile(xviFile);

      expect(xviFile.isGridVisible, isFalse);

      config.isGridVisible = true;

      expect(xviFile.isGridVisible, isTrue);
    });
  });
}
