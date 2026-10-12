// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';
import 'package:charset/charset.dart';

/// Encodes and decodes Therion file contents by the encoding name written in
/// the file (`encoding <name>`). Readers and writers share it, so a file is
/// always written with the same encoding it is read with.
class MPEncodingAux {
  /// Therion ISO charset names have no hyphen after "ISO" (`ISO8859-2`), but
  /// charset.dart expects one (`ISO-8859-2`).
  static final RegExp _therionISONameRegex = RegExp(
    r'^iso([^_-].*)$',
    caseSensitive: false,
  );

  /// The encoding for a Therion encoding name, or `null` when there is none.
  static Encoding? encodingByTherionName(String encodingName) {
    final String normalizedName = encodingName.toUpperCase();

    switch (normalizedName) {
      case 'UTF-8':
        return utf8;
      case 'ASCII':
        return ascii;
      case 'ISO8859-1':
      case 'ISO-8859-1':
        return latin1;
    }

    final RegExpMatch? isoMatch = _therionISONameRegex.firstMatch(
      normalizedName,
    );
    final String charsetName = (isoMatch == null)
        ? normalizedName
        : 'ISO-${isoMatch.group(1)}';

    return Charset.getByName(charsetName);
  }

  /// Decodes [bytes] with [encodingName], or as UTF-8 when the name is
  /// unknown.
  static String decode(List<int> bytes, String encodingName) {
    final Encoding encoding = encodingByTherionName(encodingName) ?? utf8;

    return encoding.decode(bytes);
  }

  /// Encodes [text] with [encodingName], or as UTF-8 when the name is
  /// unknown.
  static Uint8List encode(String text, String encodingName) {
    final Encoding encoding = encodingByTherionName(encodingName) ?? utf8;

    return Uint8List.fromList(encoding.encode(text));
  }
}
