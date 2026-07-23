// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:ui';

/// The desktop window state restored when Mapiah starts.
class MPWindowPlacement {
  static const String maximizedSettingValue = 'maximized';
  static const String _leftKey = 'left';
  static const String _topKey = 'top';
  static const String _widthKey = 'width';
  static const String _heightKey = 'height';

  final bool isMaximized;
  final Rect? bounds;

  const MPWindowPlacement.maximized()
    : isMaximized = true,
      bounds = null;

  MPWindowPlacement.windowed({required Rect this.bounds})
    : isMaximized = false,
      assert(bounds.isFinite, 'Window bounds must be finite'),
      assert(bounds.width > 0, 'Window width must be positive'),
      assert(bounds.height > 0, 'Window height must be positive');

  /// Parses a persisted placement, returning null for malformed values.
  static MPWindowPlacement? tryParse(String value) {
    if (value == maximizedSettingValue) {
      return const MPWindowPlacement.maximized();
    }

    try {
      final Object? decoded = jsonDecode(value);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final Object? left = decoded[_leftKey];
      final Object? top = decoded[_topKey];
      final Object? width = decoded[_widthKey];
      final Object? height = decoded[_heightKey];

      if ((left is! num) ||
          (top is! num) ||
          (width is! num) ||
          (height is! num)) {
        return null;
      }

      final Rect bounds = Rect.fromLTWH(
        left.toDouble(),
        top.toDouble(),
        width.toDouble(),
        height.toDouble(),
      );

      if (!bounds.isFinite || (bounds.width <= 0) || (bounds.height <= 0)) {
        return null;
      }

      return MPWindowPlacement.windowed(bounds: bounds);
    } on FormatException {
      return null;
    }
  }

  /// Serializes this placement for the internal settings store.
  String toSettingValue() {
    if (isMaximized) {
      return maximizedSettingValue;
    }

    final Rect windowBounds = bounds!;

    return jsonEncode(<String, double>{
      _leftKey: windowBounds.left,
      _topKey: windowBounds.top,
      _widthKey: windowBounds.width,
      _heightKey: windowBounds.height,
    });
  }
}
