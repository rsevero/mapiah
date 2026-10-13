// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'th_test_aux.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp';
  }
}

/// An empty date (`-`) left `isRange` unset, so `toMap`, `==` and
/// `hashCode` threw a `LateInitializationError`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  final MPLocator mpLocator = MPLocator();

  test('an empty date', () {
    final THDatetimePart empty = THDatetimePart(datetime: ' - ');

    expect(empty.isEmpty, isTrue);
    expect(empty.isRange, isFalse);
    expect(empty.toString(), '-');
    expect(empty.toMap(), <String, dynamic>{
      'partType': 'datetime',
      'datetime': '-',
      'isRange': false,
      'isEmpty': true,
    });
    expect(THDatetimePart.fromMap(empty.toMap()), empty);
    expect(empty.copyWith(), empty);
    expect(empty.hashCode, THDatetimePart(datetime: '-').hashCode);
    expect(empty == THDatetimePart(datetime: '2024'), isFalse);
  });

  test('a file with an author option with an empty date', () async {
    mpLocator.appLocalizations = AppLocalizationsEn();
    mpLocator.mpGeneralController.reset();

    final (TH2File file, bool isSuccessful, List<String> errors) =
        await TH2FileParser().parse(
          THTestAux.testPath(
            'th_file_parser-00265-scrap_with_author_option_with_empty_date_range.th2',
          ),
        );

    expect(isSuccessful, isTrue, reason: errors.join('\n'));
    expect(TH2File.fromMap(file.toMap()), file);
  });
}
