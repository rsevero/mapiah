// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mobx/mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'mp_telemetry_controller.g.dart';

class MPTelemetryController = MPTelemetryControllerBase
    with _$MPTelemetryController;

abstract class MPTelemetryControllerBase with Store {
  @observable
  bool? consentState;

  // In-memory state — not persisted.
  Timer? _retryTimer;
  int _openTH2Count = 0;
  DateTime? _th2SessionStartedAt;
  DateTime? _therionStartedAt;

  Future<void> initialize() async {
    final MPLocator locator = MPLocator();
    final bool? consent = locator.mpSettingsController.getBoolIfSet(
      MPSettingID.Main_TelemetryConsent,
    );

    consentState = consent;

    if (consent == true) {
      await _tryRolloverAndSend();
      _startRetryTimerIfNeeded();
    }
  }

  @action
  Future<void> setConsent(bool value) async {
    final MPLocator locator = MPLocator();

    consentState = value;
    locator.mpSettingsController.setBool(
      MPSettingID.Main_TelemetryConsent,
      value,
    );

    if (!value) {
      _cancelRetryTimer();
      _clearLocalData();
      unawaited(_sendOptOut());
    } else {
      unawaited(_sendOptIn());
      await _tryRolloverAndSend();
      _startRetryTimerIfNeeded();
    }
  }

  void recordTH2Opened(String filePath) {
    if (consentState != true) {
      return;
    }

    final MPLocator locator = MPLocator();

    _openTH2Count++;

    if (_openTH2Count == 1) {
      _th2SessionStartedAt = DateTime.now().toUtc();
    }

    final int currentCount = locator.mpSettingsController.getIntWithDefault(
      MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
    );

    locator.mpSettingsController.setInt(
      MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
      currentCount + 1,
    );

    final List<String> currentFiles = locator.mpSettingsController
        .getStringListWithDefault(
          MPSettingID.Internal_TelemetryCurrentDayTH2Files,
        );

    if (!currentFiles.contains(filePath)) {
      locator.mpSettingsController.setStringList(
        MPSettingID.Internal_TelemetryCurrentDayTH2Files,
        List<String>.from(currentFiles)..add(filePath),
      );
    }

    _ensureCurrentDateSet(locator);
  }

  void recordTH2Closed(String filePath) {
    if (consentState != true) {
      return;
    }

    if (_openTH2Count > 0) {
      _openTH2Count--;
    }

    if ((_openTH2Count == 0) && (_th2SessionStartedAt != null)) {
      final int elapsedSecs = DateTime.now()
          .toUtc()
          .difference(_th2SessionStartedAt!)
          .inSeconds;

      _th2SessionStartedAt = null;

      final MPLocator locator = MPLocator();
      final int currentSecs = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
      );

      locator.mpSettingsController.setInt(
        MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
        currentSecs + elapsedSecs,
      );
    }
  }

  void recordTHConfigOpened(String thConfigPath) {
    if (consentState != true) {
      return;
    }

    final MPLocator locator = MPLocator();
    final List<String> currentFiles = locator.mpSettingsController
        .getStringListWithDefault(
          MPSettingID.Internal_TelemetryCurrentDayTHConfigFiles,
        );

    if (!currentFiles.contains(thConfigPath)) {
      locator.mpSettingsController.setStringList(
        MPSettingID.Internal_TelemetryCurrentDayTHConfigFiles,
        List<String>.from(currentFiles)..add(thConfigPath),
      );
    }

    _ensureCurrentDateSet(locator);
  }

  void recordTherionStarted(String thConfigPath) {
    if (consentState != true) {
      return;
    }

    _therionStartedAt = DateTime.now().toUtc();

    final MPLocator locator = MPLocator();
    final int currentCount = locator.mpSettingsController.getIntWithDefault(
      MPSettingID.Internal_TelemetryCurrentDayTherionRunCount,
    );

    locator.mpSettingsController.setInt(
      MPSettingID.Internal_TelemetryCurrentDayTherionRunCount,
      currentCount + 1,
    );

    recordTHConfigOpened(thConfigPath);
  }

  void recordTherionStopped() {
    if ((consentState != true) || (_therionStartedAt == null)) {
      return;
    }

    final int elapsedSecs = DateTime.now()
        .toUtc()
        .difference(_therionStartedAt!)
        .inSeconds;

    _therionStartedAt = null;

    final MPLocator locator = MPLocator();
    final int currentSecs = locator.mpSettingsController.getIntWithDefault(
      MPSettingID.Internal_TelemetryCurrentDayTherionTimeSecs,
    );

    locator.mpSettingsController.setInt(
      MPSettingID.Internal_TelemetryCurrentDayTherionTimeSecs,
      currentSecs + elapsedSecs,
    );
  }

  Future<void> _tryRolloverAndSend() async {
    if (consentState != true) {
      return;
    }

    final MPLocator locator = MPLocator();
    final String today = mpDebugTelemetryOverrideDate.isNotEmpty
        ? mpDebugTelemetryOverrideDate
        : _utcDateString(DateTime.now().toUtc());
    final String storedDate = locator.mpSettingsController.getStringWithDefault(
      MPSettingID.Internal_TelemetryCurrentDate,
    );

    if (storedDate.isNotEmpty && (storedDate != today)) {
      final Map<String, dynamic> record = await _buildAggregatedRecord(
        storedDate,
        locator,
      );
      final String encoded = jsonEncode(record);
      final List<String> pending = locator.mpSettingsController
          .getStringListWithDefault(
            MPSettingID.Internal_TelemetryPendingRecords,
          );

      locator.mpSettingsController.setStringList(
        MPSettingID.Internal_TelemetryPendingRecords,
        List<String>.from(pending)..add(encoded),
      );

      _clearCurrentDayData(locator);
    }

    locator.mpSettingsController.setString(
      MPSettingID.Internal_TelemetryCurrentDate,
      today,
    );

    await _sendPendingRecords(locator);
  }

  Future<void> _sendPendingRecords(MPLocator locator) async {
    final List<String> pending = locator.mpSettingsController
        .getStringListWithDefault(MPSettingID.Internal_TelemetryPendingRecords);

    if (pending.isEmpty) {
      return;
    }

    final List<dynamic> records = pending
        .map((String s) => jsonDecode(s))
        .toList();
    final String body = jsonEncode(<String, dynamic>{'records': records});

    if (mpDebugTelemetryLogOnly) {
      locator.mpLog.d(
        '[Telemetry DEBUG] Would POST to $mpTelemetrySubmitEndpoint:\n$body',
      );
      locator.mpSettingsController.setStringList(
        MPSettingID.Internal_TelemetryPendingRecords,
        const <String>[],
      );
      _cancelRetryTimer();

      return;
    }

    try {
      final http.Response response = await http
          .post(
            Uri.parse(mpTelemetrySubmitEndpoint),
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json',
              mpHttpHeaderAcceptEncoding: mpHttpHeaderAcceptEncodingGzip,
            },
            body: body,
          )
          .timeout(Duration(seconds: mpTelemetryHttpTimeoutSeconds));

      if (response.statusCode == mpHttpStatusOk) {
        locator.mpSettingsController.setStringList(
          MPSettingID.Internal_TelemetryPendingRecords,
          const <String>[],
        );
        _cancelRetryTimer();
      }
    } on Object {
      // Silently ignore — retry timer will handle the next attempt.
    }
  }

  Future<void> _sendOptIn() async {
    if (mpDebugTelemetryLogOnly) {
      MPLocator().mpLog.d(
        '[Telemetry DEBUG] Would POST to $mpTelemetryOptInEndpoint: {}',
      );

      return;
    }

    try {
      await http
          .post(
            Uri.parse(mpTelemetryOptInEndpoint),
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json',
            },
            body: '{}',
          )
          .timeout(Duration(seconds: mpTelemetryHttpTimeoutSeconds));
    } on Object {
      // Silently ignore — opt-in notification is best-effort.
    }
  }

  Future<void> _sendOptOut() async {
    if (mpDebugTelemetryLogOnly) {
      MPLocator().mpLog.d(
        '[Telemetry DEBUG] Would POST to $mpTelemetryOptOutEndpoint: {}',
      );

      return;
    }

    try {
      await http
          .post(
            Uri.parse(mpTelemetryOptOutEndpoint),
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json',
            },
            body: '{}',
          )
          .timeout(Duration(seconds: mpTelemetryHttpTimeoutSeconds));
    } on Object {
      // Silently ignore — opt-out is best-effort.
    }
  }

  void _clearCurrentDayData(MPLocator locator) {
    locator.mpSettingsController.setStringList(
      MPSettingID.Internal_TelemetryCurrentDayTH2Files,
      const <String>[],
    );
    locator.mpSettingsController.setInt(
      MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
      0,
    );
    locator.mpSettingsController.setInt(
      MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
      0,
    );
    locator.mpSettingsController.setStringList(
      MPSettingID.Internal_TelemetryCurrentDayTHConfigFiles,
      const <String>[],
    );
    locator.mpSettingsController.setInt(
      MPSettingID.Internal_TelemetryCurrentDayTherionRunCount,
      0,
    );
    locator.mpSettingsController.setInt(
      MPSettingID.Internal_TelemetryCurrentDayTherionTimeSecs,
      0,
    );
  }

  void _clearLocalData() {
    final MPLocator locator = MPLocator();

    locator.mpSettingsController.setStringList(
      MPSettingID.Internal_TelemetryPendingRecords,
      const <String>[],
    );
    locator.mpSettingsController.setString(
      MPSettingID.Internal_TelemetryCurrentDate,
      '',
    );
    _clearCurrentDayData(locator);
  }

  void _startRetryTimerIfNeeded() {
    final MPLocator locator = MPLocator();
    final List<String> pending = locator.mpSettingsController
        .getStringListWithDefault(MPSettingID.Internal_TelemetryPendingRecords);

    if (pending.isEmpty || (_retryTimer != null)) {
      return;
    }

    _retryTimer = Timer.periodic(
      Duration(minutes: mpTelemetryRetryIntervalMinutes),
      (_) => _tryRolloverAndSend(),
    );
  }

  void _cancelRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  Future<Map<String, dynamic>> _buildAggregatedRecord(
    String date,
    MPLocator locator,
  ) async {
    final Map<String, String> osInfo = await _gatherOSInfo();
    final String mapiahVersion = await _getMapiahVersion();

    final List<String> th2Files = locator.mpSettingsController
        .getStringListWithDefault(
          MPSettingID.Internal_TelemetryCurrentDayTH2Files,
        );
    final int th2OpenCount = locator.mpSettingsController.getIntWithDefault(
      MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
    );
    final int th2TimeSecs = locator.mpSettingsController.getIntWithDefault(
      MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
    );
    final List<String> thConfigFiles = locator.mpSettingsController
        .getStringListWithDefault(
          MPSettingID.Internal_TelemetryCurrentDayTHConfigFiles,
        );
    final int therionRunCount = locator.mpSettingsController.getIntWithDefault(
      MPSettingID.Internal_TelemetryCurrentDayTherionRunCount,
    );
    final int therionTimeSecs = locator.mpSettingsController.getIntWithDefault(
      MPSettingID.Internal_TelemetryCurrentDayTherionTimeSecs,
    );

    final Map<String, dynamic> record = <String, dynamic>{
      'date': date,
      'osType': osInfo['osType']!,
      'osVersion': osInfo['osVersion']!,
      'mapiahVersion': mapiahVersion,
      'buildType': _getBuildType(),
      'th2DifferentFilesCount': th2Files.length,
      'th2OpenCount': th2OpenCount,
      'th2TimeMinutes': th2TimeSecs ~/ 60,
      'thConfigDifferentFilesCount': thConfigFiles.length,
      'therionRunCount': therionRunCount,
      'therionTimeSecs': therionTimeSecs,
    };

    if (osInfo.containsKey('linuxDistro')) {
      record['linuxDistro'] = osInfo['linuxDistro']!;
    }

    if (osInfo.containsKey('windowManager')) {
      record['windowManager'] = osInfo['windowManager']!;
    }

    return record;
  }

  String _getBuildType() {
    if (mpIsAppImage) {
      return mpTelemetryBuildTypeAppImage;
    }

    if (mpIsFlatpak) {
      return mpTelemetryBuildTypeFlatpak;
    }

    return mpTelemetryBuildTypeOther;
  }

  Future<String> _getMapiahVersion() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();

      return info.version;
    } on Object {
      return 'unknown';
    }
  }

  Future<Map<String, String>> _gatherOSInfo() async {
    final Map<String, String> info = <String, String>{};

    info['osType'] = Platform.operatingSystem;
    info['osVersion'] = Platform.operatingSystemVersion;

    if (Platform.isLinux) {
      final String? distro = await _readLinuxDistro();

      if (distro != null) {
        info['linuxDistro'] = distro;
      }

      final String? wm = _readLinuxWindowManager();

      if (wm != null) {
        info['windowManager'] = wm;
      }
    }

    return info;
  }

  Future<String?> _readLinuxDistro() async {
    try {
      final File osRelease = File('/etc/os-release');

      if (!osRelease.existsSync()) {
        return null;
      }

      final String content = await osRelease.readAsString();

      for (final String line in content.split('\n')) {
        if (line.startsWith('PRETTY_NAME=')) {
          final String value = line.substring('PRETTY_NAME='.length).trim();

          return value.replaceAll('"', '');
        }
      }
    } on Object {
      // Ignore — best effort.
    }

    return null;
  }

  String? _readLinuxWindowManager() {
    final String? wm =
        Platform.environment['XDG_CURRENT_DESKTOP'] ??
        Platform.environment['DESKTOP_SESSION'];

    if ((wm == null) || wm.isEmpty) {
      return null;
    }

    return wm;
  }

  String _utcDateString(DateTime utcDate) {
    final String year = utcDate.year.toString().padLeft(4, '0');
    final String month = utcDate.month.toString().padLeft(2, '0');
    final String day = utcDate.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  void _ensureCurrentDateSet(MPLocator locator) {
    final String storedDate = locator.mpSettingsController.getStringWithDefault(
      MPSettingID.Internal_TelemetryCurrentDate,
    );

    if (storedDate.isEmpty) {
      locator.mpSettingsController.setString(
        MPSettingID.Internal_TelemetryCurrentDate,
        _utcDateString(DateTime.now().toUtc()),
      );
    }
  }
}
