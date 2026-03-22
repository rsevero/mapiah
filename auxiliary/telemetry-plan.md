<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Mapiah Telemetry System — Implementation Reference

## Context

Mapiah uses an anonymous, opt-in usage data gathering system to understand how users interact
with the app. The system is privacy-first: no identifying information is ever collected or
transmitted, fully user-controlled, and low overhead.

**Status: fully implemented as of 2026-03-22.**

---

## Files

### New Files
| File | Purpose |
|------|---------|
| `lib/src/controllers/mp_telemetry_controller.dart` | MobX controller for all telemetry logic |
| `lib/src/controllers/mp_telemetry_controller.g.dart` | MobX generated code |
| `lib/src/widgets/mp_telemetry_consent_dialog.dart` | Consent dialog widget |
| `assets/help/en/telemetry.md` | English telemetry explanation help page |
| `assets/help/pt/telemetry.md` | Portuguese telemetry explanation help page |
| `openapi/telemetry.yaml` | OpenAPI 3.0 spec for the telemetry server API |

### Modified Files
| File | Change |
|------|--------|
| `lib/src/constants/mp_constants.dart` | `mpIsAppImage` build flag + all telemetry constants |
| `lib/src/controllers/types/mp_setting_type.dart` | 9 new `MPSettingID` entries |
| `lib/src/controllers/mp_settings_controller.dart` | Default values for all new settings |
| `lib/src/auxiliary/mp_locator.dart` | `mpTelemetryController` field |
| `lib/main.dart` | `unawaited(mpLocator.mpTelemetryController.initialize())` after settings load |
| `lib/src/pages/mapiah_home.dart` | Consent check + sequenced version check |
| `lib/src/pages/mp_settings_page.dart` | Toggle + "Review" link; consent change routed through controller |
| `lib/src/controllers/mp_general_controller.dart` | TH2 open/close hooks |
| `lib/src/auxiliary/mp_therion_runner.dart` | Therion start/stop hooks |
| `lib/l10n/intl_en.arb` + `lib/l10n/intl_pt.arb` | 8 new localization keys |

---

## Constants (`mp_constants.dart`)

```dart
// Build-time flag (parallel to mpIsFlatpak; set with -D isAppImage=true at build time)
const bool mpIsAppImage = bool.fromEnvironment('isAppImage', defaultValue: false);

// Server endpoints
const String mpTelemetryBaseURL     = 'https://api.mapiah.org';
const String mpTelemetrySubmitEndpoint  = '$mpTelemetryBaseURL/v1/telemetry';
const String mpTelemetryOptInEndpoint   = '$mpTelemetryBaseURL/v1/telemetry/opt-in';
const String mpTelemetryOptOutEndpoint  = '$mpTelemetryBaseURL/v1/telemetry/opt-out';
const int    mpTelemetryRetryIntervalMinutes = 15;
const int    mpTelemetryHttpTimeoutSeconds   = 15;

// Build type identifiers
const String mpTelemetryBuildTypeAppImage = 'AppImage';
const String mpTelemetryBuildTypeFlatpak  = 'Flatpak';
const String mpTelemetryBuildTypeOther    = 'Other';

// Help page asset name (without path/extension)
const String mpHelpPageTelemetry = 'telemetry';
```

---

## Settings (`MPSettingID` enum)

| ID | Type | Default | Description |
|----|------|---------|-------------|
| `Main_TelemetryConsent` | bool | — (no default; use `isBoolSet()`) | User consent; null = not yet asked |
| `Internal_TelemetryCurrentDate` | string | `''` | UTC date being tracked (`YYYY-MM-DD`) |
| `Internal_TelemetryCurrentDayTH2Files` | stringList | `[]` | Unique TH2 paths opened today |
| `Internal_TelemetryCurrentDayTH2OpenCount` | int | `0` | Total TH2 open events today |
| `Internal_TelemetryCurrentDayTH2TimeSecs` | int | `0` | Seconds with ≥1 TH2 open today |
| `Internal_TelemetryCurrentDayTHConfigFiles` | stringList | `[]` | Unique THConfig paths used today |
| `Internal_TelemetryCurrentDayTherionRunCount` | int | `0` | Therion run events today |
| `Internal_TelemetryCurrentDayTherionTimeSecs` | int | `0` | Seconds spent running Therion today |
| `Internal_TelemetryPendingRecords` | stringList | `[]` | JSON-encoded completed daily records |

### Time storage vs transmission

| Metric | Stored locally | Transmitted |
|--------|---------------|-------------|
| TH2 open time | seconds | **minutes** (`secs ÷ 60`, integer division) |
| Therion run time | seconds | **seconds** (as-is) |

---

## `MPTelemetryController`

### Public API

```dart
Future<void> initialize()
Future<void> setConsent(bool value)
void recordTH2Opened(String filePath)
void recordTH2Closed(String filePath)
void recordTHConfigOpened(String thConfigPath)   // called internally by recordTherionStarted
void recordTherionStarted(String thConfigPath)
void recordTherionStopped()
```

### In-memory state (not persisted)

```dart
Timer?   _retryTimer;
int      _openTH2Count = 0;        // how many TH2 files are currently open
DateTime? _th2SessionStartedAt;    // UTC when first TH2 opened in current session
DateTime? _therionStartedAt;       // UTC when current Therion run started
```

### Consent lifecycle

**`initialize()`** — reads persisted consent; if `true`, calls `_tryRolloverAndSend()` and
starts retry timer if there are pending records.

**`setConsent(true)`**:
1. Persist `Main_TelemetryConsent = true`
2. Fire-and-forget POST to `/v1/telemetry/opt-in` (empty body `{}`)
3. Call `_tryRolloverAndSend()` + start retry timer if needed

**`setConsent(false)`**:
1. Persist `Main_TelemetryConsent = false`
2. Cancel retry timer
3. Clear all `Internal_Telemetry*` settings
4. Fire-and-forget POST to `/v1/telemetry/opt-out` (empty body `{}`)

### Multiple simultaneous TH2 files

```
recordTH2Opened(filePath):
  _openTH2Count++
  if _openTH2Count == 1:
    _th2SessionStartedAt = now UTC     // timer starts on first open
  increment TH2OpenCount
  add filePath to TH2Files set (dedup)

recordTH2Closed(filePath):
  _openTH2Count--
  if _openTH2Count == 0 && _th2SessionStartedAt != null:
    TH2TimeSecs += now.difference(_th2SessionStartedAt).inSeconds
    _th2SessionStartedAt = null        // reset for next session
```

Time is measured from first-open to last-close regardless of intermediate opens/closes.

### Rollover logic (`_tryRolloverAndSend`)

1. Get UTC `today` string
2. Read `Internal_TelemetryCurrentDate`
3. If stored date is non-empty AND ≠ `today`:
   - Build aggregated record from current day data
   - Append JSON-encoded record to `Internal_TelemetryPendingRecords`
   - Clear all `Internal_TelemetryCurrentDay*` settings
4. Set `Internal_TelemetryCurrentDate = today`
5. Call `_sendPendingRecords()`

Only records from **previous UTC days** are ever sent; today's partial data stays local.

### Send logic (`_sendPendingRecords`)

HTTP POST to `mpTelemetrySubmitEndpoint`:
```json
{ "records": [ ...aggregated day records... ] }
```
Headers: `Content-Type: application/json`, `Accept-Encoding: gzip`
Timeout: 15 s
On HTTP 200 → clear `Internal_TelemetryPendingRecords`, cancel retry timer
On failure → silently ignore (retry timer handles next attempt)

### Retry timer

```dart
void _startRetryTimerIfNeeded() {
  // Only start when there are pending records and no timer is running.
  if (pending.isEmpty || _retryTimer != null) return;
  _retryTimer = Timer.periodic(Duration(minutes: 15), (_) => _tryRolloverAndSend());
}
void _cancelRetryTimer() { _retryTimer?.cancel(); _retryTimer = null; }
```

### Aggregated day record schema

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

`linuxDistro` and `windowManager` are omitted on non-Linux platforms. All dates are UTC.

### OS info gathering

- `Platform.operatingSystem` → `osType` (linux/macos/windows)
- `Platform.operatingSystemVersion` → `osVersion`
- Linux only: `/etc/os-release` `PRETTY_NAME` → `linuxDistro`
- Linux only: `$XDG_CURRENT_DESKTOP` or `$DESKTOP_SESSION` → `windowManager`

Gathered once per day at aggregation time (low overhead).

---

## Integration Hooks

### TH2 open/close — `MPGeneralController.addFileTab` / `removeFileTab`

```dart
// addFileTab: only call for genuinely new files
if (isNewFile) MPLocator().mpTelemetryController.recordTH2Opened(filename);

// removeFileTab
MPLocator().mpTelemetryController.recordTH2Closed(filename);
```

### Therion run — `MPTherionRunner.start()`

```dart
// Before try block:
mpLocator.mpTelemetryController.recordTherionStarted(thConfigFilePath);

// In finally block:
mpLocator.mpTelemetryController.recordTherionStopped();
```

`recordTherionStarted` also calls `recordTHConfigOpened` internally.

---

## Startup Sequencing (`mapiah_home.dart`)

On first launch the version-check dialog is held until the user responds to the consent dialog,
preventing both dialogs from appearing simultaneously:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) async {
  if (!mpLocator.mpSettingsController.isBoolSet(MPSettingID.Main_TelemetryConsent)) {
    await MPTelemetryConsentDialog.show(context);
  }
  MPDialogAux.checkForUpdates();
});
```

`MPTelemetryConsentDialog.show()` returns `Future<void>` so it can be awaited.

---

## Settings Page (`mp_settings_page.dart`)

- `Main_TelemetryConsent` auto-generates a `SwitchListTile` (bool type) in the Main section.
- A "Review telemetry details and consent" `TextButton` is injected immediately after it,
  opening `MPTelemetryConsentDialog.show(context)`.
- When `_applyChanges` processes `Main_TelemetryConsent`, it calls
  `mpLocator.mpTelemetryController.setConsent(value)` (not the raw `settingsController.setBool`)
  so the full opt-in/opt-out logic is executed.

---

## Localization Keys

| Key | EN | PT |
|-----|----|----|
| `telemetryConsentDialogTitle` | "Help improve Mapiah" | "Ajude a melhorar o Mapiah" |
| `telemetryConsentDialogBody` | 2–3 sentence summary | (translated) |
| `telemetryConsentDialogLearnMore` | "Learn more about what is collected" | "Saiba mais sobre o que é coletado" |
| `telemetryConsentDialogAccept` | "Yes, participate" | "Sim, participar" |
| `telemetryConsentDialogDecline` | "No thanks" | "Não, obrigado" |
| `telemetrySettingsToggleLabel` | "Share anonymous usage data" | "Compartilhar dados de uso anônimos" |
| `telemetrySettingsReviewLink` | "Review telemetry details and consent" | "Revisar detalhes da telemetria e consentimento" |
| `telemetrySettingsSectionTitle` | "Telemetry" | "Telemetria" |

---

## OpenAPI Spec (`openapi/telemetry.yaml`)

Three endpoints at `https://api.mapiah.org/v1`:

| Method | Path | Purpose |
|--------|------|---------|
| POST | `/telemetry` | Submit array of aggregated daily records |
| POST | `/telemetry/opt-in` | Anonymous opt-in counter increment |
| POST | `/telemetry/opt-out` | Anonymous opt-out counter increment |

Opt-in and opt-out bodies are empty `{}`. No identifying information stored or transmitted.

---

## Verification Checklist

1. **First launch (consent not set):** Consent dialog appears before version-check dialog. "No
   thanks" → no data collected, all `Internal_*` settings empty, retry timer not started, opt-out
   POST fired. Relaunch → dialog does NOT appear again.
2. **Consent yes:** `Main_TelemetryConsent = true`, opt-in POST fired. Open/close TH2 files →
   `TH2OpenCount` increments, `TH2TimeSecs` accumulates. Run Therion → `TherionTimeSecs` increases.
3. **Day rollover:** Manually set `Internal_TelemetryCurrentDate` to yesterday → on next
   `_tryRolloverAndSend`, a record is appended to `Internal_TelemetryPendingRecords`.
   Verify `th2TimeMinutes = th2TimeSecs ÷ 60`.
4. **Retry timer:** Starts after rollover creates pending records; cancelled after successful send;
   NOT started when no pending records exist.
5. **Opt-out after consent:** Set to false → local data cleared, opt-out POST fired, timer cancelled.
6. **Re-opt-in:** Set back to true → opt-in POST fired, rollover/send cycle restarts.
7. **Privacy check:** Inspect HTTP payloads — no file paths, IPs, or user-identifiable data.
8. **`flutter analyze`:** No new errors or warnings.

---

## Notes & Trade-offs

- **No OpenAPI code generation**: HTTP calls written manually (same pattern as version check).
  Avoids a new build dependency.
- **`stringList` for pending records**: Each element is a JSON-encoded string; consistent with
  existing settings infrastructure. File paths used locally for unique-count tracking, never sent.
- **`setConsent` returns `Future`**: The `@action` annotation on a `Future`-returning method is
  valid in MobX; the action boundary covers the synchronous part.
- **`unawaited` for opt-in/opt-out POSTs**: Best-effort notifications; failures are silently
  ignored. Using `unawaited` from `dart:async` suppresses the analyzer warning.
- **`MPLocator()` in controller methods**: Controllers cannot access the `mpLocator` global from
  `main.dart` directly; they use the `MPLocator()` singleton factory instead.
- **Settings setters are synchronous**: `setBool`, `setInt`, `setString`, `setStringList` write
  to `SharedPreferencesWithCache` synchronously (cache update is immediate; disk write is async
  in the background). No `await` needed on setters.
- **UTC dates throughout**: All date comparisons and storage use UTC to avoid timezone edge cases.
- **Multiple simultaneous TH2 files**: `_openTH2Count` tracks concurrently open files; time
  measurement runs from first-open to last-close, spanning all intermediate opens/closes.
- **Startup sequencing**: Version-check dialog is deferred until consent dialog is dismissed on
  first launch, preventing both dialogs from competing for attention.
