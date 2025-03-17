part of 'th_command_option.dart';

// date: -value <date> sets the date for the date point.
class THDateValueCommandOption extends THCommandOption {
  late final THDatetimePart date;

  THDateValueCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.date,
  }) : super.forCWJM();

  THDateValueCommandOption.fromString({
    required super.optionParent,
    required String date,
    super.originalLineInTH2File = '',
  }) : super() {
    this.date = THDatetimePart.fromString(datetime: date);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.dateValue;

  @override
  String typeToFile() => 'value';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'date': date.toMap(),
    });

    return map;
  }

  factory THDateValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THDateValueCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      date: THDatetimePart.fromMap(map['date']),
    );
  }

  factory THDateValueCommandOption.fromJson(String jsonString) {
    return THDateValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THDateValueCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THDatetimePart? date,
  }) {
    return THDateValueCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(covariant THDateValueCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.date == date;
  }

  @override
  int get hashCode => super.hashCode ^ date.hashCode;

  @override
  String specToFile() {
    return date.toString();
  }
}
