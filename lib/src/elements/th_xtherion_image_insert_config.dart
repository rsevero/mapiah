part of 'th_element.dart';

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
    super.originalLineInTH2File = '',
  })  : xx = THDoublePart.fromString(valueString: xx),
        vsb = THDoublePart.fromString(valueString: vsb),
        igamma = THDoublePart.fromString(valueString: igamma),
        yy = THDoublePart.fromString(valueString: yy),
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
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is THXTherionImageInsertConfig &&
        super == other &&
        filename == other.filename &&
        xx == other.xx &&
        vsb == other.vsb &&
        igamma == other.igamma &&
        yy == other.yy &&
        xviRoot == other.xviRoot &&
        iidx == other.iidx &&
        imgx == other.imgx &&
        xData == other.xData &&
        xImage == other.xImage;
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
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
      );

  @override
  bool isSameClass(Object object) {
    return object is THXTherionImageInsertConfig;
  }
}
