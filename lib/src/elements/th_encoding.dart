import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_encoding.mapper.dart';

@MappableClass()
class THEncoding extends THElement with THEncodingMappable {
  THEncoding(super.parent) : super.addToParent();

  set encoding(String aEncoding) {
    thFile.encoding = aEncoding;
  }

  String get encoding {
    return thFile.encoding;
  }

  @override
  bool isSameClass(THElement element) {
    return element is THEncoding;
  }
}
