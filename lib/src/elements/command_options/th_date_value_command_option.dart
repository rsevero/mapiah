part of 'th_command_option.dart';

// date: -value <date> sets the date for the date point.
class THDateValueCommandOption extends THCommandOption {
  late final THDatetimePart date;

  THDateValueCommandOption.forCWJM({
    required super.parentMapiahID,
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
  THCommandOptionType get optionType => THCommandOptionType.dateValue;

  @override
  String typeToFile() => 'value';

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'date': date.toMap(),
    };
  }

  factory THDateValueCommandOption.fromMap(Map<String, dynamic> map) {
    return THDateValueCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      date: THDatetimePart.fromMap(map['date']),
    );
  }

  factory THDateValueCommandOption.fromJson(String jsonString) {
    return THDateValueCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THDateValueCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THDatetimePart? date,
  }) {
    return THDateValueCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(covariant THDateValueCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID && other.date == date;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        date,
      );

  @override
  String specToFile() {
    return date.toString();
  }
}
