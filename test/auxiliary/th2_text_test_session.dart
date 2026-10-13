// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/th2_text_apply_session.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

/// A [TH2TextApplySession] with plain fields, for the Phase 2 apply tests.
class TH2TextTestSession implements TH2TextApplySession {
  @override
  int sessionRevision = 0;

  @override
  bool isOpen = true;

  @override
  String content;

  @override
  String initialContent;

  @override
  TH2TextLineMap initialLineMap;

  @override
  int cursorLine = 0;

  @override
  TH2TextValidationCache validationCache;

  /// How many times [lockBuffer] was called.
  int lockBufferCalls = 0;

  TH2TextTestSession._({
    required this.content,
    required this.initialContent,
    required this.initialLineMap,
    required this.validationCache,
  });

  /// A session describing the live model of [controller].
  factory TH2TextTestSession.of(
    TH2FileEditController controller, {
    TH2TextValidationCache? validationCache,
  }) {
    final (String text, TH2TextLineMap lineMap) = controller
        .serializeForTextMode();

    return TH2TextTestSession._(
      content: text,
      initialContent: text,
      initialLineMap: lineMap,
      validationCache: validationCache ?? TH2TextValidationCache(),
    );
  }

  /// Makes the session describe the live model of [controller] again, as a
  /// session that stays in text mode after an apply does.
  void restartFrom(TH2FileEditController controller) {
    final (String text, TH2TextLineMap lineMap) = controller
        .serializeForTextMode();

    content = text;
    initialContent = text;
    initialLineMap = lineMap;
    validationCache.clear();
  }

  @override
  void lockBuffer() {
    lockBufferCalls++;
  }
}
