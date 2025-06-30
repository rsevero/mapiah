import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

void saveFileWeb(Uint8List bytes, String filename) {
  print('DEBUG (Mapiah): Entered saveFileWeb with filename: $filename');
  print('DEBUG (Mapiah): Bytes length: ${bytes.length}');
  final web.Blob blob = web.Blob(
    [bytes.buffer.toJS].toJS,
    web.BlobPropertyBag(type: 'text/plain', endings: 'native'),
  );
  print('DEBUG (Mapiah): Blob created with type: ${blob.type}');
  web.HTMLAnchorElement()
    ..href = web.URL.createObjectURL(blob)
    ..setAttribute('download', filename)
    ..click()
    ..remove();
  print('DEBUG (Mapiah): Download link clicked for file: $filename');
}
