<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Telemetry — Anonymous Usage Data

Mapiah can optionally collect anonymous, aggregated usage data to help prioritize development and understand how the application is used.

## What is collected

Each day that you use Mapiah, a single aggregated record may be sent containing:

| Field | Description |
|-------|-------------|
| Date | UTC date (e.g. 2026-03-20) |
| OS type | linux, macos, or windows |
| OS version | raw version string from the operating system |
| Linux distro | distribution name (Linux only, e.g. "Fedora Linux 43") |
| Window manager | desktop environment (Linux only, e.g. "KDE") |
| Mapiah version | the version of Mapiah you are running |
| Build type | AppImage, Flatpak, or Other |
| TH2 files (unique) | number of distinct TH2 files opened that day |
| TH2 open count | total number of times a TH2 file was opened |
| TH2 time (minutes) | total minutes with at least one TH2 file open |
| THConfig files (unique) | number of distinct THConfig files used |
| Therion run count | number of times Therion was run |
| Therion time (seconds) | total seconds spent running Therion |

## What is NOT collected

* Your name, email, or any account information
* Device identifiers, IP addresses, or location
* File names or file paths
* The content of any cave survey or TH2 file
* Any information that could identify you or your computer

## How data is handled

Data is collected locally throughout the day and only the previous day's aggregated record is ever transmitted. No partial or real-time data leaves your computer. Records are sent via HTTPS to `api.mapiah.org`. If a send fails (no network, server down), Mapiah retries automatically every 15 minutes.

When you first accept or decline telemetry, an immediate notification (containing no identifying information) is sent to the server so the anonymous opt-in or opt-out counter can be incremented. This lets Mapiah understand overall consent trends without any user-level tracking.

## How to change your choice

You can enable or disable telemetry at any time on the _Settings_ page under the **Main** section. The toggle labeled "Share anonymous usage data" controls this setting. You can also click "Review telemetry details and consent" on the Settings page to see this dialog again.

When you opt out, all locally stored telemetry data is deleted immediately and an anonymous opt-out notification is sent to the server. When you opt back in, an anonymous opt-in notification is sent.
