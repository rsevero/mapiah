import 'dart:convert';

abstract class THPart {
  String toJson() {
    return jsonEncode(toMap());
  }

  Map<String, dynamic> toMap();

  THPart copyWith();
}
