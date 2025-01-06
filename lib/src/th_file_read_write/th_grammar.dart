import 'package:petitparser/petitparser.dart';

import 'package:mapiah/src/definitions/th_definitions.dart';

/// .th file grammar.
class THGrammar extends GrammarDefinition {
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
  Parser quotedString() => (char(thDoubleQuote) &
          (char(thDoubleQuote).skip(before: char(thDoubleQuote)) |
                  noneOf(thDoubleQuote))
              .star()
              .flatten() &
          char(thDoubleQuote))
      .pick(1);

  /// Unquoted string
  Parser unquotedString() => noneOf('$thWhitespaceChars$thDoubleQuote').plus();

  /// Any string
  Parser anyString() => quotedString() | unquotedString();

  /// Bracket string
  Parser bracketStringTemplate(Parser content) =>
      (char('[') & content.flatten() & char(']')).pick(1);
  Parser bracketStringGeneral() => bracketStringTemplate(noneOf('[]').star());

  /// Number
  Parser number() => (pattern('-+').optional() &
          digit().plus() &
          (char('.') & digit().plus()).optional())
      .flatten()
      .trim();
  Parser numberWithSuffix(something) => (pattern('-+').optional() &
          digit().plus() &
          (char('.') & digit().plus()).optional() &
          something)
      .flatten()
      .trim();
  Parser plusNumber() =>
      (char('+') & digit().plus() & (char('.') & digit().plus()).optional())
          .trim();
  Parser minusNumber() =>
      (char('-') & digit().plus() & (char('.') & digit().plus()).optional())
          .trim();

  /// NaN
  Parser nan() => (pattern('-.') | stringIgnoreCase('NaN'));

  /// point data
  Parser pointData() => number().repeat(2, 2).trim();

  /// comment
  Parser commentTemplate(commentType) => ((char(thCommentChar) & any().star())
      .flatten()
      .trim()
      .map((value) => [commentType, value.trim()]));
  Parser fullLineComment() =>
      commentTemplate('fulllinecomment').map((value) => [value]);
  Parser endLineComment() => commentTemplate('samelinecomment');

  /// keyword
  Parser keywordStartChar() => pattern('A-Za-z0-9_/');
  Parser keywordNonStartChar() => (ref0(keywordStartChar) | char('-'));
  Parser keyword() =>
      (keywordStartChar() & keywordNonStartChar().star()).flatten().trim();

  /// extkeyword
  Parser extKeywordNonStartChar() => (keywordNonStartChar() | pattern("+*.,'"));
  Parser extKeyword() =>
      (keywordStartChar() & extKeywordNonStartChar().star()).flatten().trim();

  /// reference
  Parser referenceNonStartChar() => (extKeywordNonStartChar() | char('@'));
  Parser reference() =>
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
  Parser dateTime() =>
      dateTimeRange().flatten().trim() | singleDateTime() | noDateTime();

  /// person
  Parser person() =>
      unquotedString()
          .timesSeparated(anyOf('$thWhitespaceChars$thDoubleQuote').plus(), 2)
          .flatten()
          .trim() |
      quotedString();

  /// length unit
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
      .trim();

  /// angle units
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
      .trim();

  /// clino units
  Parser clinoUnit() =>
      ref0(angleUnit) |
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
  Parser onOffAutoOptions() => (stringIgnoreCase('on') |
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
  Parser commandTemplate(command) =>
      ref0(command).trim() & ref0(endLineComment).optional();

  /// multiline comment
  Parser multiLineComment() => ref1(commandTemplate, multiLineCommentCommand);
  Parser multiLineCommentCommand() =>
      stringIgnoreCase('comment').map((value) => ['multilinecomment']);
  Parser multiLineCommentLine() => any().star().flatten().map((value) => [
        ['multilinecommentline', value]
      ]);
  Parser endMultiLineComment() =>
      ref1(commandTemplate, endMultiLineCommentCommand);
  Parser endMultiLineCommentCommand() =>
      stringIgnoreCase('endcomment').map((value) => ['endmultilinecomment']);

  /// encoding
  Parser encodingStartChar() => pattern('A-Za-z');
  Parser encodingNonStartChar() => (ref0(keywordStartChar) | pattern('0-9-'));
  Parser encodingName() =>
      (ref0(encodingStartChar) & ref0(encodingNonStartChar).star())
          .flatten()
          .trim()
          .map((value) => value.toUpperCase());
  Parser encodingCommand() => stringIgnoreCase('encoding') & ref0(encodingName);
  Parser encoding() => ref1(commandTemplate, encodingCommand);

  /// TODO: input
  /// TODO: survey
  /// TODO: centreline

  /// scrap
  Parser scrap() => ref1(commandTemplate, scrapCommand);
  Parser scrapCommand() => scrapRequired() & scrapOptions();
  Parser scrapRequired() => stringIgnoreCase('scrap') & ref0(keyword);
  Parser scrapOptions() => (authorOption() |
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
      .star();

  /// scrap -author
  Parser authorOption() =>
      stringIgnoreCase('author').skip(before: char('-')) & ref0(authorOptions);
  Parser authorOptions() => dateTime() & person();

  /// scrap -copyright
  Parser copyrightOption() =>
      stringIgnoreCase('copyright').skip(before: char('-')) &
      ref0(copyrightOptions);
  Parser copyrightOptions() => dateTime() & anyString();

  /// scrap -cs
  Parser csOption() =>
      stringIgnoreCase('cs').skip(before: char('-')) & csSpec();
  Parser csSpec() => csSpecs().map((value) => [value]);

  Parser csSpecs() =>
      (csUtm() | csStrings() | csJtsk() | csEpsgEsri() | csEtrs() | csOsgb())
          .trim();
  Parser csUtm() => (string('UTM') &
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
  Parser csEtrs() => (string('ETRS') &
          ((char('2') & pattern('89')) | (char('3') & pattern('0-7')))
              .optional())
      .flatten();
  Parser csOsgb() =>
      (string('OSGB:') & pattern('HNOST') & pattern('A-HJ-Z')).flatten();

  /// scrap -flip
  Parser flipOption() =>
      stringIgnoreCase('flip').skip(before: char('-')) &
      ref0(flipOptions).map((value) => [value]);
  Parser flipOptions() => (stringIgnoreCase('none') |
          stringIgnoreCase('horizontal') |
          stringIgnoreCase('vertical'))
      .trim();

  /// scrap -projection
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
          .trim();
  Parser projectionOption() =>
      stringIgnoreCase('projection').skip(before: char('-')) &
      ref0(projectionSpec);

  /// scrap -scale
  Parser scrapScaleOption() =>
      stringIgnoreCase('scale').skip(before: char('-')) & ref0(scrapScaleSpec);
  Parser scrapScaleSpec() =>
      ref0(number).map((value) => [value]) |
      bracketStringTemplate(scrapScaleNumber());
  Parser scrapScaleNumber() =>
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

  /// scrap -sketch
  Parser sketchOption() =>
      stringIgnoreCase('sketch').skip(before: char('-')) & ref0(sketchSpec);
  Parser sketchSpec() => (anyString() & pointData()).trim();

  /// scrap -station-names
  Parser stationNamesOption() =>
      stringIgnoreCase('station-names').skip(before: char('-')) &
      ref0(stationNamesSpec);
  Parser stationNamesSpec() =>
      ((string('[]') | pattern('^[] \t').plus()).flatten().trim()).repeat(2, 2);

  /// scrap -stations
  Parser stationsOption() =>
      stringIgnoreCase('stations').skip(before: char('-')) &
      ref0(csvKeyword).map((value) => [value]);

  /// scrap -title
  Parser titleOption() =>
      stringIgnoreCase('title').skip(before: char('-')) & ref0(titleOptions);
  Parser titleOptions() => anyString().map((value) => [value]);

  /// scrap -walls
  Parser wallsOption() =>
      stringIgnoreCase('walls').skip(before: char('-')) &
      ref0(onOffAutoOptions);

  /// Endscrap
  Parser endscrap() => ref1(commandTemplate, endscrapCommand);
  Parser endscrapCommand() =>
      stringIgnoreCase('endscrap').map((value) => [value]);

  /// point
  Parser point() => ref1(commandTemplate, pointCommand);
  Parser pointCommand() => pointRequired() & pointOptions();
  Parser pointRequired() =>
      stringIgnoreCase('point') & ref0(pointData) & pointType();
  Parser pointType() =>
      (stringIgnoreCase('air-draught') |
              stringIgnoreCase('altar') |
              stringIgnoreCase('altitude') |
              stringIgnoreCase('anastomosis') |
              stringIgnoreCase('anchor') |
              stringIgnoreCase('aragonite') |
              stringIgnoreCase('archeo-excavation') |
              stringIgnoreCase('archeo-material') |
              stringIgnoreCase('audio') |
              stringIgnoreCase('bat') |
              stringIgnoreCase('bedrock') |
              stringIgnoreCase('blocks') |
              stringIgnoreCase('bones') |
              stringIgnoreCase('breakdown-choke') |
              stringIgnoreCase('bridge') |
              stringIgnoreCase('camp') |
              stringIgnoreCase('cave-pearl') |
              stringIgnoreCase('clay-choke') |
              stringIgnoreCase('clay-tree') |
              stringIgnoreCase('clay') |
              stringIgnoreCase('continuation') |
              stringIgnoreCase('crystal') |
              stringIgnoreCase('curtains') |
              stringIgnoreCase('curtain') |
              stringIgnoreCase('danger') |
              stringIgnoreCase('date') |
              stringIgnoreCase('debris') |
              stringIgnoreCase('dig') |
              stringIgnoreCase('dimensions') |
              stringIgnoreCase('disc-pillars') |
              stringIgnoreCase('disc-pillar') |
              stringIgnoreCase('disc-stalactites') |
              stringIgnoreCase('disc-stalactite') |
              stringIgnoreCase('disc-stalagmites') |
              stringIgnoreCase('disc-stalagmite') |
              stringIgnoreCase('disk') |
              stringIgnoreCase('electric-light') |
              stringIgnoreCase('entrance') |
              stringIgnoreCase('ex-voto') |
              stringIgnoreCase('extra') |
              stringIgnoreCase('fixed-ladder') |
              stringIgnoreCase('flowstone-choke') |
              stringIgnoreCase('flowstone') |
              stringIgnoreCase('flute') |
              stringIgnoreCase('gate') |
              stringIgnoreCase('gradient') |
              stringIgnoreCase('guano') |
              stringIgnoreCase('gypsum-flower') |
              stringIgnoreCase('gypsum') |
              stringIgnoreCase('handrail') |
              stringIgnoreCase('height') |
              stringIgnoreCase('helictites') |
              stringIgnoreCase('helictite') |
              stringIgnoreCase('human-bones') |
              stringIgnoreCase('ice-pillar') |
              stringIgnoreCase('ice-stalactite') |
              stringIgnoreCase('ice-stalagmite') |
              stringIgnoreCase('ice') |
              stringIgnoreCase('karren') |
              stringIgnoreCase('label') |
              stringIgnoreCase('low-end') |
              stringIgnoreCase('map-connection') |
              stringIgnoreCase('masonry') |
              stringIgnoreCase('moonmilk') |
              stringIgnoreCase('mudcrack') |
              stringIgnoreCase('mud') |
              stringIgnoreCase('name-plate') |
              stringIgnoreCase('narrow-end') |
              stringIgnoreCase('no-equipment') |
              stringIgnoreCase('no-wheelchair') |
              stringIgnoreCase('paleo-material') |
              stringIgnoreCase('passage-height') |
              stringIgnoreCase('pebbles') |
              stringIgnoreCase('pendant') |
              stringIgnoreCase('photo') |
              stringIgnoreCase('pillars-with-curtains') |
              stringIgnoreCase('pillar-with-curtains') |
              stringIgnoreCase('pillar') |
              stringIgnoreCase('popcorn') |
              stringIgnoreCase('raft-cone') |
              stringIgnoreCase('raft') |
              stringIgnoreCase('remark') |
              stringIgnoreCase('rimstone-dam') |
              stringIgnoreCase('rimstone-pool') |
              stringIgnoreCase('root') |
              stringIgnoreCase('rope-ladder') |
              stringIgnoreCase('rope') |
              stringIgnoreCase('sand') |
              stringIgnoreCase('scallop') |
              stringIgnoreCase('section') |
              stringIgnoreCase('seed-germination') |
              stringIgnoreCase('sink') |
              stringIgnoreCase('snow') |
              stringIgnoreCase('soda-straw') |
              stringIgnoreCase('spring') |
              stringIgnoreCase('stalactite-stalagmite') |
              stringIgnoreCase('stalactites-stalagmites') |
              stringIgnoreCase('stalactites') |
              stringIgnoreCase('stalactite') |
              stringIgnoreCase('stalagmites') |
              stringIgnoreCase('stalagmite') |
              stringIgnoreCase('station-name') |
              stringIgnoreCase('station') |
              stringIgnoreCase('steps') |
              stringIgnoreCase('traverse') |
              stringIgnoreCase('tree-trunk') |
              (stringIgnoreCase('u') & (char(':') & ref0(keyword)).pick(1)) |
              stringIgnoreCase('vegetable-debris') |
              stringIgnoreCase('via-ferrata') |
              stringIgnoreCase('volcano') |
              stringIgnoreCase('walkway') |
              stringIgnoreCase('wall-calcite') |
              stringIgnoreCase('water-drip') |
              stringIgnoreCase('water-flow') |
              stringIgnoreCase('water') |
              stringIgnoreCase('wheelchair'))
          .trim() &
      (char(':') & ref0(keyword).trim()).pick(1).optional();
  Parser pointOptions() => (alignOption() |
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
          pointScaleOption() |
          scrapOption() |
          subtypeOption() |
          textOption() |
          valueOption() |
          visibilityOption())
      .star();

  /// point -align
  Parser alignOption() =>
      stringIgnoreCase('align').skip(before: char('-')) & ref0(alignOptions);
  Parser alignOptions() => (stringIgnoreCase('bottom-left') |
          stringIgnoreCase('bottom-right') |
          stringIgnoreCase('bottom,') |
          stringIgnoreCase('bl') |
          stringIgnoreCase('br') |
          stringIgnoreCase('b') |
          stringIgnoreCase('center,') |
          stringIgnoreCase('c') |
          stringIgnoreCase('left,') |
          stringIgnoreCase('l') |
          stringIgnoreCase('right,') |
          stringIgnoreCase('r') |
          stringIgnoreCase('top-left') |
          stringIgnoreCase('top-right') |
          stringIgnoreCase('top,') |
          stringIgnoreCase('tl') |
          stringIgnoreCase('tr') |
          stringIgnoreCase('t'))
      .trim()
      .map((value) => [value]);

  /// point -clip
  Parser clipOption() =>
      stringIgnoreCase('clip').skip(before: char('-')) & ref0(onOffOptions);
  Parser clipCommandLikeOption() =>
      stringIgnoreCase('clip') & ref0(onOffOptions);

  /// point -context
  Parser contextOption() =>
      stringIgnoreCase('context').skip(before: char('-')) &
      ref0(contextOptions);
  Parser contextCommandLikeOption() =>
      stringIgnoreCase('context') & ref0(contextOptions);
  Parser contextOptions() => (keyword() & keyword()).trim();

  /// point -dist
  Parser distOption() =>
      stringIgnoreCase('dist').skip(before: char('-')) & distOptions();
  Parser distOptions() => (number().trim().map((value) => [value]) |
          bracketStringTemplate(number() & lengthUnit()))
      .trim();

  /// point -explored
  Parser exploredOption() =>
      stringIgnoreCase('explored').skip(before: char('-')) &
      ref0(exploredOptions);
  Parser exploredOptions() => (number().trim().map((value) => [value]) |
          bracketStringTemplate(number() & lengthUnit()))
      .trim();

  /// point -extend
  Parser extendOption() =>
      stringIgnoreCase('extend').skip(before: char('-')) & ref0(extendOptions);
  Parser extendOptions() =>
      ((stringIgnoreCase('prev') & stringIgnoreCase('ious').optional())
                  .flatten() &
              ref0(reference))
          .pick(1)
          .optional()
          .trim()
          .map((value) => [value]);

  /// point/line -id
  Parser idOption() =>
      stringIgnoreCase('id').skip(before: char('-')) & ref0(idOptions);
  Parser idCommandLikeOption() => stringIgnoreCase('id') & ref0(idOptions);
  Parser idOptions() => ref0(extKeyword).trim().map((value) => [value]);

  /// point -from
  Parser fromOption() =>
      stringIgnoreCase('from').skip(before: char('-')) & ref0(fromOptions);
  Parser fromOptions() => ref0(extKeyword).trim().map((value) => [value]);

  /// point -name
  Parser nameOption() =>
      stringIgnoreCase('name').skip(before: char('-')) & ref0(nameOptions);
  Parser nameOptions() =>
      ref0(reference).trim().map((value) => [value]) |
      ref0(quotedString).map((value) => [value]);

  /// point -orientation
  Parser orientationOption() =>
      (stringIgnoreCase('orientation') | stringIgnoreCase('orient'))
          .skip(before: char('-'))
          .map((value) => 'orientation') &
      ref0(orientationOptions);
  Parser orientationCommandLikeOption() =>
      (stringIgnoreCase('orientation') | stringIgnoreCase('orient'))
          .map((value) => 'orientation') &
      ref0(orientationOptions);
  Parser orientationOptions() => number().map((value) => [value]);

  /// point/line/area -place
  Parser placeOption() =>
      stringIgnoreCase('place').skip(before: char('-')) & ref0(placeOptions);
  Parser placeCommandLikeOption() =>
      stringIgnoreCase('place') & ref0(placeOptions);
  Parser placeOptions() => (stringIgnoreCase('bottom') |
          stringIgnoreCase('default') |
          stringIgnoreCase('top'))
      .trim()
      .map((value) => [value]);

  /// point -scale
  Parser pointScaleOption() =>
      stringIgnoreCase('scale').skip(before: char('-')) &
      ref0(pointScaleOptions);
  Parser pointLineSegmentScaleOption() =>
      stringIgnoreCase('scale') & ref0(pointScaleOptions);
  Parser pointScaleOptions() =>
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
  Parser scrapOption() =>
      stringIgnoreCase('scrap').skip(before: char('-')) &
      ref0(scrapOptionOptions);
  Parser scrapOptionOptions() => reference().map((value) => [value]);

  /// point/line -subtype
  Parser subtypeOption() =>
      stringIgnoreCase('subtype').skip(before: char('-')) &
      ref0(subtypeOptions);
  Parser subtypeCommandLikeOption() =>
      stringIgnoreCase('subtype') & ref0(subtypeOptions);
  Parser subtypeOptions() => unquotedString().map((value) => [value]);

  /// point/line -text
  Parser textOption() =>
      stringIgnoreCase('text').skip(before: char('-')) & ref0(textOptions);
  Parser textCommandLikeOption() =>
      stringIgnoreCase('text') & ref0(textOptions);
  Parser textOptions() => anyString().map((value) => [value]);

  /// point -value
  Parser valueOption() =>
      stringIgnoreCase('value').skip(before: char('-')) & ref0(valueOptions);
  Parser valueOptions() => (char('-').trim().map((value) => ['hyphen', value]) |
      dateTime().trim().map((value) => ['datetime', value]) |
      number().trim().map((value) => ['single_number', value]) |
      bracketStringTemplate(
              numberWithSuffix(char('?').optional()) & lengthUnit().optional())
          .trim()
          .map((value) => ['number_with_something_else', value]) |
      bracketStringTemplate(plusNumber() & minusNumber())
          .trim()
          .map((value) => ['plus_number_minus_number', value]) |
      nan().trim().map((value) => ['nan', value]) |
      bracketStringTemplate(
              stringIgnoreCase('fix') & number() & lengthUnit().optional())
          .trim()
          .map((value) => ['fix_number', value]) |
      bracketStringTemplate(number() & number() & lengthUnit().optional())
          .trim()
          .map((value) => ['two_numbers_with_optional_unit', value]));

  /// point -visibility
  Parser visibilityOption() =>
      stringIgnoreCase('visibility').skip(before: char('-')) &
      ref0(onOffOptions);
  Parser visibilityCommandLikeOption() =>
      stringIgnoreCase('visibility') & ref0(onOffOptions);

  /// line
  Parser line() => ref1(commandTemplate, lineCommand);
  Parser lineCommand() => lineRequired() & lineOptions();
  Parser lineRequired() => stringIgnoreCase('line') & lineType();
  Parser lineType() =>
      (stringIgnoreCase('abyss-entrance') |
              stringIgnoreCase('arrow') |
              stringIgnoreCase('border') |
              stringIgnoreCase('ceiling-meander') |
              stringIgnoreCase('ceiling-step') |
              stringIgnoreCase('chimney') |
              stringIgnoreCase('contour') |
              stringIgnoreCase('dripline') |
              stringIgnoreCase('fault') |
              stringIgnoreCase('fixed-ladder') |
              stringIgnoreCase('floor-meander') |
              stringIgnoreCase('floor-step') |
              stringIgnoreCase('flowstone') |
              stringIgnoreCase('gradient') |
              stringIgnoreCase('handrail') |
              stringIgnoreCase('joint') |
              stringIgnoreCase('label') |
              stringIgnoreCase('low-ceiling') |
              stringIgnoreCase('map-connection') |
              stringIgnoreCase('moonmilk') |
              stringIgnoreCase('overhang') |
              stringIgnoreCase('pit-chimney') |
              stringIgnoreCase('pitch') |
              stringIgnoreCase('pit') |
              stringIgnoreCase('rimstone-dam') |
              stringIgnoreCase('rimstone-pool') |
              stringIgnoreCase('rock-border') |
              stringIgnoreCase('rock-edge') |
              stringIgnoreCase('rope-ladder') |
              stringIgnoreCase('rope') |
              stringIgnoreCase('section') |
              stringIgnoreCase('slope') |
              stringIgnoreCase('steps') |
              stringIgnoreCase('survey') |
              stringIgnoreCase('u') |
              stringIgnoreCase('via-ferrata') |
              stringIgnoreCase('walk-way') |
              stringIgnoreCase('wall') |
              stringIgnoreCase('water-flow'))
          .trim() &
      (char(':') & ref0(keyword).trim()).pick(1).optional();
  Parser lineOptions() => (anchorsOption() |
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
          lineScaleOption() |
          subtypeOption() |
          textOption() |
          visibilityOption())
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
          .map((value) => [
                'linecommandlikeoption',
                [value]
              ]) &
      ref0(endLineComment).optional();

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
      stringIgnoreCase('adjust') & ref0(adjustOptions);
  Parser adjustOptions() =>
      (stringIgnoreCase('horizontal') | stringIgnoreCase('vertical'))
          .trim()
          .map((value) => [value]);

  /// line -altitude
  Parser altitudeCommandLikeOption() =>
      stringIgnoreCase('altitude') & ref0(valueOptions);
  Parser altitudeOptions() =>
      (char('-').trim().map((value) => ['hyphen', value]) |
          number().trim().map((value) => ['single_number', value]) |
          nan().trim().map((value) => ['nan', value]) |
          bracketStringTemplate(
                  stringIgnoreCase('fix') & number() & lengthUnit().optional())
              .trim()
              .map((value) => ['fix_number', value]) |
          bracketStringTemplate(number() & number() & lengthUnit().optional())
              .trim()
              .map((value) => ['two_numbers_with_optional_unit', value]));

  /// line -anchors
  Parser anchorsOption() =>
      ref0(anchorsCommandID).skip(before: char('-')) & ref0(onOffOptions);
  Parser anchorsCommandLikeOption() =>
      ref0(anchorsCommandID) & ref0(onOffOptions);
  Parser anchorsCommandID() => stringIgnoreCase('anchors');

  /// line -border
  Parser borderOption() =>
      stringIgnoreCase('border').skip(before: char('-')) & ref0(onOffOptions);
  Parser borderCommandLikeOption() =>
      stringIgnoreCase('border') & ref0(onOffOptions);

  /// line -close
  Parser closeOption() =>
      stringIgnoreCase('close').skip(before: char('-')) &
      ref0(onOffAutoOptions);
  Parser closeCommandLikeOption() =>
      stringIgnoreCase('close') & ref0(onOffAutoOptions);

  /// line -direction
  Parser directionOption() =>
      stringIgnoreCase('direction').skip(before: char('-')) &
      ref0(directionOptions);
  Parser directionOptions() =>
      ref0(beginEndBothNoneOptions).trim().map((value) => [value]);
  Parser directionCommandLikeOption() =>
      stringIgnoreCase('direction') & ref0(directionLineSegmentOptions);
  Parser directionLineSegmentOptions() =>
      (ref0(beginEndBothNoneOptions) | stringIgnoreCase('point'))
          .trim()
          .map((value) => [value]);

  /// line -gradient
  Parser gradientOption() =>
      stringIgnoreCase('gradient').skip(before: char('-')) &
      ref0(gradientOptions);
  Parser gradientGeneralOptions() =>
      stringIgnoreCase('none') | stringIgnoreCase('center');
  Parser gradientOptions() =>
      ref0(gradientGeneralOptions).trim().map((value) => [value]);
  Parser gradientCommandLikeOption() =>
      stringIgnoreCase('gradient') & ref0(gradientLineSegmentOptions);
  Parser gradientLineSegmentOptions() =>
      (ref0(beginEndBothNoneOptions) | stringIgnoreCase('point'))
          .trim()
          .map((value) => [value]);

  /// line -head
  Parser headOption() =>
      stringIgnoreCase('head').skip(before: char('-')) & ref0(headOptions);
  Parser headCommandLikeOption() =>
      stringIgnoreCase('head') & ref0(headOptions);
  Parser headOptions() =>
      ref0(beginEndBothNoneOptions).trim().map((value) => [value]);

  /// line -height
  Parser heightOption() =>
      stringIgnoreCase('height').skip(before: char('-')) & ref0(heightOptions);
  Parser heightCommandLikeOption() =>
      stringIgnoreCase('height') & ref0(heightOptions);
  Parser heightOptions() => ref0(number).map((value) => [value]);

  /// line -scale
  Parser lineScaleOption() =>
      stringIgnoreCase('scale').skip(before: char('-')) &
      ref0(lineScaleOptions);
  Parser lineScaleCommandLikeOption() =>
      stringIgnoreCase('scale') & ref0(lineScaleOptions);
  Parser lineScaleOptions() =>
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
          .skip(after: ref0(thWhitespace).plus())
          .trim()
          .map((value) => ['multiplechoice', value]) |
      number().trim().map((value) => ['numeric', value]) |
      extKeyword().map((value) => ['text', value]);

  /// linepoint l-size/size
  Parser lsizeCommandLikeOption() =>
      (stringIgnoreCase('l-size') | stringIgnoreCase('size'))
          .map((value) => 'l-size') &
      ref0(lsizeOptions);
  Parser lsizeOptions() => number().trim().map((value) => [value]);

  /// linepoint -mark
  Parser markCommandLikeOption() =>
      stringIgnoreCase('mark') & ref0(markOptions);
  Parser markOptions() => keyword().map((value) => [value]);

  /// line -outline
  Parser outlineOption() =>
      stringIgnoreCase('outline').skip(before: char('-')) &
      ref0(outlineOptions);
  Parser outlineCommandLikeOption() =>
      stringIgnoreCase('outline') & ref0(outlineOptions);
  Parser outlineOptions() => (stringIgnoreCase('in') |
          stringIgnoreCase('out') |
          stringIgnoreCase('none'))
      .trim()
      .map((value) => [value]);

  /// line -rebelays
  Parser rebelaysOption() =>
      stringIgnoreCase('rebelays').skip(before: char('-')) & ref0(onOffOptions);
  Parser rebelaysCommandLikeOption() =>
      stringIgnoreCase('rebelays') & ref0(onOffOptions);

  /// line -reverse
  Parser reverseOption() =>
      stringIgnoreCase('reverse').skip(before: char('-')) & ref0(onOffOptions);
  Parser reverseCommandLikeOption() =>
      stringIgnoreCase('reverse') & ref0(onOffOptions);

  /// line -smooth
  Parser smoothCommandLikeOption() =>
      stringIgnoreCase('smooth') & ref0(onOffAutoOptions);

  /// area
  Parser area() => ref1(commandTemplate, areaCommand);
  Parser areaCommand() => areaRequired() & areaOptions();
  Parser areaRequired() => stringIgnoreCase('area') & areaType();
  Parser areaType() =>
      (stringIgnoreCase('bedrock') |
              stringIgnoreCase('blocks') |
              stringIgnoreCase('clay') |
              stringIgnoreCase('debris') |
              stringIgnoreCase('flowstone') |
              stringIgnoreCase('ice') |
              stringIgnoreCase('moonmilk') |
              stringIgnoreCase('mudcrack') |
              stringIgnoreCase('pebbles') |
              stringIgnoreCase('pillar-with-curtains') |
              stringIgnoreCase('pillars-with-curtains') |
              stringIgnoreCase('pillars') |
              stringIgnoreCase('pillar') |
              stringIgnoreCase('sand') |
              stringIgnoreCase('snow') |
              stringIgnoreCase('stalactite-stalagmite') |
              stringIgnoreCase('stalactite') |
              stringIgnoreCase('stalagmite') |
              stringIgnoreCase('sump') |
              stringIgnoreCase('u') |
              stringIgnoreCase('water'))
          .trim() &
      (char(':') & ref0(keyword).trim()).pick(1).optional();
  Parser areaOptions() => (clipOption() |
          contextOption() |
          idOption() |
          placeOption() |
          visibilityOption())
      .star();
  Parser areaCommandLikeOptions() =>
      (clipCommandLikeOption() |
              contextCommandLikeOption() |
              idCommandLikeOption() |
              placeCommandLikeOption() |
              visibilityCommandLikeOption())
          .map((value) => [
                'areaCommandLikeOption',
                [value]
              ]) &
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
  Parser xtherionConfig() => (stringIgnoreCase('##XTHERION##').trim() &
          (keyword() & any().plus().flatten().trim()))
      .map((value) => [value]);
}
