// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// Therion object id rules (thbook, "keyword" and "ext keyword"; Therion's
/// `th_is_extkeyword` and `thparse_objectname`).
class THIDAux {
  /// Characters an ext_keyword accepts at any position.
  static final RegExp _anyPositionCharacter = RegExp(r'[A-Za-z0-9_/-]');

  /// Characters an ext_keyword accepts after its first character.
  static final RegExp _laterPositionCharacter = RegExp(r"[A-Za-z0-9_/\-'*+,.]");

  /// Rewrites [value] into a valid Therion ext_keyword, replacing every
  /// character it does not accept at its position with `_`. A valid id is
  /// returned unchanged.
  static String toExtKeyword(String value) {
    final StringBuffer buffer = StringBuffer();

    for (int index = 0; index < value.length; index++) {
      final String character = value[index];
      final RegExp accepted = (index == 0)
          ? _anyPositionCharacter
          : _laterPositionCharacter;

      buffer.write(accepted.hasMatch(character) ? character : '_');
    }

    return buffer.toString();
  }

  /// The object-name part of a Therion reference `name@survey`, or the whole
  /// [reference] when it has no survey part.
  static String objectNamePart(String reference) {
    final int surveySeparatorIndex = reference.indexOf('@');

    return (surveySeparatorIndex < 0)
        ? reference
        : reference.substring(0, surveySeparatorIndex);
  }
}
