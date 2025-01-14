import 'dart:ui';

import 'package:dart_mappable/dart_mappable.dart';

class OffsetMapper extends SimpleMapper<Offset> {
  const OffsetMapper();

  @override
  Offset decode(dynamic value) {
    final RegExp regExp = RegExp(r'Offset\s*\(\s*([\d.]+)\s*,\s*([\d.]+)\s*\)');
    final Match? match = regExp.firstMatch(value);

    if (match != null) {
      final double dx = double.parse(match.group(1)!);
      final double dy = double.parse(match.group(2)!);
      return Offset(dx, dy);
    } else {
      throw FormatException('Invalid Offset format');
    }
  }

  @override
  dynamic encode(Offset self) {
    return self.toString();
  }
}
