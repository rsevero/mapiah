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

class MPSVGAux {
  static const String noIntrinsicSizeMessage =
      'SVG file has no intrinsic size. Add a viewBox or width/height, or choose import dimensions in Mapiah.';

  static MPSVGIntrinsicSizeInfo? parseIntrinsicSizeInfo(String svgText) {
    final XmlDocument document = XmlDocument.parse(svgText);
    final Iterable<XmlElement> svgElements = document.findAllElements('svg');

    if (svgElements.isEmpty) {
      return null;
    }

    final XmlElement svgElement = svgElements.first;
    final String? widthText = svgElement.getAttribute('width');
    final String? heightText = svgElement.getAttribute('height');
    final String? viewBoxText = svgElement.getAttribute('viewBox');
    final double? parsedWidth = _parseLength(widthText);
    final double? parsedHeight = _parseLength(heightText);
    final Rect? parsedViewBox = _parseViewBox(viewBoxText);

    if (parsedViewBox == null &&
        ((parsedWidth == null) || (parsedHeight == null))) {
      return null;
    }

    final double resolvedWidth = parsedWidth ?? parsedViewBox!.width;
    final double resolvedHeight = parsedHeight ?? parsedViewBox!.height;
    final Rect sourceViewBox =
        parsedViewBox ?? Rect.fromLTWH(0.0, 0.0, resolvedWidth, resolvedHeight);

    return MPSVGIntrinsicSizeInfo(
      width: resolvedWidth,
      height: resolvedHeight,
      sourceViewBox: sourceViewBox,
    );
  }

  static Future<svg.PictureInfo> loadPictureInfo({
    required TH2FileEditController th2FileEditController,
    required String imageFilename,
  }) async {
    final String resolvedPath = MPDirectoryAux.getResolvedPath(
      th2FileEditController.th2File.filename,
      imageFilename,
    );
    final String svgText = await File(resolvedPath).readAsString();

    return svg.vg.loadPicture(svg.SvgStringLoader(svgText), null);
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
