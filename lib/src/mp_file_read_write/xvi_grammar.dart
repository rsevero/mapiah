import 'package:petitparser/petitparser.dart';

/// .xvi file grammar.
class XVIGrammar extends GrammarDefinition {
  @override
  Parser start() => xviFileStart();
  Parser xviFileStart() => (emptyLine() | xviFileContent()).star();
  Parser xviFileContent() =>
      xviGridSize() |
      xviStations() |
      // xviShots().optional() &
      // xviSketchLines().optional() &
      xviGrid();

  Parser emptyLine() => (whitespace().star() & newline()).map((_) => null);

  Parser xviNumber() => ((char('+').or(char('-'))).optional() &
          digit().plus() &
          (char('.') & digit().plus()).optional())
      .flatten();

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

  // Generic parser for 'set <name> { ... }' blocks
  Parser xviSet(String name, Parser contentParser) => (whitespace().star() &
      stringIgnoreCase('set').trim() &
      stringIgnoreCase(name).trim() &
      xviCurlyBracketsContent(contentParser).trim());

  Parser xviGrid() => xviSet(
      'XVIgrid',
      xviNumber()
          .timesSeparated((whitespace() | newline()).plus(), 8)
          .map((list) => {'XVIGrid': list.elements})).map((value) => value[3]);

  Parser xviGridSize() =>
      xviSet('XVIgrids', xviNumber().trim() & lengthUnit().trim())
          .map((value) => {
                'XVIGridSize': [value[3][0], value[3][1]]
              });

  Parser xviStations() =>
      xviSet('XVIstations', xviStationBlock().plus()).map((values) => {
            'XVIStations': values[3] as List<dynamic>,
          });

  Parser xviCurlyBracketsContent(Parser contentParser) =>
      (char('{').trim() & contentParser.trim() & char('}').trim())
          .map((values) => values[1]);

  Parser xviStationBlock() => xviCurlyBracketsContent(xviStationFields());

  Parser xviStationFields() =>
      xviNumber().trim() & xviNumber().trim() & xviStationName().trim();

  Parser xviStationName() => ((letter() | digit()) &
          ((letter() | digit()) | (char('.') & char('.').not())).star())
      .trim()
      .flatten();
}
