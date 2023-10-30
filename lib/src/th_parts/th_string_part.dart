import 'package:mapiah/src/th_definitions.dart';

class THStringPart {
  String content;

  THStringPart(this.content);

  static final _quoteRegex = RegExp(thQuote);

  @override
  String toString() {
    return content;
  }

  String toFile() {
    var asString = content;

    if ((content.contains(' ')) || (content.contains(thQuote))) {
      asString = asString.replaceAll(_quoteRegex, thDoubleQuote);
      asString = '"$asString"';
    }

    return asString;
  }
}
