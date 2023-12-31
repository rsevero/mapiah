import "package:mapiah/src/th_elements/th_element.dart";

class THEncoding extends THElement {
  THEncoding(super.parent) : super.withParent();

  set encoding(String aEncoding) {
    thFile.encoding = aEncoding;
  }

  String get encoding {
    return thFile.encoding;
  }
}
