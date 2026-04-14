// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

/// Represents a sampled RGB color from a raster image.
class TH2FileEditLineTraceColor {
  final int red;

  final int green;

  final int blue;

  const TH2FileEditLineTraceColor({
    required this.red,
    required this.green,
    required this.blue,
  });
}

/// Pre-computed transform and cached RGBA bytes for a single raster image.
///
/// All async work (image decoding and RGBA extraction) is done once in [load].
/// After that, [sampleAtCanvas] is fully synchronous.
class TH2FileEditTraceImagePreprocessor {
  final int _imageWidth;

  final int _imageHeight;

  final Uint8List _rgba;

  /// Canvas-space position of the image's top-left corner.
  final Offset _topLeft;

  /// Canvas-space vector from top-left to top-right (one pixel-column wide).
  final Offset _xAxis;

  /// Canvas-space vector from top-left to bottom-left (one pixel-row tall).
  final Offset _yAxis;

  final double _xAxisLengthSquared;

  final double _yAxisLengthSquared;

  TH2FileEditTraceImagePreprocessor._({
    required int imageWidth,
    required int imageHeight,
    required Uint8List rgba,
    required Offset topLeft,
    required Offset xAxis,
    required Offset yAxis,
    required double xAxisLengthSquared,
    required double yAxisLengthSquared,
  }) : _imageWidth = imageWidth,
       _imageHeight = imageHeight,
       _rgba = rgba,
       _topLeft = topLeft,
       _xAxis = xAxis,
       _yAxis = yAxis,
       _xAxisLengthSquared = xAxisLengthSquared,
       _yAxisLengthSquared = yAxisLengthSquared;

  /// Loads a preprocessor for [rasterImage].
  ///
  /// Returns null if the image cannot be decoded or if its geometry is
  /// degenerate (zero width or height in canvas space).
  static Future<TH2FileEditTraceImagePreprocessor?> load({
    required MPRuntimeRasterImageInsertConfigMixin rasterImage,
    required TH2FileEditController th2FileEditController,
  }) async {
    ui.Image? decodedImage = rasterImage.decodedRasterImage;

    if (decodedImage == null) {
      final Future<ui.Image>? loading = rasterImage.getRasterImageFrameInfo(
        th2FileEditController,
      );

      if (loading == null) {
        return null;
      }

      decodedImage = await loading;
    }

    final ByteData? byteData = await decodedImage.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );

    if (byteData == null) {
      return null;
    }

    final Uint8List rgba = byteData.buffer.asUint8List();
    final double imageWidth = decodedImage.width.toDouble();
    final double imageHeight = decodedImage.height.toDouble();

    // Pre-compute the canvas-space affine basis for this image.
    final Offset topLeft = rasterImage.transformWorldPointFromBaseWorldPoint(
      Offset(rasterImage.xx.value, rasterImage.yy.value - imageHeight),
    );
    final Offset topRight = rasterImage.transformWorldPointFromBaseWorldPoint(
      Offset(
        rasterImage.xx.value + imageWidth,
        rasterImage.yy.value - imageHeight,
      ),
    );
    final Offset bottomLeft = rasterImage.transformWorldPointFromBaseWorldPoint(
      Offset(rasterImage.xx.value, rasterImage.yy.value),
    );

    final Offset xAxis = topRight - topLeft;
    final Offset yAxis = bottomLeft - topLeft;
    final double xAxisLengthSquared =
        (xAxis.dx * xAxis.dx) + (xAxis.dy * xAxis.dy);
    final double yAxisLengthSquared =
        (yAxis.dx * yAxis.dx) + (yAxis.dy * yAxis.dy);

    if (xAxisLengthSquared <= 0.000001 || yAxisLengthSquared <= 0.000001) {
      return null;
    }

    return TH2FileEditTraceImagePreprocessor._(
      imageWidth: decodedImage.width,
      imageHeight: decodedImage.height,
      rgba: rgba,
      topLeft: topLeft,
      xAxis: xAxis,
      yAxis: yAxis,
      xAxisLengthSquared: xAxisLengthSquared,
      yAxisLengthSquared: yAxisLengthSquared,
    );
  }

  /// Returns the RGB color at [canvasPoint], or null if the point falls
  /// outside this image.
  TH2FileEditLineTraceColor? sampleAtCanvas(Offset canvasPoint) {
    final ({int x, int y})? pixel = _canvasToRasterPixel(canvasPoint);

    if (pixel == null) {
      return null;
    }

    final int index = ((pixel.y * _imageWidth) + pixel.x) * 4;

    if (index < 0 || (index + 2) >= _rgba.length) {
      return null;
    }

    return TH2FileEditLineTraceColor(
      red: _rgba[index],
      green: _rgba[index + 1],
      blue: _rgba[index + 2],
    );
  }

  ({int x, int y})? _canvasToRasterPixel(Offset canvasPoint) {
    final double imageWidth = _imageWidth.toDouble();
    final double imageHeight = _imageHeight.toDouble();
    final Offset relativePoint = canvasPoint - _topLeft;
    final double imageX =
        ((relativePoint.dx * _xAxis.dx) + (relativePoint.dy * _xAxis.dy)) /
        _xAxisLengthSquared *
        imageWidth;
    final double imageY =
        ((relativePoint.dx * _yAxis.dx) + (relativePoint.dy * _yAxis.dy)) /
        _yAxisLengthSquared *
        imageHeight;

    if (imageX < 0 ||
        imageY < 0 ||
        imageX >= imageWidth ||
        imageY >= imageHeight) {
      return null;
    }

    final int pixelX = imageX.floor();
    final int pixelY = (imageHeight - 1.0 - imageY).floor();

    return (x: pixelX, y: pixelY);
  }
}

/// Manages a per-session cache of [TH2FileEditTraceImagePreprocessor] instances.
///
/// Call [warmUp] once before the trace loop to load all currently visible
/// raster images. After that, [orderedPreprocessors] provides synchronous
/// pixel sampling with no further async work in the hot path.
class TH2FileEditTracePreprocessorCache {
  final Map<
    MPRuntimeRasterImageInsertConfigMixin,
    TH2FileEditTraceImagePreprocessor
  >
  _cache = {};

  List<TH2FileEditTraceImagePreprocessor> _orderedPreprocessors = const [];

  /// Returns preprocessors in top-to-bottom z-order (same order that
  /// [_sampleRasterColorAtCanvas] should search to match the highest-layer
  /// image first).
  List<TH2FileEditTraceImagePreprocessor> get orderedPreprocessors =>
      _orderedPreprocessors;

  /// Loads all currently visible raster images and caches their preprocessors.
  ///
  /// Images already in the cache are not reloaded. The ordered list is rebuilt
  /// on every call to reflect the current set of visible images.
  Future<void> warmUp({
    required TH2FileEditController th2FileEditController,
  }) async {
    final List<MPRuntimeImageInsertConfigMixin> images = th2FileEditController
        .th2File
        .getImages()
        .toList();
    final List<TH2FileEditTraceImagePreprocessor> ordered = [];

    for (final MPRuntimeImageInsertConfigMixin image in images.reversed) {
      if (!image.isVisible) {
        continue;
      }

      final MPRuntimeRasterImageInsertConfigMixin? rasterImage =
          image.asRasterImage;

      if (rasterImage == null) {
        continue;
      }

      TH2FileEditTraceImagePreprocessor? preprocessor = _cache[rasterImage];

      if (preprocessor == null) {
        preprocessor = await TH2FileEditTraceImagePreprocessor.load(
          rasterImage: rasterImage,
          th2FileEditController: th2FileEditController,
        );

        if (preprocessor == null) {
          continue;
        }

        _cache[rasterImage] = preprocessor;
      }

      ordered.add(preprocessor);
    }

    _orderedPreprocessors = ordered;
  }

  /// Clears all cached preprocessors and the ordered list.
  void clear() {
    _cache.clear();
    _orderedPreprocessors = const [];
  }
}
