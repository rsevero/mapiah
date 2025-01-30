part of 'th_command_option.dart';

// id <ext_keyword> . ID of the symbol.
class THIDCommandOption extends THCommandOption {
  late final String thID;

  THIDCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.thID,
  }) : super.forCWJM();

  THIDCommandOption({
    required super.optionParent,
    required this.thID,
    super.originalLineInTH2File = '',
  }) : super(); // TODO: call thFile.addElementWithTHID for the parent of this option. Was done with: optionParent.thFile.addElementWithTHID(optionParent, thID);

  @override
  THCommandOptionType get optionType => THCommandOptionType.id;

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'thID': thID,
    };
  }

  factory THIDCommandOption.fromMap(Map<String, dynamic> map) {
    return THIDCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      thID: map['thID'],
    );
  }

  factory THIDCommandOption.fromJson(String jsonString) {
    return THIDCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THIDCommandOption copyWith({
    int? parentMapiahID,
    String? thID,
  }) {
    return THIDCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      thID: thID ?? this.thID,
    );
  }

  @override
  bool operator ==(covariant THIDCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID && other.thID == thID;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        thID,
      );

  @override
  String specToFile() {
    return thID;
  }
}
