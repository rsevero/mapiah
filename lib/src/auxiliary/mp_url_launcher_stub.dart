// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:url_launcher/url_launcher.dart';

Future<bool> openUrlImpl(Uri uri) async {
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
