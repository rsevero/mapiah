// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/th_project/th2_file_node.dart';
import 'package:mapiah/src/elements/th_project/th_project_file_node.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/pages/th2_file_tabs_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

const String th2TreeValidContents =
    'encoding utf-8\n'
    'scrap s1 -projection plan\n'
    '  point 1 1 station -id p1 -name 1\n'
    '  line wall -id l1\n'
    '    10 20\n'
    '    30 40\n'
    '  endline\n'
    '  point 3 3 station -id p3 -name 3\n'
    'endscrap\n'
    'scrap s2 -projection plan\n'
    '  point 5 5 station -id p2 -name 2\n'
    'endscrap\n';

const String th2TreeBrokenContents =
    'encoding utf-8\n'
    'point 1 1 station\n'
    'scrap s1\n'
    '  poin 2 2 station\n'
    'endscrap\n';

const String th2TreeOtherBrokenContents =
    'encoding utf-8\n'
    'scrap s1\n'
    'endscrap\n'
    'endscrap\n';

/// A duplicated scrap id makes the parser throw an unexpected exception.
const String th2TreeThrowingContents =
    'encoding utf-8\n'
    'scrap repeated\n'
    'endscrap\n'
    'scrap repeated\n'
    'endscrap\n';

/// A temporary project: `thconfig` sources `cave.th`, which inputs
/// `a.th2` and `b.th2`.
class TH2TreeTestProject {
  final Directory directory;

  TH2TreeTestProject._(this.directory);

  static TH2TreeTestProject create({
    String aContents = th2TreeValidContents,
    String bContents = th2TreeValidContents,
  }) {
    final Directory directory = Directory.systemTemp.createTempSync(
      'mapiah_th2_tree_',
    );
    final TH2TreeTestProject project = TH2TreeTestProject._(directory);

    File(project.configPath).writeAsStringSync('source cave.th\n');
    File(p.join(directory.path, 'cave.th')).writeAsStringSync(
      'survey cave\n  input a.th2\n  input b.th2\nendsurvey\n',
    );
    project.write('a.th2', aContents);
    project.write('b.th2', bContents);

    return project;
  }

  String get configPath => p.join(directory.path, 'thconfig');

  String pathOf(String name) => p.join(directory.path, name);

  void write(String name, String contents) {
    File(pathOf(name)).writeAsStringSync(contents);
  }

  void delete() {
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }
}

/// The project node of the `.th2` file [name] of [project].
TH2FileNode th2NodeOf(TH2TreeTestProject project, String name) {
  final THProjectFileNode? node = mpLocator.thProjectController
      .nodeByCanonicalPath(project.pathOf(name));

  return node! as TH2FileNode;
}

/// The whole workspace (tabs plus project tree) for widget tests.
Widget buildTH2TreeTestApp({Locale locale = const Locale('en')}) {
  mpLocator.mpSettingsController.setBool(
    MPSettingID.Main_TelemetryConsent,
    false,
  );

  return MaterialApp(
    localizationsDelegates: <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: const TH2FileTabsPage(),
  );
}

/// Lets real file I/O finish, pumping frames, until [until] holds (or a
/// bounded number of attempts ran).
Future<void> settleTH2Tree(
  WidgetTester tester, {
  bool Function()? until,
  int maxAttempts = 40,
}) async {
  for (int attempt = 0; attempt < maxAttempts; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();

    if ((until != null) && until()) {
      break;
    }
  }

  await tester.pump();
}

/// Waits until the controller of [path] exists and finished loading or
/// failed.
Future<TH2FileEditController?> settleTH2Load(
  WidgetTester tester,
  String path,
) async {
  bool isSettled() {
    final TH2FileEditController? controller = mpLocator.mpGeneralController
        .getTH2FileEditControllerIfExists(path);

    return (controller != null) &&
        (controller.isFileLoaded || (controller.loadError != null));
  }

  await settleTH2Tree(tester, until: isSettled);

  return mpLocator.mpGeneralController.getTH2FileEditControllerIfExists(path);
}

/// Opens [project] with real I/O inside a widget test.
Future<void> openTH2TreeProject(
  WidgetTester tester,
  TH2TreeTestProject project,
) async {
  await tester.runAsync(
    () => mpLocator.thProjectController.openProject(project.configPath),
  );
  await tester.pump();
}
