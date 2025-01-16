import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_encoding.mapper.dart';

@MappableClass()
class THEncoding extends THElement with THEncodingMappable {
  // Used by dart_mappable.
  THEncoding.notAddToParent(
    super.mapiahID,
    super.parentMapiahID,
    super.sameLineComment,
    String encoding,
  ) : super.notAddToParent() {
    this.encoding = encoding;
  }

  THEncoding(super.parent) : super.addToParent();

  set encoding(String newEncoding) {
    thFile.encoding = newEncoding;
  }

  String get encoding {
    return thFile.encoding;
  }

  @override
  bool isSameClass(THElement element) {
    return element is THEncoding;
  }
}
