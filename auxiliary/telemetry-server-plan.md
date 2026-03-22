<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Mapiah Telemetry Server — Implementation Plan

## Overview

A small PHP + MySQL server hosted at `api.mapiah.org` on Hostinger. Receives anonymous
aggregated usage records from Mapiah clients, stores them in a two-tier retention structure
(daily for 366 days, then monthly forever), and exposes a read-only admin dashboard.

**Separate repository**: `mapiah-telemetry-server`
**API contract**: `openapi/telemetry.yaml` in the Mapiah client repo is the source of truth.

---

## Repository Structure

```
mapiah-telemetry-server/
├── public/                         ← document root (set in Hostinger panel)
│   ├── .htaccess                   ← URL rewriting + HTTPS redirect + admin auth
│   ├── v1/
│   │   ├── telemetry.php           ← POST /v1/telemetry
│   │   ├── telemetry-opt-in.php    ← POST /v1/telemetry/opt-in
│   │   └── telemetry-opt-out.php   ← POST /v1/telemetry/opt-out
│   └── admin/
│       ├── .htpasswd               ← bcrypt password file (gitignored)
│       └── index.php               ← read-only dashboard
├── src/
│   ├── db.php                      ← PDO connection singleton
│   ├── response.php                ← json_ok() / json_error() helpers
│   ├── validate.php                ← DailyRecord field validation
│   ├── upsert.php                  ← daily_totals upsert logic
│   └── json_merge.php              ← merge two JSON count maps {key: int}
├── cron/
│   └── rollup.php                  ← aggregation + purge (run daily via cron)
├── schema/
│   └── schema.sql                  ← CREATE TABLE statements
├── config.php.example              ← template; real config.php is gitignored
├── .gitignore
└── README.md
```

---

## Database Schema

### `daily_totals` — one row per calendar day; kept 366 days

```sql
CREATE TABLE daily_totals (
  day               DATE NOT NULL PRIMARY KEY,
  user_days         INT UNSIGNED NOT NULL DEFAULT 0,  -- number of client submissions
  linux_users       INT UNSIGNED NOT NULL DEFAULT 0,
  macos_users       INT UNSIGNED NOT NULL DEFAULT 0,
  windows_users     INT UNSIGNED NOT NULL DEFAULT 0,
  appimage_users    INT UNSIGNED NOT NULL DEFAULT 0,
  flatpak_users     INT UNSIGNED NOT NULL DEFAULT 0,
  other_users       INT UNSIGNED NOT NULL DEFAULT 0,
  th2_files         INT UNSIGNED NOT NULL DEFAULT 0,  -- sum across all submissions
  th2_opens         INT UNSIGNED NOT NULL DEFAULT 0,
  th2_minutes       INT UNSIGNED NOT NULL DEFAULT 0,
  thconfig_files    INT UNSIGNED NOT NULL DEFAULT 0,
  therion_runs      INT UNSIGNED NOT NULL DEFAULT 0,
  therion_secs      BIGINT UNSIGNED NOT NULL DEFAULT 0,
  versions_json     JSON NULL,   -- {"1.2.3": 5, "1.3.0": 2}
  distros_json      JSON NULL,   -- {"Fedora Linux 43": 4, "Ubuntu 24.04": 1}
  wm_json           JSON NULL    -- {"KDE": 3, "GNOME": 2}
);
```

### `monthly_totals` — one row per calendar month; kept forever

```sql
CREATE TABLE monthly_totals (
  month             DATE NOT NULL PRIMARY KEY,  -- first day of the month
  user_days         INT UNSIGNED NOT NULL DEFAULT 0,
  linux_users       INT UNSIGNED NOT NULL DEFAULT 0,
  macos_users       INT UNSIGNED NOT NULL DEFAULT 0,
  windows_users     INT UNSIGNED NOT NULL DEFAULT 0,
  appimage_users    INT UNSIGNED NOT NULL DEFAULT 0,
  flatpak_users     INT UNSIGNED NOT NULL DEFAULT 0,
  other_users       INT UNSIGNED NOT NULL DEFAULT 0,
  th2_files         BIGINT UNSIGNED NOT NULL DEFAULT 0,
  th2_opens         BIGINT UNSIGNED NOT NULL DEFAULT 0,
  th2_minutes       BIGINT UNSIGNED NOT NULL DEFAULT 0,
  thconfig_files    BIGINT UNSIGNED NOT NULL DEFAULT 0,
  therion_runs      BIGINT UNSIGNED NOT NULL DEFAULT 0,
  therion_secs      BIGINT UNSIGNED NOT NULL DEFAULT 0,
  versions_json     JSON NULL,
  distros_json      JSON NULL,
  wm_json           JSON NULL
);
```

### `consent_events` — anonymous opt-in / opt-out counter; kept forever

```sql
CREATE TABLE consent_events (
  id          BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  event_type  ENUM('opt_in', 'opt_out') NOT NULL,
  event_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_type_date (event_type, event_at)
);
```

---

## Endpoint Logic

### `POST /v1/telemetry`

1. Decode JSON body; reject if body > 64 KB (HTTP 400).
2. Validate `records` is a non-empty array (max 400 elements).
3. For each record: validate all required fields (types, ranges, enum values). Skip invalid
   records silently — never reject the whole batch for one bad record.
4. For each valid record: upsert into `daily_totals`:
   - `BEGIN` transaction, `SELECT … FOR UPDATE` on `daily_totals WHERE day = record.date`.
   - If row exists: add numeric fields, merge JSON count maps in PHP, `UPDATE`.
   - If no row: `INSERT`.
   - `COMMIT`.
5. Always respond `200 {}` for well-formed requests (so old client versions never retry forever).

**JSON count map merge** (`json_merge.php`): given two `{"key": int}` maps, produce a map
where each key's value is the sum. Used for `versions_json`, `distros_json`, `wm_json`.

```php
function mergeCountMaps(?array $a, ?array $b): array {
    $result = $a ?? [];
    foreach (($b ?? []) as $key => $count) {
        $result[$key] = ($result[$key] ?? 0) + $count;
    }
    return $result;
}
```

### `POST /v1/telemetry/opt-in` and `/opt-out`

Insert one row into `consent_events`. Body is ignored. Always respond `200 {}`.

---

## Aggregation & Retention Cron (`cron/rollup.php`)

Run once daily at **03:00 UTC** via Hostinger cron (`php /path/to/cron/rollup.php`).

### Step 1 — Roll daily → monthly

A calendar month is eligible for rollup when every recorded day in that month is older than
**366 days** (condition: `HAVING MAX(day) <= cutoff`). This ensures no partial months are
rolled up prematurely.

```
cutoff = TODAY - 366 days

For each distinct month_start where MAX(day) <= cutoff:
    SELECT all daily_totals rows for that month.
    Aggregate them (SUM numerics, merge JSONs).
    UPSERT into monthly_totals.
    DELETE those daily_totals rows.
```

The table may temporarily hold up to ~397 rows (366 + up to 31 days while waiting for a
month-end to cross the threshold). This is expected and harmless.

### Step 2 — Purge orphan daily rows

Delete any `daily_totals` rows with `day <= cutoff` that were not part of a complete month
eligible for rollup (e.g. the very first days of data collection if data started mid-month
and that partial month never filled in).

```sql
DELETE FROM daily_totals WHERE day <= cutoff;
```

### JSON aggregation in cron

Same `mergeCountMaps()` helper used in the HTTP handler. Decode each row's JSON columns,
merge all of them into one map, encode back to JSON for the aggregate row.

---

## Rate Limiting

Simple DB-based rate limiter (works on all Hostinger shared plans without APCu):

```sql
CREATE TABLE rate_limits (
  ip_hash    CHAR(64) NOT NULL,  -- SHA-256 of IP; IP itself never stored
  endpoint   VARCHAR(30) NOT NULL,
  window_start DATETIME NOT NULL,
  hit_count  SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  PRIMARY KEY (ip_hash, endpoint, window_start),
  INDEX idx_cleanup (window_start)
);
```

- Window: 1 minute. Limit: 10 hits per IP per endpoint per window.
- On each request: `INSERT … ON DUPLICATE KEY UPDATE hit_count = hit_count + 1`, then
  read `hit_count`. If > 10, return HTTP 429.
- Cron or on-request cleanup: delete rows with `window_start < NOW() - INTERVAL 2 MINUTE`.
- IP is hashed before storing — the raw IP never touches the database.

---

## Admin Dashboard (`public/admin/index.php`)

### Authentication

HTTP Basic Auth via `.htaccess` + `.htpasswd` (bcrypt). The `.htpasswd` file is gitignored;
generated once on the server with `htpasswd -c -B .htpasswd admin`.

### Layout

Single PHP-rendered HTML page. No framework. Chart.js loaded from CDN.

### Sections

**1. Consent summary** (text cards)
- Total opt-ins (all time)
- Total opt-outs (all time)
- Net participants (opt-ins − opt-outs)
- Opt-ins last 30 days / last 7 days

**2. Active user-days over time** (two bar charts)
- Last 30 days (from daily_totals)
- All months (from monthly_totals)
- Y-axis: user_days (count of submissions per period)

**3. OS distribution** (doughnut chart)
- Source: sum of linux/macos/windows_users from daily_totals for last 30 days

**4. Build type distribution** (doughnut chart)
- Source: sum of appimage/flatpak/other_users from daily_totals for last 30 days

**5. Mapiah version distribution** (horizontal bar chart)
- Source: merge of `versions_json` from daily_totals for last 30 days
- Shows top 10 versions

**6. TH2 usage** (line chart — last 30 days)
- Lines: avg th2_minutes per user-day, avg th2_opens per user-day

**7. Therion usage** (line chart — last 30 days)
- Lines: avg therion_runs per user-day, avg therion_secs per user-day

**8. Linux distros** (table, last 30 days)
- Merged from `distros_json`, top 15 distros with counts

**9. Window managers** (table, last 30 days)
- Merged from `wm_json`, top 10 WMs with counts

---

## Security Summary

| Concern | Mitigation |
|---------|-----------|
| Production data pollution from debug runs | Client-side: `mpDebugTelemetryLogOnly` flag stops all HTTP calls |
| Rate abuse | DB-based rate limiter; 10 req/min/IP/endpoint |
| XSS in admin | All DB values passed through `htmlspecialchars()` before render |
| SQL injection | PDO prepared statements throughout |
| Admin access | HTTP Basic Auth (bcrypt); HTTPS enforced |
| IP privacy | SHA-256 hash stored in rate_limits; raw IP never persisted |
| Body size DoS | 64 KB hard limit on request body |
| Large record batches | Max 400 records per POST |

---

## Deployment on Hostinger

```bash
# First deploy
ssh user@hostinger-server
git clone git@github.com:rsevero/mapiah-telemetry-server.git
cp config.php.example config.php   # fill in DB credentials
mysql -u user -p mapiah_telemetry < schema/schema.sql

# Set document root to public/ in Hostinger panel
# Add cron: 0 3 * * * php /home/user/mapiah-telemetry-server/cron/rollup.php

# Subsequent deploys
git pull
# No migration needed unless schema changed
```

---

## Open Questions

- **Hostinger plan**: does it support `SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE`?
  If not, the upsert can use `LOCK TABLES` as a fallback for the daily_totals upsert.
- **Admin password rotation**: store reminder in a private note; `.htpasswd` is never in git.
- **Alerting**: no alerting planned initially. Monitor via admin dashboard manually.
- **Backups**: rely on Hostinger automated backups for the database. No additional backup script
  planned initially.
