part of 'th_command_option.dart';

// title <string> . description of the object
class THTitleCommandOption extends THCommandOption {
  final THStringPart title;

  THTitleCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.title,
  }) : super.forCWJM();

  THTitleCommandOption({
    required super.optionParent,
    required String titleText,
    super.originalLineInTH2File = '',
  }) : title = THStringPart(content: titleText),
       super();

  @override
  THCommandOptionType get type => THCommandOptionType.title;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'title': title.toMap()});

    return map;
  }

  factory THTitleCommandOption.fromMap(Map<String, dynamic> map) {
    return THTitleCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      title: THStringPart.fromMap(map['title']),
    );
  }

  factory THTitleCommandOption.fromJson(String jsonString) {
    return THTitleCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THTitleCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THStringPart? title,
  }) {
    return THTitleCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      title: title ?? this.title,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THTitleCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.title == title;
  }

  @override
  int get hashCode => super.hashCode ^ title.hashCode;

  @override
  String specToFile() {
    return title.toString();
  }
}
