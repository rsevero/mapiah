import 'dart:convert';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';

// name <reference> . if the point type is station, this option gives the reference to the
// real survey station.
class THNameCommandOption extends THCommandOption {
  late final String reference;

  THNameCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.reference,
  }) : super.forCWJM();

  THNameCommandOption({
    required super.optionParent,
    required this.reference,
  }) : super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.name;

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'reference': reference,
    };
  }

  factory THNameCommandOption.fromMap(Map<String, dynamic> map) {
    return THNameCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      reference: map['reference'],
    );
  }

  factory THNameCommandOption.fromJson(String jsonString) {
    return THNameCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THNameCommandOption copyWith({
    int? parentMapiahID,
    String? reference,
  }) {
    return THNameCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      reference: reference ?? this.reference,
    );
  }

  @override
  bool operator ==(covariant THNameCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.reference == reference;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        reference,
      );

  @override
  String specToFile() {
    return reference;
  }
}
