import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";
import "package:mapiah/src/elements/th_file.dart";

part 'th_encoding.mapper.dart';

@MappableClass()
class THEncoding extends THElement with THEncodingMappable {
  late String _encoding;

  // Used by dart_mappable.
  THEncoding.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
    String encoding,
  ) : super.notAddToParent() {
    _encoding = encoding;
  }

  THEncoding(super.parentMapiahID, String encoding) : super() {
    _encoding = encoding;
  }

  void setEncoding(THFile thFile, String encoding) {
    _encoding = encoding;
    thFile.encoding = encoding;
  }

  String get encoding => _encoding;

  @override
  bool isSameClass(Object object) {
    return object is THEncoding;
  }
}
