// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// What a `TH2TextEditController` needs from the controller that owns its
/// file. `TH2FileEditController` implements it, so the text session has no
/// operation coordinator of its own.
abstract interface class TH2TextEditOwner {
  /// The file's name, for validation.
  String get filename;

  /// The `TH2File`'s MPID, for validation.
  int get th2FileMPID;

  /// The file's line ending: Enter's ending and the validation default.
  String get defaultLineEnding;

  bool get isDisposed;

  /// Whether the file can be saved. Observable.
  bool get canSave;

  /// The operation-owned buffer lock. Observable.
  bool get isBufferLocked;

  /// Takes the buffer lock. Taking it while held changes nothing.
  void acquireBufferLock();

  /// Releases the buffer lock. Only an owner operation releases it,
  /// unconditionally at its end; releasing it when not held changes nothing.
  void releaseBufferLock();

  Future<void> save();

  /// The gated operation that ends the text session without an apply.
  Future<void> discardTextEdits();

  /// The gated canvas undo or redo of a session before its first text edit.
  Future<void> requestCanvasHistory({required bool redo});
}
