<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Linux release instructions

Before creating the release tag, run `dart run scripts/update_flutter_and_mapiah_version.dart` from the repository root and include both updated `Mapiah-User-Guide-en.pdf` and `Mapiah-Guia_do_usuario-pt.pdf` in the release commit. The version script now generates the PDFs and needs Google Chrome (or set `CHROME_BIN` to its executable). The AppImage workflow generates both guides again from the tagged help assets and uploads them to the GitHub release.
