import 'package:petitparser/petitparser.dart';

import 'package:mapiah/src/th_definitions.dart';

/// .th file grammar.
class THGrammar extends GrammarDefinition {
  @override
  Parser start() => th2Structure().end();

  /// TH2 Structure
  Parser th2Structure() =>
      encodingCommand().optional() & (comment() | th2Command()).star();
  Parser th2Command() => scrapCommand();

  /// Whitespace
  Parser thWhitespace() => (string('\\\n') | whitespace()).plus();
  Parser thWhitespaceNoLineBreak() =>
      (string('\\\n') | (char('\n').not() & whitespace())).plus();

  /// Quoted string
  ///
  /// TODO: The convertion of two double quotes in one will be done after grammar
  /// parsing.
  Parser quotedString() => (char('"') &
          (char('"').skip(before: char('"')) | pattern('^"')).star().flatten() &
          char('"'))
      .pick(1);

  /// Bracket string
  Parser bracketStringTemplate(content) =>
      (char('[') & content() & char(']')).pick(1);
  Parser bracketStringGeneral() =>
      bracketStringTemplate(pattern('^]').star().flatten());

  /// Number
  Parser number() =>
      (pattern('-+').optional() & digit().plus() & char('.') & digit().plus())
          .optional()
          .flatten()
          .trim(ref0(thWhitespace), ref0(thWhitespace));

  /// Comment
  Parser comment() => (char(thCommentChar) & pattern('^\n').star())
      .flatten()
      .trim(ref0(thWhitespace), ref0(thWhitespace))
      .map((value) => value.trim());

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
  Parser dotTwoDigits() => (char('.') & ref0(twoDigits)).pick(1);
  Parser atTwoDigits() => (char('@') & ref0(twoDigits)).pick(1);
  Parser colonTwoDigits() => (char(':') & ref0(twoDigits)).pick(1);
  Parser noDateTime() =>
      char('-').flatten().trim(ref0(thWhitespace), ref0(thWhitespace));
  Parser singleDateTime() =>

      /// Year
      (ref0(year) &

              /// Month: optional
              (ref0(dotTwoDigits) &

                      /// Day: optional
                      (ref0(dotTwoDigits) &

                              /// Hour: optional
                              (ref0(atTwoDigits) &

                                      /// Minutes: optional
                                      (ref0(colonTwoDigits) &

                                              /// Seconds: optional
                                              (ref0(colonTwoDigits) &

                                                      /// Fractional seconds: optional
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
      ((char('-').trim(ref0(thWhitespace), ref0(thWhitespace)) &
              ref0(singleDateTime).trim(ref0(thWhitespace), ref0(thWhitespace)))
          .pick(1));
  Parser dateTime() => noDateTime() | dateTimeRange() | singleDateTime();

  /// Person
  ///
  /// TODO: The name/surname separation will be done outside this grammar.
  Parser person() => ref0(quotedString);

  /// Length unit
  Parser lengthUnit() => (

          /// centimeters and meters
          (stringIgnoreCase('centi').optional() &
                  stringIgnoreCase('met') &
                  (stringIgnoreCase('er') | stringIgnoreCase('re')) &
                  stringIgnoreCase('s').optional()) |
              stringIgnoreCase('m') |
              stringIgnoreCase('cm') |

              /// inches
              (stringIgnoreCase('inch') & stringIgnoreCase('es').optional()) |
              stringIgnoreCase('in') |

              /// feet
              (stringIgnoreCase('feet') & stringIgnoreCase('s').optional()) |
              stringIgnoreCase('ft') |

              /// yard
              (stringIgnoreCase('yard') & stringIgnoreCase('s').optional()) |
              stringIgnoreCase('yd'))
      .flatten()
      .trim(ref0(thWhitespace), ref0(thWhitespace));

  /// Angle units
  Parser angleUnit() => (

          /// Degrees
          (stringIgnoreCase('degree') & stringIgnoreCase('s').optional()) |
              stringIgnoreCase('deg') |

              /// Minutes
              (stringIgnoreCase('minute') & stringIgnoreCase('s').optional()) |
              stringIgnoreCase('min') |

              /// Grads
              (stringIgnoreCase('grad') & stringIgnoreCase('s').optional()) |

              /// Mils
              (stringIgnoreCase('mil') & stringIgnoreCase('s').optional()))
      .flatten()
      .trim(ref0(thWhitespace), ref0(thWhitespace));

  /// Clino units
  Parser clinoUnit() =>
      ref0(angleUnit) |
      (stringIgnoreCase('percent') & stringIgnoreCase('age').optional())
          .flatten()
          .trim(ref0(thWhitespace), ref0(thWhitespace));

  /// Command template
  Parser commandTemplate(command) => (command) & ref0(comment).optional();

  /// encoding
  Parser encodingStartChar() => pattern('A-Za-z');
  Parser encodingNonStartChar() => (ref0(keywordStartChar) | pattern('0-9-'));
  Parser encodingName() =>
      (ref0(encodingStartChar) & ref0(encodingNonStartChar).star())
          .flatten()
          .trim(ref0(thWhitespace), ref0(thWhitespace))
          .map((value) => value.toUpperCase());
  Parser encodingCommand() =>
      stringIgnoreCase('encoding') &
      ref0(encodingName) &
      ref0(comment).optional();

  /// TODO: input
  /// TODO: survey
  /// TODO: centreline

  /// Scrap
  Parser scrap() => ref1(commandTemplate, scrapCommand);
  Parser scrapCommand() => scrapRequired() & scrapOptions();
  Parser scrapRequired() => stringIgnoreCase('scrap') & ref0(keyword);
  Parser scrapOptions() => projectionOption() | scaleOption();
  Parser projectionSpecification() =>
      // type: none
      ((stringIgnoreCase('none') |

              // type: plan with optional index
              ((stringIgnoreCase('plan') &
                  ((char(':') & ref0(keyword))).optional())) |

              // type: elevation with optional index
              ((stringIgnoreCase('elevation') &
                  ((char(':') & ref0(keyword))).optional())) |

              // type: elevation with view direction
              (char('[') &
                      (stringIgnoreCase('elevation') &
                          ref0(number) &
                          angleUnit().optional()) &
                      char(']'))
                  .pick(1) |

              // type: extended with optional index
              (stringIgnoreCase('extended') &
                  ((char(':') & ref0(keyword))).optional())))
          .flatten()
          .trim(ref0(thWhitespace), ref0(thWhitespace));
  Parser projectionOption() =>
      stringIgnoreCase('projection') & ref0(projectionSpecification);
  Parser scaleOption() => stringIgnoreCase('scale') & ref0(scaleSpecification);
  Parser scaleSpecification() =>
      ref0(number) | ref1(bracketStringTemplate, scaleNumber);
  Parser scaleNumber() =>
      (ref0(number) & lengthUnit()) |
      (ref0(number) & ref0(number) & lengthUnit()) |
      (ref0(number) &
          ref0(number) &
          ref0(number) &
          ref0(number) &
          ref0(number) &
          ref0(number) &
          ref0(number) &
          ref0(number) &
          lengthUnit().optional());
}
