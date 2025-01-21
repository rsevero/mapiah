import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';

// copyright <date> <string> . copyright date and name
class THCopyrightCommandOption extends THCommandOption {
  static const String _thisOptionType = 'copyright';
  late final THDatetimePart datetime;
  final String copyrightMessage;

  /// Constructor necessary for dart_mappable support.
  THCopyrightCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.datetime,
    required this.copyrightMessage,
  }) : super();

  THCopyrightCommandOption.addToOptionParent({
    required super.optionParent,
    required this.datetime,
    required this.copyrightMessage,
  }) : super.addToOptionParent(optionType: _thisOptionType);

  THCopyrightCommandOption.fromString({
    required super.optionParent,
    required String datetime,
    required this.copyrightMessage,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    this.datetime = THDatetimePart.fromString(datetime: datetime);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
      'datetime': datetime.toMap(),
      'copyrightMessage': copyrightMessage,
    };
  }

  factory THCopyrightCommandOption.fromMap(Map<String, dynamic> map) {
    return THCopyrightCommandOption(
      parentMapiahID: map['parentMapiahID'],
      optionType: map['optionType'],
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
    String? optionType,
    THDatetimePart? datetime,
    String? copyrightMessage,
  }) {
    return THCopyrightCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      datetime: datetime ?? this.datetime,
      copyrightMessage: copyrightMessage ?? this.copyrightMessage,
    );
  }

  @override
  bool operator ==(covariant THCopyrightCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType &&
        other.datetime == datetime &&
        other.copyrightMessage == copyrightMessage;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
        datetime,
        copyrightMessage,
      );

  @override
  String specToFile() {
    return '$datetime $copyrightMessage';
  }
}
