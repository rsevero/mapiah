import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final deps = await _run('flutter', ['pub', 'deps', '--json']);
  final data = jsonDecode(deps) as Map<String, dynamic>;

  // Only hosted packages exist on pub.dev; skip SDK/git/path
  final pkgs = (data['packages'] as List)
      .where((p) => p['kind'] != 'root' && p['source'] == 'hosted')
      .map((p) => (p['name'] as String, p['version'] as String))
      .toSet();

  for (final (name, version) in pkgs) {
    final pkgInfo = await _httpGet('https://pub.dev/api/packages/$name');
    if (pkgInfo != null && pkgInfo['isDiscontinued'] == true) {
      final repl = pkgInfo['replacedBy'];
      stdout.writeln('DISCONTINUED: $name${repl != null ? ' -> $repl' : ''}');
    }
    final verInfo = await _httpGet(
      'https://pub.dev/api/packages/$name/versions/$version',
    );
    if (verInfo != null && verInfo['retracted'] == true) {
      stdout.writeln('RETRACTED VERSION: $name $version');
    }
  }
}

Future<String> _run(String exe, List<String> args) async {
  final p = await Process.start(exe, args, runInShell: true);
  final out = await p.stdout.transform(utf8.decoder).join();
  final err = await p.stderr.transform(utf8.decoder).join();
  final code = await p.exitCode;
  if (code != 0) throw Exception('Failed to run $exe ${args.join(' ')}: $err');
  return out;
}

Future<Map<String, dynamic>?> _httpGet(String url) async {
  final client = HttpClient();
  try {
    final req = await client.getUrl(Uri.parse(url));
    final res = await req.close();
    if (res.statusCode != 200) return null;
    final body = await res.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, dynamic>;
  } finally {
    client.close(force: true);
  }
}
