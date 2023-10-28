import 'package:petitparser/petitparser.dart';

import 'package:mapiah/src/th_definitions.dart';

/// .th file grammar.
class THGrammar extends GrammarDefinition {
  @override
  Parser start() => th2Structure().end();

  /// TH2 Structure
  Parser th2Structure() => encoding() | th2Command() | fullLineComment();
  Parser th2Command() => scrap() | endscrap();

  /// Whitespace
  Parser thWhitespace() => anyOf(' \t').plus();

  /// Quoted string
  ///
  /// TODO: The convertion of two double quotes in one will be done after grammar
  /// parsing.
  Parser quotedString() => (char(thQuote) &
          (char(thQuote).skip(before: char(thQuote)) | pattern('^$thQuote'))
              .star()
              .flatten() &
          char(thQuote))
      .pick(1);

  /// Bracket string
  Parser bracketStringTemplate(content) =>
      (char('[').trim(ref0(thWhitespace), ref0(thWhitespace)) &
              content &
              char(']').trim(ref0(thWhitespace), ref0(thWhitespace)))
          .pick(1);
  Parser bracketStringGeneral() =>
      bracketStringTemplate(pattern('^]').star().flatten());

  /// Number
  Parser number() => (pattern('-+').optional() &
          digit().plus() &
          (char('.') & digit().plus()).optional())
      .flatten()
      .trim(ref0(thWhitespace), ref0(thWhitespace));

  /// Comment
  Parser commentTemplate(commentType) => ((char(thCommentChar) & any().star())
      .flatten()
      .trim(ref0(thWhitespace), ref0(thWhitespace))
      .map((value) => [commentType, value.trim()]));
  Parser fullLineComment() =>
      commentTemplate('fulllinecomment').map((value) => [value]);
  Parser endLineComment() => commentTemplate('samelinecomment');

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

  /// Comma separated list of keywords
  Parser csvKeyword() => (keyword() & (char(',') & keyword()).star())
      .flatten()
      .trim(ref0(thWhitespace), ref0(thWhitespace));

  /// Command template
  Parser commandTemplate(command) =>
      ref0(command) & ref0(endLineComment).optional();

  /// encoding
  Parser encodingStartChar() => pattern('A-Za-z');
  Parser encodingNonStartChar() => (ref0(keywordStartChar) | pattern('0-9-'));
  Parser encodingName() =>
      (ref0(encodingStartChar) & ref0(encodingNonStartChar).star())
          .flatten()
          .trim(ref0(thWhitespace), ref0(thWhitespace))
          .map((value) => value.toUpperCase());
  Parser encodingCommand() => stringIgnoreCase('encoding') & ref0(encodingName);
  Parser encoding() => ref1(commandTemplate, encodingCommand);

  /// TODO: input
  /// TODO: survey
  /// TODO: centreline

  /// Scrap
  Parser scrap() => ref1(commandTemplate, scrapCommand);
  Parser scrapCommand() => scrapRequired() & scrapOptions();
  Parser scrapRequired() => stringIgnoreCase('scrap') & ref0(keyword);
  Parser scrapOptions() =>
      csOption().optional() &
      projectionOption().optional() &
      scaleOption().optional() &
      stationsOption().optional();

  /// CS Option
  Parser csOption() =>
      stringIgnoreCase('cs').skip(before: char('-')) & ref0(csSpec);
  Parser csSpecs() =>
      (csUtm() | csStrings() | csJtsk() | csEpsgEsri() | csEtrs() | csOsgb())
          .trim(ref0(thWhitespace), ref0(thWhitespace));
  Parser csSpec() => csSpecs().map((value) => [value]);
  Parser csUtm() => (string('UTM') &
          ((pattern('1-6') & digit()) | digit()) &
          pattern('NS').optional())
      .flatten();
  Parser csStrings() =>
      (string('lat-long') | string('long-lat') | string('S-MERC')).flatten();
  Parser csJtsk() =>
      (char('i').optional() & string('JTSK') & string('03').optional())
          .flatten();
  Parser csEpsgEsri() =>
      ((string('EPSG') | string('ESRI')) & char(':') & digit().plus())
          .flatten();
  Parser csEtrs() => (string('ETRS') &
          ((char('2') & pattern('89')) | (char('3') & pattern('0-7')))
              .optional())
      .flatten();
  Parser csOsgb() =>
      (string('OSGB:') & pattern('HNOST') & pattern('A-HJ-Z')).flatten();

  /// Projection Option
  Parser projectionSpec() =>
      // type: none
      ((stringIgnoreCase('none') &
                  ((char(':') & ref0(keyword)).pick(1)).optional()) |

              // type: plan with optional index
              ((stringIgnoreCase('plan') &
                  ((char(':') & ref0(keyword)).pick(1)).optional())) |

              // type: elevation with optional index
              ((stringIgnoreCase('elevation') &
                  ((char(':') & ref0(keyword)).pick(1)).optional())) |

              // type: elevation with view direction
              (char('[') &
                      (stringIgnoreCase('elevation') &
                          ((char(':') & ref0(keyword)).pick(1)).optional() &
                          ref0(number) &
                          angleUnit().optional()) &
                      char(']'))
                  .pick(1) |

              // type: extended with optional index
              (stringIgnoreCase('extended') &
                  ((char(':') & ref0(keyword)).pick(1)).optional()))
          .trim(ref0(thWhitespace), ref0(thWhitespace));
  Parser projectionOption() =>
      stringIgnoreCase('projection').skip(before: char('-')) &
      ref0(projectionSpec);

  /// Scale option
  Parser scaleOption() =>
      stringIgnoreCase('scale').skip(before: char('-')) & ref0(scaleSpec);
  Parser scaleSpec() =>
      ref0(number).map((value) => [value]) |
      bracketStringTemplate(scaleNumber());
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

  /// -stations
  Parser stationsOption() =>
      stringIgnoreCase('stations').skip(before: char('-')) &
      ref0(csvKeyword).map((value) => [value]);

  /// Endscrap
  Parser endscrap() => ref1(commandTemplate, endscrapCommand);
  Parser endscrapCommand() =>
      stringIgnoreCase('endscrap').map((value) => [value]);
}
