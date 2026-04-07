// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'package:flutter/services.dart';

const MethodChannel _windowSizeMethodChannel = MethodChannel(
  'flutter/windowsize',
);

const String _setWindowTitleMethod = 'setWindowTitle';

/// Updates the desktop window title when the plugin is available.
Future<void> mpSetWindowTitleIfAvailable(final String title) async {
  try {
    await _windowSizeMethodChannel.invokeMethod<void>(
      _setWindowTitleMethod,
      title,
    );
  } on MissingPluginException {
    // Widget tests do not register desktop plugins, so ignore missing handlers.
  } on PlatformException {
    // Ignore unsupported platform/plugin failures outside desktop runtime.
  }
}
