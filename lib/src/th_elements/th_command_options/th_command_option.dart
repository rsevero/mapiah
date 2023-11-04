import 'package:mapiah/src/th_elements/th_has_options.dart';

abstract class THCommandOption {
  final THHasOptions optionParent;

  THCommandOption(this.optionParent) {
    optionParent.addUpdateOption(this);
  }

  String get optionType;

  String specToFile();
}
