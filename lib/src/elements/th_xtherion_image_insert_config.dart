// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'th_element.dart';

/// Should support the following image file formats:
/// * PNG
/// * JPEG/JPG
/// * GIF
/// * PNM/PPM
/// * XVI
abstract class THXTherionImageInsertConfig extends THElement
    with MPBoundingBoxMixin, MPRuntimeImageInsertConfigMixin {
  @override
  final String filename;

  // Field names gotten from XTherion me.imgs.tcl file
  THDoublePart xx;
  // vsb in xTherion is the per-image visibility/state flag:
  // * 1 shows and drives redraw/rescan;
  // * 0 hides and skips heavy work;
  // * negative values denote “failed to load” placeholders to be safely skipped
  //   until an automatic refresh reconstructs and restores the intended 0/1
  //   visibility. They are produced subtracting 2 from the original vsb value
  //   on load failure and adding 2 on load success.
  // In Mapiah it is converted to 'isVisible' as a simple bool.
  bool _isVisible;
  THDoublePart igamma;
  THDoublePart yy;
  int iidx;
  String imgx;
  String xData;
  bool xImage;

  THXTherionImageInsertConfig._forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required this.filename,
    required this.xx,
    required bool isVisible,
    required this.igamma,
    required this.yy,
    required this.iidx,
    required this.imgx,
    required this.xData,
    required this.xImage,
    required super.originalLineInTH2File,
  }) : _isVisible = isVisible,
       super.forCWJM();

  THXTherionImageInsertConfig._getMPID({
    required super.parentMPID,
    super.sameLineComment,
    required this.filename,
    required this.xx,
    bool isVisible = true,
    THDoublePart? igamma,
    required this.yy,
    this.iidx = 0,
    this.imgx = '',
    this.xData = '',
    this.xImage = false,
    super.originalLineInTH2File = '',
  }) : igamma = (igamma == null)
           ? THDoublePart.fromString(valueString: '1.0')
           : igamma,
       _isVisible = isVisible,
       super.getMPID();

  THXTherionImageInsertConfig._fromString({
    required super.parentMPID,
    required this.filename,
    required String xx,
    String vsb = '1',
    String igamma = '1.0',
    required String yy,
    this.iidx = 0,
    this.imgx = '',
    this.xData = '',
    this.xImage = false,
    super.originalLineInTH2File = '',
  }) : xx = THDoublePart.fromString(valueString: xx),
       _isVisible = (int.tryParse(vsb) ?? 1) > 0,
       igamma = THDoublePart.fromString(valueString: igamma),
       yy = THDoublePart.fromString(valueString: yy),
       super.getMPID();

  factory THXTherionImageInsertConfig.forCWJM({
    required int mpID,
    required int parentMPID,
    String? sameLineComment,
    required String filename,
    required THDoublePart xx,
    required bool isVisible,
    bool isGridVisible = true,
    required THDoublePart igamma,
    required THDoublePart yy,
    String xviRoot = '',
    required int iidx,
    required String imgx,
    required String xData,
    required bool xImage,
    bool? isXVI,
    required String originalLineInTH2File,
  }) {
    final bool resolvedIsXVI = isXVI ?? _filenameIsXVI(filename);

    if (resolvedIsXVI) {
      return THXVIXTherionImageInsertConfig.forCWJM(
        mpID: mpID,
        parentMPID: parentMPID,
        sameLineComment: sameLineComment,
        filename: filename,
        xx: xx,
        isVisible: isVisible,
        isGridVisible: isGridVisible,
        igamma: igamma,
        yy: yy,
        xviRoot: xviRoot,
        iidx: iidx,
        imgx: imgx,
        xData: xData,
        xImage: xImage,
        originalLineInTH2File: originalLineInTH2File,
      );
    }

    return THRasterXTherionImageInsertConfig.forCWJM(
      mpID: mpID,
      parentMPID: parentMPID,
      sameLineComment: sameLineComment,
      filename: filename,
      xx: xx,
      isVisible: isVisible,
      igamma: igamma,
      yy: yy,
      iidx: iidx,
      imgx: imgx,
      xData: xData,
      xImage: xImage,
      originalLineInTH2File: originalLineInTH2File,
    );
  }

  factory THXTherionImageInsertConfig.fromString({
    required int parentMPID,
    required String filename,
    required String xx,
    String vsb = '1',
    String igamma = '1.0',
    required String yy,
    String xviRoot = '',
    int iidx = 0,
    String imgx = '',
    String xData = '',
    bool xImage = false,
    String originalLineInTH2File = '',
  }) {
    if (_filenameIsXVI(filename)) {
      return THXVIXTherionImageInsertConfig.fromString(
        parentMPID: parentMPID,
        filename: filename,
        xx: xx,
        vsb: vsb,
        igamma: igamma,
        yy: yy,
        xviRoot: xviRoot,
        iidx: iidx,
        imgx: imgx,
        xData: xData,
        xImage: xImage,
        originalLineInTH2File: originalLineInTH2File,
      );
    }

    return THRasterXTherionImageInsertConfig.fromString(
      parentMPID: parentMPID,
      filename: filename,
      xx: xx,
      vsb: vsb,
      igamma: igamma,
      yy: yy,
      iidx: iidx,
      imgx: imgx,
      xData: xData,
      xImage: xImage,
      originalLineInTH2File: originalLineInTH2File,
    );
  }

  factory THXTherionImageInsertConfig({
    required int parentMPID,
    required String filename,
    required THDoublePart xx,
    bool isVisible = true,
    bool isGridVisible = true,
    THDoublePart? igamma,
    required THDoublePart yy,
    String xviRoot = '',
    int iidx = 0,
    String imgx = '',
    String xData = '',
    bool xImage = false,
    String originalLineInTH2File = '',
  }) {
    if (_filenameIsXVI(filename)) {
      return THXVIXTherionImageInsertConfig(
        parentMPID: parentMPID,
        filename: filename,
        xx: xx,
        isVisible: isVisible,
        isGridVisible: isGridVisible,
        igamma: igamma,
        yy: yy,
        xviRoot: xviRoot,
        iidx: iidx,
        imgx: imgx,
        xData: xData,
        xImage: xImage,
        originalLineInTH2File: originalLineInTH2File,
      );
    }

    return THRasterXTherionImageInsertConfig(
      parentMPID: parentMPID,
      filename: filename,
      xx: xx,
      isVisible: isVisible,
      igamma: igamma,
      yy: yy,
      iidx: iidx,
      imgx: imgx,
      xData: xData,
      xImage: xImage,
      originalLineInTH2File: originalLineInTH2File,
    );
  }

  factory THXTherionImageInsertConfig.adjustPosition({
    required int parentMPID,
    required String filename,
    required THDoublePart xx,
    bool isVisible = true,
    bool isGridVisible = true,
    THDoublePart? igamma,
    required THDoublePart yy,
    String xviRoot = '',
    int iidx = 0,
    String imgx = '',
    String xData = '',
    bool xImage = false,
    String originalLineInTH2File = '',
    required TH2FileEditController th2FileEditController,
  }) {
    final THXTherionImageInsertConfig newImage = THXTherionImageInsertConfig(
      parentMPID: parentMPID,
      filename: filename,
      xx: xx,
      isVisible: isVisible,
      isGridVisible: isGridVisible,
      igamma: igamma,
      yy: yy,
      xviRoot: xviRoot,
      iidx: iidx,
      imgx: imgx,
      xData: xData,
      xImage: xImage,
      originalLineInTH2File: originalLineInTH2File,
    );

    final MPRuntimeXVIImageInsertConfigMixin? xviImage = newImage.asXVIImage;

    if (xviImage == null) {
      return newImage;
    }

    final XVIFile? xviFile = xviImage.getXVIFile(th2FileEditController);

    if (xviFile == null) {
      throw Exception(
        'THXTherionImageInsertConfig.adjustPosition: XVI file could not be loaded for image insert config: $filename',
      );
    }

    final XVIGrid grid = xviFile.grid;

    /// Not including:
    ///
    /// (grid.ngx.value * grid.gxy.value)
    ///
    /// in xviHeight so the top left corner of the grid always matches the top
    /// left corner of the drawing even if the grid is vertically screwed.
    final double xviHeight = grid.ngy.value * grid.gyy.value;

    newImage.yy = newImage.yy.copyWith(value: newImage.yy.value - xviHeight);
    (newImage as THXVIXTherionImageInsertConfig).fixXVIRoot();

    return newImage;
  }

  @override
  THElementType get elementType => THElementType.xTherionImageInsertConfig;

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'filename': filename,
      'xx': xx.toMap(),
      'isVisible': _isVisible,
      'igamma': igamma.toMap(),
      'yy': yy.toMap(),
      'iidx': iidx,
      'imgx': imgx,
      'xData': xData,
      'xImage': xImage,
      'isXVI': isXVI,
      ...extraToMap(),
    };
  }

  static THXTherionImageInsertConfig fromMap(Map<String, dynamic> map) {
    return THXTherionImageInsertConfig.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      filename: map['filename'],
      xx: THDoublePart.fromMap(map['xx']),
      isVisible: map['isVisible'],
      isGridVisible: map['isGridVisible'] ?? true,
      igamma: THDoublePart.fromMap(map['igamma']),
      yy: THDoublePart.fromMap(map['yy']),
      xviRoot: map['xviRoot'] ?? '',
      iidx: map['iidx'].toInt(),
      imgx: map['imgx'],
      xData: map['xData'],
      xImage: map['xImage'],
      isXVI: map['isXVI'],
      originalLineInTH2File: map['originalLineInTH2File'],
    );
  }

  static THXTherionImageInsertConfig fromJson(String source) =>
      fromMap(jsonDecode(source));

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

  @override
  THXTherionImageInsertConfig copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? filename,
    THDoublePart? xx,
    bool? isVisible,
    bool? isGridVisible,
    THDoublePart? igamma,
    THDoublePart? yy,
    String? xviRoot,
    int? iidx,
    String? imgx,
    String? xData,
    bool? xImage,
    bool? isXVI,
    String? originalLineInTH2File,
  });

  @protected
  bool equalsTHXTherionImageInsertConfigBase(
    THXTherionImageInsertConfig other,
  ) {
    return super.equalsBase(other) &&
        filename == other.filename &&
        xx == other.xx &&
        isVisible == other.isVisible &&
        igamma == other.igamma &&
        yy == other.yy &&
        iidx == other.iidx &&
        imgx == other.imgx &&
        xData == other.xData &&
        xImage == other.xImage;
  }

  @protected
  int get thXTherionImageInsertConfigBaseHashCode {
    return super.hashCode ^
        Object.hash(
          filename,
          xx,
          isVisible,
          igamma,
          yy,
          iidx,
          imgx,
          xData,
          xImage,
        );
  }

  Map<String, dynamic> extraToMap();

  String get xviRoot => '';

  @override
  MPRuntimeXVIImageInsertConfigMixin? get asXVIImage => null;

  @override
  MPRuntimeRasterImageInsertConfigMixin? get asRasterImage => null;

  @override
  bool get isXVI;

  static bool _filenameIsXVI(String filename) {
    return filename.toLowerCase().endsWith(mpXVIExtension);
  }
}

class THXVIXTherionImageInsertConfig extends THXTherionImageInsertConfig
    with MPRuntimeXVIImageInsertConfigMixin {
  @override
  String xviRoot;

  bool _isGridVisible;

  XVIFile? _xviFile;
  bool _loadFailuredialogShown = false;

  double _xviRootedXX = 0.0;
  double _xviRootedYY = 0.0;

  THXVIXTherionImageInsertConfig.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required super.filename,
    required super.xx,
    required super.isVisible,
    required bool isGridVisible,
    required super.igamma,
    required super.yy,
    required this.xviRoot,
    required super.iidx,
    required super.imgx,
    required super.xData,
    required super.xImage,
    required super.originalLineInTH2File,
  }) : _isGridVisible = isGridVisible,
       super._forCWJM();

  THXVIXTherionImageInsertConfig({
    required super.parentMPID,
    required super.filename,
    required super.xx,
    super.isVisible = true,
    bool isGridVisible = true,
    super.igamma,
    required super.yy,
    this.xviRoot = '',
    super.iidx = 0,
    super.imgx = '',
    super.xData = '',
    super.xImage = false,
    super.originalLineInTH2File = '',
  }) : _isGridVisible = isGridVisible,
       super._getMPID();

  THXVIXTherionImageInsertConfig.fromString({
    required super.parentMPID,
    required super.filename,
    required super.xx,
    super.vsb = '1',
    super.igamma = '1.0',
    required super.yy,
    this.xviRoot = '',
    super.iidx = 0,
    super.imgx = '',
    super.xData = '',
    super.xImage = false,
    super.originalLineInTH2File = '',
  }) : _isGridVisible = true,
       super._fromString();

  @override
  bool get isXVI => true;

  @override
  MPRuntimeXVIImageInsertConfigMixin get asXVIImage => this;

  @override
  Map<String, dynamic> extraToMap() {
    return {'xviRoot': xviRoot, 'isGridVisible': _isGridVisible};
  }

  @override
  THXVIXTherionImageInsertConfig copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? filename,
    THDoublePart? xx,
    bool? isVisible,
    bool? isGridVisible,
    THDoublePart? igamma,
    THDoublePart? yy,
    String? xviRoot,
    int? iidx,
    String? imgx,
    String? xData,
    bool? xImage,
    bool? isXVI,
    String? originalLineInTH2File,
  }) {
    return THXVIXTherionImageInsertConfig.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      filename: filename ?? this.filename,
      xx: xx ?? this.xx,
      isVisible: isVisible ?? this.isVisible,
      isGridVisible: isGridVisible ?? this.isGridVisible,
      igamma: igamma ?? this.igamma,
      yy: yy ?? this.yy,
      xviRoot: xviRoot ?? this.xviRoot,
      iidx: iidx ?? this.iidx,
      imgx: imgx ?? this.imgx,
      xData: xData ?? this.xData,
      xImage: xImage ?? this.xImage,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is THXVIXTherionImageInsertConfig &&
        equalsTHXTherionImageInsertConfigBase(other) &&
        isGridVisible == other.isGridVisible &&
        xviRoot == other.xviRoot;
  }

  @override
  int get hashCode =>
      thXTherionImageInsertConfigBaseHashCode ^
      Object.hash(isGridVisible, xviRoot);

  @override
  bool isSameClass(Object object) {
    return object is THXVIXTherionImageInsertConfig;
  }

  @override
  Rect? calculateBoundingBox(TH2FileEditController th2FileEditController) {
    if (!isVisible) {
      return null;
    }

    final XVIFile? xviFile = getXVIFile(th2FileEditController);

    if (xviFile == null) {
      return null;
    }

    final Rect boundingBox = xviFile.getBoundingBox(th2FileEditController)!;
    final Offset xviOffset =
        Offset(xviRootedXX, xviRootedYY) -
        Offset(xviFile.grid.gx.value, xviFile.grid.gy.value);

    return MPNumericAux.orderedRectFromRect(boundingBox.shift(xviOffset));
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

      fixXVIRoot();
    }

    return _xviFile;
  }

  @override
  double get xviRootedXX => _xviRootedXX;

  @override
  double get xviRootedYY => _xviRootedYY;

  void setXVIFile(XVIFile? xviFile) {
    _xviFile = xviFile;

    if (_xviFile != null) {
      _xviFile!.isGridVisible = _isGridVisible;
    }

    fixXVIRoot();
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

  void fixXVIRoot() {
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

class THRasterXTherionImageInsertConfig extends THXTherionImageInsertConfig
    with MPRuntimeRasterImageInsertConfigMixin {
  Future<ui.Image>? _rasterImage;
  ui.Image? _decodedRasterImage;

  THRasterXTherionImageInsertConfig.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required super.filename,
    required super.xx,
    required super.isVisible,
    required super.igamma,
    required super.yy,
    required super.iidx,
    required super.imgx,
    required super.xData,
    required super.xImage,
    required super.originalLineInTH2File,
  }) : super._forCWJM();

  THRasterXTherionImageInsertConfig({
    required super.parentMPID,
    required super.filename,
    required super.xx,
    super.isVisible = true,
    super.igamma,
    required super.yy,
    super.iidx = 0,
    super.imgx = '',
    super.xData = '',
    super.xImage = false,
    super.originalLineInTH2File = '',
  }) : super._getMPID();

  THRasterXTherionImageInsertConfig.fromString({
    required super.parentMPID,
    required super.filename,
    required super.xx,
    super.vsb = '1',
    super.igamma = '1.0',
    required super.yy,
    super.iidx = 0,
    super.imgx = '',
    super.xData = '',
    super.xImage = false,
    super.originalLineInTH2File = '',
  }) : super._fromString();

  @override
  bool get isXVI => false;

  @override
  MPRuntimeRasterImageInsertConfigMixin get asRasterImage => this;

  @override
  Map<String, dynamic> extraToMap() {
    return <String, dynamic>{};
  }

  @override
  THRasterXTherionImageInsertConfig copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? filename,
    THDoublePart? xx,
    bool? isVisible,
    bool? isGridVisible,
    THDoublePart? igamma,
    THDoublePart? yy,
    String? xviRoot,
    int? iidx,
    String? imgx,
    String? xData,
    bool? xImage,
    bool? isXVI,
    String? originalLineInTH2File,
  }) {
    return THRasterXTherionImageInsertConfig.forCWJM(
      mpID: mpID ?? this.mpID,
      parentMPID: parentMPID ?? this.parentMPID,
      sameLineComment: makeSameLineCommentNull
          ? null
          : (sameLineComment ?? this.sameLineComment),
      filename: filename ?? this.filename,
      xx: xx ?? this.xx,
      isVisible: isVisible ?? this.isVisible,
      igamma: igamma ?? this.igamma,
      yy: yy ?? this.yy,
      iidx: iidx ?? this.iidx,
      imgx: imgx ?? this.imgx,
      xData: xData ?? this.xData,
      xImage: xImage ?? this.xImage,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is THRasterXTherionImageInsertConfig &&
        equalsTHXTherionImageInsertConfigBase(other);
  }

  @override
  int get hashCode => thXTherionImageInsertConfigBaseHashCode;

  @override
  bool isSameClass(Object object) {
    return object is THRasterXTherionImageInsertConfig;
  }

  @override
  Rect? calculateBoundingBox(TH2FileEditController th2FileEditController) {
    if (!isVisible) {
      return null;
    }

    getRasterImageFrameInfo(th2FileEditController);

    final ui.Image? rasterImage = _decodedRasterImage;

    return (rasterImage == null)
        ? MPNumericAux.orderedRectSmallestAroundPoint(
            center: Offset(xx.value, yy.value),
          )
        : Rect.fromLTWH(
            xx.value,
            yy.value,
            rasterImage.width.toDouble(),
            rasterImage.height.toDouble(),
          );
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

          return img;
        });

    return _rasterImage!;
  }

  void setRasterImage(ui.Image? image) {
    _decodedRasterImage = image;
  }
}
