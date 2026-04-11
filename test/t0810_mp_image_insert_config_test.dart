// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_svg_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/parts/th_double_part.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th_file_parser.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th_test_aux.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

void main() {
  THTestAux.ensureTestEnvironment();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

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
      expect(config.pivotSet, isFalse);
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
      expect(raster.pivotSet, isFalse);
      expect(xvi.xScale.toString(), '1');
      expect(xvi.rotationDeg.toString(), '0');
      expect(xvi.pivotSet, isTrue);
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
      expect(config.pivotSet, isFalse);
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
      expect(decoded.pivotSet, original.pivotSet);
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
      expect(fromMetadata.pivotSet, isTrue);
      expect(
        (fromMetadata as MPXVIImageInsertConfig).xviRoot,
        original.xviRoot,
      );
      expect((fromMap as MPXVIImageInsertConfig).isGridVisible, isFalse);
      expect(fromMap.toMap(), original.toMap());
    });

    test('svg metadata round-trips through toMap and fromMap', () {
      final MPSVGImageInsertConfig original = MPSVGImageInsertConfig(
        parentMPID: mpParentMPIDPlaceholder,
        filename: 'images/plan.svg',
        xx: 12.0,
        yy: 30.0,
        xScale: -2.0,
        yScale: 3.0,
        rotationCenterDx: 4.0,
        rotationCenterDy: -5.0,
        rotationDeg: 25.0,
        intrinsicSizeInfo: const MPSVGIntrinsicSizeInfo(
          width: 120.0,
          height: 60.0,
          sourceViewBox: Rect.fromLTWH(-10.0, 5.0, 120.0, 60.0),
        ),
      );

      final MPImageInsertConfig fromMetadata =
          MPImageInsertConfig.fromMetadataString(
            parentMPID: mpParentMPIDPlaceholder,
            metadata: original.toMetadataString(),
          );
      final MPImageInsertConfig fromMap = MPImageInsertConfig.fromMap(
        original.toMap(),
      );
      final MPSVGImageInsertConfig fromMetadataSVG =
          fromMetadata as MPSVGImageInsertConfig;

      expect(fromMetadata, isA<MPSVGImageInsertConfig>());
      expect(fromMetadataSVG.intrinsicSizeInfo.width, 120.0);
      expect(fromMetadataSVG.intrinsicSizeInfo.height, 60.0);
      expect(
        fromMetadataSVG.intrinsicSizeInfo.sourceViewBox,
        Rect.fromLTWH(-10.0, 5.0, 120.0, 60.0),
      );
      expect((fromMap as MPSVGImageInsertConfig).toMap(), original.toMap());
    });
  });

  group('MPImageInsertConfig runtime preparation', () {
    setUp(() {
      mpLocator.appLocalizations = AppLocalizationsEn();
      mpLocator.mpGeneralController.reset();
    });

    test(
      'XTherion image config factories route raster and XVI to subclasses',
      () {
        final THXTherionImageInsertConfig raster =
            THXTherionImageInsertConfig.fromString(
              parentMPID: mpParentMPIDPlaceholder,
              filename: 'images/legacy.png',
              xx: '1',
              yy: '2',
            );
        final THXTherionImageInsertConfig xvi = THXTherionImageInsertConfig(
          parentMPID: mpParentMPIDPlaceholder,
          filename: 'images/legacy.xvi',
          xx: THDoublePart(value: 3.0),
          yy: THDoublePart(value: 4.0),
        );

        expect(raster, isA<THRasterXTherionImageInsertConfig>());
        expect(raster.asRasterImage, isNotNull);
        expect(raster.asXVIImage, isNull);

        expect(xvi, isA<THXVIXTherionImageInsertConfig>());
        expect(xvi.asXVIImage, isNotNull);
        expect(xvi.asRasterImage, isNull);
      },
    );

    test(
      'XTherion fromMap routes by format before reading XVI-only fields',
      () {
        final THXTherionImageInsertConfig raster =
            THXTherionImageInsertConfig.fromMap(<String, dynamic>{
              'mpID': 100,
              'parentMPID': mpParentMPIDPlaceholder,
              'sameLineComment': null,
              'format': mpImageInsertFormatRaster,
              'filename': 'images/legacy.png',
              'xx': const <String, dynamic>{'value': 1.0},
              'isVisible': true,
              'igamma': const <String, dynamic>{'value': 1.0},
              'yy': const <String, dynamic>{'value': 2.0},
              'xviRoot': 'should_be_ignored',
              'isGridVisible': false,
              'iidx': 0,
              'imgx': '',
              'xData': '',
              'xImage': false,
              'originalLineInTH2File': '',
            });
        final THXTherionImageInsertConfig xvi =
            THXTherionImageInsertConfig.fromMap(<String, dynamic>{
              'mpID': 101,
              'parentMPID': mpParentMPIDPlaceholder,
              'sameLineComment': null,
              'format': mpImageInsertFormatXVI,
              'filename': 'images/legacy.xvi',
              'xx': const <String, dynamic>{'value': 3.0},
              'isVisible': true,
              'igamma': const <String, dynamic>{'value': 1.0},
              'yy': const <String, dynamic>{'value': 4.0},
              'xviRoot': 'station_A',
              'isGridVisible': false,
              'iidx': 0,
              'imgx': '',
              'xData': '',
              'xImage': false,
              'originalLineInTH2File': '',
            });

        expect(raster, isA<THRasterXTherionImageInsertConfig>());
        expect(raster.asXVIImage, isNull);
        expect(xvi, isA<THXVIXTherionImageInsertConfig>());
        expect(xvi.asXVIImage!.xviRoot, 'station_A');
        expect(xvi.asXVIImage!.isGridVisible, isFalse);
      },
    );

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

    test('conversion from XTherion keeps runtime image semantics', () {
      final THXTherionImageInsertConfig raster = THXTherionImageInsertConfig(
        parentMPID: mpParentMPIDPlaceholder,
        filename: 'images/legacy.png',
        xx: THDoublePart(value: 12.0),
        yy: THDoublePart(value: 34.0),
        isVisible: false,
      );
      final THXTherionImageInsertConfig xvi = THXTherionImageInsertConfig(
        parentMPID: mpParentMPIDPlaceholder,
        filename: 'images/legacy.xvi',
        xx: THDoublePart(value: 56.0),
        yy: THDoublePart(value: 78.0),
        isVisible: false,
        isGridVisible: false,
        xviRoot: 'station_A',
      );

      final MPImageInsertConfig convertedRaster =
          MPImageInsertConfig.fromXTherionImageInsertConfig(
            xtherionImageInsertConfig: raster,
          );
      final MPImageInsertConfig convertedXVI =
          MPImageInsertConfig.fromXTherionImageInsertConfig(
            xtherionImageInsertConfig: xvi,
          );
      final MPXVIImageInsertConfig convertedXVIAsXVI =
          convertedXVI as MPXVIImageInsertConfig;

      expect(convertedRaster, isA<MPRasterImageInsertConfig>());
      expect(convertedRaster.mpID, raster.mpID);
      expect(convertedRaster.filename, raster.filename);
      expect(convertedRaster.xx, raster.xx);
      expect(convertedRaster.yy, raster.yy);
      expect(convertedRaster.isVisible, isFalse);
      expect(convertedRaster.xScale.toString(), '1');
      expect(convertedRaster.rotationDeg.toString(), '0');
      expect(convertedRaster.pivotSet, isFalse);

      expect(convertedXVI, isA<MPXVIImageInsertConfig>());
      expect(convertedXVI.mpID, xvi.mpID);
      expect(convertedXVI.filename, xvi.filename);
      expect(convertedXVI.xx, xvi.xx);
      expect(convertedXVI.yy, xvi.yy);
      expect(convertedXVI.isVisible, isFalse);
      expect(convertedXVI.pivotSet, isTrue);
      expect(convertedXVIAsXVI.isGridVisible, isFalse);
      expect(convertedXVIAsXVI.xviRoot, 'station_A');
    });

    test(
      'raster bounding box is refreshed after decoded raster image becomes available',
      () async {
        final TH2FileParser parser = TH2FileParser();
        final String path = THTestAux.testPath('2025-10-26-001-with_image.th2');
        final (_, isSuccessful, errors) = await parser.parse(
          path,
          forceNewController: true,
        );

        expect(isSuccessful, isTrue, reason: 'Parser errors: $errors');

        final TH2FileEditController controller = mpLocator.mpGeneralController
            .getTH2FileEditController(filename: path);
        final MPRasterImageInsertConfig config = MPRasterImageInsertConfig(
          parentMPID: mpParentMPIDPlaceholder,
          filename: './jpg/2025-10-07-001.jpg',
          xx: 10.0,
          yy: 20.0,
        );
        final Rect initialBoundingBox = config.getBoundingBox(controller)!;
        final Image decodedImage = await _createTestImage(
          width: 40,
          height: 20,
        );

        config.setRasterImage(decodedImage);

        final Rect refreshedBoundingBox = config.getBoundingBox(controller)!;

        expect(initialBoundingBox.width, lessThan(1.0));
        expect(initialBoundingBox.height, lessThan(1.0));
        expect(refreshedBoundingBox.width, 40.0);
        expect(refreshedBoundingBox.height, 20.0);
      },
    );

    test(
      'raster pivot defaults to image center until explicitly set',
      () async {
        final MPRasterImageInsertConfig config = MPRasterImageInsertConfig(
          parentMPID: mpParentMPIDPlaceholder,
          filename: 'images/photo.png',
          xx: 10.0,
          yy: 20.0,
        );
        final Image decodedImage = await _createTestImage(
          width: 40,
          height: 20,
        );

        config.setRasterImage(decodedImage);

        expect(config.pivotSet, isFalse);
        expect(config.localRotationCenter, const Offset(20.0, -10.0));
        expect(config.scaledRotationCenter, const Offset(20.0, -10.0));
      },
    );
  });
}

Future<Image> _createTestImage({
  required int width,
  required int height,
}) async {
  final Completer<Image> completer = Completer<Image>();
  final Uint8List pixels = Uint8List(width * height * 4);

  for (int i = 0; i < pixels.length; i += 4) {
    pixels[i] = 0xFF;
    pixels[i + 1] = 0x00;
    pixels[i + 2] = 0x00;
    pixels[i + 3] = 0xFF;
  }

  decodeImageFromPixels(
    pixels,
    width,
    height,
    PixelFormat.rgba8888,
    completer.complete,
  );

  return completer.future;
}
