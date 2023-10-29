import 'package:mapiah/src/th_elements/th_has_options.dart';

abstract class THCommandOption {
  final THHasOptions parent;

  THCommandOption(this.parent) {
    parent.addUpdateOption(this);
  }

  String optionType();

  String specToString();
}
