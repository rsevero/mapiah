import 'package:mapiah/src/elements/th_file.dart';

mixin MPTHFileReferenceMixin {
  THFile? _thFile;

  THFile? get thFile => _thFile;

  void setTHFile(THFile thFile) {
    _thFile = thFile;
  }
}
