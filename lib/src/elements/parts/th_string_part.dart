import 'dart:convert';

import 'package:mapiah/src/definitions/th_definitions.dart';
import 'package:mapiah/src/elements/parts/th_part.dart';

class THStringPart extends THPart {
  final String content;

  THStringPart({this.content = ''});

  @override
  THPartType get type => THPartType.string;

  static final _quoteRegex = RegExp(thDoubleQuote);

  @override
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'partType': type.name,
    };
  }

  factory THStringPart.fromMap(Map<String, dynamic> map) {
    return THStringPart(
      content: map['content'] ?? '',
    );
  }

  factory THStringPart.fromJson(String jsonString) {
    return THStringPart.fromMap(jsonDecode(jsonString));
  }

  @override
  THStringPart copyWith({
    String? content,
  }) {
    return THStringPart(
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(covariant THStringPart other) {
    if (identical(this, other)) return true;

    return other.content == content;
  }

  @override
  int get hashCode => content.hashCode;

  @override
  String toString() {
    String asString = content;

    if (content.isEmpty) {
      asString = r'""';
    } else if ((content.contains(' ')) || (content.contains(thDoubleQuote))) {
      asString = asString.replaceAll(_quoteRegex, thDoubleQuotePair);
      asString = '"$asString"';
    }

    return asString;
  }
}
