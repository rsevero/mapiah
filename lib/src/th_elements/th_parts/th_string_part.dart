import 'package:mapiah/src/th_definitions.dart';

class THStringPart {
  String content;

  THStringPart([this.content = '']);

  static final _quoteRegex = RegExp(thDoubleQuote);

  @override
  String toString() {
    return content;
  }

  String toFile() {
    var asString = content;

    if (content.isEmpty) {
      asString = r'""';
    } else if ((content.contains(' ')) || (content.contains(thDoubleQuote))) {
      asString = asString.replaceAll(_quoteRegex, thDoubleQuotePair);
      asString = '"$asString"';
    }

    return asString;
  }
}
