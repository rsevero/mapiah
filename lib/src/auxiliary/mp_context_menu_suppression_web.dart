// Platform-specific context menu suppression for Flutter web using package:web and dart:js_interop.
// Only imported on web via conditional imports.

import 'package:web/web.dart' as web;
import 'dart:js_interop';

void suppressContextMenu() {
  web.window.addEventListener(
    'contextmenu',
    ((web.Event event) {
      event.preventDefault();
    }).toJS,
    false.toJS,
  );
}
