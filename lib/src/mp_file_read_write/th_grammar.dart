// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/mp_file_read_write/grammar_utils.dart';
import 'package:petitparser/petitparser.dart';

/// PetitParser grammar definition for Therion survey data (`.th`) files.
class THGrammar extends GrammarDefinition {
  @override
  Parser start() => thDataFileStart();

  /// Root parser matching entire file content or statements.
  Parser thDataFileStart() => thDataStatement().star().end();

  /// Single statement in a .th file.
  Parser thDataStatement() =>
      emptyLine() |
      fullLineComment() |
      inputCommand() |
      surveyStartCommand() |
      surveyEndCommand() |
      centrelineStartCommand() |
      centrelineEndCommand() |
      mapStartCommand() |
      mapEndCommand() |
      scrapStartCommand() |
      scrapEndCommand() |
      surfaceStartCommand() |
      surfaceEndCommand() |
      equateCommand() |
      joinCommand() |
      importCommand() |
      settingCommand() |
      shotReading() |
      generalCommand();

  /// Empty or whitespace-only line.
  Parser emptyLine() =>
      (GrammarUtils.thWhitespaceOptional() & endOfLineOrInput())
          .map((dynamic _) => <String, dynamic>{'type': 'emptyLine'});

  /// Full-line comment starting with `#`.
  Parser fullLineComment() =>
      (GrammarUtils.thWhitespaceOptional() &
              char('#') &
              any().star().flatten() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String commentBody = list[2] as String;

            return <String, dynamic>{
              'type': 'comment',
              'text': '#$commentBody'.trim(),
            };
          });

  /// `input <file-name>`
  Parser inputCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('input') &
              GrammarUtils.thWhitespace() &
              GrammarUtils.anyString() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String path = list[3] as String;

            return <String, dynamic>{
              'type': 'input',
              'filePath': path,
            };
          });

  /// `survey <id> [options]`
  Parser surveyStartCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('survey') &
              GrammarUtils.thWhitespace() &
              GrammarUtils.anyString() &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String surveyId = list[3] as String;
            final dynamic optionsRaw = list[4];
            final String rawOpts =
                (optionsRaw is List && optionsRaw.length > 1)
                    ? optionsRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'surveyStart',
              'surveyId': surveyId,
              'rawOptions': rawOpts,
            };
          });

  /// `endsurvey [<id>]`
  Parser surveyEndCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('endsurvey') &
              (GrammarUtils.thWhitespace() & GrammarUtils.anyString()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final dynamic idRaw = list[2];
            final String surveyId =
                (idRaw is List && idRaw.length > 1) ? idRaw[1] as String : '';

            return <String, dynamic>{
              'type': 'surveyEnd',
              'surveyId': surveyId,
            };
          });

  /// `centreline [options]` or `centerline [options]`
  Parser centrelineStartCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              (GrammarUtils.stringIgnoreCase('centreline') |
                  GrammarUtils.stringIgnoreCase('centerline')) &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final dynamic optionsRaw = list[2];
            final String rawOpts =
                (optionsRaw is List && optionsRaw.length > 1)
                    ? optionsRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'centrelineStart',
              'rawOptions': rawOpts,
            };
          });

  /// `endcentreline` or `endcenterline`
  Parser centrelineEndCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              (GrammarUtils.stringIgnoreCase('endcentreline') |
                  GrammarUtils.stringIgnoreCase('endcenterline')) &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic _) => <String, dynamic>{'type': 'centrelineEnd'});

  /// `map <id> [options]`
  Parser mapStartCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('map') &
              GrammarUtils.thWhitespace() &
              GrammarUtils.anyString() &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String mapId = list[3] as String;
            final dynamic optionsRaw = list[4];
            final String rawOpts =
                (optionsRaw is List && optionsRaw.length > 1)
                    ? optionsRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'mapStart',
              'mapId': mapId,
              'rawOptions': rawOpts,
            };
          });

  /// `endmap [<id>]`
  Parser mapEndCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('endmap') &
              (GrammarUtils.thWhitespace() & GrammarUtils.anyString()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final dynamic idRaw = list[2];
            final String mapId =
                (idRaw is List && idRaw.length > 1) ? idRaw[1] as String : '';

            return <String, dynamic>{
              'type': 'mapEnd',
              'mapId': mapId,
            };
          });

  /// `scrap <id> [options]`
  Parser scrapStartCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('scrap') &
              GrammarUtils.thWhitespace() &
              GrammarUtils.anyString() &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String scrapId = list[3] as String;
            final dynamic optionsRaw = list[4];
            final String rawOpts =
                (optionsRaw is List && optionsRaw.length > 1)
                    ? optionsRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'scrapStart',
              'scrapId': scrapId,
              'rawOptions': rawOpts,
            };
          });

  /// `endscrap [<id>]`
  Parser scrapEndCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('endscrap') &
              (GrammarUtils.thWhitespace() & GrammarUtils.anyString()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final dynamic idRaw = list[2];
            final String scrapId =
                (idRaw is List && idRaw.length > 1) ? idRaw[1] as String : '';

            return <String, dynamic>{
              'type': 'scrapEnd',
              'scrapId': scrapId,
            };
          });

  /// `surface [options]`
  Parser surfaceStartCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('surface') &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final dynamic optionsRaw = list[2];
            final String rawOpts =
                (optionsRaw is List && optionsRaw.length > 1)
                    ? optionsRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'surfaceStart',
              'rawOptions': rawOpts,
            };
          });

  /// `endsurface`
  Parser surfaceEndCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('endsurface') &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic _) => <String, dynamic>{'type': 'surfaceEnd'});

  /// `equate <st1> <st2> ...`
  Parser equateCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('equate') &
              GrammarUtils.thWhitespace() &
              rawArguments() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String args = list[3] as String;
            final List<String> stations =
                args.isNotEmpty ? args.split(RegExp(r'\s+')) : <String>[];

            return <String, dynamic>{
              'type': 'equate',
              'stations': stations,
            };
          });

  /// `join <line1> <line2> [options]`
  Parser joinCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('join') &
              GrammarUtils.thWhitespace() &
              GrammarUtils.anyString() &
              GrammarUtils.thWhitespace() &
              GrammarUtils.anyString() &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String line1 = list[3] as String;
            final String line2 = list[5] as String;
            final dynamic optionsRaw = list[6];
            final String rawOpts =
                (optionsRaw is List && optionsRaw.length > 1)
                    ? optionsRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'join',
              'line1': line1,
              'line2': line2,
              'rawOptions': rawOpts,
            };
          });

  /// `import <file-path> [options]`
  Parser importCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('import') &
              GrammarUtils.thWhitespace() &
              GrammarUtils.anyString() &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String path = list[3] as String;
            final dynamic optionsRaw = list[4];
            final String rawOpts =
                (optionsRaw is List && optionsRaw.length > 1)
                    ? optionsRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'import',
              'filePath': path,
              'rawOptions': rawOpts,
            };
          });

  /// `encoding`, `cs`, `declination`, `grade`, `revise`, `require`, etc.
  Parser settingCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              settingKeyword() &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String keyword = list[1] as String;
            final dynamic argsRaw = list[2];
            final String args =
                (argsRaw is List && argsRaw.length > 1)
                    ? argsRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'setting',
              'keyword': keyword,
              'rawArguments': args,
            };
          });

  Parser settingKeyword() =>
      GrammarUtils.stringIgnoreCase('encoding') |
      GrammarUtils.stringIgnoreCase('cs') |
      GrammarUtils.stringIgnoreCase('declination') |
      GrammarUtils.stringIgnoreCase('grade') |
      GrammarUtils.stringIgnoreCase('revise') |
      GrammarUtils.stringIgnoreCase('require') |
      GrammarUtils.stringIgnoreCase('title') |
      GrammarUtils.stringIgnoreCase('author') |
      GrammarUtils.stringIgnoreCase('copyright') |
      GrammarUtils.stringIgnoreCase('date') |
      GrammarUtils.stringIgnoreCase('explo-date') |
      GrammarUtils.stringIgnoreCase('team') |
      GrammarUtils.stringIgnoreCase('explo-team') |
      GrammarUtils.stringIgnoreCase('units') |
      GrammarUtils.stringIgnoreCase('data') |
      GrammarUtils.stringIgnoreCase('flags') |
      GrammarUtils.stringIgnoreCase('station') |
      GrammarUtils.stringIgnoreCase('fix') |
      GrammarUtils.stringIgnoreCase('extend') |
      GrammarUtils.stringIgnoreCase('station-names');

  /// Survey leg reading: <from> <to> <length> [<bearing> [<clino>]] [flags]
  Parser shotReading() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.unquotedString() &
              GrammarUtils.thWhitespace() &
              GrammarUtils.unquotedString() &
              GrammarUtils.thWhitespace() &
              GrammarUtils.number() &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String from = list[1] as String;
            final String to = list[3] as String;
            final String lenStr = list[5] as String;
            final dynamic extraRaw = list[6];
            final String extra =
                (extraRaw is List && extraRaw.length > 1)
                    ? extraRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'shot',
              'from': from,
              'to': to,
              'length': double.tryParse(lenStr) ?? 0.0,
              'extra': extra,
            };
          });

  /// Fallback for general statements.
  Parser generalCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.unquotedString() &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String keyword = list[1] as String;
            final dynamic argsRaw = list[2];
            final String args =
                (argsRaw is List && argsRaw.length > 1)
                    ? argsRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'general',
              'keyword': keyword,
              'rawArguments': args,
            };
          });

  /// Rest of line arguments up to comment or end of line.
  Parser rawArguments() =>
      any()
          .starLazy(
            (GrammarUtils.thWhitespaceOptional() & char('#')) |
                char('\n') |
                char('\r') |
                endOfInput(),
          )
          .flatten()
          .map((dynamic value) => (value as String).trim());

  /// Optional trailing inline comment (`# ...`).
  Parser trailingComment() =>
      (GrammarUtils.thWhitespaceOptional() &
              char('#') &
              any().starLazy(char('\n') | char('\r') | endOfInput()))
          .optional();

  /// End of line (CR/LF) or end of input.
  Parser endOfLineOrInput() =>
      (char('\n') | (char('\r') & char('\n').optional()) | endOfInput());
}
