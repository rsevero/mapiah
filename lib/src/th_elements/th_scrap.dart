import "package:mapiah/src/th_elements/th_element.dart";
import "package:mapiah/src/th_elements/th_has_options.dart";

class THScrap extends THElement with THHasOptions, THParent {
  var id = '';

  THScrap(super.parent, this.id) : super.withParent();
}
