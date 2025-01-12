import 'package:mapiah/src/elements/th_element.dart';

class THFileParseResult {
  final THFile thFile;
  final bool success;
  final List<String> errors;

  THFileParseResult(this.thFile, this.success, this.errors);
}
