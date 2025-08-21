part of 'th_command_option.dart';

// text . text of the label, remark or continuation. It may contain following
// formatting keywords:
//
// * <br> . line break
// * <center>/<centre>, <left>, <right> . line alignment for multi-line labels.
// Ignored if there is no <br> tag.
// * <thsp> . thin space
// * <rm>, <it>, <bf>, <ss>, <si> . font switches
// * <rtl> and </rtl> . marks beginning and end of a right-to-left written text
// * <lang:XX> . creates multilingual label (see string type for detailed
// description)
// * <size:N> . specify the font size in points; N should be an integer between
// 1 and 127.
// * <size:N%> . specify the font size as a percentage of the native font size
// of the given label; N should be between 1 and 999.25
// * <size:S> . specify the font size using predefined scales; S can be one of
// xs, s, m, l, xl.
class THTextCommandOption extends THCommandOption {
  final THStringPart text;

  // static final Map<String, Set<String>> _supportedTypes = {
  //   'point': {
  //     'label',
  //     'remark',
  //     'continuation',
  //   },
  //   'line': {
  //     'label',
  //   },
  // };

  THTextCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.text,
  }) : super.forCWJM();

  THTextCommandOption({
    required super.optionParent,
    required String textContent,
    super.originalLineInTH2File = '',
  }) : text = THStringPart(content: textContent),
       super();

  @override
  THCommandOptionType get type => THCommandOptionType.text;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({'text': text.toMap()});

    return map;
  }

  factory THTextCommandOption.fromMap(Map<String, dynamic> map) {
    return THTextCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      text: THStringPart.fromMap(map['text']),
    );
  }

  factory THTextCommandOption.fromJson(String jsonString) {
    return THTextCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THTextCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THStringPart? text,
  }) {
    return THTextCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      text: text ?? this.text,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THTextCommandOption) return false;
    if (!super.equalsBase(other)) return false;

    return other.text == text;
  }

  @override
  int get hashCode => super.hashCode ^ text.hashCode;

  @override
  String specToFile() {
    return text.toString();
  }
}
