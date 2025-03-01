part of 'th_command_option.dart';

// id <ext_keyword> . ID of the symbol.
class THIDCommandOption extends THCommandOption {
  late final String thID;

  THIDCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.thID,
  }) : super.forCWJM();

  THIDCommandOption({
    required super.optionParent,
    required this.thID,
    super.originalLineInTH2File = '',
  }) : super(); // TODO: call thFile.addElementWithTHID for the parent of this option. Was done with: optionParent.thFile.addElementWithTHID(optionParent, thID);

  @override
  THCommandOptionType get type => THCommandOptionType.id;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'thID': thID,
    });

    return map;
  }

  factory THIDCommandOption.fromMap(Map<String, dynamic> map) {
    return THIDCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      thID: map['thID'],
    );
  }

  factory THIDCommandOption.fromJson(String jsonString) {
    return THIDCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THIDCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    String? thID,
  }) {
    return THIDCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      thID: thID ?? this.thID,
    );
  }

  @override
  bool operator ==(covariant THIDCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.thID == thID;
  }

  @override
  int get hashCode => super.hashCode ^ thID.hashCode;

  @override
  String specToFile() {
    return thID;
  }
}
