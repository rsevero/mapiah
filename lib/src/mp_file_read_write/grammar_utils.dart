// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:petitparser/petitparser.dart';

/// Shared grammar utilities and token parsers used by PetitParser grammars.
class GrammarUtils {
  /// Case-insensitive string matcher.
  static Parser stringIgnoreCase(String s) {
    return string(s, ignoreCase: true);
  }

  /// Whitespace parser matching one or more spaces and tabs.
  static Parser thWhitespace() {
    return anyOf(mpWhitespaceChars).plus();
  }

  /// Optional whitespace parser matching zero or more spaces and tabs.
  static Parser thWhitespaceOptional() {
    return anyOf(mpWhitespaceChars).star();
  }

  /// Quoted string parser matching "..." with "" escaping.
  static Parser quotedString() {
    return (char(mpDoubleQuote) &
            (char(mpDoubleQuote).skip(before: char(mpDoubleQuote)) |
                    noneOf(mpDoubleQuote))
                .star()
                .flatten() &
            char(mpDoubleQuote))
        .pick(1);
  }

  /// Unquoted string parser matching non-whitespace, non-double-quote characters.
  static Parser unquotedString() {
    return noneOf('$mpWhitespaceChars$mpDoubleQuote').plus().flatten();
  }

  /// Bracket string parser with template content.
  static Parser bracketStringTemplate(Parser content) {
    return (char('[') & content & char(']')).pick(1);
  }

  /// General bracket string parser matching [...].
  static Parser bracketStringGeneral() {
    return bracketStringTemplate(noneOf('[]').star().flatten());
  }

  /// Any string parser matching quoted, bracketed, or unquoted strings.
  static Parser anyString() {
    return quotedString() |
        bracketStringGeneral() |
        unquotedString();
  }

  /// General number parser matching signed/unsigned integers and floating-point numbers.
  static Parser number() {
    return (pattern('-+').optional() &
            digit().plus() &
            (char('.') & digit().plus()).optional())
        .flatten();
  }

  /// Positive number parser matching +123 or +123.45 with explicit plus.
  static Parser plusNumber() {
    return (char('+') &
            digit().plus() &
            (char('.') & digit().plus()).optional())
        .flatten();
  }

  /// Negative number parser matching -123 or -123.45.
  static Parser minusNumber() {
    return (char('-') &
            digit().plus() &
            (char('.') & digit().plus()).optional())
        .flatten();
  }

  /// Comment parser template.
  static Parser commentTemplate(String commentType) {
    return (char(mpCommentChar) & any().star()).flatten().trim().map(
      (dynamic value) => [commentType, (value as String).trim()],
    );
  }

  /// Full line comment parser.
  static Parser fullLineComment() {
    return commentTemplate('fulllinecomment').map((dynamic value) => [value]);
  }

  /// End-of-line comment parser.
  static Parser endLineComment() {
    return commentTemplate('samelinecomment');
  }
}
