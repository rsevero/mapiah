part of 'th_command_option.dart';

// copyright <date> <string> . copyright date and name
class THCopyrightCommandOption extends THCommandOption {
  late final THDatetimePart datetime;
  final THStringPart copyright;

  /// Constructor necessary for dart_mappable support.
  THCopyrightCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.datetime,
    required this.copyright,
  }) : super.forCWJM();

  THCopyrightCommandOption({
    required super.optionParent,
    required this.datetime,
    required String copyrightMessage,
    super.originalLineInTH2File = '',
  })  : copyright = THStringPart(content: copyrightMessage),
        super();

  THCopyrightCommandOption.fromString({
    required super.optionParent,
    required String datetime,
    required String copyrightMessage,
    super.originalLineInTH2File = '',
  })  : copyright = THStringPart(content: copyrightMessage),
        super() {
    this.datetime = THDatetimePart.fromString(datetime: datetime);
  }

  @override
  THCommandOptionType get type => THCommandOptionType.copyright;

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'datetime': datetime.toMap(),
      'copyright': copyright.toMap(),
    });

    return map;
  }

  factory THCopyrightCommandOption.fromMap(Map<String, dynamic> map) {
    return THCopyrightCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      datetime: THDatetimePart.fromMap(map['datetime']),
      copyright: THStringPart.fromMap(map['copyrightMessage']),
    );
  }

  factory THCopyrightCommandOption.fromJson(String jsonString) {
    return THCopyrightCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THCopyrightCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THDatetimePart? datetime,
    THStringPart? copyright,
  }) {
    return THCopyrightCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      datetime: datetime ?? this.datetime,
      copyright: copyright ?? this.copyright,
    );
  }

  @override
  bool operator ==(covariant THCopyrightCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.datetime == datetime &&
        other.copyright == copyright;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        datetime,
        copyright,
      );

  @override
  String specToFile() {
    return '$datetime ${copyright.toString()}';
  }
}
