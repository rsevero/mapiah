import 'dart:io';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MPDirectoryAux {
  static Directory _rootDirectory = Directory('');
  static bool _rootDirectorySet = false;

  static Future<Directory> get rootDirectory async {
    if (!_rootDirectorySet) {
      _rootDirectory = await getApplicationDocumentsDirectory();
      _rootDirectorySet = true;
    }
    return _rootDirectory;
  }

  static Future<Directory> config() async {
    final Directory rootDir = await rootDirectory;
    final Directory configDirectory = Directory(
      p.join(rootDir.path, thMainDirectory, thConfigDirectory),
    );

    await configDirectory.create(recursive: true);

    return configDirectory;
  }

  static Future<Directory> main() async {
    final Directory rootDir = await rootDirectory;
    final Directory mainDirectory = Directory(
      p.join(rootDir.path, thMainDirectory),
    );

    await mainDirectory.create(recursive: true);

    return mainDirectory;
  }

  static Future<Directory> projects() async {
    final Directory rootDir = await rootDirectory;
    final Directory projectsDirectory = Directory(
      p.join(rootDir.path, thMainDirectory, thProjectsDirectory),
    );

    await projectsDirectory.create(recursive: true);

    return projectsDirectory;
  }

  static String getDefaultLineEnding() {
    if (Platform.isWindows) {
      return '\r\n';
    } else {
      return '\n'; // Linux and macOS
    }
  }

  static String getResolvedPath(String referencePath, String filename) {
    final String resolvedPath = p.normalize(
      p.isAbsolute(filename)
          ? filename
          : p.join(p.dirname(referencePath), filename),
    );

    return resolvedPath;
  }
}
