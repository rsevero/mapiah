import 'package:mapiah/src/elements/th_element.dart';

abstract class MPSelectedElement {
  int get mapiahID => originalElementClone.mapiahID;

  THElement get originalElementClone;
}
