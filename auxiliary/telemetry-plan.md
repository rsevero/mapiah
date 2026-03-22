<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Plan: Mapiah Telemetry System

## Context

Mapiah needs an anonymous, opt-in usage data gathering system to understand how users interact with the app. This will help prioritize development and measure adoption. The system must be privacy-first: no identifying information collected or transmitted, fully user-controlled, and low overhead.

## Overview of Changes

### New Files
1. `lib/src/controllers/mp_telemetry_controller.dart` — MobX controller for all telemetry logic
2. `lib/src/widgets/mp_telemetry_consent_dialog.dart` — Consent dialog widget
3. `assets/help/telemetry_en.md` + `assets/help/telemetry_pt.md` — Full detailed telemetry explanation pages
4. `openapi/telemetry.yaml` — OpenAPI 3.0 spec for the telemetry server API

### Modified Files
1. `lib/src/controllers/types/mp_setting_type.dart` — Add new `MPSettingID` entries
2. `lib/src/controllers/mp_settings_controller.dart` — Register new settings with defaults
3. `lib/src/constants/mp_constants.dart` — Add `mpIsAppImage`, telemetry URL, and constants
4. `lib/src/pages/mapiah_home.dart` — Trigger consent check on startup
5. `lib/src/pages/mp_settings_page.dart` — Telemetry toggle + link to consent dialog
6. `lib/l10n/intl_en.arb` + `lib/l10n/intl_pt.arb` — Localization strings for consent dialog
7. `lib/main.dart` — Register `mpTelemetryController` in `MPLocator`

---

## Step 1: Build Constants (`mp_constants.dart`)

Add after the existing Flatpak constants:

```dart
// Build-time flags
const bool mpIsAppImage = bool.fromEnvironment('isAppImage', defaultValue: false);

// Telemetry
const String mpTelemetryBaseURL = 'https://api.mapiah.org';
const String mpTelemetrySubmitEndpoint = '$mpTelemetryBaseURL/v1/telemetry';
const String mpTelemetryOptOutEndpoint = '$mpTelemetryBaseURL/v1/telemetry/opt-out';
const int mpTelemetryRetryIntervalMinutes = 15;
const int mpTelemetryHttpTimeoutSeconds = 15;
const String mpTelemetryBuildTypeAppImage = 'AppImage';
const String mpTelemetryBuildTypeFlatpak = 'Flatpak';
const String mpTelemetryBuildTypeOther = 'Other';
```

---

## Step 2: New `MPSettingID` Entries (`mp_setting_type.dart`)

Add to the `MPSettingID` enum:

```dart
// Telemetry consent (bool; unset = user not yet asked)
Main_TelemetryConsent,

// Current in-progress day tracking (UTC date)
Internal_TelemetryCurrentDate,               // string: "YYYY-MM-DD" (UTC)
Internal_TelemetryCurrentDayTH2Files,        // stringList: unique TH2 paths opened today
Internal_TelemetryCurrentDayTH2OpenCount,    // int: total TH2 open events today
Internal_TelemetryCurrentDayTH2TimeSecs,     // int: total seconds with ≥1 TH2 open today
Internal_TelemetryCurrentDayTHConfigFiles,   // stringList: unique THConfig paths today
Internal_TelemetryCurrentDayTherionRunCount, // int: Therion run events today
Internal_TelemetryCurrentDayTherionTimeSecs, // int: total seconds spent running Therion today

// Aggregated, ready-to-send records (one per completed day)
Internal_TelemetryPendingRecords, // stringList: JSON-encoded daily records
```

### Time Storage vs Transmission

| Metric | Stored locally | Sent in aggregated record |
|--------|---------------|--------------------------|
| TH2 open time | seconds (`Internal_TelemetryCurrentDayTH2TimeSecs`) | **minutes** (`th2TimeMinutes = secs / 60`) |
| Therion run time | seconds (`Internal_TelemetryCurrentDayTherionTimeSecs`) | **seconds** (`therionTimeSecs`) |

Add corresponding `MPSettingType` entries for each (bool, string, stringList, int as appropriate).

---

## Step 3: Register Settings Defaults (`mp_settings_controller.dart`)

Following the existing pattern (e.g., `Internal_LastNewVersionCheckMS`):
- `Main_TelemetryConsent` — bool, no default (use `isBoolSet()` to detect unconfigured state)
- `Internal_TelemetryCurrentDate` — string, default `''`
- `Internal_TelemetryCurrentDayTH2Files` — stringList, default `[]`
- `Internal_TelemetryCurrentDayTH2OpenCount` — int, default `0`
- `Internal_TelemetryCurrentDayTH2TimeSecs` — int, default `0`
- `Internal_TelemetryCurrentDayTHConfigFiles` — stringList, default `[]`
- `Internal_TelemetryCurrentDayTherionRunCount` — int, default `0`
- `Internal_TelemetryCurrentDayTherionTimeSecs` — int, default `0`
- `Internal_TelemetryPendingRecords` — stringList, default `[]`

---

## Step 4: `MPTelemetryController` (`mp_telemetry_controller.dart`)

### Responsibilities
- Check/manage consent state
- Record raw daily events (TH2 open/close, Therion run/stop)
- Aggregate previous days and store in `Internal_TelemetryPendingRecords`
- Send pending records via HTTP on app start
- Start/cancel a 15-min retry timer only when there are pending records
- Handle opt-out: delete all local data, send opt-out POST
- Roll over to a new UTC day at midnight

### MobX Structure

```dart
part 'mp_telemetry_controller.g.dart';

class MPTelemetryController = _MPTelemetryControllerBase
    with _$MPTelemetryController;

abstract class _MPTelemetryControllerBase with Store {
  @observable bool? consentState;  // null = not yet decided

  // In-memory state (not observable, not persisted)
  Timer? _retryTimer;
  int _openTH2Count = 0;           // How many TH2 files are currently open
  DateTime? _th2SessionStartedAt;  // UTC timestamp when first TH2 was opened (in current session)
  DateTime? _therionStartedAt;     // UTC timestamp when Therion started

  @action void setConsent(bool value) { ... }
  @action void recordTH2Opened(String filePath) { ... }
  @action void recordTH2Closed(String filePath) { ... }
  @action void recordTherionStarted(String thConfigPath) { ... }
  @action void recordTherionStopped() { ... }

  Future<void> initialize() { ... }
  Future<void> _tryRolloverAndSend() { ... }
  Future<void> _sendPendingRecords() { ... }
  Future<void> _sendOptOut() { ... }
  void _clearLocalData() { ... }
  void _startRetryTimerIfNeeded() { ... }
  void _cancelRetryTimer() { ... }
  Map<String, dynamic> _buildAggregatedRecord(String date) { ... }
  String _getBuildType() { ... }
  Future<Map<String, String>> _gatherOSInfo() { ... }
}
```

### OS Info Gathering

- `Platform.operatingSystem` → os type (linux/macos/windows)
- `Platform.operatingSystemVersion` → raw OS version string
- Linux only:
  - Read `/etc/os-release` → parse `PRETTY_NAME` for distro
  - Read `$XDG_CURRENT_DESKTOP` or `$DESKTOP_SESSION` env var → window manager
- macOS/Windows: version from `Platform.operatingSystemVersion`

OS info is gathered once per day at aggregation time (low overhead).

### Aggregated Day Record Schema

```json
{
  "date": "2026-03-20",
  "osType": "linux",
  "osVersion": "6.19.8-200.fc43.x86_64",
  "linuxDistro": "Fedora Linux 43",
  "windowManager": "KDE",
  "mapiahVersion": "1.2.3",
  "buildType": "AppImage",
  "th2DifferentFilesCount": 2,
  "th2OpenCount": 5,
  "th2TimeMinutes": 45,
  "thConfigDifferentFilesCount": 1,
  "therionRunCount": 3,
  "therionTimeSecs": 120
}
```

`linuxDistro` and `windowManager` are omitted on non-Linux platforms.
All dates are UTC.

### Aggregation Conversion
- `th2TimeMinutes` = `Internal_TelemetryCurrentDayTH2TimeSecs` ÷ 60 (integer division)
- `therionTimeSecs` = `Internal_TelemetryCurrentDayTherionTimeSecs` (as-is)

### Rollover Logic

On every send attempt (`_tryRolloverAndSend`):
1. Get current date (UTC) as `today`
2. Read `Internal_TelemetryCurrentDate`
3. If stored date is non-empty AND differs from `today`:
   - Build aggregated record from current day data
   - Append JSON-encoded record to `Internal_TelemetryPendingRecords`
   - Clear all `Internal_TelemetryCurrentDay*` settings
   - Set `Internal_TelemetryCurrentDate` = `today`
4. Attempt to send pending records

Only records from **previous UTC days** are ever sent; today's partial data stays local.

### Send Logic

HTTP POST to `mpTelemetrySubmitEndpoint`:
```json
{ "records": [ ...aggregated day records... ] }
```

Headers: `Content-Type: application/json`, `Accept-Encoding: gzip`
Timeout: 15 seconds
On HTTP 200 → delete `Internal_TelemetryPendingRecords`, cancel retry timer
On failure → silently ignore (retry timer handles next attempt)

### Retry Timer

The timer is only active when there are pending records to send:

```dart
void _startRetryTimerIfNeeded() {
  final List<String> pending = mpLocator.mpSettingsController
      .getStringListWithDefault(MPSettingID.Internal_TelemetryPendingRecords);
  if (pending.isEmpty || _retryTimer != null) {
    return;
  }
  _retryTimer = Timer.periodic(
    const Duration(minutes: mpTelemetryRetryIntervalMinutes),
    (_) => _tryRolloverAndSend(),
  );
}

void _cancelRetryTimer() {
  _retryTimer?.cancel();
  _retryTimer = null;
}
```

Timer starts after rollover creates new pending records, or at `initialize()` if records already exist.
Timer is cancelled after successful send or on consent withdrawal.

### Consent Withdrawal

When `setConsent(false)` is called:
1. Cancel retry timer
2. Clear all `Internal_Telemetry*` settings
3. Fire-and-forget POST to `mpTelemetryOptOutEndpoint` with empty body `{}`

---

## Step 5: Help Pages

Create `assets/help/telemetry_en.md` and `assets/help/telemetry_pt.md` with full detailed
explanation of:
- What data is collected
- What is NOT collected (no IPs, device IDs, user IDs, file paths, etc.)
- How data is anonymized and aggregated before sending
- Where data goes (api.mapiah.org)
- How to change consent in Settings
- The technical schema of the aggregated record

These pages are linked from the consent dialog.

---

## Step 6: Consent Dialog (`mp_telemetry_consent_dialog.dart`)

A standard `AlertDialog` with:
- Title: "Help improve Mapiah"
- Short body: 2–3 sentences explaining that anonymous aggregate usage data can be shared to improve the app, and that the setting can be changed in Settings at any time
- An inline `TextButton` / `InkWell` link: "Learn more about what is collected" → opens the telemetry help page (using existing markdown display pattern)
- Two action buttons: "No thanks" and "Yes, participate"
- `barrierDismissible: false` (must make a choice)

Dialog shown from `MapiahHome.initState()`:

```dart
if (!mpLocator.mpSettingsController.isBoolSet(MPSettingID.Main_TelemetryConsent)) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    MPTelemetryConsentDialog.show(context);
  });
}
```

---

## Step 7: Settings Page (`mp_settings_page.dart`)

After the existing settings, add a "Telemetry" section containing:
1. A `SwitchListTile` (or equivalent) for `Main_TelemetryConsent` — "Share anonymous usage data"
2. Immediately below: a `TextButton` link — "Review telemetry details and consent" → opens the consent dialog again

---

## Step 8: Integration Hooks

### TH2 File Events
In `MPGeneralController` (file open/close):
- On TH2 file opened → `mpLocator.mpTelemetryController.recordTH2Opened(filePath)`
- On TH2 file closed → `mpLocator.mpTelemetryController.recordTH2Closed(filePath)`

**Multiple simultaneous files**: Mapiah supports several TH2 files open at the same time, so multiple
`recordTH2Opened` calls can occur before any `recordTH2Closed`. Time tracking uses `_openTH2Count`:

```
recordTH2Opened(filePath):
  _openTH2Count++
  if _openTH2Count == 1:
    _th2SessionStartedAt = DateTime.now().toUtc()  // first file opened
  increment TH2OpenCount
  add filePath to TH2Files set

recordTH2Closed(filePath):
  _openTH2Count--
  if _openTH2Count == 0 && _th2SessionStartedAt != null:
    elapsed = now.difference(_th2SessionStartedAt).inSeconds
    TH2TimeSecs += elapsed
    _th2SessionStartedAt = null   // reset for next session
```

This correctly measures uninterrupted time with at least one TH2 open, regardless of how many
files are open simultaneously.

### Therion Run Events
In `MPDialogAux.runTherionWithTHConfigFile()`:
- Before run → `mpLocator.mpTelemetryController.recordTherionStarted(thConfigPath)`
- After run completes → `mpLocator.mpTelemetryController.recordTherionStopped()`

Elapsed seconds = `DateTime.now().toUtc().difference(_therionStartedAt!).inSeconds`

### App Initialization
In `MPLocator`, add `mpTelemetryController` field, instantiated after settings are ready.
In `main.dart`, call `mpLocator.mpTelemetryController.initialize()` after settings load.

---

## Step 9: `MPLocator` Registration

Add to the MPLocator singleton:
```dart
late final MPTelemetryController mpTelemetryController;
```

Instantiated after `mpSettingsController.initialized` resolves, same as existing controllers.

---

## Step 10: OpenAPI Spec (`openapi/telemetry.yaml`)

```yaml
openapi: "3.0.3"
info:
  title: Mapiah Telemetry API
  version: "1.0.0"
  description: |
    Anonymous, aggregated usage telemetry for Mapiah.
    No identifying information (IPs, device IDs, user IDs, file paths)
    is stored server-side or transmitted by the client.

servers:
  - url: https://api.mapiah.org/v1

paths:
  /telemetry:
    post:
      summary: Submit aggregated daily usage records
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/TelemetrySubmission'
      responses:
        '200':
          description: Records accepted

  /telemetry/opt-out:
    post:
      summary: Notify that a user has opted out
      description: |
        No identifying information is sent or stored. The server only
        increments an anonymous opt-out counter.
      requestBody:
        required: false
        content:
          application/json:
            schema:
              type: object
      responses:
        '200':
          description: Opt-out recorded (anonymous counter only)

components:
  schemas:
    TelemetrySubmission:
      type: object
      required: [records]
      properties:
        records:
          type: array
          items:
            $ref: '#/components/schemas/DailyRecord'

    DailyRecord:
      type: object
      required:
        - date
        - osType
        - osVersion
        - mapiahVersion
        - buildType
        - th2DifferentFilesCount
        - th2OpenCount
        - th2TimeMinutes
        - thConfigDifferentFilesCount
        - therionRunCount
        - therionTimeSecs
      properties:
        date:
          type: string
          format: date
          description: UTC date (YYYY-MM-DD)
        osType:
          type: string
          enum: [linux, macos, windows]
        osVersion:
          type: string
        linuxDistro:
          type: string
          description: Only present when osType is linux
        windowManager:
          type: string
          description: Only present when osType is linux
        mapiahVersion:
          type: string
        buildType:
          type: string
          enum: [AppImage, Flatpak, Other]
        th2DifferentFilesCount:
          type: integer
          minimum: 0
        th2OpenCount:
          type: integer
          minimum: 0
        th2TimeMinutes:
          type: integer
          minimum: 0
          description: Total minutes with at least one TH2 file open (derived from seconds stored locally)
        thConfigDifferentFilesCount:
          type: integer
          minimum: 0
        therionRunCount:
          type: integer
          minimum: 0
        therionTimeSecs:
          type: integer
          minimum: 0
          description: Total seconds spent running Therion
```

---

## Step 11: Localization Strings

Add to `intl_en.arb`:
- `telemetryConsentDialogTitle`: "Help improve Mapiah"
- `telemetryConsentDialogBody`: short 2–3 sentence summary
- `telemetryConsentDialogLearnMore`: "Learn more about what is collected"
- `telemetryConsentDialogAccept`: "Yes, participate"
- `telemetryConsentDialogDecline`: "No thanks"
- `telemetrySettingsToggleLabel`: "Share anonymous usage data"
- `telemetrySettingsReviewLink`: "Review telemetry details and consent"

Translate all to `intl_pt.arb`.

---

## Step 12: `CHANGELOG.md` + `TODO.md`

Update `CHANGELOG.md` with a new entry describing the telemetry feature.
Check `TODO.md` for any items to mark done.

---

## Verification

1. **First launch (consent not set):** Consent dialog appears. "No thanks" → no data collected,
   all `Internal_*` settings empty, retry timer not started. Relaunch → dialog does NOT appear again.
2. **Consent yes:** `Main_TelemetryConsent = true`. Open/close TH2 files →
   `Internal_TelemetryCurrentDayTH2OpenCount` increments and `Internal_TelemetryCurrentDayTH2TimeSecs`
   accumulates. Run Therion → `Internal_TelemetryCurrentDayTherionTimeSecs` increases.
3. **Day rollover:** Manually set `Internal_TelemetryCurrentDate` to yesterday → on next
   `_tryRolloverAndSend` call, a record is aggregated into `Internal_TelemetryPendingRecords`.
   Verify `th2TimeMinutes = th2TimeSecs / 60`.
4. **Retry timer:** Verify timer starts after rollover and is cancelled after successful send.
   Verify timer is NOT started when no pending records exist.
5. **Opt-out after consent:** Set to false → local data cleared, opt-out POST fired, timer cancelled.
6. **Privacy check:** Inspect HTTP payload — no file paths, IPs, or user-identifiable data.
7. **flutter analyze**: Run after all changes.

---

## Notes & Trade-offs

- **No OpenAPI code generation**: HTTP calls written manually following the spec (same pattern as
  version check). Avoids a new build dependency.
- **stringList for pending records**: Each element is a JSON-encoded string; consistent with existing
  settings infrastructure. File paths used locally for unique-count tracking, never sent.
- **Time precision**: TH2 open time stored in **seconds**, aggregated/sent in **minutes**.
  Therion run time stored and sent in **seconds**.
- **`mpIsAppImage` build flag**: Follows `mpIsFlatpak` pattern. Set with `-D isAppImage=true`
  at build time for AppImage releases.
- **UTC dates throughout**: All date comparisons and storage use UTC to avoid timezone edge cases.
- **Retry timer lifecycle**: Only running when `Internal_TelemetryPendingRecords` is non-empty,
  keeping background overhead near zero during normal use.
- **Multiple simultaneous TH2 files**: `_openTH2Count` tracks concurrently open files; time
  measurement runs from first-open to last-close, correctly spanning all intermediate opens/closes.
