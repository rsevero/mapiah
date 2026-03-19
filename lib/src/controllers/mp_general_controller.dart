// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mapiah/src/auxiliary/mp_copy_element_result.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mobx/mobx.dart';

part 'mp_general_controller.g.dart';

class MPGeneralController = MPGeneralControllerBase with _$MPGeneralController;

abstract class MPGeneralControllerBase with Store {
  int _nextMPIDForElements = mpFirstMPIDForElements;
  int _nextMPIDForTH2Files = mpFirstMPIDForTH2Files;

  String _lastAccessedDirectory = '';

  String get lastAccessedDirectory => _lastAccessedDirectory;

  @readonly
  String _thConfigFilePath = '';

  @readonly
  ObservableList<String> _openFileOrder = ObservableList<String>();

  @readonly
  int _activeTabIndex = 0;

  final HashMap<String, TH2FileEditController> _t2hFileEditControllers =
      HashMap<String, TH2FileEditController>();

  List<String> _availableEncodings = ['ASCII', 'UTF-8'];

  /// Global clipboard for copy/paste operations.
  List<MPCopyElementWithChildren>? _clipboard;

  MPGeneralControllerBase() {
    Future<void>.microtask(() async {
      await updateAvailableEncodingsList();
    });
  }

  set lastAccessedDirectory(String value) {
    if (!value.endsWith('/')) {
      value += '/';
    }
    _lastAccessedDirectory = value;
  }

  @action
  void setTHConfigFilePath(String value) {
    _thConfigFilePath = value.trim();
  }

  String get thConfigFilePath => _thConfigFilePath;

  void _clearActiveTabOverlayWindows() {
    if ((_activeTabIndex >= 0) && (_activeTabIndex < _openFileOrder.length)) {
      final String outgoingFilename = _openFileOrder[_activeTabIndex];
      final TH2FileEditController? outgoingController =
          _t2hFileEditControllers[outgoingFilename];

      outgoingController?.overlayWindowController.clearOverlayWindows();
    }
  }

  @action
  void addFileTab(String filename) {
    _clearActiveTabOverlayWindows();

    if (!_openFileOrder.contains(filename)) {
      _openFileOrder.add(filename);
    }
    _activeTabIndex = _openFileOrder.indexOf(filename);
  }

  @action
  void removeFileTab({required String filename}) {
    final int indexToRemove = _openFileOrder.indexOf(filename);

    if (indexToRemove != -1) {
      _openFileOrder.removeAt(indexToRemove);
      removeFileController(filename: filename);

      if (_openFileOrder.isEmpty) {
        _activeTabIndex = 0;
      } else if (_activeTabIndex >= _openFileOrder.length) {
        _activeTabIndex = _openFileOrder.length - 1;
      }
    }
  }

  @action
  void setActiveTab(int index) {
    if ((index >= 0) && (index < _openFileOrder.length)) {
      /// Close all overlay windows on the outgoing tab before switching.
      if (_activeTabIndex != index) {
        _clearActiveTabOverlayWindows();
      }

      _activeTabIndex = index;

      /// Give keyboard focus to the incoming tab's canvas so that shortcuts
      /// such as Ctrl+V are delivered there and not to an offstage canvas.
      /// TH2FileTabsPage also reinforces this via a post-frame callback, but
      /// calling requestFocus here ensures focus is correct even in contexts
      /// where the page is not yet mounted (e.g. logic-level tests).
      final String incomingFilename = _openFileOrder[index];
      final TH2FileEditController? incomingController =
          _t2hFileEditControllers[incomingFilename];

      incomingController?.th2FileFocusNode.requestFocus();
    }
  }

  @action
  void reorderFileTabs(List<String> newOrder) {
    // Only update if the new order has the same number of files
    if (newOrder.length != _openFileOrder.length) {
      return;
    }

    // Get the current active filename
    final String? currentActiveFilename =
        (_activeTabIndex >= 0 && _activeTabIndex < _openFileOrder.length)
        ? _openFileOrder[_activeTabIndex]
        : null;

    // Update the order
    _openFileOrder.clear();
    _openFileOrder.addAll(newOrder);

    // Update activeTabIndex to match the new position of the currently active file
    if (currentActiveFilename != null &&
        newOrder.contains(currentActiveFilename)) {
      _activeTabIndex = newOrder.indexOf(currentActiveFilename);
    }
  }

  int nextMPIDForElements() {
    return _nextMPIDForElements++;
  }

  int nextMPIDForTH2Files() {
    return _nextMPIDForTH2Files--;
  }

  /// Get the current clipboard content.
  List<MPCopyElementWithChildren>? getClipboard() {
    return _clipboard;
  }

  /// Set the clipboard content.
  void setClipboard(List<MPCopyElementWithChildren>? copyResult) {
    _clipboard = copyResult;
  }

  /// Check if clipboard has content.
  bool get hasClipboardContent =>
      (_clipboard != null) && _clipboard!.isNotEmpty;

  /// Reset the Mapiah ID for elements to the first value.
  /// Should only be used for tests.
  void reset() {
    _nextMPIDForElements = mpFirstMPIDForElements;
    _nextMPIDForTH2Files = mpFirstMPIDForTH2Files;
    _t2hFileEditControllers.clear();
    _thConfigFilePath = '';
    _clipboard = null;
  }

  TH2FileEditController? getTH2FileEditControllerIfExists(String filename) {
    return _t2hFileEditControllers[filename];
  }

  TH2FileEditController getTH2FileEditController({
    required String filename,
    final Uint8List? fileBytes,
    bool forceNewController = false,
  }) {
    if (_t2hFileEditControllers.containsKey(filename)) {
      if (forceNewController) {
        _t2hFileEditControllers.remove(filename);
      } else {
        return _t2hFileEditControllers[filename]!;
      }
    }

    final TH2FileEditController createdController =
        TH2FileEditControllerBase.create(filename, fileBytes: fileBytes);

    _t2hFileEditControllers[filename] = createdController;

    return createdController;
  }

  TH2FileEditController getTH2FileEditControllerForNewFile({
    required String scrapTHID,
    required List<THCommandOption> scrapOptions,
    required String encoding,
  }) {
    final TH2File th2File = TH2File();
    final int thFileMPID = th2File.mpID;
    final int filenameNumber = thFileMPID.abs();
    final String filename = '${mpNewFilePrefix}_$filenameNumber';
    final THEncoding thEncoding = THEncoding(
      parentMPID: thFileMPID,
      encoding: encoding,
    );
    final THScrap thScrap = THScrap(parentMPID: thFileMPID, thID: scrapTHID);
    final int thScrapMPID = thScrap.mpID;
    final THEndscrap thEndscrap = THEndscrap(parentMPID: thScrapMPID);

    th2File.isNewFile = true;
    th2File.filename = filename;
    th2File.addElement(thEncoding);
    th2File.addElementToParent(thEncoding);
    th2File.addElement(thScrap);
    th2File.addElementToParent(thScrap);
    th2File.addElement(thEndscrap);
    thScrap.addElementToParent(
      thEndscrap,
      elementPositionInParent: mpAddChildAtEndOfParentChildrenList,
    );

    for (THCommandOption option in scrapOptions) {
      if (option.parentMPID != thScrapMPID) {
        option = option.copyWith(parentMPID: thScrapMPID);
      }
      thScrap.addUpdateOption(option);
    }

    if (_t2hFileEditControllers.containsKey(filename)) {
      throw Exception(
        'At MPGeneralController.getTH2FileEditControllerForNewFile: controller for new file $filename already exists',
      );
    }

    final TH2FileEditController createdController =
        TH2FileEditControllerBase.createFromNewTH2File(th2File);

    createdController.setActiveScrap(thScrapMPID);
    createdController.setFilename(filename);

    _t2hFileEditControllers[filename] = createdController;

    return createdController;
  }

  void renameFileController({
    required String oldFilename,
    required String newFilename,
  }) {
    if (_t2hFileEditControllers.containsKey(oldFilename)) {
      final TH2FileEditController controller = _t2hFileEditControllers.remove(
        oldFilename,
      )!;

      _t2hFileEditControllers[newFilename] = controller;
    }

    final int index = _openFileOrder.indexOf(oldFilename);

    if (index >= 0) {
      _openFileOrder[index] = newFilename;
    }
  }

  void removeFileController({required String filename}) {
    if (_t2hFileEditControllers.containsKey(filename)) {
      _t2hFileEditControllers.remove(filename);
    }
  }

  List<String> getAvailableEncodings() {
    return _availableEncodings;
  }

  void addAvailableEncoding(String encoding) {
    final String newEncoding = encoding.trim().toUpperCase();

    if (newEncoding.isNotEmpty && !_availableEncodings.contains(newEncoding)) {
      _availableEncodings.add(newEncoding);
      _availableEncodings = MPTextToUser.getOrderedChoicesList(
        _availableEncodings,
      );
    }
  }

  Future<void> updateAvailableEncodingsList() async {
    try {
      final String therionExecutablePath =
          _resolveTherionExecutablePathForEncodingDiscovery();
      final ProcessResult result = await Process.run(
        therionExecutablePath,
        const [mpTherionPrintEncodingsArgument],
      );

      if (result.exitCode != 0) {
        return;
      }

      /// Switch expression doing type pattern matching on result.stdout
      /// (dynamic):
      /// * If stdout is already a String (String s => s), use it directly.
      /// * If it is raw bytes (List<int> bytes => utf8.decode(bytes)), decode
      ///   as UTF‑8.
      /// * Otherwise (_ => result.stdout.toString()), fall back to toString().
      /// Result: stdoutString is a normalized String regardless of the original
      /// stdout representation on different platforms.
      final String stdoutString = switch (result.stdout) {
        String s => s,
        List<int> bytes => utf8.decode(bytes),
        _ => result.stdout.toString(),
      };
      final List<String> encodings = _extractEncodingsFromTherionOutput(
        stdoutString,
      );

      for (final String encoding in encodings) {
        addAvailableEncoding(encoding);
      }
    } catch (_) {
      // Ignore (therion not installed or not in PATH)
    }
  }

  String _resolveTherionExecutablePathForEncodingDiscovery() {
    final String configuredTherionExecutablePath =
        _configuredTherionExecutablePath();
    final bool hasConfiguredTherionExecutablePath =
        configuredTherionExecutablePath.isNotEmpty;

    if (hasConfiguredTherionExecutablePath) {
      return configuredTherionExecutablePath;
    }

    return _defaultTherionExecutableCommandForCurrentPlatform();
  }

  String _configuredTherionExecutablePath() {
    final MPLocator mpLocator = MPLocator();
    final String configuredTherionExecutablePath = mpLocator
        .mpSettingsController
        .getStringWithDefault(MPSettingID.Main_TherionExecutablePath)
        .trim();

    return configuredTherionExecutablePath;
  }

  String _defaultTherionExecutableCommandForCurrentPlatform() {
    final bool isWindowsPlatform = Platform.isWindows;

    if (isWindowsPlatform) {
      return '$mpTherionExecutableName$mpWindowsExecutableExtension';
    }

    return mpTherionDefaultExecutableCommand;
  }

  List<String> _extractEncodingsFromTherionOutput(String output) {
    final Set<String> set = <String>{};
    final RegExp tokenRegExp = RegExp(r'^[A-Za-z0-9._\-]+$');

    for (final String rawLine in output.split(RegExp(r'[\r\n]+'))) {
      final String line = rawLine.trim();

      if (line.isEmpty) {
        continue;
      }

      for (final String token in line.split(RegExp(r'\s+'))) {
        final String t = token.trim();

        if (t.isEmpty) {
          continue;
        }
        if (tokenRegExp.hasMatch(t)) {
          set.add(t);
        }
      }
    }

    final List<String> list = MPTextToUser.getOrderedChoicesList(set);

    return list;
  }
}
