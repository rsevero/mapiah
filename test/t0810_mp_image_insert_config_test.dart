// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'th_test_aux.dart';

void main() {
  THTestAux.ensureTestEnvironment();

  group('MPImageInsertConfig defaults', () {
    test('raster defaults match phase 1 plan', () {
      final MPRasterImageInsertConfig config = MPRasterImageInsertConfig(
        parentMPID: mpParentMPIDPlaceholder,
        filename: 'images/photo.png',
        xx: THDoublePart.fromString(valueString: '10'),
        yy: THDoublePart.fromString(valueString: '20'),
      );

      expect(config.xScale.toString(), '1');
      expect(config.yScale.toString(), '1');
      expect(config.rotationCenterDx.toString(), '0');
      expect(config.rotationCenterDy.toString(), '0');
      expect(config.rotationDeg.toString(), '0');
      expect(config.isVisible, isTrue);
    });
  });

  group('MPImageInsertConfig codec', () {
    test('raster metadata round-trips and does not persist visibility', () {
      final MPRasterImageInsertConfig original = MPRasterImageInsertConfig(
        parentMPID: mpParentMPIDPlaceholder,
        filename: 'images/photo 01;v1.png',
        xx: THDoublePart.fromString(valueString: '10.5'),
        yy: THDoublePart.fromString(valueString: '-20'),
        xScale: THDoublePart.fromString(valueString: '2'),
        yScale: THDoublePart.fromString(valueString: '3'),
        rotationCenterDx: THDoublePart.fromString(valueString: '4'),
        rotationCenterDy: THDoublePart.fromString(valueString: '5'),
        rotationDeg: THDoublePart.fromString(valueString: '6'),
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
        xx: THDoublePart.fromString(valueString: '-36'),
        yy: THDoublePart.fromString(valueString: '28'),
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
}
