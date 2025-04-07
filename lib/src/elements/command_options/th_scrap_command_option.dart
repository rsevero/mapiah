part of 'th_command_option.dart';

// scrap <reference> . if the point type is section, this is a reference to a
// cross-section scrap.
class THScrapCommandOption extends THCommandOption {
  late final String reference;

  THScrapCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.reference,
  }) : super.forCWJM();

  THScrapCommandOption({
    required super.optionParent,
    required this.reference,
    super.originalLineInTH2File = '',
  }) : super();

  @override
  THCommandOptionType get type => THCommandOptionType.scrap;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'reference': reference,
    });

    return map;
  }

  factory THScrapCommandOption.fromMap(Map<String, dynamic> map) {
    return THScrapCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      reference: map['reference'],
    );
  }

  factory THScrapCommandOption.fromJson(String jsonString) {
    return THScrapCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THScrapCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    String? reference,
  }) {
    return THScrapCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      reference: reference ?? this.reference,
    );
  }

  @override
  bool operator ==(covariant THScrapCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.reference == reference;
  }

  @override
  int get hashCode => super.hashCode ^ reference.hashCode;

  @override
  String specToFile() {
    return reference;
  }
}
