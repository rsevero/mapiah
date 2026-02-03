import 'mp_url_launcher_stub.dart'
    if (dart.library.io) 'mp_url_launcher_io.dart';

class MPUrlLauncher {
  static Future<bool> openUrl(Uri uri) => openUrlImpl(uri);
}
