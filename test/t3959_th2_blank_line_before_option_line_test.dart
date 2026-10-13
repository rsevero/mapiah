// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

/// A blank line or a multiline comment right before an option line of a line
/// body used to make the parser throw a `TypeError`, because the option was
/// given to the empty line or comment instead of the line or line segment.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

  Future<(TH2File, bool, List<String>)> parseText(String text) {
    mpLocator.mpGeneralController.reset();

    return TH2FileParser().parse(
      '/tmp/t3959.th2',
      fileBytes: utf8.encode(text),
    );
  }

  String asSaved(TH2File file) {
    return TH2FileWriter().serialize(
      file,
      includeEmptyLines: true,
      useOriginalRepresentation: true,
    );
  }

  THLine onlyLine(TH2File file) {
    return file.getLines().single;
  }

  test('blank line before a line point option', () async {
    const String text = '''encoding UTF-8
scrap s1
  line wall
    1 1

    smooth off
    2 2
  endline
endscrap
''';
    final (TH2File file, bool isSuccessful, List<String> errors) =
        await parseText(text);

    expect(isSuccessful, isTrue, reason: errors.join('\n'));

    final THLine line = onlyLine(file);
    final List<int> segmentMPIDs = line.getLineSegmentMPIDs(file);
    final THLineSegment firstSegment =
        file.elementByMPID(segmentMPIDs.first) as THLineSegment;

    expect(firstSegment.hasOption(THCommandOptionType.smooth), isTrue);

    /// The writer writes a line point's options right after the point, so the
    /// option line moves above the empty line, and saving again keeps it there.
    const String saved = '''encoding UTF-8
scrap s1
  line wall
    1 1
    smooth off

    2 2
  endline
endscrap
''';

    expect(asSaved(file), saved);

    final (TH2File reparsed, bool isReparseSuccessful, _) = await parseText(
      saved,
    );

    expect(isReparseSuccessful, isTrue);
    expect(asSaved(reparsed), saved);
  });

  test('blank line before a line option before the first point', () async {
    const String text = '''encoding UTF-8
scrap s1
  line wall

    close on
    1 1
    2 2
  endline
endscrap
''';
    final (TH2File file, bool isSuccessful, List<String> errors) =
        await parseText(text);

    expect(isSuccessful, isTrue, reason: errors.join('\n'));
    expect(onlyLine(file).hasOption(THCommandOptionType.close), isTrue);
  });

  test('multiline comment before a line point option', () async {
    const String text = '''encoding UTF-8
scrap s1
  line wall
    1 1
    comment
    x
    endcomment
    smooth off
    2 2
  endline
endscrap
''';
    final (TH2File file, bool isSuccessful, List<String> errors) =
        await parseText(text);

    expect(isSuccessful, isTrue, reason: errors.join('\n'));

    final THLine line = onlyLine(file);
    final THLineSegment firstSegment =
        file.elementByMPID(line.getLineSegmentMPIDs(file).first)
            as THLineSegment;

    expect(firstSegment.hasOption(THCommandOptionType.smooth), isTrue);
  });
}
