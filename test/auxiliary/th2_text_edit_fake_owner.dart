// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_owner.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mobx/mobx.dart';

/// A [TH2TextEditOwner] that records calls and never writes disk or
/// traverses the live stack. Operations run [onSave], [onDiscard] and
/// [onCanvasHistory] when set; otherwise they are explicit refusals that do
/// nothing.
class TH2TextEditFakeOwner implements TH2TextEditOwner {
  @override
  String filename;

  @override
  int th2FileMPID;

  @override
  String defaultLineEnding;

  @override
  bool isDisposed = false;

  final Observable<bool> canSaveObservable;

  final Observable<bool> isBufferLockedObservable = Observable<bool>(false);

  int acquireCalls = 0;

  int releaseCalls = 0;

  int saveCalls = 0;

  int discardCalls = 0;

  final List<bool> canvasHistoryRequests = <bool>[];

  Future<void> Function()? onSave;

  Future<void> Function()? onDiscard;

  Future<void> Function(bool redo)? onCanvasHistory;

  TH2TextEditFakeOwner({
    this.filename = 'fake.th2',
    this.th2FileMPID = 1,
    this.defaultLineEnding = '\n',
    bool canSave = true,
  }) : canSaveObservable = Observable<bool>(canSave);

  /// An owner describing [controller]'s file.
  factory TH2TextEditFakeOwner.of(TH2FileEditController controller) {
    return TH2TextEditFakeOwner(
      filename: controller.th2File.filename,
      th2FileMPID: controller.th2File.mpID,
      defaultLineEnding: controller.th2File.lineEnding,
    );
  }

  @override
  bool get canSave => canSaveObservable.value;

  set canSave(bool value) => runInAction(() => canSaveObservable.value = value);

  @override
  bool get isBufferLocked => isBufferLockedObservable.value;

  @override
  void acquireBufferLock() {
    acquireCalls++;
    runInAction(() => isBufferLockedObservable.value = true);
  }

  @override
  void releaseBufferLock() {
    releaseCalls++;
    runInAction(() => isBufferLockedObservable.value = false);
  }

  /// Runs [operation] as an owner operation: it releases the lock at its end,
  /// whether or not it took it.
  Future<T> runOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } finally {
      releaseBufferLock();
    }
  }

  @override
  Future<void> save() async {
    saveCalls++;
    await onSave?.call();
  }

  @override
  Future<void> discardTextEdits() async {
    discardCalls++;
    await onDiscard?.call();
  }

  @override
  Future<void> requestCanvasHistory({required bool redo}) async {
    canvasHistoryRequests.add(redo);
    await onCanvasHistory?.call(redo);
  }
}

/// A TH2 text controller over [owner], with a session open on [content].
TH2TextEditController th2TextEditControllerWithSession(
  TH2TextEditFakeOwner owner,
  String content, {
  TH2TextLineMap? lineMap,
}) {
  final TH2TextEditController controller = TH2TextEditController(owner: owner);

  controller.installBaseline(
    TH2TextEditBaseline(
      content: content,
      lineMap: lineMap ?? th2EmptyTextLineMap(),
    ),
  );

  return controller;
}

/// A writer map with no lines, for sessions whose map is never read.
TH2TextLineMap th2EmptyTextLineMap() {
  return TH2TextLineMap.fromWriterLedger(
    ownerByLine: const <int?>[],
    th2File: TH2File(),
    relocations: const <TH2TextRelocation>[],
    addedEndings: const <TH2TextAddedEnding>[],
  );
}
