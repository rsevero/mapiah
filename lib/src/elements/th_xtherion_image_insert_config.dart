part of 'th_element.dart';

/// Should support the following image file formats:
/// * PNG
/// * JPEG/JPG
/// * GIF
/// * PNM/PPM
/// * XVI
class THXTherionImageInsertConfig extends THElement with MPBoundingBox {
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
  bool isVisible;
  THDoublePart igamma;
  THDoublePart yy;
  String xviRoot;
  int iidx;
  String imgx;
  String xData;
  bool xImage;
  bool isXVI;

  /// Non-mapped support fileds
  XVIFile? _xviFile;
  Future<ui.Image>? _rasterImage;
  ui.Image? _decodedRasterImage;

  double _xviRootedXX = 0.0;
  double _xviRootedYY = 0.0;

  THXTherionImageInsertConfig.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required this.filename,
    required this.xx,
    required this.isVisible,
    required this.igamma,
    required this.yy,
    required this.xviRoot,
    required this.iidx,
    required this.imgx,
    required this.xData,
    required this.xImage,
    required this.isXVI,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THXTherionImageInsertConfig.fromString({
    required super.parentMPID,
    required this.filename,
    required String xx,
    String vsb = '1',
    String igamma = '1.0',
    required String yy,
    this.xviRoot = '',
    this.iidx = 0,
    this.imgx = '',
    this.xData = '',
    this.xImage = false,
    super.originalLineInTH2File = '',
  }) : xx = THDoublePart.fromString(valueString: xx),
       isVisible = (int.tryParse(vsb) ?? 1) > 0,
       igamma = THDoublePart.fromString(valueString: igamma),
       yy = THDoublePart.fromString(valueString: yy),
       isXVI = filename.toLowerCase().endsWith(mpXVIExtension),
       super.getMPID();

  THXTherionImageInsertConfig({
    required super.parentMPID,
    required this.filename,
    required this.xx,
    this.isVisible = true,
    THDoublePart? igamma,
    required this.yy,
    this.xviRoot = '',
    this.iidx = 0,
    this.imgx = '',
    this.xData = '',
    this.xImage = false,
    super.originalLineInTH2File = '',
  }) : igamma = (igamma == null)
           ? THDoublePart.fromString(valueString: '1.0')
           : igamma,
       isXVI = filename.toLowerCase().endsWith(mpXVIExtension),
       super.getMPID();

  THXTherionImageInsertConfig.adjustPosition({
    required super.parentMPID,
    required this.filename,
    required this.xx,
    this.isVisible = true,
    THDoublePart? igamma,
    required this.yy,
    this.xviRoot = '',
    this.iidx = 0,
    this.imgx = '',
    this.xData = '',
    this.xImage = false,
    super.originalLineInTH2File = '',
    required TH2FileEditController th2FileEditController,
  }) : igamma = (igamma == null)
           ? THDoublePart.fromString(valueString: '1.0')
           : igamma,
       isXVI = filename.toLowerCase().endsWith(mpXVIExtension),
       super.getMPID() {
    if (isXVI) {
      final XVIFile? xviFile = getXVIFile(th2FileEditController);

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

      yy = yy.copyWith(value: yy.value - xviHeight);
      _fixXVIRoot();
    }
  }

  @override
  THElementType get elementType => THElementType.xTherionImageInsertConfig;

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'filename': filename,
      'xx': xx.toMap(),
      'isVisible': isVisible,
      'igamma': igamma.toMap(),
      'yy': yy.toMap(),
      'xviRoot': xviRoot,
      'iidx': iidx,
      'imgx': imgx,
      'xData': xData,
      'xImage': xImage,
      'isXVI': isXVI,
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
      igamma: THDoublePart.fromMap(map['igamma']),
      yy: THDoublePart.fromMap(map['yy']),
      xviRoot: map['xviRoot'],
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
  THXTherionImageInsertConfig copyWith({
    int? mpID,
    int? parentMPID,
    String? sameLineComment,
    bool makeSameLineCommentNull = false,
    String? filename,
    THDoublePart? xx,
    bool? isVisible,
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
    return THXTherionImageInsertConfig.forCWJM(
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
      xviRoot: xviRoot ?? this.xviRoot,
      iidx: iidx ?? this.iidx,
      imgx: imgx ?? this.imgx,
      xData: xData ?? this.xData,
      xImage: xImage ?? this.xImage,
      isXVI: isXVI ?? this.isXVI,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THXTherionImageInsertConfig) return false;
    if (!super.equalsBase(other)) return false;

    return filename == other.filename &&
        xx == other.xx &&
        isVisible == other.isVisible &&
        igamma == other.igamma &&
        yy == other.yy &&
        xviRoot == other.xviRoot &&
        iidx == other.iidx &&
        imgx == other.imgx &&
        xData == other.xData &&
        xImage == other.xImage &&
        isXVI == other.isXVI;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        filename,
        xx,
        isVisible,
        igamma,
        yy,
        xviRoot,
        iidx,
        imgx,
        xData,
        xImage,
        isXVI,
      );

  @override
  bool isSameClass(Object object) {
    return object is THXTherionImageInsertConfig;
  }

  XVIFile? getXVIFile(TH2FileEditController th2FileEditController) {
    if (_xviFile == null && isXVI) {
      final XVIFileParser parser = XVIFileParser();
      final XVIFile? xviFile;
      final bool isSuccessful;
      final List<String> errors;
      final String resolvedPath = MPDirectoryAux.getResolvedPath(
        th2FileEditController.thFile.filename,
        filename,
      );

      (xviFile, isSuccessful, errors) = parser.parse(resolvedPath);

      if (isSuccessful && (xviFile != null)) {
        _xviFile = xviFile;

        _fixXVIRoot();
      } else {
        _xviFile = null;

        // TODO: present XVI parse errors to the user
        print(errors.join('\n'));
      }
    }

    return _xviFile;
  }

  /// Implementation of xth_me_imgs_set_root from me_imgs.tcl xTherion.
  void _fixXVIRoot() {
    _xviRootedXX = xx.value;
    _xviRootedYY = yy.value;

    if (!isXVI || xviRoot.isEmpty) {
      return;
    }

    if (_xviFile == null) {
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

  double get xviRootedXX => _xviRootedXX;

  double get xviRootedYY => _xviRootedYY;

  Future<ui.Image> getRasterImageFrameInfo(
    TH2FileEditController th2FileEditController,
  ) {
    _rasterImage ??=
        MPEditElementAux.getRasterImageFrameInfo(
          th2FileEditController,
          filename,
        ).then((img) {
          _decodedRasterImage = img;

          return img;
        });

    return _rasterImage!;
  }

  @override
  Rect calculateBoundingBox(TH2FileEditController th2FileEditController) {
    return isXVI
        ? _calculateXVIBoundingBox(th2FileEditController)
        : _calculateRasterImageBoundingBox(th2FileEditController);
  }

  Rect _calculateRasterImageBoundingBox(
    TH2FileEditController th2FileEditController,
  ) {
    // Ensure loading has been triggered (will cache when done)
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

  Rect _calculateXVIBoundingBox(TH2FileEditController th2FileEditController) {
    final XVIFile? xviFile = getXVIFile(th2FileEditController);

    if (xviFile == null) {
      return MPNumericAux.orderedRectSmallestAroundPoint(center: Offset.zero);
    }

    final Rect boundingBox = xviFile.getBoundingBox(th2FileEditController);
    final Offset xviOffset =
        Offset(xviRootedXX, xviRootedYY) -
        Offset(xviFile.grid.gx.value, xviFile.grid.gy.value);

    return MPNumericAux.orderedRectFromRect(boundingBox.shift(xviOffset));
  }
}
