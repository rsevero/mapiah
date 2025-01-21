import 'dart:convert';

import 'package:mapiah/src/auxiliary/th_serializeable.dart';

abstract class THPart implements THSerializable {
  @override
  String toJson() {
    return jsonEncode(toMap());
  }
}
