// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mapiah/src/generated/i18n/app_localizations_en.dart';
import 'package:path/path.dart' as p;

/// A file picker whose Save As answer the test controls: [result] at once,
/// or whatever completes [pending]. Like the Linux picker, it writes the
/// given bytes (empty) to the chosen path when [emptiesTarget] is set.
class TH2TextModeFakeFilePicker extends FilePickerPlatform {
  Uri? result;

  Completer<Uri?>? pending;

  bool emptiesTarget = false;

  int saveFileCalls = 0;

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    saveFileCalls++;

    final Completer<Uri?>? currentPending = pending;
    final Uri? answer = (currentPending == null)
        ? result
        : await currentPending.future;

    if (emptiesTarget && (answer != null)) {
      File(answer.toFilePath()).writeAsBytesSync(bytes);
    }

    return answer;
  }
}

/// Shared setup of the TH2 text mode tests (t3976–t3990).
class TH2TextModeTestAux {
  static final MPLocator _locator = MPLocator();

  /// Resets the app state the text mode tests touch.
  static Future<void> setUp() async {
    _locator.appLocalizations = AppLocalizationsEn();
    await _locator.mpSettingsController.initialized;
    MPTextToUser.initialize();
    _locator.thProjectController.closeProject();
    _locator.mpGeneralController.reset();
    _locator.mpSettingsController.setBool(
      MPSettingID.Main_TelemetryConsent,
      false,
    );
  }

  /// A new temporary directory, deleted at the end of the test.
  static Directory tempDirectory() {
    final Directory directory = Directory.systemTemp.createTempSync(
      'mapiah_th2_text_mode_',
    );

    addTearDown(() {
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    });

    return directory;
  }

  /// Writes [contents] to [name] in [directory] (a new temporary directory
  /// by default), loads it into a registered controller and, with [openTab],
  /// opens its tab.
  static Future<TH2FileEditController> open(
    String contents, {
    Directory? directory,
    String name = 'file.th2',
    bool openTab = true,
  }) async {
    final Directory targetDirectory = directory ?? tempDirectory();
    final String path = p.join(targetDirectory.path, name);

    File(path).writeAsStringSync(contents);

    final TH2FileEditController controller = _locator.mpGeneralController
        .getTH2FileEditController(filename: path);

    await controller.load();

    if (openTab) {
      _locator.mpGeneralController.addFileTab(path);
    }

    return controller;
  }

  /// Installs [picker] as the platform file picker for this test.
  static TH2TextModeFakeFilePicker installPicker() {
    final FilePickerPlatform previous = FilePickerPlatform.instance;
    final TH2TextModeFakeFilePicker picker = TH2TextModeFakeFilePicker();

    FilePickerPlatform.instance = picker;
    addTearDown(() => FilePickerPlatform.instance = previous);

    return picker;
  }

  /// Records every user message for this test.
  static List<String> captureUserMessages() {
    final List<String> messages = <String>[];

    TH2FileEditControllerBase.onUserMessageForTesting = messages.add;
    addTearDown(() => TH2FileEditControllerBase.onUserMessageForTesting = null);

    return messages;
  }

  /// Enters text mode and checks it did.
  static Future<TH2TextEditController> enter(
    TH2FileEditController controller,
  ) async {
    await controller.enterTextMode();
    expect(controller.editMode, TH2EditMode.text);

    final TH2TextEditController session = controller.textEditController!;

    expect(session.isOpen, isTrue);

    return session;
  }

  /// Replaces the buffer, as typing does.
  static void edit(TH2FileEditController controller, String content) {
    expect(controller.textEditController!.setContent(content), isTrue);
  }

  static String readFile(TH2FileEditController controller) {
    return File(controller.th2File.filename).readAsStringSync();
  }
}
