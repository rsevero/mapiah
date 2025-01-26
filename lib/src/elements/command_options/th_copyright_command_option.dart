part of 'th_command_option.dart';

// copyright <date> <string> . copyright date and name
class THCopyrightCommandOption extends THCommandOption {
  late final THDatetimePart datetime;
  final THStringPart copyright;

  /// Constructor necessary for dart_mappable support.
  THCopyrightCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.datetime,
    required this.copyright,
  }) : super.forCWJM();

  THCopyrightCommandOption({
    required super.optionParent,
    required this.datetime,
    required String copyrightMessage,
  })  : copyright = THStringPart(content: copyrightMessage),
        super();

  THCopyrightCommandOption.fromString({
    required super.optionParent,
    required String datetime,
    required String copyrightMessage,
  })  : copyright = THStringPart(content: copyrightMessage),
        super() {
    this.datetime = THDatetimePart.fromString(datetime: datetime);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.copyright;

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'datetime': datetime.toMap(),
      'copyright': copyright.toMap(),
    };
  }

  factory THCopyrightCommandOption.fromMap(Map<String, dynamic> map) {
    return THCopyrightCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      datetime: THDatetimePart.fromMap(map['datetime']),
      copyright: THStringPart.fromMap(map['copyrightMessage']),
    );
  }

  factory THCopyrightCommandOption.fromJson(String jsonString) {
    return THCopyrightCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THCopyrightCommandOption copyWith({
    int? parentMapiahID,
    THDatetimePart? datetime,
    THStringPart? copyright,
  }) {
    return THCopyrightCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      datetime: datetime ?? this.datetime,
      copyright: copyright ?? this.copyright,
    );
  }

  @override
  bool operator ==(covariant THCopyrightCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.datetime == datetime &&
        other.copyright == copyright;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        datetime,
        copyright,
      );

  @override
  String specToFile() {
    return '$datetime ${copyright.toString()}';
  }
}
