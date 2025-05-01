part of 'th_command_option.dart';

// date: -value <date> sets the date for the date point.
class THDateValueCommandOption extends THCommandOption {
  late final THDatetimePart datetime;

  THDateValueCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.datetime,
  }) : super.forCWJM();

  THDateValueCommandOption.fromString({
    required super.optionParent,
    required String datetime,
    super.originalLineInTH2File = '',
  }) : super() {
    this.datetime = THDatetimePart.fromString(datetime: datetime);
  }

  THDateValueCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required String datetime,
    super.originalLineInTH2File = '',
  }) : super.forCWJM() {
    this.datetime = THDatetimePart.fromString(datetime: datetime);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.dateValue;

  @override
  String typeToFile() => 'value';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'datetime': datetime.toMap(),
    });

    return map;
  }

  factory THDateValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THDateValueCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      datetime: THDatetimePart.fromMap(map['datetime']),
    );
  }

  factory THDateValueCommandOption.fromJson(String jsonString) {
    return THDateValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THDateValueCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THDatetimePart? datetime,
  }) {
    return THDateValueCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      datetime: datetime ?? this.datetime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THDateValueCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.datetime == datetime;
  }

  @override
  int get hashCode => super.hashCode ^ datetime.hashCode;

  @override
  String specToFile() {
    return datetime.toString();
  }
}
