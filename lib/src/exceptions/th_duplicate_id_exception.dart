import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THDuplicateIDException extends THBaseException {
  THDuplicateIDException(String duplicateID, String filename)
    : super("Duplicate ID '$duplicateID' in file '$filename'");
}
