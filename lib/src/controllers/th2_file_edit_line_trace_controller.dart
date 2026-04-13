// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

class TH2FileEditLineTraceController {
  final TH2FileEditController _th2FileEditController;

  static const int _strictColorDistanceThreshold = 1600;
  static const int _fallbackColorDistanceThreshold = 6400;
  static const int _maxArcSampleCount = 48;
  static const double _minTraceProgressOnCanvas = 0.75;

  final ValueNotifier<bool> isTracingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> canStartTracingNotifier = ValueNotifier<bool>(
    false,
  );
  final ValueNotifier<Offset?> debugCanvasClickPointNotifier =
      ValueNotifier<Offset?>(null);

  bool _isTraceLoopRunning = false;
  bool _shouldContinueTracing = false;

  double? _stepDistanceOnCanvas;
  _RGBColor? _targetColor;

  late final MPLocator _locator = MPLocator();
  final File _traceLogFile = File(
    '${Directory.systemTemp.path}/mapiah_line_trace_debug.log',
  );
  bool _didLogTraceFilePath = false;
  Future<void> _traceLogWriteQueue = Future<void>.value();
  final Map<ui.Image, Uint8List> _rawRgbaCacheByImage = <ui.Image, Uint8List>{};

  TH2FileEditLineTraceController(this._th2FileEditController);

  String get traceLogFilePath => _traceLogFile.path;

  void _traceDebug(String message) {
    final String line = '[${DateTime.now().toIso8601String()}] $message';
    _locator.mpLog.d(line);

    if (!_didLogTraceFilePath) {
      _didLogTraceFilePath = true;
      final String filePathLine =
          '[${DateTime.now().toIso8601String()}] [Trace] Writing trace logs to: ${_traceLogFile.path}';
      _locator.mpLog.d(filePathLine);
      _traceLogWriteQueue = _traceLogWriteQueue.then((_) async {
        await _traceLogFile.writeAsString(
          '$filePathLine\n',
          mode: FileMode.append,
        );
      });
    }

    _traceLogWriteQueue = _traceLogWriteQueue.then((_) async {
      await _traceLogFile.writeAsString('$line\n', mode: FileMode.append);
    });

    unawaited(
      _traceLogWriteQueue.catchError((Object error, StackTrace stackTrace) {
        _locator.mpLog.d('[Trace] Failed to write trace log file: $error');
      }),
    );
  }

  bool get isTracing => isTracingNotifier.value;

  double? get stepDistanceOnCanvas => _stepDistanceOnCanvas;

  bool get hasAnyImage => _th2FileEditController.th2File.getImages().isNotEmpty;

  Future<void> updateCanStartTracing() async {
    if (!hasAnyImage || !_th2FileEditController.isInAddLineState) {
      canStartTracingNotifier.value = false;

      return;
    }

    final List<Offset> lineNodes = _th2FileEditController
        .areaLineCreationController
        .getCurrentInteractiveLineNodeCanvasCoordinates();

    if (lineNodes.length < 2) {
      canStartTracingNotifier.value = false;

      return;
    }

    final _RGBColor? sampledColor = await _sampleRasterColorAtCanvas(
      lineNodes.last,
      requireVisibleImageOnly: true,
      source: 'updateCanStartTracing',
    );

    canStartTracingNotifier.value = sampledColor != null;
    _traceDebug(
      '[Trace] updateCanStartTracing result: canStart=${canStartTracingNotifier.value}',
    );
  }

  Future<void> startTracingFromCurrentLine() async {
    _traceDebug('[Trace] startTracingFromCurrentLine called');

    if (isTracingNotifier.value) {
      _traceDebug('Tracing already running');
      return;
    }

    final List<Offset> lineNodes = _th2FileEditController
        .areaLineCreationController
        .getCurrentInteractiveLineNodeCanvasCoordinates();

    if (lineNodes.length < 2) {
      _traceDebug(
        'Cannot start tracing: less than 2 line nodes, have ${lineNodes.length}',
      );
      return;
    }

    _traceDebug('Starting trace from canvas point: ${lineNodes.last}');

    final _RGBColor? sampledColor = await _sampleRasterColorAtCanvas(
      lineNodes.last,
      requireVisibleImageOnly: true,
      source: 'startTracingFromCurrentLine',
    );

    if (sampledColor == null) {
      _traceDebug(
        'Cannot start tracing: no raster color found at current point',
      );
      canStartTracingNotifier.value = false;

      return;
    }

    _traceDebug(
      'Tracing starting with target color: RGB(${sampledColor.r}, ${sampledColor.g}, ${sampledColor.b})',
    );

    final double fixedStepDistance = max(
      1.0,
      (lineNodes.last - lineNodes[lineNodes.length - 2]).distance,
    );

    _traceDebug('Step distance: $fixedStepDistance');

    _stepDistanceOnCanvas = fixedStepDistance;
    _targetColor = sampledColor;
    _shouldContinueTracing = true;
    isTracingNotifier.value = true;

    if (_isTraceLoopRunning) {
      return;
    }

    _isTraceLoopRunning = true;
    _traceDebug('[Trace] entering _runTraceLoop');

    try {
      await _runTraceLoop();
    } finally {
      _traceDebug('[Trace] leaving _runTraceLoop');
      _isTraceLoopRunning = false;
      _shouldContinueTracing = false;
      isTracingNotifier.value = false;
      await updateCanStartTracing();
    }
  }

  Future<void> toggleTracing() async {
    _traceDebug(
      '[Trace] toggleTracing called: isTracing=${isTracingNotifier.value}, canStart=${canStartTracingNotifier.value}',
    );

    if (isTracingNotifier.value) {
      stopTracing();

      return;
    }

    await startTracingFromCurrentLine();
  }

  void stopTracing() {
    _shouldContinueTracing = false;
    isTracingNotifier.value = false;
  }

  void reset() {
    stopTracing();
    _targetColor = null;
    _stepDistanceOnCanvas = null;
    canStartTracingNotifier.value = false;
    _rawRgbaCacheByImage.clear();
  }

  Future<void> _runTraceLoop() async {
    _traceDebug(
      '[Trace] _runTraceLoop start: shouldContinue=$_shouldContinueTracing, inAddLine=${_th2FileEditController.isInAddLineState}',
    );

    while (_shouldContinueTracing && _th2FileEditController.isInAddLineState) {
      final bool stepSucceeded = await _traceSingleStep();

      if (!stepSucceeded) {
        stopTracing();

        return;
      }

      // Yield to the event loop so UI events (including Stop) are processed.
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }

    _traceDebug(
      '[Trace] _runTraceLoop end: shouldContinue=$_shouldContinueTracing, inAddLine=${_th2FileEditController.isInAddLineState}',
    );
  }

  Future<bool> _traceSingleStep() async {
    final _TraceContext? context = _createTraceContext();

    if (context == null) {
      _traceDebug('Trace step failed: no trace context available');
      return false;
    }

    final List<double> localStepAttempts = <double>[
      context.stepDistance,
      context.stepDistance / 2.0,
      context.stepDistance * 2.0,
    ];

    for (final double localStepDistance in localStepAttempts) {
      if (localStepDistance < 1.0) {
        continue;
      }

      _traceDebug('Trace attempting step distance: $localStepDistance');

      final Offset? tracedPoint = await _findNextPoint(
        context: context,
        localStepDistance: localStepDistance,
      );

      if (tracedPoint == null) {
        _traceDebug(
          'Trace step distance $localStepDistance: no matching points found',
        );
        continue;
      }

      _traceDebug(
        'Trace step distance $localStepDistance: found point at $tracedPoint',
      );

      final double tracedDistanceFromCurrent =
          (tracedPoint - context.currentPoint).distance;

      if (tracedDistanceFromCurrent < _minTraceProgressOnCanvas) {
        _traceDebug(
          'Trace step distance $localStepDistance: ignoring no-progress point (distance=$tracedDistanceFromCurrent)',
        );
        continue;
      }

      final bool shouldAutoClose =
          (tracedPoint - context.startPoint).distance <= context.stepDistance;

      if (shouldAutoClose) {
        _traceDebug('Trace: auto-closing loop');
        _appendCanvasNode(context.startPoint);
        stopTracing();

        return true;
      }

      _appendCanvasNode(tracedPoint);
      _scrollCanvasToFollow(tracedPoint);

      return true;
    }

    _traceDebug('Trace step failed: no matching points in any step attempt');
    return false;
  }

  _TraceContext? _createTraceContext() {
    final _RGBColor? targetColor = _targetColor;
    final double? stepDistance = _stepDistanceOnCanvas;

    if ((targetColor == null) || (stepDistance == null)) {
      return null;
    }

    final List<Offset> lineNodes = _th2FileEditController
        .areaLineCreationController
        .getCurrentInteractiveLineNodeCanvasCoordinates();

    if (lineNodes.length < 2) {
      return null;
    }

    final Offset startPoint = lineNodes.first;
    final Offset previousPoint = lineNodes[lineNodes.length - 2];
    final Offset currentPoint = lineNodes.last;
    final Offset direction = currentPoint - previousPoint;

    if (direction.distance <= 0.000001) {
      return null;
    }

    final Offset unitDirection = direction / direction.distance;

    return _TraceContext(
      currentPoint: currentPoint,
      startPoint: startPoint,
      stepDistance: stepDistance,
      targetColor: targetColor,
      unitDirection: unitDirection,
    );
  }

  Future<Offset?> _findNextPoint({
    required _TraceContext context,
    required double localStepDistance,
  }) async {
    final Offset arcCenter =
        context.currentPoint + (context.unitDirection * localStepDistance);
    final int sampleCount = min(
      _maxArcSampleCount,
      max(24, (localStepDistance * 12.0).round()),
    );
    final List<Offset> matchingArcPoints = <Offset>[];
    final List<List<Offset>> matchingArcs = <List<Offset>>[];
    Offset? bestCandidate;
    int bestCandidateDistance = 2147483647;

    _traceDebug(
      '    Arc search: center=$arcCenter, radius=$localStepDistance, samples=$sampleCount',
    );
    _traceDebug(
      '    Target color tolerance threshold: sqrt($_strictColorDistanceThreshold) strict, sqrt($_fallbackColorDistanceThreshold) fallback (squared RGB distance)',
    );

    for (int i = 0; i < sampleCount; i++) {
      if (!_shouldContinueTracing) {
        _traceDebug('    Arc search aborted: tracing stop requested');

        return null;
      }

      final double angle = (2.0 * pi * i) / sampleCount;
      final Offset radial = Offset(cos(angle), sin(angle));
      final Offset candidate = arcCenter + (radial * localStepDistance);
      final double aheadDot =
          ((candidate - context.currentPoint).dx * context.unitDirection.dx) +
          ((candidate - context.currentPoint).dy * context.unitDirection.dy);

      if (aheadDot < 0) {
        if (matchingArcPoints.isNotEmpty) {
          matchingArcs.add(List<Offset>.from(matchingArcPoints));
          matchingArcPoints.clear();
        }

        continue;
      }

      final _RGBColor? candidateColor = await _sampleRasterColorAtCanvas(
        candidate,
        requireVisibleImageOnly: true,
        source: 'findNextPoint',
      );

      if (candidateColor != null) {
        final int distance = _squaredRGBDistance(
          candidateColor,
          context.targetColor,
        );
        if (distance < bestCandidateDistance) {
          bestCandidateDistance = distance;
          bestCandidate = candidate;
        }

        final bool matches = distance <= _strictColorDistanceThreshold;
        _traceDebug(
          '      Sample $i: RGB(${candidateColor.r}, ${candidateColor.g}, ${candidateColor.b}), distance=$distance, matches=$matches',
        );

        if (matches) {
          matchingArcPoints.add(candidate);
        } else if (matchingArcPoints.isNotEmpty) {
          matchingArcs.add(List<Offset>.from(matchingArcPoints));
          matchingArcPoints.clear();
        }
      } else if (matchingArcPoints.isNotEmpty) {
        _traceDebug('      Sample $i: no raster color');
        matchingArcs.add(List<Offset>.from(matchingArcPoints));
        matchingArcPoints.clear();
      }
    }

    _traceDebug('    Found ${matchingArcs.length} color-matching arc segments');

    if (matchingArcPoints.isNotEmpty) {
      matchingArcs.add(List<Offset>.from(matchingArcPoints));
    }

    if (matchingArcs.isEmpty) {
      if (bestCandidate != null &&
          bestCandidateDistance <= _fallbackColorDistanceThreshold) {
        _traceDebug(
          '    No strict arc found; using best fallback candidate with distance=$bestCandidateDistance at $bestCandidate',
        );

        return bestCandidate;
      }

      return null;
    }

    List<Offset> longestArc = matchingArcs.first;

    for (final List<Offset> arc in matchingArcs.skip(1)) {
      if (arc.length > longestArc.length) {
        longestArc = arc;
      }
    }

    Offset centroid = Offset.zero;

    for (final Offset point in longestArc) {
      centroid += point;
    }

    return centroid / longestArc.length.toDouble();
  }

  Future<_RGBColor?> _sampleRasterColorAtCanvas(
    Offset canvasPoint, {
    required bool requireVisibleImageOnly,
    required String source,
  }) async {
    debugCanvasClickPointNotifier.value = canvasPoint;

    final List<MPRuntimeImageInsertConfigMixin> images = _th2FileEditController
        .th2File
        .getImages()
        .toList();

    _traceDebug(
      '[$source] Sampling raster color at canvas point $canvasPoint (${images.length} total images)',
    );

    for (final MPRuntimeImageInsertConfigMixin image in images.reversed) {
      if (requireVisibleImageOnly && !image.isVisible) {
        _traceDebug('  Skipping hidden image');
        continue;
      }

      final MPRuntimeRasterImageInsertConfigMixin? rasterImage =
          image.asRasterImage;

      if (rasterImage == null) {
        _traceDebug('  Skipping vector/XVI image');
        continue;
      }

      _traceDebug('  Checking raster image (${rasterImage.filename})');

      final ui.Image? decodedImage = await _ensureDecodedRasterImageLoaded(
        rasterImage,
      );

      if (decodedImage == null) {
        _traceDebug('    Image not loaded');
        continue;
      }

      _traceDebug(
        '    Image decoded (${decodedImage.width}x${decodedImage.height})',
      );

      final ({int x, int y})? pixelPosition = _canvasToRasterPixel(
        rasterImage: rasterImage,
        decodedImage: decodedImage,
        canvasPoint: canvasPoint,
      );

      if (pixelPosition == null) {
        _traceDebug('    Point outside image bounds');
        continue;
      }

      _traceDebug(
        '    Pixel position: (${pixelPosition.x}, ${pixelPosition.y})',
      );

      Uint8List? rgba = _rawRgbaCacheByImage[decodedImage];

      if (rgba == null) {
        final ByteData? byteData = await decodedImage.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );

        if (byteData == null) {
          _traceDebug('    Could not get byte data');
          continue;
        }

        rgba = byteData.buffer.asUint8List();
        _rawRgbaCacheByImage[decodedImage] = rgba;
      }

      final int index =
          ((pixelPosition.y * decodedImage.width) + pixelPosition.x) * 4;

      if (index < 0 || (index + 2) >= rgba.length) {
        _traceDebug('    Pixel index out of bounds: $index');
        continue;
      }

      final _RGBColor color = _RGBColor(
        r: rgba[index],
        g: rgba[index + 1],
        b: rgba[index + 2],
      );
      _traceDebug(
        '[$source] Sampled pixel: image=${rasterImage.filename}, xy=(${pixelPosition.x}, ${pixelPosition.y}), rgba=(${rgba[index]}, ${rgba[index + 1]}, ${rgba[index + 2]}, ${rgba[index + 3]})',
      );
      return color;
    }

    _traceDebug('  No raster color found at this point');
    return null;
  }

  Future<ui.Image?> _ensureDecodedRasterImageLoaded(
    MPRuntimeRasterImageInsertConfigMixin rasterImage,
  ) async {
    final ui.Image? cachedImage = rasterImage.decodedRasterImage;

    if (cachedImage != null) {
      return cachedImage;
    }

    final Future<ui.Image>? loading = rasterImage.getRasterImageFrameInfo(
      _th2FileEditController,
    );

    if (loading == null) {
      return null;
    }

    return loading;
  }

  ({int x, int y})? _canvasToRasterPixel({
    required MPRuntimeRasterImageInsertConfigMixin rasterImage,
    required ui.Image decodedImage,
    required Offset canvasPoint,
  }) {
    final double imageWidth = decodedImage.width.toDouble();
    final double imageHeight = decodedImage.height.toDouble();

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

    final Offset relativePoint = canvasPoint - topLeft;
    final double imageX =
        ((relativePoint.dx * xAxis.dx) + (relativePoint.dy * xAxis.dy)) /
        xAxisLengthSquared *
        imageWidth;
    final double imageY =
        ((relativePoint.dx * yAxis.dx) + (relativePoint.dy * yAxis.dy)) /
        yAxisLengthSquared *
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

  int _squaredRGBDistance(_RGBColor a, _RGBColor b) {
    final int dr = a.r - b.r;
    final int dg = a.g - b.g;
    final int db = a.b - b.b;

    return (dr * dr) + (dg * dg) + (db * db);
  }

  void _appendCanvasNode(Offset canvasPoint) {
    final Offset screenPoint = _th2FileEditController.offsetCanvasToScreen(
      canvasPoint,
    );

    _traceDebug(
      'Trace append segment at canvas=$canvasPoint screen=$screenPoint',
    );

    _th2FileEditController.areaLineCreationController.addNewLineLineSegment(
      screenPoint,
    );
  }

  void _scrollCanvasToFollow(Offset canvasPoint) {
    _th2FileEditController.centerCanvasOn(canvasPoint);
  }
}

class _TraceContext {
  final Offset currentPoint;
  final Offset startPoint;
  final double stepDistance;
  final _RGBColor targetColor;
  final Offset unitDirection;

  _TraceContext({
    required this.currentPoint,
    required this.startPoint,
    required this.stepDistance,
    required this.targetColor,
    required this.unitDirection,
  });
}

class _RGBColor {
  final int r;
  final int g;
  final int b;

  _RGBColor({required this.r, required this.g, required this.b});
}
