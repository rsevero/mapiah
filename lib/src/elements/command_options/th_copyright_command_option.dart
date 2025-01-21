import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';

// copyright <date> <string> . copyright date and name
class THCopyrightCommandOption extends THCommandOption {
  late final THDatetimePart datetime;
  final String copyrightMessage;

  /// Constructor necessary for dart_mappable support.
  THCopyrightCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.datetime,
    required this.copyrightMessage,
  }) : super.forCWJM();

  THCopyrightCommandOption({
    required super.optionParent,
    required this.datetime,
    required this.copyrightMessage,
  }) : super();

  THCopyrightCommandOption.fromString({
    required super.optionParent,
    required String datetime,
    required this.copyrightMessage,
  }) : super() {
    this.datetime = THDatetimePart.fromString(datetime: datetime);
  }

  @override
  THCommandOptionType get optionType => THCommandOptionType.copyright;

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'datetime': datetime.toMap(),
      'copyrightMessage': copyrightMessage,
    };
  }

  factory THCopyrightCommandOption.fromMap(Map<String, dynamic> map) {
    return THCopyrightCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      datetime: THDatetimePart.fromMap(map['datetime']),
      copyrightMessage: map['copyrightMessage'],
    );
  }

  factory THCopyrightCommandOption.fromJson(String jsonString) {
    return THCopyrightCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THCopyrightCommandOption copyWith({
    int? parentMapiahID,
    THDatetimePart? datetime,
    String? copyrightMessage,
  }) {
    return THCopyrightCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      datetime: datetime ?? this.datetime,
      copyrightMessage: copyrightMessage ?? this.copyrightMessage,
    );
  }

  @override
  bool operator ==(covariant THCopyrightCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.datetime == datetime &&
        other.copyrightMessage == copyrightMessage;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        datetime,
        copyrightMessage,
      );

  @override
  String specToFile() {
    return '$datetime $copyrightMessage';
  }
}
