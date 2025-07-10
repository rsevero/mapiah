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

  Parser xviGrid() => (whitespace().star() &
          stringIgnoreCase('set').trim() &
          stringIgnoreCase('XVIgrid').trim() &
          char('{').trim() &
          xviNumber()
              .timesSeparated((whitespace() | newline()).plus(), 8)
              .map((list) => {'XVIGrid': list.elements}) &
          char('}').trim())
      .map((value) => value[4]);

  Parser xviGridSize() => (whitespace().star() &
          stringIgnoreCase('set').trim() &
          stringIgnoreCase('XVIgrids').trim() &
          char('{').trim() &
          xviNumber().trim() &
          lengthUnit().trim() &
          char('}').trim())
      .map((value) => {
            'XVIGridSize': [value[4], value[5]]
          });

  Parser xviStations() => (whitespace().star() &
          stringIgnoreCase('set').trim() &
          stringIgnoreCase('XVIstations').trim() &
          xviStationsBlock().trim())
      .map((values) => {
            'XVIStations': values[3] as List<dynamic>,
          });

  Parser xviCurlyBracketsContent(Parser contentParser) =>
      (char('{').trim() & contentParser.trim() & char('}').trim())
          .map((values) => values[1]);

  Parser xviStationsBlock() =>
      xviCurlyBracketsContent(xviStationBlock().plus());

  Parser xviStationBlock() => xviCurlyBracketsContent(xviStationFields());

  Parser xviStationFields() =>
      xviNumber().trim() & xviNumber().trim() & xviStationName().trim();

  Parser xviStationName() => ((letter() | digit()) &
          ((letter() | digit()) | (char('.') & char('.').not())).star())
      .trim()
      .flatten();
}
