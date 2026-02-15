import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THNoElementByIDException extends THBaseException {
  THNoElementByIDException(String elementType, String id, String filename)
    : super(
        "No element of type '$elementType' with ID '$id' in file '$filename'",
      );
}
