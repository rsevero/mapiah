import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/definitions/th_definitions.dart';

part 'th_string_part.mapper.dart';

@MappableClass()
class THStringPart with THStringPartMappable {
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
