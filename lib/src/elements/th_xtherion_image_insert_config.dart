part of 'th_element.dart';

/// Should support the following image file formats:
/// * PNG
/// * JPEG/JPG
/// * GIF
/// * PNM/PPM
/// * XVI
class THXTherionImageInsertConfig extends THElement {
  String filename;

  // Field names gotten from XTherion me.imgs.tcl file
  THDoublePart xx;
  THDoublePart vsb;
  THDoublePart igamma;
  THDoublePart yy;
  String xviRoot;
  int iidx;
  String imgx;
  String xData;
  bool xImage;
  bool isXVI;

  /// Mapped support fields
  bool isVisible;

  /// Non-mapped support fileds
  XVIFile? _xviFile;

  THXTherionImageInsertConfig.forCWJM({
    required super.mpID,
    required super.parentMPID,
    super.sameLineComment,
    required this.filename,
    required this.xx,
    required this.vsb,
    required this.igamma,
    required this.yy,
    required this.xviRoot,
    required this.iidx,
    required this.imgx,
    required this.xData,
    required this.xImage,
    required this.isXVI,
    required this.isVisible,
    required super.originalLineInTH2File,
  }) : super.forCWJM();

  THXTherionImageInsertConfig({
    required super.parentMPID,
    required this.filename,
    required String xx,
    required String vsb,
    required String igamma,
    required String yy,
    required this.xviRoot,
    required this.iidx,
    required this.imgx,
    required this.xData,
    required this.xImage,
    this.isVisible = true,
    super.originalLineInTH2File = '',
  })  : xx = THDoublePart.fromString(valueString: xx),
        vsb = THDoublePart.fromString(valueString: vsb),
        igamma = THDoublePart.fromString(valueString: igamma),
        yy = THDoublePart.fromString(valueString: yy),
        isXVI = filename.toLowerCase().endsWith(mpXVIExtension),
        super.addToParent();

  @override
  THElementType get elementType => THElementType.xTherionImageInsertConfig;

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'filename': filename,
      'xx': xx,
      'vsb': vsb,
      'igamma': igamma,
      'yy': yy,
      'xviRoot': xviRoot,
      'iidx': iidx,
      'imgx': imgx,
      'xData': xData,
      'xImage': xImage,
      'isXVI': isXVI,
      'isVisible': isVisible,
    };
  }

  static THXTherionImageInsertConfig fromMap(Map<String, dynamic> map) {
    return THXTherionImageInsertConfig.forCWJM(
      mpID: map['mpID'],
      parentMPID: map['parentMPID'],
      sameLineComment: map['sameLineComment'],
      filename: map['filename'],
      xx: THDoublePart.fromMap(map['xx']),
      vsb: THDoublePart.fromMap(map['vsb']),
      igamma: THDoublePart.fromMap(map['igamma']),
      yy: THDoublePart.fromMap(map['yy']),
      xviRoot: map['xviRoot'],
      iidx: map['iidx'].toInt(),
      imgx: map['imgx'],
      xData: map['xData'],
      xImage: map['xImage'],
      isXVI: map['isXVI'],
      isVisible: map['isVisible'],
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
    THDoublePart? vsb,
    THDoublePart? igamma,
    THDoublePart? yy,
    String? xviRoot,
    int? iidx,
    String? imgx,
    String? xData,
    bool? xImage,
    bool? isXVI,
    bool? isVisible,
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
      vsb: vsb ?? this.vsb,
      igamma: igamma ?? this.igamma,
      yy: yy ?? this.yy,
      xviRoot: xviRoot ?? this.xviRoot,
      iidx: iidx ?? this.iidx,
      imgx: imgx ?? this.imgx,
      xData: xData ?? this.xData,
      xImage: xImage ?? this.xImage,
      isXVI: isXVI ?? this.isXVI,
      isVisible: isVisible ?? this.isVisible,
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
        vsb == other.vsb &&
        igamma == other.igamma &&
        yy == other.yy &&
        xviRoot == other.xviRoot &&
        iidx == other.iidx &&
        imgx == other.imgx &&
        xData == other.xData &&
        xImage == other.xImage &&
        isXVI == other.isXVI &&
        isVisible == other.isVisible;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        filename,
        xx,
        vsb,
        igamma,
        yy,
        xviRoot,
        iidx,
        imgx,
        xData,
        xImage,
        isXVI,
        isVisible,
      );

  @override
  bool isSameClass(Object object) {
    return object is THXTherionImageInsertConfig;
  }

  XVIFile? getXVIFile(TH2FileEditController th2FileEditController) {
    if (_xviFile == null && isXVI) {
      final XVIFileParser parser = XVIFileParser();
      final XVIFile xviFile;
      final bool isSuccessful;
      final List<String> errors;
      final String referenceFilename = th2FileEditController.thFile.filename;
      final String resolvedPath = p.normalize(p.isAbsolute(filename)
          ? filename
          : p.join(p.dirname(referenceFilename), filename));

      (xviFile, isSuccessful, errors) = parser.parse(resolvedPath);

      if (isSuccessful) {
        _xviFile = xviFile;
        if (_xviFile != null) {
          _fixXVIRoot();
        }
      } else {
        _xviFile = null;

        // TODO: present XVI parse errors to the user
        print(errors.join('\n'));
      }
    }

    return _xviFile;
  }

  void _fixXVIRoot() {
    if (!isXVI || xviRoot.isEmpty) {
      return;
    }

    for (final XVIStation station in _xviFile!.stations) {
      if (station.name == xviRoot) {
        final THPositionPart stationPosition = station.position;
        final double newXX =
            xx.value + _xviFile!.grid.gx.value - stationPosition.x;
        final double newYY =
            yy.value + _xviFile!.grid.gy.value - stationPosition.y;

        xx = xx.copyWith(value: newXX);
        yy = yy.copyWith(value: newYY);
        xviRoot = '';

        break;
      }
    }
  }
}
