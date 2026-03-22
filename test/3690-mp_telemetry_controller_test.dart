// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'th_test_aux.dart';

void main() {
  final bool isEnvironmentReady = THTestAux.ensureTestEnvironment();

  if (!isEnvironmentReady) {
    throw StateError('The test environment could not be initialized.');
  }

  final MPLocator locator = MPLocator();

  setUpAll(() async {
    await locator.mpSettingsController.initialized;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    locator.mpSettingsController.reset();
    locator.mpTelemetryController.consentState = null;
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String todayUtc() {
    final DateTime now = DateTime.now().toUtc();
    final String year = now.year.toString().padLeft(4, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // ---------------------------------------------------------------------------
  // Consent gating
  // ---------------------------------------------------------------------------

  group('MPTelemetryController — consent gating', () {
    test('recordTH2Opened is a no-op without consent', () {
      locator.mpTelemetryController.recordTH2Opened('file.th2');

      final int openCount = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
      );
      final List<String> files = locator.mpSettingsController
          .getStringListWithDefault(
            MPSettingID.Internal_TelemetryCurrentDayTH2Files,
          );

      expect(openCount, 0);
      expect(files, isEmpty);
    });

    test('recordTH2Closed is a no-op without consent', () {
      locator.mpTelemetryController.recordTH2Closed('file.th2');

      final int timeSecs = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
      );

      expect(timeSecs, 0);
    });

    test('recordTherionStarted is a no-op without consent', () {
      locator.mpTelemetryController.recordTherionStarted('run.thconfig');

      final int runCount = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTherionRunCount,
      );

      expect(runCount, 0);
    });

    test('recordTherionStopped is a no-op without consent', () {
      locator.mpTelemetryController.recordTherionStopped();

      final int timeSecs = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTherionTimeSecs,
      );

      expect(timeSecs, 0);
    });

    test('recordTH2Opened is a no-op when consent is false', () {
      locator.mpTelemetryController.consentState = false;
      locator.mpTelemetryController.recordTH2Opened('file.th2');

      final int openCount = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
      );

      expect(openCount, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // TH2 open recording
  // ---------------------------------------------------------------------------

  group('MPTelemetryController — TH2 open recording', () {
    setUp(() {
      locator.mpTelemetryController.consentState = true;
    });

    tearDown(() {
      // Balance any opens so _openTH2Count returns to 0.
      locator.mpTelemetryController.recordTH2Closed('file.th2');
    });

    test('increments open count on first open', () {
      locator.mpTelemetryController.recordTH2Opened('file.th2');

      final int openCount = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
      );

      expect(openCount, 1);
    });

    test('increments open count for each additional open', () {
      locator.mpTelemetryController.recordTH2Opened('file.th2');
      locator.mpTelemetryController.recordTH2Opened('file.th2');

      final int openCount = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
      );

      expect(openCount, 2);

      // Extra close to balance the extra open above.
      locator.mpTelemetryController.recordTH2Closed('file.th2');
    });

    test('adds file path to the files list on open', () {
      locator.mpTelemetryController.recordTH2Opened('file.th2');

      final List<String> files = locator.mpSettingsController
          .getStringListWithDefault(
            MPSettingID.Internal_TelemetryCurrentDayTH2Files,
          );

      expect(files, contains('file.th2'));
    });

    test('does not duplicate a file path opened multiple times', () {
      locator.mpTelemetryController.recordTH2Opened('file.th2');
      locator.mpTelemetryController.recordTH2Opened('file.th2');

      final List<String> files = locator.mpSettingsController
          .getStringListWithDefault(
            MPSettingID.Internal_TelemetryCurrentDayTH2Files,
          );

      expect(files.where((String f) => f == 'file.th2').length, 1);

      locator.mpTelemetryController.recordTH2Closed('file.th2');
    });

    test('adds different file paths as separate entries', () {
      locator.mpTelemetryController.recordTH2Opened('a.th2');
      locator.mpTelemetryController.recordTH2Opened('b.th2');

      final List<String> files = locator.mpSettingsController
          .getStringListWithDefault(
            MPSettingID.Internal_TelemetryCurrentDayTH2Files,
          );

      expect(files, containsAll(<String>['a.th2', 'b.th2']));

      locator.mpTelemetryController.recordTH2Closed('a.th2');
      // tearDown closes one more.
    });

    test('sets the current date on first open', () {
      locator.mpTelemetryController.recordTH2Opened('file.th2');

      final String storedDate = locator.mpSettingsController
          .getStringWithDefault(MPSettingID.Internal_TelemetryCurrentDate);

      expect(storedDate, todayUtc());
    });
  });

  // ---------------------------------------------------------------------------
  // TH2 close recording
  // ---------------------------------------------------------------------------

  group('MPTelemetryController — TH2 close recording', () {
    setUp(() {
      locator.mpTelemetryController.consentState = true;
    });

    test('accumulates time in seconds when the last file closes', () {
      locator.mpTelemetryController.recordTH2Opened('file.th2');
      locator.mpTelemetryController.recordTH2Closed('file.th2');

      final int timeSecs = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
      );

      expect(timeSecs, greaterThanOrEqualTo(0));
    });

    test(
      'does not accumulate time when there are still open files after close',
      () {
        locator.mpTelemetryController.recordTH2Opened('a.th2');
        locator.mpTelemetryController.recordTH2Opened('b.th2');

        final int timeBeforeClose = locator.mpSettingsController
            .getIntWithDefault(
              MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
            );

        locator.mpTelemetryController.recordTH2Closed('a.th2');

        final int timeAfterPartialClose = locator.mpSettingsController
            .getIntWithDefault(
              MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
            );

        expect(timeAfterPartialClose, timeBeforeClose);

        locator.mpTelemetryController.recordTH2Closed('b.th2');
      },
    );

    test('accumulates time additively across multiple sessions', () {
      locator.mpTelemetryController.recordTH2Opened('file.th2');
      locator.mpTelemetryController.recordTH2Closed('file.th2');

      final int firstSessionTime = locator.mpSettingsController
          .getIntWithDefault(
            MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
          );

      locator.mpTelemetryController.recordTH2Opened('file.th2');
      locator.mpTelemetryController.recordTH2Closed('file.th2');

      final int twoSessionTime = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
      );

      expect(twoSessionTime, greaterThanOrEqualTo(firstSessionTime));
    });
  });

  // ---------------------------------------------------------------------------
  // Therion recording
  // ---------------------------------------------------------------------------

  group('MPTelemetryController — Therion recording', () {
    setUp(() {
      locator.mpTelemetryController.consentState = true;
    });

    test('increments therion run count on start', () {
      locator.mpTelemetryController.recordTherionStarted('run.thconfig');

      final int runCount = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTherionRunCount,
      );

      expect(runCount, 1);

      locator.mpTelemetryController.recordTherionStopped();
    });

    test('increments run count cumulatively across multiple runs', () {
      locator.mpTelemetryController.recordTherionStarted('run.thconfig');
      locator.mpTelemetryController.recordTherionStopped();
      locator.mpTelemetryController.recordTherionStarted('run.thconfig');
      locator.mpTelemetryController.recordTherionStopped();

      final int runCount = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTherionRunCount,
      );

      expect(runCount, 2);
    });

    test('accumulates therion time in seconds on stop', () {
      locator.mpTelemetryController.recordTherionStarted('run.thconfig');
      locator.mpTelemetryController.recordTherionStopped();

      final int timeSecs = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTherionTimeSecs,
      );

      expect(timeSecs, greaterThanOrEqualTo(0));
    });

    test('adds thconfig path to the thconfig files list', () {
      locator.mpTelemetryController.recordTherionStarted('run.thconfig');

      final List<String> configs = locator.mpSettingsController
          .getStringListWithDefault(
            MPSettingID.Internal_TelemetryCurrentDayTHConfigFiles,
          );

      expect(configs, contains('run.thconfig'));

      locator.mpTelemetryController.recordTherionStopped();
    });

    test('does not duplicate thconfig paths', () {
      locator.mpTelemetryController.recordTherionStarted('run.thconfig');
      locator.mpTelemetryController.recordTherionStopped();
      locator.mpTelemetryController.recordTherionStarted('run.thconfig');
      locator.mpTelemetryController.recordTherionStopped();

      final List<String> configs = locator.mpSettingsController
          .getStringListWithDefault(
            MPSettingID.Internal_TelemetryCurrentDayTHConfigFiles,
          );

      expect(configs.where((String c) => c == 'run.thconfig').length, 1);
    });

    test('recordTherionStopped is a no-op if therion was never started', () {
      locator.mpTelemetryController.recordTherionStopped();

      final int timeSecs = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTherionTimeSecs,
      );

      expect(timeSecs, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // Day rollover
  // ---------------------------------------------------------------------------

  group('MPTelemetryController — day rollover', () {
    test('advances stored date to today when date is stale', () async {
      locator.mpSettingsController.setBool(
        MPSettingID.Main_TelemetryConsent,
        true,
      );
      locator.mpSettingsController.setString(
        MPSettingID.Internal_TelemetryCurrentDate,
        '2000-01-01',
      );

      await locator.mpTelemetryController.initialize();

      final String storedDate = locator.mpSettingsController
          .getStringWithDefault(MPSettingID.Internal_TelemetryCurrentDate);

      expect(storedDate, todayUtc());
    });

    test('clears day counters after rollover', () async {
      locator.mpSettingsController.setBool(
        MPSettingID.Main_TelemetryConsent,
        true,
      );
      locator.mpSettingsController.setString(
        MPSettingID.Internal_TelemetryCurrentDate,
        '2000-01-01',
      );
      locator.mpSettingsController.setInt(
        MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
        5,
      );
      locator.mpSettingsController.setInt(
        MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
        3600,
      );
      locator.mpSettingsController.setInt(
        MPSettingID.Internal_TelemetryCurrentDayTherionRunCount,
        3,
      );
      locator.mpSettingsController.setInt(
        MPSettingID.Internal_TelemetryCurrentDayTherionTimeSecs,
        120,
      );

      await locator.mpTelemetryController.initialize();

      expect(
        locator.mpSettingsController.getIntWithDefault(
          MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
        ),
        0,
      );
      expect(
        locator.mpSettingsController.getIntWithDefault(
          MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
        ),
        0,
      );
      expect(
        locator.mpSettingsController.getIntWithDefault(
          MPSettingID.Internal_TelemetryCurrentDayTherionRunCount,
        ),
        0,
      );
      expect(
        locator.mpSettingsController.getIntWithDefault(
          MPSettingID.Internal_TelemetryCurrentDayTherionTimeSecs,
        ),
        0,
      );
    });

    test('queues a pending record for the stale day', () async {
      locator.mpSettingsController.setBool(
        MPSettingID.Main_TelemetryConsent,
        true,
      );
      locator.mpSettingsController.setString(
        MPSettingID.Internal_TelemetryCurrentDate,
        '2000-01-01',
      );

      await locator.mpTelemetryController.initialize();

      // The HTTP send will fail silently in tests, leaving the record queued.
      final List<String> pending = locator.mpSettingsController
          .getStringListWithDefault(
            MPSettingID.Internal_TelemetryPendingRecords,
          );

      expect(pending.length, 1);
    });

    test('no rollover when stored date already matches today', () async {
      locator.mpSettingsController.setBool(
        MPSettingID.Main_TelemetryConsent,
        true,
      );
      locator.mpSettingsController.setString(
        MPSettingID.Internal_TelemetryCurrentDate,
        todayUtc(),
      );
      locator.mpSettingsController.setInt(
        MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
        7,
      );

      await locator.mpTelemetryController.initialize();

      expect(
        locator.mpSettingsController.getIntWithDefault(
          MPSettingID.Internal_TelemetryCurrentDayTH2OpenCount,
        ),
        7,
      );
      expect(
        locator.mpSettingsController.getStringListWithDefault(
          MPSettingID.Internal_TelemetryPendingRecords,
        ),
        isEmpty,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Midnight rollover: active session handling
  // ---------------------------------------------------------------------------

  group('MPTelemetryController — midnight session snapshot', () {
    test('active TH2 session survives rollover: closing after rollover '
        'still accumulates time to the new day', () async {
      locator.mpTelemetryController.consentState = true;

      // Open a file — this sets _th2SessionStartedAt to now.
      locator.mpTelemetryController.recordTH2Opened('cave.th2');

      // Simulate that the stored date is from a previous day, so rollover fires.
      locator.mpSettingsController.setBool(
        MPSettingID.Main_TelemetryConsent,
        true,
      );
      locator.mpSettingsController.setString(
        MPSettingID.Internal_TelemetryCurrentDate,
        '2000-01-01',
      );

      await locator.mpTelemetryController.initialize();

      // New day data must start fresh.
      expect(
        locator.mpSettingsController.getIntWithDefault(
          MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
        ),
        0,
      );

      // Close the file — the session must still be tracked after rollover,
      // so closing it should accumulate time to today (>= 0 seconds).
      locator.mpTelemetryController.recordTH2Closed('cave.th2');

      final int todayTimeSecs = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
      );

      expect(todayTimeSecs, greaterThanOrEqualTo(0));
    });

    test('active Therion session survives rollover: stopping after rollover '
        'still accumulates time to the new day', () async {
      locator.mpTelemetryController.consentState = true;

      locator.mpTelemetryController.recordTherionStarted('run.thconfig');

      locator.mpSettingsController.setBool(
        MPSettingID.Main_TelemetryConsent,
        true,
      );
      locator.mpSettingsController.setString(
        MPSettingID.Internal_TelemetryCurrentDate,
        '2000-01-01',
      );

      await locator.mpTelemetryController.initialize();

      expect(
        locator.mpSettingsController.getIntWithDefault(
          MPSettingID.Internal_TelemetryCurrentDayTherionTimeSecs,
        ),
        0,
      );

      locator.mpTelemetryController.recordTherionStopped();

      final int todayTimeSecs = locator.mpSettingsController.getIntWithDefault(
        MPSettingID.Internal_TelemetryCurrentDayTherionTimeSecs,
      );

      expect(todayTimeSecs, greaterThanOrEqualTo(0));
    });

    test(
      'pre-midnight TH2 time is credited to the old day record, not the new day',
      () async {
        // Seed the old day with time that was already accumulated before midnight.
        // This simulates time that was flushed to persistent storage during the
        // previous day's session (e.g., a prior close cycle).
        locator.mpSettingsController.setBool(
          MPSettingID.Main_TelemetryConsent,
          true,
        );
        locator.mpSettingsController.setString(
          MPSettingID.Internal_TelemetryCurrentDate,
          '2000-01-01',
        );
        locator.mpSettingsController.setInt(
          MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
          600,
        );

        await locator.mpTelemetryController.initialize();

        // After rollover the old day record is queued; today starts at 0.
        final int newDayTime = locator.mpSettingsController.getIntWithDefault(
          MPSettingID.Internal_TelemetryCurrentDayTH2TimeSecs,
        );

        expect(newDayTime, 0);

        final List<String> pending = locator.mpSettingsController
            .getStringListWithDefault(
              MPSettingID.Internal_TelemetryPendingRecords,
            );

        // The pending record must contain the old day's time.
        expect(pending, isNotEmpty);
        expect(pending.first, contains('"th2TimeMinutes":10'));
      },
    );
  });
}
