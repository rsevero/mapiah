// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
class THBaseException implements Exception {
  final String message;
  final StackTrace stackTrace;

  THBaseException(this.message, [StackTrace? stackTrace])
    : stackTrace = stackTrace ?? StackTrace.current;

  @override
  String toString() => message;
}
