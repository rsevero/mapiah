import 'package:mapiah/src/elements/th_element.dart';

abstract class THSelectedElement {
  THElement get modifiedElement;

  THElement get originalElement;

  set modifiedElement(THElement element);

  set originalElement(THElement element);
}
