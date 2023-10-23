import 'package:petitparser/petitparser.dart';

/// .th file grammar.
class THGrammar extends GrammarDefinition {
  @override
  Parser start() => keyword().end();

  /// Whitespace
  Parser thWhitespace() => (string('\\\n') | whitespace()).plus();

  /// Keyword
  Parser keywordStartChar() => pattern('A-Za-z0-9_/');
  Parser keywordNonStartChar() => (ref0(keywordStartChar) | char('-'));
  Parser keyword() =>
      (ref0(keywordStartChar) & ref0(keywordNonStartChar).star())
          .flatten()
          .trim(ref0(thWhitespace), ref0(thWhitespace));

  /// Extkeyword
  Parser extKeywordNonStartChar() =>
      (ref0(keywordNonStartChar) | pattern("+*.,'"));
  Parser extKeyword() =>
      (ref0(keywordStartChar) & ref0(extKeywordNonStartChar).star())
          .flatten()
          .trim(ref0(thWhitespace), ref0(thWhitespace));

  /// Date
  Parser year() => digit().repeat(2, 4).flatten();
  Parser twoDigits() => digit().repeat(1, 2).flatten();
  Parser dotTwoDigits() => char('.').seq(ref0(twoDigits)).pick(1);
  Parser atTwoDigits() => char('@').seq(ref0(twoDigits)).pick(1);
  Parser colonTwoDigits() => char(':').seq(ref0(twoDigits)).pick(1);
  Parser noDateTime() =>
      char('-').flatten().trim(ref0(thWhitespace), ref0(thWhitespace));
  Parser singleDateTime() =>
      // Year
      (ref0(year) &
              // Month: optional
              (ref0(dotTwoDigits) &
                      // Day: optional
                      (ref0(dotTwoDigits) &
                              // Hour: optional
                              (ref0(atTwoDigits) &
                                      // Minutes: optional
                                      (ref0(colonTwoDigits) &
                                              // Seconds: optional
                                              (ref0(colonTwoDigits) &
                                                      // Fractional seconds: optional
                                                      (ref0(dotTwoDigits)
                                                              .optional())
                                                          .optional())
                                                  .optional())
                                          .optional())
                                  .optional())
                          .optional())
                  .optional())
          .trim(ref0(thWhitespace), ref0(thWhitespace));
  Parser dateTimeRange() =>
      ref0(singleDateTime) &
      (char('-')
          .trim(ref0(thWhitespace), ref0(thWhitespace))
          .seq(
              ref0(singleDateTime).trim(ref0(thWhitespace), ref0(thWhitespace)))
          .pick(1));
  Parser dateTime() => noDateTime() | dateTimeRange() | singleDateTime();

  /// Person
  Parser aString() => (char('"') &
          (char('"').skip(before: char('"')) | pattern('^"')).star().flatten() &
          char('"'))
      .pick(1);
}
