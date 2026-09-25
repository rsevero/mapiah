// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'th_command_option.dart';

/// One background sketch and its lower left corner in scrap coordinates.
class THSketchSpec {
  final THStringPart filename;
  final THPositionPart point;

  THSketchSpec({required String filename, required this.point})
    : filename = THStringPart(content: filename);

  Map<String, dynamic> toMap() => {
    'filename': filename.toMap(),
    'point': point.toMap(),
  };

  factory THSketchSpec.fromMap(Map<String, dynamic> map) => THSketchSpec(
    filename: map['filename']['content'],
    point: THPositionPart.fromMap(map['point']),
  );

  String specToFile() => '${filename.toString()} ${point.toString()}';

  @override
  bool operator ==(Object other) =>
      other is THSketchSpec &&
      other.filename == filename &&
      other.point == point;

  @override
  int get hashCode => Object.hash(filename, point);
}

/// The ordered set of `-sketch` options on one scrap.
class THSketchCommandOption extends THCommandOption {
  final List<THSketchSpec> sketches;

  THSketchCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required String filename,
    required THPositionPart point,
    List<THSketchSpec> additionalSketches = const [],
  }) : sketches = List.unmodifiable([
         THSketchSpec(filename: filename, point: point),
         ...additionalSketches,
       ]),
       super.forCWJM();

  THSketchCommandOption.fromString({
    required super.parentMPID,
    required String filename,
    required List<dynamic> pointList,
    super.originalLineInTH2File = '',
  }) : sketches = List.unmodifiable([
         THSketchSpec(
           filename: filename,
           point: THPositionPart.fromStringList(list: pointList),
         ),
       ]),
       super();

  THSketchCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required String filename,
    required List<String> pointList,
    super.originalLineInTH2File = '',
  }) : sketches = List.unmodifiable([
         THSketchSpec(
           filename: filename,
           point: THPositionPart.fromStringList(list: pointList),
         ),
       ]),
       super.forCWJM();

  THSketchCommandOption._withSketches({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required List<THSketchSpec> sketches,
  }) : assert(sketches.isNotEmpty),
       sketches = List.unmodifiable(sketches),
       super.forCWJM();

  @override
  THCommandOptionType get type => THCommandOptionType.sketch;

  String get filename => sketches.first.filename.content;
  THPositionPart get point => sketches.first.point;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = super.toMap();

    map.addAll({
      'filename': sketches.first.filename.toMap(),
      'point': sketches.first.point.toMap(),
      'additionalSketches': sketches.skip(1).map((spec) => spec.toMap()).toList(),
    });

    return map;
  }

  factory THSketchCommandOption.fromMap(Map<String, dynamic> map) {
    final List<dynamic> additional = map['additionalSketches'] ?? [];

    return THSketchCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      filename: map['filename']['content'],
      point: THPositionPart.fromMap(map['point']),
      additionalSketches: additional
          .map((dynamic item) => THSketchSpec.fromMap(item))
          .toList(),
    );
  }

  factory THSketchCommandOption.fromJson(String jsonString) =>
      THSketchCommandOption.fromMap(jsonDecode(jsonString));

  @override
  THSketchCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    String? filename,
    THPositionPart? point,
    List<THSketchSpec>? sketches,
  }) {
    final List<THSketchSpec> copiedSketches = sketches ?? [
      THSketchSpec(
        filename: filename ?? this.filename,
        point: point ?? this.point,
      ),
      ...this.sketches.skip(1),
    ];

    return THSketchCommandOption._withSketches(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      sketches: copiedSketches,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is THSketchCommandOption &&
      super.equalsBase(other) &&
      const ListEquality<THSketchSpec>().equals(other.sketches, sketches);

  @override
  int get hashCode =>
      super.hashCode ^ const ListEquality<THSketchSpec>().hash(sketches);

  @override
  String specToFile() => sketches
      .map((THSketchSpec sketch) => sketch.specToFile())
      .join(' -sketch ');
}
