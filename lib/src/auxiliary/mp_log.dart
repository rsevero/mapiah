import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

Logger get logger => MPLog.instance;

enum MPLogLevel {
  all,
  finest,
  finer,
  fine,
  debug,
  info,
  warning,
  error,
  fatal,
  off,
}

/// Logger package levels:
///
/// enum Level {
///  trace,
///  debug,
///  info,
///  warning,
///  error,
///  fatal,
///  off,
/// }

/// logging package levels:
///
/// Level.ALL
/// Level.FINEST
/// Level.FINER
/// Level.FINE
/// Level.CONFIG
/// Level.INFO
/// Level.WARNING
/// Level.SEVERE
/// Level.SHOUT
/// Level.OFF

class MPLog extends Logger {
  MPLog._()
      : super(
          filter: null,
          printer: PrettyPrinter(
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
            printEmojis: true,
            colors: true,
          ),
        );

  static final instance = MPLog._();

  bool _shouldLog(MPLogLevel logLevel) {
    if (kDebugMode) {
      return (Enum.compareByIndex(logLevel, MPLogLevel.fine) > 0);
    } else {
      return (Enum.compareByIndex(logLevel, MPLogLevel.info) > 0);
    }
  }

  /// Log a message at level [MPLogLevel.finest].
  void finest(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    if (_shouldLog(MPLogLevel.finest)) {
      super.t(message, error: error, stackTrace: stackTrace, time: time);
    }
  }

  /// Log a message at level [MPLogLevel.finer].
  void finer(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    if (_shouldLog(MPLogLevel.finer)) {
      super.t(message, error: error, stackTrace: stackTrace, time: time);
    }
  }

  /// Log a message at level [MPLogLevel.fine].
  void fine(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    if (_shouldLog(MPLogLevel.fine)) {
      super.t(message, error: error, stackTrace: stackTrace, time: time);
    }
  }

  /// Log a message at level [MPLogLevel.fine].
  @Deprecated(
      "MPLog.t() exists only to mask Logger.t(). There are 3 options to use instead: for [MPLogLevel.fine] use fine() instead, for [MPLogLevel.finer] use finer() instead, for [MPLogLevel.finest] use finset() instead.")
  @override
  void t(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    if (_shouldLog(MPLogLevel.fine)) {
      super.t(message, error: error, stackTrace: stackTrace, time: time);
    }
  }

  /// Log a message at level [MPLogLevel.debug].
  @override
  void d(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    if (_shouldLog(MPLogLevel.debug)) {
      super.d(message, error: error, stackTrace: stackTrace, time: time);
    }
  }

  /// Log a message at level [MPLogLevel.info].
  @override
  void i(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    if (_shouldLog(MPLogLevel.info)) {
      super.i(message, error: error, stackTrace: stackTrace, time: time);
    }
  }

  /// Log a message at level [MPLogLevel.warning].
  @override
  void w(dynamic message,
      {Object? error, StackTrace? stackTrace, DateTime? time}) {
    if (_shouldLog(MPLogLevel.warning)) {
      super.w(message, error: error, stackTrace: stackTrace, time: time);
    }
  }

  /// Log a message at level [MPLogLevel.error].
  @override
  void e(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    if (_shouldLog(MPLogLevel.error)) {
      super.e(message, error: error, stackTrace: stackTrace, time: time);
    }
  }

  /// Log a message at level [MPLogLevel.fatal].
  @override
  void f(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    DateTime? time,
  }) {
    if (_shouldLog(MPLogLevel.fatal)) {
      super.f(message, error: error, stackTrace: stackTrace, time: time);
    }
  }
}
