import 'package:petitparser/petitparser.dart';

/// .xvi file grammar.
class XVIGrammar extends GrammarDefinition {
  @override
  Parser start() => (emptyLine() | xviFileContent()).star();
  Parser xviFileContent() =>
      // xviGridSize().optional() &
      // xviStations().optional() &
      // xviShots().optional() &
      // xviSketchLines().optional() &
      xviGrid();

  Parser emptyLine() => (whitespace().star() & newline()).map((_) => null);

  Parser xviGrid() =>
      whitespace().star() &
      stringIgnoreCase('set').trim() &
      stringIgnoreCase('XVIgrid').trim() &
      char('{').trim() &
      xviNumber()
          .timesSeparated((whitespace() | newline()).plus(), 8)
          .map((list) => list.elements) &
      char('}').trim();

  Parser xviNumber() => ((char('+').or(char('-'))).optional() &
          digit().plus() &
          (char('.') & digit().plus()).optional())
      .flatten();
}
