import 'package:petitparser/petitparser.dart';

/// .xvi file grammar.
class XVIGrammar extends GrammarDefinition {
  @override
  Parser start() => xviFileStart();
  Parser xviFileStart() => (emptyLine() | xviFileContent()).star();
  Parser xviFileContent() =>
      // xviGridSize().optional() &
      // xviStations().optional() &
      // xviShots().optional() &
      // xviSketchLines().optional() &
      xviGrid();

  Parser emptyLine() => (whitespace().star() & newline()).map((_) => null);

  Parser xviGrid() => (whitespace().star() &
          stringIgnoreCase('set').trim() &
          stringIgnoreCase('XVIgrid').trim() &
          char('{').trim() &
          xviNumber()
              .timesSeparated((whitespace() | newline()).plus(), 8)
              .map((list) => {'XVIgrid': list.elements}) &
          char('}').trim())
      .map((value) => value[4]);

  Parser xviNumber() => ((char('+').or(char('-'))).optional() &
          digit().plus() &
          (char('.') & digit().plus()).optional())
      .flatten();
}
