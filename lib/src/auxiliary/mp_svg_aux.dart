// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:xml/xml.dart';

class MPSVGIntrinsicSizeInfo {
  final double width;
  final double height;
  final Rect sourceViewBox;

  const MPSVGIntrinsicSizeInfo({
    required this.width,
    required this.height,
    required this.sourceViewBox,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'width': width,
      'height': height,
      'sourceViewBox': <String, dynamic>{
        'left': sourceViewBox.left,
        'top': sourceViewBox.top,
        'width': sourceViewBox.width,
        'height': sourceViewBox.height,
      },
    };
  }

  static MPSVGIntrinsicSizeInfo fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic> sourceViewBoxMap =
        map['sourceViewBox'] as Map<String, dynamic>;

    return MPSVGIntrinsicSizeInfo(
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      sourceViewBox: Rect.fromLTWH(
        (sourceViewBoxMap['left'] as num).toDouble(),
        (sourceViewBoxMap['top'] as num).toDouble(),
        (sourceViewBoxMap['width'] as num).toDouble(),
        (sourceViewBoxMap['height'] as num).toDouble(),
      ),
    );
  }
}

class MPSVGMetadataInfo {
  final double? width;
  final double? height;
  final Rect? sourceViewBox;

  const MPSVGMetadataInfo({
    required this.width,
    required this.height,
    required this.sourceViewBox,
  });

  bool get hasWidthAndHeight => (width != null) && (height != null);

  bool get hasViewBox => sourceViewBox != null;

  MPSVGIntrinsicSizeInfo? resolveIntrinsicSizeInfo({
    double? fallbackWidth,
    double? fallbackHeight,
  }) {
    final double? resolvedWidth =
        width ?? fallbackWidth ?? sourceViewBox?.width;
    final double? resolvedHeight =
        height ?? fallbackHeight ?? sourceViewBox?.height;

    if ((resolvedWidth == null) ||
        (resolvedHeight == null) ||
        (resolvedWidth <= 0.0) ||
        (resolvedHeight <= 0.0)) {
      return null;
    }

    final Rect resolvedViewBox =
        sourceViewBox ?? Rect.fromLTWH(0.0, 0.0, resolvedWidth, resolvedHeight);

    return MPSVGIntrinsicSizeInfo(
      width: resolvedWidth,
      height: resolvedHeight,
      sourceViewBox: resolvedViewBox,
    );
  }
}

class MPSVGAux {
  static MPSVGMetadataInfo parseMetadataInfo(String svgText) {
    final XmlDocument document = XmlDocument.parse(svgText);
    final Iterable<XmlElement> svgElements = document.findAllElements('svg');

    if (svgElements.isEmpty) {
      return const MPSVGMetadataInfo(
        width: null,
        height: null,
        sourceViewBox: null,
      );
    }

    final XmlElement svgElement = svgElements.first;
    final String? widthText = svgElement.getAttribute('width');
    final String? heightText = svgElement.getAttribute('height');
    final String? viewBoxText = svgElement.getAttribute('viewBox');
    final double? parsedWidth = _parseLength(widthText);
    final double? parsedHeight = _parseLength(heightText);
    final Rect? parsedViewBox = _parseViewBox(viewBoxText);

    return MPSVGMetadataInfo(
      width: parsedWidth,
      height: parsedHeight,
      sourceViewBox: parsedViewBox,
    );
  }

  static Future<svg.PictureInfo> loadPictureInfo({
    required TH2FileEditController th2FileEditController,
    required String imageFilename,
    required MPSVGIntrinsicSizeInfo intrinsicSizeInfo,
  }) async {
    final String resolvedPath = MPDirectoryAux.getResolvedPath(
      th2FileEditController.th2File.filename,
      imageFilename,
    );
    final String svgText = await File(resolvedPath).readAsString();
    final String normalizedSVGText = ensureRenderableSVGRootMetadata(
      svgText: svgText,
      intrinsicSizeInfo: intrinsicSizeInfo,
    );

    return svg.vg.loadPicture(svg.SvgStringLoader(normalizedSVGText), null);
  }

  static String ensureRenderableSVGRootMetadata({
    required String svgText,
    required MPSVGIntrinsicSizeInfo intrinsicSizeInfo,
  }) {
    final XmlDocument document = XmlDocument.parse(svgText);
    final Iterable<XmlElement> svgElements = document.findAllElements('svg');

    if (svgElements.isEmpty) {
      return svgText;
    }

    final XmlElement svgElement = svgElements.first;

    if (svgElement.getAttribute('width') == null) {
      svgElement.setAttribute('width', intrinsicSizeInfo.width.toString());
    }

    if (svgElement.getAttribute('height') == null) {
      svgElement.setAttribute('height', intrinsicSizeInfo.height.toString());
    }

    if (svgElement.getAttribute('viewBox') == null) {
      final Rect viewBox = intrinsicSizeInfo.sourceViewBox;

      svgElement.setAttribute(
        'viewBox',
        '${viewBox.left} ${viewBox.top} ${viewBox.width} ${viewBox.height}',
      );
    }

    return document.toXmlString();
  }

  static double? _parseLength(String? text) {
    if ((text == null) || text.trim().isEmpty) {
      return null;
    }

    final RegExpMatch? match = RegExp(
      r'^([+-]?(?:\d+\.?\d*|\.\d+))',
    ).firstMatch(text.trim());

    if (match == null) {
      return null;
    }

    return double.tryParse(match.group(1)!);
  }

  static Rect? _parseViewBox(String? text) {
    if ((text == null) || text.trim().isEmpty) {
      return null;
    }

    final List<String> parts = text
        .trim()
        .split(RegExp(r'[\s,]+'))
        .where((String value) => value.isNotEmpty)
        .toList();

    if (parts.length != 4) {
      return null;
    }

    final double? minX = double.tryParse(parts[0]);
    final double? minY = double.tryParse(parts[1]);
    final double? width = double.tryParse(parts[2]);
    final double? height = double.tryParse(parts[3]);

    if ((minX == null) ||
        (minY == null) ||
        (width == null) ||
        (height == null) ||
        (width <= 0.0) ||
        (height <= 0.0)) {
      return null;
    }

    return Rect.fromLTWH(minX, minY, width, height);
  }
}
