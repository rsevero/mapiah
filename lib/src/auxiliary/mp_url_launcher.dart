// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/auxiliary/mp_url_launcher_stub.dart'
    if (dart.library.io) 'mp_url_launcher_io.dart';

class MPUrlLauncher {
  static Future<bool> openUrl(Uri uri) => openUrlImpl(uri);
}
