// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mobx/mobx.dart';

/// The per-file operation gate: a try-lock that admits one gated operation
/// at a time. A request made while an operation runs is dropped.
class TH2FileOperationGate {
  final bool Function() _isOwnerDisposed;

  final Observable<bool> _isBusy = Observable<bool>(
    false,
    name: 'TH2FileOperationGate.isBusy',
  );

  TH2FileOperationGate({required bool Function() isOwnerDisposed})
    : _isOwnerDisposed = isOwnerDisposed;

  /// Whether a gated operation is running. Observable.
  bool get isBusy => _isBusy.value;

  /// Runs [body] unless an operation is already running or the owner is
  /// disposed, in which case it returns `null` at once without running it.
  Future<T?> run<T>(Future<T> Function() body) async {
    if (_isBusy.value || _isOwnerDisposed()) {
      return null;
    }

    runInAction(() => _isBusy.value = true);

    try {
      return await body();
    } finally {
      runInAction(() => _isBusy.value = false);
    }
  }
}
