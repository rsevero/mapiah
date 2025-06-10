import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

void saveFileWeb(Uint8List bytes, String filename) {
  final web.Blob blob = web.Blob(
    [bytes.buffer.toJS].toJS,
    web.BlobPropertyBag(type: 'text/plain', endings: 'native'),
  );

  web.HTMLAnchorElement()
    ..href = web.URL.createObjectURL(blob)
    ..setAttribute('download', filename)
    ..click()
    ..remove();
}
