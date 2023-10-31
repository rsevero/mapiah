import 'package:mapiah/src/th_elements/th_has_options.dart';

abstract class THCommandOption {
  final THHasOptions parentOption;

  THCommandOption(this.parentOption) {
    parentOption.addUpdateOption(this);
  }

  String get optionType;

  String specToFile();
}
