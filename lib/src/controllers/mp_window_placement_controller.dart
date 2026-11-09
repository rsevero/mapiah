// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show AppExitType;

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

  Future<void> hide();

  Future<void> closeApplication();

  void setCloseHandler(Future<void> Function() closeHandler);
}

/// Adapts the window_manager and screen_retriever native API to Mapiah's
/// window lifecycle.
class MPWindowManagerPlatform implements MPPlatformWindow {
  final Window? Function() _currentWindowProvider;
  final Future<void> Function() _exitApplication;

  Window? _window;
  Future<void> Function()? _closeHandler;
  bool _isPreventClose = false;
  bool _isClosingApplication = false;

  /// [currentWindowProvider] and [exitApplication] replace the native window
  /// lookup and the application exit in tests.
  MPWindowManagerPlatform({
    Window? Function()? currentWindowProvider,
    Future<void> Function()? exitApplication,
  }) : _currentWindowProvider =
           currentWindowProvider ?? WindowManager.instance.getCurrent,
       _exitApplication = exitApplication ?? _exitApplicationNow;

  static Future<void> _exitApplicationNow() async {
    await ServicesBinding.instance.exitApplication(AppExitType.required);
  }

  /// The application's window, resolved by [ensureInitialized].
  Window get _currentWindow {
    final Window? window = _window;

    if (window == null) {
      throw StateError('The desktop window is not initialized');
    }

    return window;
  }

  @override
  Future<void> ensureInitialized() async {
    if (_window != null) {
      return;
    }

    final Window? window = _currentWindowProvider();

    if (window == null) {
      throw StateError('No native desktop window is available');
    }

    _window = window;
    window.addListener(_onWindowEvent);
  }

  @override
  Future<void> maximize() async => _currentWindow.maximize();

  @override
  Future<void> unmaximize() async => _currentWindow.unmaximize();

  @override
  Future<bool> isMaximized() async => _currentWindow.isMaximized;

  @override
  Future<bool> isFullScreen() async => _currentWindow.isFullScreen;

  @override
  Future<Rect> getBounds() async => _currentWindow.bounds.toRect();

  @override
  Future<List<Rect>> getDisplayBounds() async {
    final List<Display> displays = DisplayManager.instance.getAll();
    final int displayCount = math.min(
      displays.length,
      mpMaximumRestoredWindowDisplayCount,
    );
    final List<Rect> displayBounds = <Rect>[];

    try {
      for (int index = 0; index < displayCount; index++) {
        final Rect bounds = displays[index].workArea.toRect();

        if (bounds.isFinite && !bounds.isEmpty) {
          displayBounds.add(bounds);
        }
      }
    } finally {
      for (final Display display in displays) {
        display.dispose();
      }
    }

    return displayBounds;
  }

  @override
  Future<void> setBounds(Rect bounds) async {
    _currentWindow.bounds = bounds.toNative();
  }

  @override
  Future<void> setPreventClose(bool preventClose) async {
    _isPreventClose = preventClose;
  }

  @override
  Future<void> hide() async => _currentWindow.hide();

  /// Closes the window past [setPreventClose], which ends the application.
  ///
  /// Exits the application directly when there is no window or the platform
  /// can't close it.
  @override
  Future<void> closeApplication() async {
    _isClosingApplication = true;

    final bool isClosing = _window?.close() ?? false;

    if (!isClosing) {
      _isClosingApplication = false;
      await _exitApplication();
    }
  }

  @override
  void setCloseHandler(Future<void> Function() closeHandler) {
    _closeHandler = closeHandler;
  }

  void _onWindowEvent(WindowEvent event) {
    if (event is! WindowCloseRequestedEvent) {
      return;
    }

    if (_isClosingApplication) {
      _isClosingApplication = false;

      return;
    }

    if (_isPreventClose) {
      event.request.cancel();
    }

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
      await platformWindow.hide();
    } on Object catch (error, stackTrace) {
      onError('Failed to hide the desktop window', error, stackTrace);
    }

    try {
      await platformWindow.closeApplication();
    } on Object catch (error, stackTrace) {
      onError('Failed to close the desktop window', error, stackTrace);
    }
  }
}
