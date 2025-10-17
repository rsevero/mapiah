part of 'th_command_option.dart';

// id <ext_keyword> . ID of the symbol.
class THIDCommandOption extends THCommandOption {
  late final String thID;

  THIDCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.thID,
  }) : super.forCWJM();

  THIDCommandOption({
    required super.parentMPID,
    required this.thID,
    super.originalLineInTH2File = '',
  }) : super();

  THIDCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required this.thID,
    super.originalLineInTH2File = '',
  }) : super.forCWJM();

  @override
  THCommandOptionType get type => THCommandOptionType.id;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'thID': thID});

    return map;
  }

  factory THIDCommandOption.fromMap(Map<String, dynamic> map) {
    return THIDCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      thID: map['thID'],
    );
  }

  factory THIDCommandOption.fromJson(String jsonString) {
    return THIDCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THIDCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    String? thID,
  }) {
    return THIDCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      thID: thID ?? this.thID,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THIDCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.thID == thID;
  }

  @override
  int get hashCode => super.hashCode ^ thID.hashCode;

  @override
  String specToFile() {
    return thID;
  }
}
