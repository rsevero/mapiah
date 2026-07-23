// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_placement.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

typedef MPWindowErrorHandler =
    void Function(String message, Object error, StackTrace stackTrace);

/// Platform operations needed to restore and persist the desktop window.
abstract interface class MPPlatformWindow {
  Future<void> ensureInitialized();

  Future<void> maximize();

  Future<void> unmaximize();

  Future<bool> isMaximized();

  Future<bool> isFullScreen();

  Future<Rect> getBounds();

  Future<List<Rect>> getDisplayBounds();

  Future<void> setBounds(Rect bounds);

  Future<void> setPreventClose(bool preventClose);

  Future<void> closeApplication();

  void setCloseHandler(Future<void> Function() closeHandler);
}

/// Adapts the window_manager plugin to Mapiah's window lifecycle.
class MPWindowManagerPlatform with WindowListener implements MPPlatformWindow {
  Future<void> Function()? _closeHandler;

  @override
  Future<void> ensureInitialized() => windowManager.ensureInitialized();

  @override
  Future<void> maximize() => windowManager.maximize();

  @override
  Future<void> unmaximize() => windowManager.unmaximize();

  @override
  Future<bool> isMaximized() => windowManager.isMaximized();

  @override
  Future<bool> isFullScreen() => windowManager.isFullScreen();

  @override
  Future<Rect> getBounds() => windowManager.getBounds();

  @override
  Future<List<Rect>> getDisplayBounds() async {
    final List<Display> displays = await screenRetriever.getAllDisplays();
    final int displayCount = math.min(
      displays.length,
      mpMaximumRestoredWindowDisplayCount,
    );
    final List<Rect> displayBounds = <Rect>[];

    for (int index = 0; index < displayCount; index++) {
      final Display display = displays[index];
      final Offset position = display.visiblePosition ?? Offset.zero;
      final Size size = display.visibleSize ?? display.size;
      final Rect bounds = position & size;

      if (bounds.isFinite && !bounds.isEmpty) {
        displayBounds.add(bounds);
      }
    }

    return displayBounds;
  }

  @override
  Future<void> setBounds(Rect bounds) => windowManager.setBounds(bounds);

  @override
  Future<void> setPreventClose(bool preventClose) =>
      windowManager.setPreventClose(preventClose);

  @override
  Future<void> closeApplication() => SystemNavigator.pop();

  @override
  void setCloseHandler(Future<void> Function() closeHandler) {
    _closeHandler = closeHandler;
    windowManager.addListener(this);
  }

  @override
  void onWindowClose() {
    final Future<void> Function()? closeHandler = _closeHandler;

    if (closeHandler != null) {
      unawaited(closeHandler());
    }
  }
}

/// Restores the saved window placement and persists it before native close.
class MPWindowPlacementController {
  final MPSettingsController settingsController;
  final MPPlatformWindow platformWindow;
  final MPWindowErrorHandler onError;

  bool _isClosing = false;

  MPWindowPlacementController({
    required this.settingsController,
    required this.platformWindow,
    required this.onError,
  });

  /// Initializes native close interception and applies the saved placement.
  Future<void> initialize() async {
    await platformWindow.ensureInitialized();
    platformWindow.setCloseHandler(saveAndClose);
    await platformWindow.setPreventClose(true);

    final MPWindowPlacement placement = settingsController.windowPlacement;

    if (placement.isMaximized) {
      await platformWindow.maximize();
    } else {
      final Rect savedBounds = placement.bounds!;
      final List<Rect> displayBounds = await platformWindow.getDisplayBounds();

      if (isPlacementCompatibleWithDisplays(savedBounds, displayBounds)) {
        await platformWindow.unmaximize();
        await platformWindow.setBounds(savedBounds);
      } else {
        await platformWindow.maximize();
      }
    }
  }

  /// Whether saved bounds remain usable with the current display layout.
  static bool isPlacementCompatibleWithDisplays(
    Rect savedBounds,
    List<Rect> displayBounds,
  ) {
    if (!savedBounds.isFinite || savedBounds.isEmpty || displayBounds.isEmpty) {
      return false;
    }

    final int displayCount = math.min(
      displayBounds.length,
      mpMaximumRestoredWindowDisplayCount,
    );
    final List<Rect> validDisplayBounds = <Rect>[];

    for (int index = 0; index < displayCount; index++) {
      final Rect bounds = displayBounds[index];

      if (bounds.isFinite && !bounds.isEmpty) {
        validDisplayBounds.add(bounds);
      }
    }

    if (validDisplayBounds.isEmpty) {
      return false;
    }

    Rect desktopBounds = validDisplayBounds.first;

    for (int index = 1; index < validDisplayBounds.length; index++) {
      desktopBounds = desktopBounds.expandToInclude(validDisplayBounds[index]);
    }

    if ((savedBounds.width > desktopBounds.width) ||
        (savedBounds.height > desktopBounds.height)) {
      return false;
    }

    final double minimumVisibleWidth = math.min(
      savedBounds.width,
      mpMinimumRestoredWindowVisibleLength,
    );
    final double minimumVisibleHeight = math.min(
      savedBounds.height,
      mpMinimumRestoredWindowVisibleLength,
    );

    for (int index = 0; index < validDisplayBounds.length; index++) {
      final Rect intersection = savedBounds.intersect(
        validDisplayBounds[index],
      );

      if ((intersection.width >= minimumVisibleWidth) &&
          (intersection.height >= minimumVisibleHeight)) {
        return true;
      }
    }

    return false;
  }

  /// Saves the current placement and then allows the native window to close.
  Future<void> saveAndClose() async {
    if (_isClosing) {
      return;
    }

    _isClosing = true;

    try {
      final bool isMaximized =
          await platformWindow.isMaximized() ||
          await platformWindow.isFullScreen();
      final MPWindowPlacement placement;

      if (isMaximized) {
        placement = const MPWindowPlacement.maximized();
      } else {
        final Rect bounds = await platformWindow.getBounds();

        placement = MPWindowPlacement.windowed(bounds: bounds);
      }

      await settingsController.setWindowPlacement(placement);
    } on Object catch (error, stackTrace) {
      onError(
        'Failed to persist the desktop window placement',
        error,
        stackTrace,
      );
    }

    try {
      await platformWindow.closeApplication();
    } on Object catch (error, stackTrace) {
      onError('Failed to close the desktop window', error, stackTrace);
    }
  }
}
