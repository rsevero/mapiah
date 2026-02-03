import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openUrlImpl(Uri uri) async {
  if (Platform.isLinux) {
    try {
      final ProcessResult result = await Process.run(
        'gio',
        ['open', uri.toString()],
        environment: {...Platform.environment, 'GIO_USE_PORTAL': '1'},
      );

      if (result.exitCode == 0) {
        return true;
      }
    } catch (_) {
      // Fall back to url_launcher below.
    }
  }

  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
