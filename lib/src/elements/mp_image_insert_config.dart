// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'th_element.dart';

abstract class MPImageInsertConfig extends THElement
    with MPBoundingBoxMixin, MPRuntimeImageInsertConfigMixin {
  @override
  final String filename;
  @override
  THDoublePart xx;
  @override
  THDoublePart yy;
  THDoublePart xScale;
  THDoublePart yScale;
  THDoublePart rotationCenterDx;
  THDoublePart rotationCenterDy;
  THDoublePart rotationDeg;

  bool _isVisible;

  MPImageInsertConfig.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required this.filename,
    required this.xx,
    required this.yy,
    required this.xScale,
    required this.yScale,
    required this.rotationCenterDx,
    required this.rotationCenterDy,
    required this.rotationDeg,
    required bool isVisible,
    required super.originalLineInTH2File,
  }) : _isVisible = isVisible,
       super.forCWJM();

  MPImageInsertConfig.getMPID({
    required super.parentMPID,
    super.sameLineComment,
    required this.filename,
    required double xx,
    required double yy,
    double xScale = 1.0,
    double yScale = 1.0,
    double rotationCenterDx = 0.0,
    double rotationCenterDy = 0.0,
    double rotationDeg = 0.0,
    bool isVisible = true,
    super.originalLineInTH2File = '',
  }) : xx = THDoublePart(value: xx),
       yy = THDoublePart(value: yy),
       xScale = THDoublePart(value: xScale),
       yScale = THDoublePart(value: yScale),
       rotationCenterDx = THDoublePart(value: rotationCenterDx),
       rotationCenterDy = THDoublePart(value: rotationCenterDy),
       rotationDeg = THDoublePart(value: rotationDeg),
       _isVisible = isVisible,
       super.getMPID();

  MPImageInsertConfig.fromString({
    required super.parentMPID,
    super.sameLineComment,
    required this.filename,
    required String xx,
    required String yy,
    String xScale = '1.0',
    String yScale = '1.0',
    String rotationCenterDx = '0.0',
    String rotationCenterDy = '0.0',
    String rotationDeg = '0.0',
    bool isVisible = true,
    super.originalLineInTH2File = '',
  }) : xx = THDoublePart.fromString(valueString: xx),
       yy = THDoublePart.fromString(valueString: yy),
       xScale = THDoublePart.fromString(valueString: xScale),
       yScale = THDoublePart.fromString(valueString: yScale),
       rotationCenterDx = THDoublePart.fromString(
         valueString: rotationCenterDx,
       ),
       rotationCenterDy = THDoublePart.fromString(
         valueString: rotationCenterDy,
       ),
       rotationDeg = THDoublePart.fromString(valueString: rotationDeg),
       _isVisible = isVisible,
       super.getMPID();

  @override
  THElementType get elementType => THElementType.mapiahImageInsertConfig;

  @override
  String get format;

  @override
  bool get isXVI;

  @override
  MPImageInsertConfig copyWithImageInsertConfigBase({
    String? filename,
    THDoublePart? xx,
    THDoublePart? yy,
    bool? isVisible,
    String? originalLineInTH2File,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'format': format,
      'filename': filename,
      'xx': xx.toMap(),
      'yy': yy.toMap(),
      'xScale': xScale.toMap(),
      'yScale': yScale.toMap(),
      'rotationCenterDx': rotationCenterDx.toMap(),
      'rotationCenterDy': rotationCenterDy.toMap(),
      'rotationDeg': rotationDeg.toMap(),
      'isVisible': _isVisible,
    };
  }

  static MPImageInsertConfig fromMap(Map<String, dynamic> map) {
    final String format = map['format'];

    switch (format) {
      case mpImageInsertFormatXVI:
        return MPXVIImageInsertConfig.forCWJM(
          mpID: map['mpID'],
          parentMPID: map['parentMPID'],
          sameLineComment: map['sameLineComment'],
          filename: map['filename'],
          xx: THDoublePart.fromMap(map['xx']),
          yy: THDoublePart.fromMap(map['yy']),
          xScale: THDoublePart.fromMap(map['xScale']),
          yScale: THDoublePart.fromMap(map['yScale']),
          rotationCenterDx: THDoublePart.fromMap(map['rotationCenterDx']),
          rotationCenterDy: THDoublePart.fromMap(map['rotationCenterDy']),
          rotationDeg: THDoublePart.fromMap(map['rotationDeg']),
          isVisible: map['isVisible'] ?? true,
          isGridVisible: map['isGridVisible'] ?? true,
          xviRoot: map['xviRoot'] ?? '',
          originalLineInTH2File: map['originalLineInTH2File'],
        );
      case mpImageInsertFormatRaster:
        return MPRasterImageInsertConfig.forCWJM(
          mpID: map['mpID'],
          parentMPID: map['parentMPID'],
          sameLineComment: map['sameLineComment'],
          filename: map['filename'],
          xx: THDoublePart.fromMap(map['xx']),
          yy: THDoublePart.fromMap(map['yy']),
          xScale: THDoublePart.fromMap(map['xScale']),
          yScale: THDoublePart.fromMap(map['yScale']),
          rotationCenterDx: THDoublePart.fromMap(map['rotationCenterDx']),
          rotationCenterDy: THDoublePart.fromMap(map['rotationCenterDy']),
          rotationDeg: THDoublePart.fromMap(map['rotationDeg']),
          isVisible: map['isVisible'] ?? true,
          originalLineInTH2File: map['originalLineInTH2File'],
        );
      default:
        throw THCustomException(
          "Unsupported MPImageInsertConfig format '$format' in MPImageInsertConfig.fromMap.",
        );
    }
  }

  static MPImageInsertConfig fromJson(String source) =>
      fromMap(jsonDecode(source));

  static MPImageInsertConfig fromXTherionImageInsertConfig({
    required THXTherionImageInsertConfig xtherionImageInsertConfig,
    TH2FileEditController? th2FileEditController,
  }) {
    switch (xtherionImageInsertConfig) {
      case THXVIXTherionImageInsertConfig xviImage:
        final MPXVIImageInsertConfig convertedImage =
            MPXVIImageInsertConfig.forCWJM(
              mpID: xviImage.mpID,
              parentMPID: xviImage.parentMPID,
              sameLineComment: xviImage.sameLineComment,
              filename: xviImage.filename,
              xx: xviImage.xx,
              yy: xviImage.yy,
              xScale: THDoublePart(value: 1.0),
              yScale: THDoublePart(value: 1.0),
              rotationCenterDx: THDoublePart(value: 0.0),
              rotationCenterDy: THDoublePart(value: 0.0),
              rotationDeg: THDoublePart(value: 0.0),
              isVisible: xviImage.isVisible,
              isGridVisible: xviImage.isGridVisible,
              xviRoot: xviImage.xviRoot,
              originalLineInTH2File: '',
            );

        if (th2FileEditController != null) {
          final XVIFile? xviFile = xviImage.getXVIFile(th2FileEditController);

          convertedImage.setXVIFile(xviFile);
        }

        return convertedImage;
      case THRasterXTherionImageInsertConfig rasterImage:
        return MPRasterImageInsertConfig.forCWJM(
          mpID: rasterImage.mpID,
          parentMPID: rasterImage.parentMPID,
          sameLineComment: rasterImage.sameLineComment,
          filename: rasterImage.filename,
          xx: rasterImage.xx,
          yy: rasterImage.yy,
          xScale: THDoublePart(value: 1.0),
          yScale: THDoublePart(value: 1.0),
          rotationCenterDx: THDoublePart(value: 0.0),
          rotationCenterDy: THDoublePart(value: 0.0),
          rotationDeg: THDoublePart(value: 0.0),
          isVisible: rasterImage.isVisible,
          originalLineInTH2File: '',
        );
    }

    throw ArgumentError(
      'Unsupported XTherion image insert config type: ${xtherionImageInsertConfig.runtimeType}',
    );
  }

  static MPImageInsertConfig fromMetadataString({
    required int parentMPID,
    required String metadata,
    String originalLineInTH2File = '',
  }) {
    final Map<String, String> payload = _decodeMetadataPayload(metadata);
    final String? format = payload['format'];

    if (format == null) {
      throw THCustomException(
        'Missing format in MPImageInsertConfig.fromMetadataString.',
      );
    }

    switch (format) {
      case mpImageInsertFormatXVI:
        return MPXVIImageInsertConfig.fromString(
          parentMPID: parentMPID,
          filename: _requiredPayloadValue(payload, 'filename'),
          xx: _requiredPayloadValue(payload, 'xx'),
          yy: _requiredPayloadValue(payload, 'yy'),
          xScale: _requiredPayloadValue(payload, 'xScale'),
          yScale: _requiredPayloadValue(payload, 'yScale'),
          rotationCenterDx: _requiredPayloadValue(payload, 'rotationCenterDx'),
          rotationCenterDy: _requiredPayloadValue(payload, 'rotationCenterDy'),
          rotationDeg: _requiredPayloadValue(payload, 'rotationDeg'),
          xviRoot: payload['xviRoot'] ?? '',
          originalLineInTH2File: originalLineInTH2File,
        );
      case mpImageInsertFormatRaster:
        return MPRasterImageInsertConfig.fromString(
          parentMPID: parentMPID,
          filename: _requiredPayloadValue(payload, 'filename'),
          xx: _requiredPayloadValue(payload, 'xx'),
          yy: _requiredPayloadValue(payload, 'yy'),
          xScale: _requiredPayloadValue(payload, 'xScale'),
          yScale: _requiredPayloadValue(payload, 'yScale'),
          rotationCenterDx: _requiredPayloadValue(payload, 'rotationCenterDx'),
          rotationCenterDy: _requiredPayloadValue(payload, 'rotationCenterDy'),
          rotationDeg: _requiredPayloadValue(payload, 'rotationDeg'),
          originalLineInTH2File: originalLineInTH2File,
        );
      default:
        throw THCustomException(
          "Unsupported MPImageInsertConfig format '$format' in MPImageInsertConfig.fromMetadataString.",
        );
    }
  }

  String toMetadataString() {
    final Map<String, String> payload = _metadataPayload();

    final List<String> parts = <String>[];

    for (final MapEntry<String, String> entry in payload.entries) {
      final String encodedValue = Uri.encodeComponent(entry.value);

      parts.add('${entry.key}=$encodedValue');
    }

    return parts.join(';');
  }

  String toMetadataLine() {
    return '$mpMapiahConfigID $mpMapiahImageInsertConfigID {${toMetadataString()}}';
  }

  Map<String, String> _metadataPayload() {
    return {
      'format': format,
      'filename': filename,
      'xx': xx.toString(),
      'yy': yy.toString(),
      'xScale': xScale.toString(),
      'yScale': yScale.toString(),
      'rotationCenterDx': rotationCenterDx.toString(),
      'rotationCenterDy': rotationCenterDy.toString(),
      'rotationDeg': rotationDeg.toString(),
      ...extraMetadataPayload(),
    };
  }

  Map<String, String> extraMetadataPayload();

  Offset get scaledRotationCenter => Offset(
    rotationCenterDx.value * xScale.value,
    rotationCenterDy.value * yScale.value,
  );

  @override
  Offset transformWorldPointFromBaseWorldPoint(Offset worldPoint) {
    final Offset localPoint = worldPoint - Offset(xx.value, yy.value);

    return transformLocalPoint(localPoint);
  }

  Offset transformLocalPoint(Offset localPoint) {
    final Offset scaledPoint = Offset(
      localPoint.dx * xScale.value,
      localPoint.dy * yScale.value,
    );
    final Offset translation = Offset(xx.value, yy.value);
    final Offset pivot = translation + scaledRotationCenter;
    final Offset translatedPoint = scaledPoint + translation;
    final double angleInRad = rotationDeg.value * mp1DegreeInRad;
    final double cosValue = cos(angleInRad);
    final double sinValue = sin(angleInRad);
    final Offset delta = translatedPoint - pivot;

    return Offset(
      pivot.dx + delta.dx * cosValue - delta.dy * sinValue,
      pivot.dy + delta.dx * sinValue + delta.dy * cosValue,
    );
  }

  Rect transformLocalRect(Rect localRect) {
    final List<Offset> transformedPoints = <Offset>[
      transformLocalPoint(localRect.topLeft),
      transformLocalPoint(localRect.topRight),
      transformLocalPoint(localRect.bottomLeft),
      transformLocalPoint(localRect.bottomRight),
    ];

    double left = transformedPoints.first.dx;
    double right = transformedPoints.first.dx;
    double top = transformedPoints.first.dy;
    double bottom = transformedPoints.first.dy;

    for (final Offset point in transformedPoints.skip(1)) {
      if (point.dx < left) {
        left = point.dx;
      }
      if (point.dx > right) {
        right = point.dx;
      }
      if (point.dy < top) {
        top = point.dy;
      }
      if (point.dy > bottom) {
        bottom = point.dy;
      }
    }

    return MPNumericAux.orderedRectFromLTRB(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  @override
  bool get isVisible => _isVisible;

  @override
  set isVisible(bool isVisible) {
    if (_isVisible == isVisible) {
      return;
    }

    _isVisible = isVisible;
    clearBoundingBox();
  }

  @protected
  bool equalsMPImageInsertConfigBase(MPImageInsertConfig other) {
    return super.equalsBase(other) &&
        filename == other.filename &&
        xx == other.xx &&
        yy == other.yy &&
        xScale == other.xScale &&
        yScale == other.yScale &&
        rotationCenterDx == other.rotationCenterDx &&
        rotationCenterDy == other.rotationCenterDy &&
        rotationDeg == other.rotationDeg &&
        isVisible == other.isVisible;
  }

  @protected
  int get mpImageInsertConfigBaseHashCode {
    return super.hashCode ^
        Object.hash(
          filename,
          xx,
          yy,
          xScale,
          yScale,
          rotationCenterDx,
          rotationCenterDy,
          rotationDeg,
          isVisible,
        );
  }

  static Map<String, String> _decodeMetadataPayload(String metadata) {
    final String trimmedMetadata = metadata.trim();
    final String content =
        (trimmedMetadata.startsWith('{') && trimmedMetadata.endsWith('}'))
        ? trimmedMetadata.substring(1, trimmedMetadata.length - 1).trim()
        : trimmedMetadata;
    final Map<String, String> payload = <String, String>{};

    if (content.isEmpty) {
      return payload;
    }

    final List<String> parts = content.split(';');

    for (final String part in parts) {
      final String trimmedPart = part.trim();

      if (trimmedPart.isEmpty) {
        continue;
      }

      final int separatorIndex = trimmedPart.indexOf('=');

      if (separatorIndex <= 0) {
        throw THCustomException(
          "Invalid MPImageInsertConfig payload part '$trimmedPart'.",
        );
      }

      final String key = trimmedPart.substring(0, separatorIndex).trim();
      final String encodedValue = trimmedPart.substring(separatorIndex + 1);

      payload[key] = Uri.decodeComponent(encodedValue);
    }

    return payload;
  }

  static String _requiredPayloadValue(Map<String, String> payload, String key) {
    final String? value = payload[key];

    if (value == null) {
      throw THCustomException("Missing '$key' in MPImageInsertConfig payload.");
    }

    return value;
  }
}

class MPXVIImageInsertConfig extends MPImageInsertConfig
    with MPRuntimeXVIImageInsertConfigMixin {
  @override
  String xviRoot;
  bool _isGridVisible;

  XVIFile? _xviFile;
  bool _loadFailuredialogShown = false;

  double _xviRootedXX = 0.0;
  double _xviRootedYY = 0.0;

  MPXVIImageInsertConfig.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required super.filename,
    required super.xx,
    required super.yy,
    required super.xScale,
    required super.yScale,
    required super.rotationCenterDx,
    required super.rotationCenterDy,
    required super.rotationDeg,
    required super.isVisible,
    required bool isGridVisible,
    required this.xviRoot,
    required super.originalLineInTH2File,
  }) : _isGridVisible = isGridVisible,
       super.forCWJM();

  MPXVIImageInsertConfig({
    required super.parentMPID,
    super.sameLineComment,
    required super.filename,
    required super.xx,
    required super.yy,
    super.xScale = 1.0,
    super.yScale = 1.0,
    super.rotationCenterDx = 0.0,
    super.rotationCenterDy = 0.0,
    super.rotationDeg = 0.0,
    super.isVisible,
    bool isGridVisible = true,
    this.xviRoot = '',
    super.originalLineInTH2File,
  }) : _isGridVisible = isGridVisible,
       super.getMPID();

  MPXVIImageInsertConfig.fromString({
    required super.parentMPID,
    super.sameLineComment,
    required super.filename,
    required super.xx,
    required super.yy,
    super.xScale = '1.0',
    super.yScale = '1.0',
    super.rotationCenterDx = '0.0',
    super.rotationCenterDy = '0.0',
    super.rotationDeg = '0.0',
    super.isVisible = true,
    bool isGridVisible = true,
    this.xviRoot = '',
    super.originalLineInTH2File = '',
  }) : _isGridVisible = isGridVisible,
       super.fromString();

  @override
  String get format => mpImageInsertFormatXVI;

  @override
  bool get isXVI => true;

  @override
  MPRuntimeXVIImageInsertConfigMixin get asXVIImage => this;

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'isGridVisible': _isGridVisible,
      'xviRoot': xviRoot,
    };
  }

  @override
  Map<String, String> extraMetadataPayload() {
    return {'xviRoot': xviRoot};
  }

  @override
  MPXVIImageInsertConfig copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? filename,
    THDoublePart? xx,
    THDoublePart? yy,
    THDoublePart? xScale,
    THDoublePart? yScale,
    THDoublePart? rotationCenterDx,
    THDoublePart? rotationCenterDy,
    THDoublePart? rotationDeg,
    bool? isVisible,
    bool? isGridVisible,
    String? xviRoot,
    String? originalLineInTH2File,
  }) {
    return MPXVIImageInsertConfig.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      filename: filename ?? this.filename,
      xx: xx ?? this.xx,
      yy: yy ?? this.yy,
      xScale: xScale ?? this.xScale,
      yScale: yScale ?? this.yScale,
      rotationCenterDx: rotationCenterDx ?? this.rotationCenterDx,
      rotationCenterDy: rotationCenterDy ?? this.rotationCenterDy,
      rotationDeg: rotationDeg ?? this.rotationDeg,
      isVisible: isVisible ?? this.isVisible,
      isGridVisible: isGridVisible ?? this.isGridVisible,
      xviRoot: xviRoot ?? this.xviRoot,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
    );
  }

  @override
  MPXVIImageInsertConfig copyWithImageInsertConfigBase({
    String? filename,
    THDoublePart? xx,
    THDoublePart? yy,
    bool? isVisible,
    String? originalLineInTH2File,
  }) {
    return copyWith(
      filename: filename,
      xx: xx,
      yy: yy,
      isVisible: isVisible,
      originalLineInTH2File: originalLineInTH2File,
    );
  }

  @override
  Rect? getLocalBounds(TH2FileEditController th2FileEditController) {
    final XVIFile? xviFile = getXVIFile(th2FileEditController);

    if (xviFile == null) {
      return null;
    }

    final Rect? boundingBox = xviFile.getBoundingBox(th2FileEditController);

    if (boundingBox == null) {
      return null;
    }

    final Offset xviOffset =
        Offset(xviRootedXX, xviRootedYY) -
        Offset(xviFile.grid.gx.value, xviFile.grid.gy.value);
    final Rect shiftedBoundingBox = MPNumericAux.orderedRectFromRect(
      boundingBox.shift(xviOffset),
    );

    return shiftedBoundingBox.shift(Offset(-xx.value, -yy.value));
  }

  @override
  Rect? calculateBoundingBox(TH2FileEditController th2FileEditController) {
    if (!isVisible) {
      return null;
    }

    final Rect? localBounds = getLocalBounds(th2FileEditController);

    if (localBounds == null) {
      return null;
    }

    return transformLocalRect(localBounds);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MPXVIImageInsertConfig &&
        equalsMPImageInsertConfigBase(other) &&
        isGridVisible == other.isGridVisible &&
        xviRoot == other.xviRoot;
  }

  @override
  int get hashCode =>
      mpImageInsertConfigBaseHashCode ^ Object.hash(isGridVisible, xviRoot);

  @override
  bool isSameClass(Object object) {
    return object is MPXVIImageInsertConfig;
  }

  @override
  XVIFile? getXVIFile(TH2FileEditController th2FileEditController) {
    if (_xviFile == null) {
      final XVIFileParser parser = XVIFileParser();
      final XVIFile? xviFile;
      final bool isSuccessful;
      final List<String> errors;
      final String resolvedPath = MPDirectoryAux.getResolvedPath(
        th2FileEditController.th2File.filename,
        filename,
      );

      (xviFile, isSuccessful, errors) = parser.parse(resolvedPath);

      if (isSuccessful && (xviFile != null)) {
        _xviFile = xviFile;
        _xviFile!.isGridVisible = _isGridVisible;
      } else {
        _xviFile = null;

        final BuildContext? context = mpLocator.mpNavigatorKey.currentContext;

        if ((context != null) && !_loadFailuredialogShown) {
          _loadFailuredialogShown = true;
          MPDialogAux.showXVIParsingErrorsDialog(context, errors);
        }

        return null;
      }

      _fixXVIRoot();
    }

    return _xviFile;
  }

  @override
  double get xviRootedXX => _xviRootedXX;

  @override
  double get xviRootedYY => _xviRootedYY;

  @override
  void setXVIFile(XVIFile? xviFile) {
    _xviFile = xviFile;

    if (_xviFile != null) {
      _xviFile!.isGridVisible = _isGridVisible;
    }

    _fixXVIRoot();
  }

  @override
  bool get isGridVisible => _isGridVisible;

  @override
  set isGridVisible(bool isGridVisible) {
    if (_isGridVisible == isGridVisible) {
      return;
    }

    _isGridVisible = isGridVisible;

    if (_xviFile != null) {
      _xviFile!.isGridVisible = isGridVisible;
      _xviFile!.clearBoundingBox();
    }

    clearBoundingBox();
  }

  void _fixXVIRoot() {
    _xviRootedXX = xx.value;
    _xviRootedYY = yy.value;

    if (xviRoot.isEmpty || (_xviFile == null)) {
      return;
    }

    for (final XVIStation station in _xviFile!.stations) {
      if (station.name == xviRoot) {
        final THPositionPart stationPosition = station.position;

        _xviRootedXX += _xviFile!.grid.gx.value - stationPosition.x;
        _xviRootedYY += _xviFile!.grid.gy.value - stationPosition.y;

        break;
      }
    }
  }
}

class MPRasterImageInsertConfig extends MPImageInsertConfig
    with MPRuntimeRasterImageInsertConfigMixin {
  Future<ui.Image>? _rasterImage;
  ui.Image? _decodedRasterImage;

  MPRasterImageInsertConfig.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required super.filename,
    required super.xx,
    required super.yy,
    required super.xScale,
    required super.yScale,
    required super.rotationCenterDx,
    required super.rotationCenterDy,
    required super.rotationDeg,
    required super.isVisible,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  MPRasterImageInsertConfig({
    required super.parentMPID,
    super.sameLineComment,
    required super.filename,
    required super.xx,
    required super.yy,
    super.xScale = 1.0,
    super.yScale = 1.0,
    super.rotationCenterDx = 0.0,
    super.rotationCenterDy = 0.0,
    super.rotationDeg = 0.0,
    super.isVisible,
    super.originalLineInTH2File,
  }) : super.getMPID();

  MPRasterImageInsertConfig.fromString({
    required super.parentMPID,
    super.sameLineComment,
    required super.filename,
    required super.xx,
    required super.yy,
    super.xScale = '1.0',
    super.yScale = '1.0',
    super.rotationCenterDx = '0.0',
    super.rotationCenterDy = '0.0',
    super.rotationDeg = '0.0',
    super.isVisible = true,
    super.originalLineInTH2File = '',
  }) : super.fromString();

  @override
  String get format => mpImageInsertFormatRaster;

  @override
  bool get isXVI => false;

  @override
  MPRuntimeRasterImageInsertConfigMixin get asRasterImage => this;

  @override
  Map<String, String> extraMetadataPayload() {
    return <String, String>{};
  }

  @override
  MPRasterImageInsertConfig copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? filename,
    THDoublePart? xx,
    THDoublePart? yy,
    THDoublePart? xScale,
    THDoublePart? yScale,
    THDoublePart? rotationCenterDx,
    THDoublePart? rotationCenterDy,
    THDoublePart? rotationDeg,
    bool? isVisible,
    String? originalLineInTH2File,
  }) {
    return MPRasterImageInsertConfig.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      filename: filename ?? this.filename,
      xx: xx ?? this.xx,
      yy: yy ?? this.yy,
      xScale: xScale ?? this.xScale,
      yScale: yScale ?? this.yScale,
      rotationCenterDx: rotationCenterDx ?? this.rotationCenterDx,
      rotationCenterDy: rotationCenterDy ?? this.rotationCenterDy,
      rotationDeg: rotationDeg ?? this.rotationDeg,
      isVisible: isVisible ?? this.isVisible,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
    );
  }

  @override
  MPRasterImageInsertConfig copyWithImageInsertConfigBase({
    String? filename,
    THDoublePart? xx,
    THDoublePart? yy,
    bool? isVisible,
    String? originalLineInTH2File,
  }) {
    return copyWith(
      filename: filename,
      xx: xx,
      yy: yy,
      isVisible: isVisible,
      originalLineInTH2File: originalLineInTH2File,
    );
  }

  @override
  Rect? getLocalBounds(TH2FileEditController th2FileEditController) {
    getRasterImageFrameInfo(th2FileEditController);

    final ui.Image? rasterImage = _decodedRasterImage;

    if (rasterImage == null) {
      return null;
    }

    return Rect.fromLTRB(
      0.0,
      -rasterImage.height.toDouble(),
      rasterImage.width.toDouble(),
      0.0,
    );
  }

  @override
  Rect? calculateBoundingBox(TH2FileEditController th2FileEditController) {
    if (!isVisible) {
      return null;
    }

    final Rect? localBounds = getLocalBounds(th2FileEditController);

    if (localBounds == null) {
      return MPNumericAux.orderedRectSmallestAroundPoint(
        center: Offset(xx.value, yy.value),
      );
    }

    return transformLocalRect(localBounds);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is MPRasterImageInsertConfig &&
        equalsMPImageInsertConfigBase(other);
  }

  @override
  int get hashCode => mpImageInsertConfigBaseHashCode;

  @override
  bool isSameClass(Object object) {
    return object is MPRasterImageInsertConfig;
  }

  @override
  Future<ui.Image>? getRasterImageFrameInfo(
    TH2FileEditController th2FileEditController,
  ) {
    _rasterImage ??=
        MPElementEditAux.getRasterImageFrameInfo(
          th2FileEditController,
          filename,
        ).then((ui.Image img) {
          _decodedRasterImage = img;
          clearBoundingBox();

          return img;
        });

    return _rasterImage!;
  }

  @override
  ui.Image? get decodedRasterImage => _decodedRasterImage;

  @override
  void setRasterImage(ui.Image? image) {
    _decodedRasterImage = image;
    clearBoundingBox();
  }
}
