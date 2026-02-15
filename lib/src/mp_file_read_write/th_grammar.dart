import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/mp_file_read_write/grammar_utils.dart';
import 'package:petitparser/petitparser.dart';

/// .th file grammar.
class THGrammar extends GrammarDefinition {
  /// Indicates whether the last normalization step altered the original value.
  bool changedValue = false;

  @override
  Parser start() => thFileStart().star();

  // .th file
  Parser thFileStart() => th2Structure().end();

  // scrap contents
  Parser scrapStart() => scrapStructure().end();

  // line contents
  Parser lineStart() => lineStructure().end();

  // area contents
  Parser areaStart() => areaStructure().end();

  // multiline commment
  Parser multiLineCommentStart() =>
      endMultiLineComment() | multiLineCommentLine();

  /// TH2 Structure
  Parser th2FileFirstLineStart() => (encoding() | th2Structure()).end();
  Parser th2Structure() => xtherionConfig() | th2Command() | fullLineComment();
  Parser th2Command() => multiLineComment() | scrap();

  /// scrap contents
  Parser scrapStructure() =>
      scrapContent() | fullLineComment() | multiLineComment();
  Parser scrapContent() => point() | line() | area() | endscrap();

  /// line contents
  Parser lineStructure() =>
      lineContent() | fullLineComment() | multiLineComment();
  Parser lineContent() =>
      bezierCurveLineSegment() |
      straightLineSegment() |
      lineSegmentOptions() |
      endline();

  /// area contents
  Parser areaStructure() =>
      areaContent() | fullLineComment() | multiLineComment();
  Parser areaContent() =>
      endarea() | areaCommandLikeOptions() | borderLineReference();

  /// Whitespace
  Parser thWhitespace() => anyOf(thWhitespaceChars).plus();

  /// Quoted string
  ///
  /// No convertion of two double quotes in one being done, i.e., the user will
  /// see each double quote (") being represented by a pair of double quotes ("").
  Parser quotedString() =>
      (char(thDoubleQuote) &
              (char(thDoubleQuote).skip(before: char(thDoubleQuote)) |
                      noneOf(thDoubleQuote))
                  .star()
                  .flatten() &
              char(thDoubleQuote))
          .pick(1);

  /// Unquoted string
  Parser unquotedString() => noneOf('$thWhitespaceChars$thDoubleQuote').plus();

  /// Alphanumeric chars
  Parser alphanumericChars() => pattern('A-Za-z0-9').plus();

  /// Delegate to the shared case-insensitive matcher in [GrammarUtils].
  Parser stringIgnoreCase(String s) => GrammarUtils.stringIgnoreCase(s);

  /// Any string
  Parser anyString() =>
      quotedString().trim() |
      bracketStringGeneral().trim() |
      unquotedString().flatten().trim();

  /// Bracket string
  Parser bracketStringTemplate(Parser content) =>
      (char('[') & content & char(']')).pick(1);
  Parser bracketStringGeneral() =>
      bracketStringTemplate(noneOf('[]').star().flatten());

  /// Number
  Parser number() =>
      (pattern('-+').optional() &
              digit().plus() &
              (char('.') & digit().plus()).optional())
          .flatten();
  Parser numberWithSuffix(Parser something) =>
      (pattern('-+').optional() &
              digit().plus() &
              (char('.') & digit().plus()).optional() &
              something)
          .flatten();
  Parser plusNumber() =>
      (char('+') & digit().plus() & (char('.') & digit().plus()).optional())
          .flatten();
  Parser minusNumber() =>
      (char('-') & digit().plus() & (char('.') & digit().plus()).optional())
          .flatten();

  /// NaN
  Parser nan() => (pattern('-.') | stringIgnoreCase('NaN'));

  /// point data
  Parser pointData() => number()
      .timesSeparated(anyOf('$thWhitespaceChars$thDoubleQuote').plus(), 2)
      .trim()
      .map((value) => value.elements);

  /// comment
  Parser commentTemplate(String commentType) =>
      ((char(thCommentChar) & any().star()).flatten().trim().map(
        (value) => [commentType, value.trim()],
      ));
  Parser fullLineComment() =>
      commentTemplate('fulllinecomment').map((value) => [value]);
  Parser endLineComment() => commentTemplate('samelinecomment');

  /// keyword
  Parser keywordStartChar() => pattern('A-Za-z0-9_/');
  Parser keywordNonStartChar() => (keywordStartChar() | char('-'));
  Parser keyword() =>
      (keywordStartChar() & keywordNonStartChar().star()).flatten().trim();

  /// extkeyword
  Parser extKeywordNonStartChar() => (keywordNonStartChar() | pattern("+*.,'"));
  Parser extKeyword() =>
      (keywordStartChar() & extKeywordNonStartChar().star()).flatten().trim();

  /// reference
  Parser referenceNonStartChar() => (extKeywordNonStartChar() | char('@'));
  Parser reference() =>
      referenceFreeString() |
      (keywordStartChar() & referenceNonStartChar().star()).flatten().trim();

  /// date
  Parser year() => digit().repeat(4, 4);
  Parser twoDigits() => digit().repeat(2, 2);
  Parser dotTwoDigits() => char('.') & twoDigits();
  Parser atTwoDigits() => char('@') & twoDigits();
  Parser colonTwoDigits() => char(':') & twoDigits();
  Parser noDateTime() => char('-').trim();
  Parser singleDateTime() => singleDateTimeBase().flatten().trim();
  Parser singleDateTimeBase() =>
      /// Year
      (year() &
      /// Month: optional
      (dotTwoDigits() &
              /// Day: optional
              (dotTwoDigits() &
                      /// Hour: optional
                      (atTwoDigits() &
                              /// Minutes: optional
                              (colonTwoDigits() &
                                      /// Seconds: optional
                                      (colonTwoDigits() &
                                              /// Fractional seconds: optional
                                              (dotTwoDigits().optional())
                                                  .optional())
                                          .optional())
                                  .optional())
                          .optional())
                  .optional())
          .optional());
  Parser dateTimeRange() =>
      (singleDateTimeBase() & char('-').trim() & singleDateTimeBase());
  Parser dateTimeAllVariations() =>
      dateTimeRange().flatten().trim() | singleDateTime() | noDateTime();
  Parser dateTimeNoNoDateTime() =>
      dateTimeRange().flatten().trim() | singleDateTime();

  /// person
  Parser person() =>
      quotedString().trim() |
      bracketStringGeneral().trim() |
      unquotedString()
          .timesSeparated(anyOf('$thWhitespaceChars$thDoubleQuote').plus(), 2)
          .flatten()
          .trim();

  /// length unit
  Parser lengthUnit() =>
      (
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
          .trim();

  /// angle units
  Parser angleUnit() =>
      (
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
          .trim();

  /// clino units
  Parser clinoUnit() =>
      angleUnit() |
      (stringIgnoreCase('percent') & stringIgnoreCase('age').optional())
          .flatten()
          .trim();

  /// comma separated list of keywords
  Parser csvKeyword() =>
      (keyword() & (char(',') & keyword()).star()).flatten().trim();

  /// on/off options;
  Parser onOffOptions() => (stringIgnoreCase('on') | stringIgnoreCase('off'))
      .trim()
      .map((value) => [value]);

  /// on/off/auto options;
  Parser onOffAutoOptions() =>
      (stringIgnoreCase('on') |
              stringIgnoreCase('off') |
              stringIgnoreCase('auto'))
          .trim()
          .map((value) => [value]);

  /// begin/end/both/none options;
  Parser beginEndBothNoneOptions() =>
      stringIgnoreCase('begin') |
      stringIgnoreCase('end') |
      stringIgnoreCase('both') |
      stringIgnoreCase('none');

  /// Command template
  Parser commandTemplate(Parser Function() command) =>
      ref0(command).trim() & endLineComment().optional();

  /// multiline comment
  Parser multiLineComment() => ref1(commandTemplate, multiLineCommentCommand);
  Parser multiLineCommentCommand() =>
      stringIgnoreCase('comment').map((value) => ['multilinecomment']);
  Parser multiLineCommentLine() => any().star().flatten().map(
    (value) => [
      ['multilinecommentline', value],
    ],
  );
  Parser endMultiLineComment() =>
      ref1(commandTemplate, endMultiLineCommentCommand);
  Parser endMultiLineCommentCommand() =>
      stringIgnoreCase('endcomment').map((value) => ['endmultilinecomment']);

  final Parser endWithTrailingSpaces = (whitespace().star() & endOfInput())
      .and();

  final Parser optionMarkerLookahead =
      (whitespace().plus() & char('-') & pattern('A-Za-z').repeat(2)).and();

  /// ID value that may contain spaces until the next option marker (" -XX")
  /// or end-of-line. Keeps interior spaces, trims the ends.
  Parser idFreeString() => _idFreeStringTemplate().map((value) => value);

  Parser _idFreeStringTemplate() {
    return any()
        .starLazy(optionMarkerLookahead | endWithTrailingSpaces)
        .flatten()
        .trim()
        .where(
          (value) =>
              value.isNotEmpty &&
              !value.startsWith('-') &&
              !value.startsWith('"'),
          message: 'Value cannot be empty or start with - or "',
        )
        .map((value) {
          final String normalized = value.replaceAll(
            RegExp(r'[^A-Za-z0-9/-]'),
            '_',
          );
          final bool wasChanged = normalized != value;

          if (wasChanged) {
            changedValue = true;
          }

          return wasChanged ? [normalized, wasChanged] : [normalized];
        });
  }

  /// Reference value that may contain spaces until the next option marker
  /// (" -XX") or end-of-line. Keeps interior spaces, trims the ends.
  Parser referenceFreeString() {
    return any()
        .starLazy(optionMarkerLookahead | endWithTrailingSpaces)
        .flatten()
        .trim()
        .where(
          (value) =>
              value.isNotEmpty &&
              !value.startsWith('-') &&
              !value.startsWith('"'),
          message: 'Value cannot be empty or start with - or "',
        )
        .map((value) {
          final String normalized = value.replaceAll(
            RegExp(r'[^A-Za-z0-9./@-]'),
            '_',
          );
          final bool wasChanged = normalized != value;

          if (wasChanged) {
            changedValue = true;
          }

          return wasChanged ? [normalized, wasChanged] : normalized;
        });
  }

  /// encoding
  Parser encodingStartChar() => pattern('A-Za-z');
  Parser encodingNonStartChar() => (keywordStartChar() | pattern('0-9-'));
  Parser encodingName() => (encodingStartChar() & encodingNonStartChar().star())
      .flatten()
      .trim()
      .map((value) => value.toUpperCase());
  Parser encodingCommand() => stringIgnoreCase('encoding') & encodingName();
  Parser encoding() => ref1(commandTemplate, encodingCommand);

  /// TODO: input
  /// TODO: survey
  /// TODO: centreline

  /// scrap
  Parser scrap() => ref1(commandTemplate, scrapCommand);
  Parser scrapCommand() => scrapRequired() & scrapOptions();
  Parser scrapRequired() =>
      stringIgnoreCase('scrap') &
      (reference() | extKeyword().map((value) => [value, false]));
  Parser scrapOptions() =>
      (attrOption() |
              authorOption() |
              copyrightOption() |
              csOption() |
              flipOption() |
              projectionOption() |
              scrapScaleOption() |
              sketchOption() |
              stationNamesOption() |
              stationsOption() |
              titleOption() |
              wallsOption())
          .skip(before: char('-'))
          .star();

  /// scrap -author
  Parser authorOption() => stringIgnoreCase('author') & authorOptions();
  Parser authorOptions() => dateTimeAllVariations() & person();

  /// scrap -copyright
  Parser copyrightOption() =>
      stringIgnoreCase('copyright') & copyrightOptions();
  Parser copyrightOptions() => dateTimeAllVariations() & anyString();

  /// scrap -cs
  Parser csOption() => stringIgnoreCase('cs') & csSpec();
  Parser csSpec() => csSpecs().map((value) => [value]);

  Parser csSpecs() =>
      (csUtm() | csStrings() | csJtsk() | csEpsgEsri() | csEtrs() | csOsgb())
          .trim();
  Parser csUtm() =>
      (string('UTM') &
              ((pattern('1-6') & digit()) | digit()) &
              pattern('NS').optional())
          .flatten();
  Parser csStrings() =>
      (string('lat-long') | string('long-lat') | string('S-MERC'));
  Parser csJtsk() =>
      (char('i').optional() & string('JTSK') & string('03').optional())
          .flatten();
  Parser csEpsgEsri() =>
      ((string('EPSG') | string('ESRI')) & char(':') & digit().plus())
          .flatten();
  Parser csEtrs() =>
      (string('ETRS') &
              ((char('2') & pattern('89')) | (char('3') & pattern('0-7')))
                  .optional())
          .flatten();
  Parser csOsgb() =>
      (string('OSGB:') & pattern('HNOST') & pattern('A-HJ-Z')).flatten();

  /// scrap -flip
  Parser flipOption() =>
      stringIgnoreCase('flip') & flipOptions().map((value) => [value]);
  Parser flipOptions() =>
      (stringIgnoreCase('none') |
              stringIgnoreCase('horizontal') |
              stringIgnoreCase('vertical'))
          .trim();

  /// scrap -projection
  Parser projectionSpec() =>
      // type: none
      ((stringIgnoreCase('none') &
                  ((char(':') & keyword()).pick(1)).optional().map(
                    (value) => value == null ? {} : {'index': value},
                  )) |
              // type: plan with optional index
              (stringIgnoreCase('plan') &
                  ((char(':') & keyword()).pick(1)).optional().map(
                    (value) => value == null ? {} : {'index': value},
                  )) |
              // type: elevation with optional index without view direction
              (stringIgnoreCase('elevation') &
                  ((char(':') & keyword()).pick(1)).optional().map(
                    (value) => value == null ? {} : {'index': value},
                  )) |
              // type: elevation with view direction
              (bracketStringTemplate(
                stringIgnoreCase('elevation') &
                    ((char(':') & keyword()).pick(
                      1,
                    )).optional() & // index (optional)
                    number().trim() & // angle
                    angleUnit().optional(), // angle unit (optional)
              ).map((list) {
                // list structure BEFORE this map:
                // ['elevation', indexOrNull, angle, angleUnitOrNull]
                final Map<String, dynamic> map = <String, dynamic>{
                  'index': list[1],
                  'angle': list[2],
                  'angle_unit': list[3],
                }..removeWhere((k, v) => v == null);

                return ['elevation', map];
              })) |
              // type: extended with optional index
              (stringIgnoreCase('extended') &
                  ((char(':') & keyword()).pick(1)).optional().map(
                    (value) => value == null ? {} : {'index': value},
                  )))
          .trim();
  Parser projectionOption() =>
      stringIgnoreCase('projection') & projectionSpec();

  /// scrap -scale
  Parser scrapScaleOption() => stringIgnoreCase('scale') & scrapScaleSpec();
  Parser scrapScaleSpec() =>
      number().trim().map((value) => [value]) |
      bracketStringTemplate(scrapScaleNumber()).trim();
  Parser scrapScaleNumber() =>
      (number().trim() &
          number().trim() &
          number().trim() &
          number().trim() &
          number().trim() &
          number().trim() &
          number().trim() &
          number().trim() &
          lengthUnit().optional()) |
      (number().trim() & number().trim() & lengthUnit()) |
      (number().trim() & lengthUnit().optional());

  /// scrap -sketch
  Parser sketchOption() => stringIgnoreCase('sketch') & sketchSpec();
  Parser sketchSpec() => (anyString() & pointData()).trim();

  /// scrap -station-names
  Parser stationNamesOption() =>
      stringIgnoreCase('station-names') & stationNamesSpec();
  Parser stationNamesSpec() =>
      ((string('[]') | pattern('^[] \t').plus()).flatten().trim()).repeat(2, 2);

  /// scrap -stations
  Parser stationsOption() =>
      stringIgnoreCase('stations') & csvKeyword().map((value) => [value]);

  /// scrap -title
  Parser titleOption() => stringIgnoreCase('title') & titleOptions();
  Parser titleOptions() => anyString().map((value) => [value]);

  /// scrap -walls
  Parser wallsOption() => stringIgnoreCase('walls') & onOffAutoOptions();

  /// Endscrap
  Parser endscrap() => ref1(commandTemplate, endscrapCommand);
  Parser endscrapCommand() =>
      stringIgnoreCase('endscrap').map((value) => [value]);

  /// point
  Parser point() => ref1(commandTemplate, pointCommand);
  Parser pointCommand() => pointRequired() & pointOptions();
  Parser pointRequired() => stringIgnoreCase('point') & pointData() & plaType();
  Parser plaType() =>
      (keyword() & (char(':') & keyword()).pick(1).optional()).trim();
  Parser pointOptions() =>
      (alignOption() |
              attrOption() |
              clipOption() |
              contextOption() |
              distOption() |
              idOption() |
              exploredOption() |
              extendOption() |
              fromOption() |
              nameOption() |
              orientationOption() |
              placeOption() |
              plScaleOption() |
              scrapOption() |
              subtypeOption() |
              textOption() |
              valueOption() |
              visibilityOption())
          .skip(before: char('-'))
          .star();

  /// point -align
  Parser alignOption() => stringIgnoreCase('align') & alignOptions();
  Parser alignOptions() =>
      (stringIgnoreCase('bottom-left') |
              stringIgnoreCase('bottom-right') |
              stringIgnoreCase('bottom') |
              stringIgnoreCase('bl') |
              stringIgnoreCase('br') |
              stringIgnoreCase('b') |
              stringIgnoreCase('center') |
              stringIgnoreCase('c') |
              stringIgnoreCase('left') |
              stringIgnoreCase('l') |
              stringIgnoreCase('right') |
              stringIgnoreCase('r') |
              stringIgnoreCase('top-left') |
              stringIgnoreCase('top-right') |
              stringIgnoreCase('top') |
              stringIgnoreCase('tl') |
              stringIgnoreCase('tr') |
              stringIgnoreCase('t'))
          .trim()
          .map((value) => [value]);

  /// point, line, area, scrap -attr
  Parser attrOption() => stringIgnoreCase('attr') & attrOptions();
  Parser attrOptions() =>
      alphanumericChars().flatten().trim() & anyString().trim();

  /// point -clip
  Parser clipOption() => stringIgnoreCase('clip') & onOffOptions();
  Parser clipCommandLikeOption() => clipOption();

  /// point -context
  Parser contextOption() => stringIgnoreCase('context') & contextOptions();
  Parser contextCommandLikeOption() => contextOption();
  Parser contextOptions() => (keyword() & keyword()).trim();

  /// point -dist
  Parser distOption() => stringIgnoreCase('dist') & distOptions();
  Parser distOptions() =>
      (number().trim().map((value) => [value]) |
              bracketStringTemplate(number() & lengthUnit()))
          .trim();

  /// point -explored
  Parser exploredOption() => stringIgnoreCase('explored') & exploredOptions();
  Parser exploredOptions() =>
      (number().trim().map((value) => [value]) |
              bracketStringTemplate(number() & lengthUnit()))
          .trim();

  /// point -extend
  Parser extendOption() => stringIgnoreCase('extend') & extendOptions();
  Parser extendOptions() =>
      ((stringIgnoreCase('prev') & stringIgnoreCase('ious').optional())
                  .flatten() &
              reference())
          .pick(1)
          .optional()
          .trim()
          .map((value) => [value]);

  /// point/line -id
  Parser idOption() => stringIgnoreCase('id') & idOptions();
  Parser idCommandLikeOption() => idOption();
  Parser idOptions() =>
      idFreeString() | extKeyword().trim().map((value) => [value, false]);

  /// point -from
  Parser fromOption() => stringIgnoreCase('from') & fromOptions();
  Parser fromOptions() => extKeyword().trim().map((value) => [value]);

  /// point -name
  Parser nameOption() => stringIgnoreCase('name') & nameOptions();
  Parser nameOptions() =>
      quotedString().trim().map((value) => [value]) |
      reference().trim().map((value) => [value]);

  /// point -orientation
  Parser orientationOption() =>
      (stringIgnoreCase('orientation') | stringIgnoreCase('orient')).map(
        (value) => 'orientation',
      ) &
      orientationOptions();
  Parser orientationCommandLikeOption() => orientationOption();
  Parser orientationOptions() => number().trim().map((value) => [value]);

  /// point/line/area -place
  Parser placeOption() => stringIgnoreCase('place') & placeOptions();
  Parser placeCommandLikeOption() => placeOption();
  Parser placeOptions() =>
      (stringIgnoreCase('bottom') |
              stringIgnoreCase('default') |
              stringIgnoreCase('top'))
          .trim()
          .map((value) => [value]);

  /// point/line -scale
  Parser plScaleOption() => stringIgnoreCase('scale') & plScaleOptions();
  Parser lineScaleCommandLikeOption() => plScaleOption();
  Parser plScaleOptions() =>
      (stringIgnoreCase('tiny') |
              stringIgnoreCase('xs') |
              stringIgnoreCase('small') |
              stringIgnoreCase('s') |
              stringIgnoreCase('normal') |
              stringIgnoreCase('m') |
              stringIgnoreCase('large') |
              stringIgnoreCase('l') |
              stringIgnoreCase('huge') |
              stringIgnoreCase('xl'))
          .trim()
          .map((value) => ['multiplechoice', value]) |
      number().trim().map((value) => ['numeric', value]);

  /// point -scrap
  Parser scrapOption() => stringIgnoreCase('scrap') & scrapOptionOptions();
  Parser scrapOptionOptions() =>
      (quotedString().trim() | unquotedString().flatten().trim()).map(
        (value) => [value],
      );

  /// point/line -subtype
  Parser subtypeOption() => stringIgnoreCase('subtype') & subtypeOptions();
  Parser subtypeCommandLikeOption() => subtypeOption();
  Parser subtypeOptions() =>
      unquotedString().flatten().trim().map((value) => [value]);

  /// point/line -text
  Parser textOption() => stringIgnoreCase('text') & textOptions();
  Parser textCommandLikeOption() => textOption();
  Parser textOptions() => anyString().map((value) => [value]);

  /// point -value
  Parser valueOption() => stringIgnoreCase('value') & valueOptions();
  Parser valueOptions() =>
      (quotedString().trim() |
              bracketStringGeneral().trim() |
              unquotedString().flatten().trim())
          .map((value) => [value]);

  /// point -visibility
  Parser visibilityOption() => stringIgnoreCase('visibility') & onOffOptions();
  Parser visibilityCommandLikeOption() => visibilityOption();

  /// line
  Parser line() => ref1(commandTemplate, lineCommand);
  Parser lineCommand() => lineRequired() & lineOptions();
  Parser lineRequired() => stringIgnoreCase('line') & plaType();
  Parser lineOptions() =>
      (anchorsOption() |
              attrOption() |
              borderOption() |
              clipOption() |
              closeOption() |
              contextOption() |
              directionOption() |
              gradientOption() |
              headOption() |
              heightOption() |
              idOption() |
              outlineOption() |
              placeOption() |
              rebelaysOption() |
              reverseOption() |
              plScaleOption() |
              subtypeOption() |
              textOption() |
              visibilityOption())
          .skip(before: char('-'))
          .star();

  /// endline
  Parser endline() => ref1(commandTemplate, endlineCommand);
  Parser endlineCommand() =>
      stringIgnoreCase('endline').map((value) => [value]);

  /// line segment options
  Parser lineSegmentOptions() =>
      ((adjustCommandLikeOption() |
                  altitudeCommandLikeOption() |
                  anchorsCommandLikeOption() |
                  borderCommandLikeOption() |
                  clipCommandLikeOption() |
                  closeCommandLikeOption() |
                  contextCommandLikeOption() |
                  directionCommandLikeOption() |
                  gradientCommandLikeOption() |
                  headCommandLikeOption() |
                  heightCommandLikeOption() |
                  idCommandLikeOption() |
                  lineScaleCommandLikeOption() |
                  lsizeCommandLikeOption() |
                  markCommandLikeOption() |
                  orientationCommandLikeOption() |
                  outlineCommandLikeOption() |
                  placeCommandLikeOption() |
                  rebelaysCommandLikeOption() |
                  reverseCommandLikeOption() |
                  smoothCommandLikeOption() |
                  subtypeCommandLikeOption() |
                  textCommandLikeOption() |
                  visibilityCommandLikeOption())
              .trim())
          .map(
            (value) => [
              'linecommandlikeoption',
              [value],
            ],
          ) &
      endLineComment().optional();

  /// straightLineSegment
  Parser straightLineSegment() =>
      ref1(commandTemplate, straightLineSegmentCommand);
  Parser straightLineSegmentCommand() => pointData()
      .trim()
      .map((value) => ['endpoint', value])
      .map((value) => ['straightlinesegment', value]);

  /// bezierCurve
  Parser bezierCurveLineSegment() =>
      ref1(commandTemplate, bezierCurveLineSegmentCommand);
  Parser bezierCurveLineSegmentCommand() =>
      (pointData().trim().map((value) => ['controlpoint1', value]) &
              pointData().trim().map((value) => ['controlpoint2', value]) &
              pointData().trim().map((value) => ['endpoint', value]))
          .map((value) => ['beziercurvelinesegment', value]);

  /// line -adjust
  Parser adjustCommandLikeOption() =>
      stringIgnoreCase('adjust') & adjustOptions();
  Parser adjustOptions() =>
      (stringIgnoreCase('horizontal') | stringIgnoreCase('vertical'))
          .trim()
          .map((value) => [value]);

  /// line -altitude
  Parser altitudeCommandLikeOption() =>
      stringIgnoreCase('altitude') & valueOptions();
  Parser altitudeOptions() =>
      (quotedString().trim() |
              bracketStringGeneral().trim() |
              unquotedString().flatten().trim())
          .map((value) => [value]);

  /// line -anchors
  Parser anchorsOption() => stringIgnoreCase('anchors') & onOffOptions();
  Parser anchorsCommandLikeOption() => anchorsOption();

  /// line -border
  Parser borderOption() => stringIgnoreCase('border') & onOffOptions();
  Parser borderCommandLikeOption() => borderOption();

  /// line -close
  Parser closeOption() => stringIgnoreCase('close') & onOffAutoOptions();
  Parser closeCommandLikeOption() => closeOption();

  /// line -direction
  Parser directionOption() =>
      stringIgnoreCase('direction') & directionOptions();
  Parser directionOptions() =>
      beginEndBothNoneOptions().trim().map((value) => [value]);
  Parser directionCommandLikeOption() =>
      stringIgnoreCase('direction') & directionLineSegmentOptions();
  Parser directionLineSegmentOptions() =>
      (beginEndBothNoneOptions() | stringIgnoreCase('point')).trim().map(
        (value) => [value],
      );

  /// line -gradient
  Parser gradientOption() => stringIgnoreCase('gradient') & gradientOptions();
  Parser gradientGeneralOptions() =>
      stringIgnoreCase('none') | stringIgnoreCase('center');
  Parser gradientOptions() =>
      gradientGeneralOptions().trim().map((value) => [value]);
  Parser gradientCommandLikeOption() =>
      stringIgnoreCase('gradient') & gradientLineSegmentOptions();
  Parser gradientLineSegmentOptions() =>
      (beginEndBothNoneOptions() | stringIgnoreCase('point')).trim().map(
        (value) => [value],
      );

  /// line -head
  Parser headOption() => stringIgnoreCase('head') & headOptions();
  Parser headCommandLikeOption() => headOption();
  Parser headOptions() =>
      beginEndBothNoneOptions().trim().map((value) => [value]);

  /// line -height
  Parser heightOption() => stringIgnoreCase('height') & heightOptions();
  Parser heightCommandLikeOption() => heightOption();
  Parser heightOptions() => number().trim().map((value) => [value]);

  /// linepoint l-size/size
  Parser lsizeCommandLikeOption() =>
      (stringIgnoreCase('l-size') | stringIgnoreCase('size')).map(
        (value) => 'l-size',
      ) &
      lsizeOptions();
  Parser lsizeOptions() => number().trim().map((value) => [value]);

  /// linepoint -mark
  Parser markCommandLikeOption() => stringIgnoreCase('mark') & markOptions();
  Parser markOptions() => keyword().map((value) => [value]);

  /// line -outline
  Parser outlineOption() => stringIgnoreCase('outline') & outlineOptions();
  Parser outlineCommandLikeOption() => outlineOption();
  Parser outlineOptions() =>
      (stringIgnoreCase('in') |
              stringIgnoreCase('out') |
              stringIgnoreCase('none'))
          .trim()
          .map((value) => [value]);

  /// line -rebelays
  Parser rebelaysOption() => stringIgnoreCase('rebelays') & onOffOptions();
  Parser rebelaysCommandLikeOption() => rebelaysOption();

  /// line -reverse
  Parser reverseOption() => stringIgnoreCase('reverse') & onOffOptions();
  Parser reverseCommandLikeOption() => reverseOption();

  /// line -smooth
  Parser smoothCommandLikeOption() =>
      stringIgnoreCase('smooth') & onOffAutoOptions();

  /// area
  Parser area() => ref1(commandTemplate, areaCommand);
  Parser areaCommand() => areaRequired() & areaOptions();
  Parser areaRequired() => stringIgnoreCase('area') & plaType();
  Parser areaOptions() =>
      (attrOption() |
              clipOption() |
              contextOption() |
              idOption() |
              placeOption() |
              visibilityOption())
          .skip(before: char('-'))
          .star();
  Parser areaCommandLikeOptions() =>
      (clipCommandLikeOption() |
              contextCommandLikeOption() |
              idCommandLikeOption() |
              placeCommandLikeOption() |
              visibilityCommandLikeOption())
          .map(
            (value) => [
              'areaCommandLikeOption',
              [value],
            ],
          ) &
      endLineComment().optional();

  /// area border reference
  Parser borderLineReference() =>
      ref1(commandTemplate, borderLineReferenceCommand);
  Parser borderLineReferenceCommand() =>
      reference().end().map((value) => ['areaborderthid', value]);

  /// endarea
  Parser endarea() => ref1(commandTemplate, endareaCommand);
  Parser endareaCommand() =>
      stringIgnoreCase('endarea').map((value) => [value]);

  /// xtherion config
  Parser xtherionConfig() =>
      (stringIgnoreCase(xTherionConfigID).trim() &
              (keyword() & any().plus().flatten().trim()))
          .map((value) => [value]);
}
