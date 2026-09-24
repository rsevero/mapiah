// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

// Generates the English and Portuguese release PDFs from every help asset.
// Run from the repository root: dart run scripts/generate_user_guides.dart
import 'dart:io';

import 'package:markdown/markdown.dart' as markdown;

const List<String> preferredOrder = <String>[
  'installation.md',
  'instalacao.md',
  'mapiah_home_help.md',
  'th2_file_edit_page_help.md',
  'keyboard_shortcuts_main.md',
  'keyboard_shortcuts_edit.md',
  'mp_settings_page_help.md',
  'run_therion_help.md',
  'telemetry.md',
  'telemetry_consent.md',
  'no_therion_found.md',
  'flathub_disabled.md',
];

const Map<String, String> englishTitles = <String, String>{
  'installation.md': 'Installation',
  'mapiah_home_help.md': 'Workspace and projects',
  'th2_file_edit_page_help.md': 'Drawing editor',
  'keyboard_shortcuts_main.md': 'Workspace keyboard shortcuts',
  'keyboard_shortcuts_edit.md': 'Drawing keyboard shortcuts',
  'mp_settings_page_help.md': 'Settings',
  'run_therion_help.md': 'Run Therion',
  'telemetry.md': 'Telemetry',
  'telemetry_consent.md': 'Telemetry consent',
  'no_therion_found.md': 'Therion installation',
  'flathub_disabled.md': 'Flatpak information',
};

const Map<String, String> portugueseTitles = <String, String>{
  'instalacao.md': 'Instalação',
  'mapiah_home_help.md': 'Espaço de trabalho e projetos',
  'th2_file_edit_page_help.md': 'Editor de desenho',
  'keyboard_shortcuts_main.md': 'Atalhos do espaço de trabalho',
  'keyboard_shortcuts_edit.md': 'Atalhos do editor de desenho',
  'mp_settings_page_help.md': 'Configurações',
  'run_therion_help.md': 'Executar Therion',
  'telemetry.md': 'Telemetria',
  'telemetry_consent.md': 'Consentimento de telemetria',
  'no_therion_found.md': 'Instalação do Therion',
  'flathub_disabled.md': 'Informações sobre Flatpak',
};

Future<void> main() async {
  final Directory root = Directory.current;

  final File manifest = File('${root.path}/pubspec.yaml');

  final RegExpMatch? versionMatch = RegExp(r'^version:\s*(\S+)', multiLine: true)
      .firstMatch(await manifest.readAsString());

  if (versionMatch == null) {
    throw StateError('Could not read the Mapiah version from pubspec.yaml.');
  }

  final String version = versionMatch.group(1)!;

  final String browser = Platform.environment['CHROME_BIN'] ?? 'google-chrome';

  final Directory temporary = await Directory.systemTemp.createTemp('mapiah-guide-');

  try {
    for (final String language in <String>['en', 'pt']) {
      final Map<String, String> titles =
          language == 'en' ? englishTitles : portugueseTitles;

      final String html = await buildGuideHtml(root, language, version, titles);

      final File htmlFile = File('${temporary.path}/guide-$language.html');

      await htmlFile.writeAsString(html);

      final String fileName = language == 'pt'
          ? 'Mapiah-Guia_do_usuario-pt.pdf'
          : 'Mapiah-User-Guide-en.pdf';

      final File generated = File('${temporary.path}/$fileName');

      final ProcessResult result = await Process.run(browser, <String>[
        '--headless',
        '--no-sandbox',
        '--disable-gpu',
        '--disable-dev-shm-usage',
        '--no-pdf-header-footer',
        '--allow-file-access-from-files',
        '--print-to-pdf=${generated.path}',
        htmlFile.uri.toString(),
      ]);

      if ((result.exitCode != 0) || !await generated.exists()) {
        throw StateError('PDF generation failed for $language: ${result.stderr}');
      }

      final List<int> signature = await generated.openRead(0, 5).first;

      if (String.fromCharCodes(signature) != '%PDF-') {
        throw StateError('Chrome produced an invalid PDF for $language.');
      }

      final File destination = File('${root.path}/$fileName');

      await generated.copy(destination.path);
      stdout.writeln('Updated ${destination.path}');
    }
  } finally {
    await temporary.delete(recursive: true);
  }
}

/// Converts all Markdown help assets in one language into a printable guide.
Future<String> buildGuideHtml(
  Directory root,
  String language,
  String version,
  Map<String, String> titles,
) async {
  final Directory helpDirectory = Directory('${root.path}/assets/help/$language');

  final List<File> files = helpDirectory
      .listSync()
      .whereType<File>()
      .where((File file) => file.path.endsWith('.md'))
      .toList();

  final String installationName =
      language == 'en' ? 'installation.md' : 'instalacao.md';

  files.add(File('${root.path}/auxiliary/install_instructions/$installationName'));

  files.sort((File first, File second) {
    final String firstName = first.uri.pathSegments.last;

    final String secondName = second.uri.pathSegments.last;

    final int firstOrder = preferredOrder.indexOf(firstName);

    final int secondOrder = preferredOrder.indexOf(secondName);

    if ((firstOrder >= 0) && (secondOrder >= 0)) {
      return firstOrder.compareTo(secondOrder);
    }

    if (firstOrder >= 0) {
      return -1;
    }

    if (secondOrder >= 0) {
      return 1;
    }

    return firstName.compareTo(secondName);
  });

  if (files.isEmpty) {
    throw StateError('No Markdown help assets found for $language.');
  }

  final String guideTitle = language == 'en' ? 'User guide' : 'Guia do usuário';

  final String contentsTitle = language == 'en' ? 'Contents' : 'Sumário';

  final StringBuffer contents = StringBuffer();

  final StringBuffer chapters = StringBuffer();

  for (final File file in files) {
    final String name = file.uri.pathSegments.last;

    final String id = name.substring(0, name.length - 3);

    final String title = titles[name] ?? id.replaceAll('_', ' ');

    final String source = (await file.readAsString()).replaceAll(
      RegExp(r'<!-- SPDX-License-Identifier:.*?-->|<!-- Copyright.*?-->', dotAll: true),
      '',
    );

    String body = markdown.markdownToHtml(
      source,
      extensionSet: markdown.ExtensionSet.gitHubWeb,
    );

    // Keep local section links within their source chapter.
    body = body.replaceAllMapped(
      RegExp(r'(id="|href="#)([^"]+)"'),
      (Match match) => '${match.group(1)}$id-${match.group(2)}"',
    );

    contents.writeln('<li><a href="#$id">${escapeHtml(title)}</a></li>');
    chapters.writeln(
      '<section class="chapter" id="$id"><h1>${escapeHtml(title)}</h1>$body</section>',
    );
  }

  final String base = root.uri.toString();

  return '''<!doctype html>
<html lang="$language"><head><meta charset="utf-8"><base href="$base">
<title>Mapiah $guideTitle $version</title>
<style>
@page { size: A4; margin: 18mm 16mm; }
body { font-family: Arial, sans-serif; color: #202936; font-size: 10pt; line-height: 1.45; }
header { margin: 28mm 0 30mm; text-align: center; }
header h1 { font-size: 30pt; color: #174e63; }
header p { font-size: 14pt; }
nav { break-after: page; }
nav li { margin: 5pt 0; }
.chapter { break-before: page; }
h1, h2, h3, h4 { color: #174e63; break-after: avoid; }
h1 { font-size: 20pt; }
h2 { font-size: 15pt; margin-top: 20pt; }
h3 { font-size: 12pt; }
a { color: #126686; }
table { border-collapse: collapse; width: 100%; font-size: 8pt; }
th, td { border: 1px solid #a9bac2; padding: 4pt; text-align: left; overflow-wrap: anywhere; }
th { background: #e8f1f4; }
tr { break-inside: avoid; }
pre { white-space: pre-wrap; overflow-wrap: anywhere; background: #edf3f5; padding: 7pt; }
code { overflow-wrap: anywhere; }
img { max-width: 100%; max-height: 22pt; vertical-align: middle; }
</style></head><body>
<header><h1>Mapiah</h1><p>$guideTitle</p><p>$version</p></header>
<nav><h1>$contentsTitle</h1><ol>$contents</ol></nav>
$chapters
</body></html>''';
}

/// Escapes chapter titles inserted into HTML text nodes.
String escapeHtml(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
