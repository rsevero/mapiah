// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/mp_file_read_write/grammar_utils.dart';
import 'package:petitparser/petitparser.dart';

/// PetitParser grammar definition for Therion configuration (`thconfig`) files.
class THConfigGrammar extends GrammarDefinition {
  @override
  Parser start() => thConfigFileStart();

  /// Root parser matching entire file content or statements.
  Parser thConfigFileStart() => thConfigStatement().star().end();

  /// Single statement in a thconfig file.
  Parser thConfigStatement() =>
      emptyLine() |
      fullLineComment() |
      sourceCommand() |
      inputCommand() |
      layoutBlock() |
      exportCommand() |
      selectCommand() |
      unselectCommand() |
      settingCommand() |
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

  /// `source <file-name>` or multi-line `source ... endsource`.
  Parser sourceCommand() => singleLineSource() | multiLineSource();

  Parser singleLineSource() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('source') &
              GrammarUtils.thWhitespace() &
              GrammarUtils.anyString() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String path = list[3] as String;

            return <String, dynamic>{
              'type': 'source',
              'filePath': path,
              'isMultiLine': false,
            };
          });

  Parser multiLineSource() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('source') &
              trailingComment() &
              endOfLineOrInput() &
              any().starLazy(endSourceTag()).flatten() &
              endSourceTag())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String body = list[4] as String;

            return <String, dynamic>{
              'type': 'source',
              'filePath': '',
              'isMultiLine': true,
              'body': body,
            };
          });

  Parser endSourceTag() =>
      GrammarUtils.thWhitespaceOptional() &
      GrammarUtils.stringIgnoreCase('endsource') &
      trailingComment() &
      endOfLineOrInput();

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

  /// `layout <id> ... endlayout`
  Parser layoutBlock() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('layout') &
              GrammarUtils.thWhitespace() &
              GrammarUtils.anyString() &
              trailingComment() &
              endOfLineOrInput() &
              any().starLazy(endLayoutTag()).flatten() &
              endLayoutTag())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String layoutId = list[3] as String;
            final String body = list[6] as String;

            return <String, dynamic>{
              'type': 'layout',
              'layoutId': layoutId,
              'body': body,
            };
          });

  Parser endLayoutTag() =>
      GrammarUtils.thWhitespaceOptional() &
      GrammarUtils.stringIgnoreCase('endlayout') &
      (GrammarUtils.thWhitespace() & GrammarUtils.anyString()).optional() &
      trailingComment() &
      endOfLineOrInput();

  /// `export <type> [options]`
  Parser exportCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('export') &
              GrammarUtils.thWhitespace() &
              GrammarUtils.anyString() &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String exportType = list[3] as String;
            final dynamic optionsRaw = list[4];
            final String rawOpts =
                (optionsRaw is List && optionsRaw.length > 1)
                    ? optionsRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'export',
              'exportType': exportType,
              'rawOptions': rawOpts,
            };
          });

  /// `select <object> [options]`
  Parser selectCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('select') &
              GrammarUtils.thWhitespace() &
              GrammarUtils.anyString() &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String targetId = list[3] as String;
            final dynamic optionsRaw = list[4];
            final String rawOpts =
                (optionsRaw is List && optionsRaw.length > 1)
                    ? optionsRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'select',
              'isSelect': true,
              'targetId': targetId,
              'rawOptions': rawOpts,
            };
          });

  /// `unselect <object> [options]`
  Parser unselectCommand() =>
      (GrammarUtils.thWhitespaceOptional() &
              GrammarUtils.stringIgnoreCase('unselect') &
              GrammarUtils.thWhitespace() &
              GrammarUtils.anyString() &
              (GrammarUtils.thWhitespace() & rawArguments()).optional() &
              trailingComment() &
              endOfLineOrInput())
          .map((dynamic value) {
            final List<dynamic> list = value as List<dynamic>;
            final String targetId = list[3] as String;
            final dynamic optionsRaw = list[4];
            final String rawOpts =
                (optionsRaw is List && optionsRaw.length > 1)
                    ? optionsRaw[1] as String
                    : '';

            return <String, dynamic>{
              'type': 'select',
              'isSelect': false,
              'targetId': targetId,
              'rawOptions': rawOpts,
            };
          });

  /// Global settings: cs, encoding, language, system, maps, scrap-sort, sketch-warp, text, log, setup3d, lookup
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
      GrammarUtils.stringIgnoreCase('cs') |
      GrammarUtils.stringIgnoreCase('encoding') |
      GrammarUtils.stringIgnoreCase('language') |
      GrammarUtils.stringIgnoreCase('system') |
      GrammarUtils.stringIgnoreCase('maps-offset') |
      GrammarUtils.stringIgnoreCase('maps') |
      GrammarUtils.stringIgnoreCase('scrap-sort') |
      GrammarUtils.stringIgnoreCase('sketch-warp') |
      GrammarUtils.stringIgnoreCase('sketch-colors') |
      GrammarUtils.stringIgnoreCase('log') |
      GrammarUtils.stringIgnoreCase('text') |
      GrammarUtils.stringIgnoreCase('setup3d') |
      GrammarUtils.stringIgnoreCase('lookup');

  /// Fallback for unclassified statements.
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
