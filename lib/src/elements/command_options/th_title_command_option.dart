part of 'th_command_option.dart';

// title <string> . description of the object
class THTitleCommandOption extends THCommandOption {
  final THStringPart title;

  THTitleCommandOption.forCWJM({
    required super.parentMapiahID,
    required super.originalLineInTH2File,
    required this.title,
  }) : super.forCWJM();

  THTitleCommandOption({
    required super.optionParent,
    required String titleText,
    super.originalLineInTH2File = '',
  })  : title = THStringPart(content: titleText),
        super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.title;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'title': title.toMap(),
    });

    return map;
  }

  factory THTitleCommandOption.fromMap(Map<String, dynamic> map) {
    return THTitleCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      title: THStringPart.fromMap(map['title']),
    );
  }

  factory THTitleCommandOption.fromJson(String jsonString) {
    return THTitleCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THTitleCommandOption copyWith({
    int? parentMapiahID,
    String? originalLineInTH2File,
    THStringPart? title,
  }) {
    return THTitleCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      title: title ?? this.title,
    );
  }

  @override
  bool operator ==(covariant THTitleCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID && other.title == title;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        title,
      );

  @override
  String specToFile() {
    return title.toString();
  }
}
