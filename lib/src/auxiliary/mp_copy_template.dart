// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_element.dart';

/// Lightweight, JSON-serializable snapshot of a single THElement.
///
/// Uses the existing THElement.toMap() / THElement.fromMap() serialization.
/// Preserves original MPID and parentMPID for later reference during paste.
class MPCopyTemplate {
  /// Element data from element.toMap() with originalLineInTH2File cleared.
  final Map<String, dynamic> elementMap;

  MPCopyTemplate({required this.elementMap});

  /// Create a template from a live THElement.
  factory MPCopyTemplate.fromElement(THElement element) {
    final Map<String, dynamic> map = element.toMap();

    // Clear the originalLineInTH2File to avoid issues during paste
    map['originalLineInTH2File'] = '';

    return MPCopyTemplate(elementMap: map);
  }

  /// Get the element type from the serialized data.
  String? get elementType => elementMap['type'] as String?;

  /// Get the original MPID from the serialized data.
  int? get originalMPID => elementMap['mpID'] as int?;

  /// Get the original parent MPID from the serialized data.
  int? get originalParentMPID => elementMap['parentMPID'] as int?;

  /// Serialize to JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {'elementMap': elementMap};
  }

  /// Deserialize from JSON-compatible map.
  factory MPCopyTemplate.fromMap(Map<String, dynamic> map) {
    return MPCopyTemplate(
      elementMap: Map<String, dynamic>.from(map['elementMap'] as Map),
    );
  }
}
