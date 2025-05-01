part of 'th_command_option.dart';

// mark <keyword> . is used to mark the point on the line (see join command).
class THMarkCommandOption extends THCommandOption {
  late final String mark;

  THMarkCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.mark,
  }) : super.forCWJM();

  THMarkCommandOption({
    required super.optionParent,
    required this.mark,
    super.originalLineInTH2File = '',
  }) : super();

  THMarkCommandOption.fromStringWithParentMPID({
    required super.parentMPID,
    required this.mark,
    super.originalLineInTH2File = '',
  }) : super.forCWJM();

  @override
  THCommandOptionType get type => THCommandOptionType.mark;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'mark': mark,
    });

    return map;
  }

  factory THMarkCommandOption.fromMap(Map<String, dynamic> map) {
    return THMarkCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      mark: map['mark'],
    );
  }

  factory THMarkCommandOption.fromJson(String jsonString) {
    return THMarkCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THMarkCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    String? mark,
  }) {
    return THMarkCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      mark: mark ?? this.mark,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THMarkCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.mark == mark;
  }

  @override
  int get hashCode => super.hashCode ^ mark.hashCode;

  // set mark(String aMark) {
  //   if (!thKeywordRegex.hasMatch(aMark)) {
  //     throw THCustomException(
  //         "Invalid mark '$aMark'. A mark must be a keyword.");
  //   }
  //   _mark = aMark;
  // }

  @override
  String specToFile() {
    return mark;
  }
}
