part of 'th_command_option.dart';

// scrap <reference> . if the point type is section, this is a reference to a cross-section
// scrap.
class THScrapCommandOption extends THCommandOption {
  late final String reference;

  THScrapCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.reference,
  }) : super.forCWJM();

  THScrapCommandOption({
    required super.optionParent,
    required this.reference,
    super.originalLineInTH2File = '',
  }) : super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.scrap;

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'reference': reference,
    };
  }

  factory THScrapCommandOption.fromMap(Map<String, dynamic> map) {
    return THScrapCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      reference: map['reference'],
    );
  }

  factory THScrapCommandOption.fromJson(String jsonString) {
    return THScrapCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THScrapCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    String? reference,
  }) {
    return THScrapCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      reference: reference ?? this.reference,
    );
  }

  @override
  bool operator ==(covariant THScrapCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        reference,
      );

  @override
  String specToFile() {
    return reference;
  }
}
