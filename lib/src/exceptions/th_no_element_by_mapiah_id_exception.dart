import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THNoElementByMPIDException extends THBaseException {
  THNoElementByMPIDException(String filename, int index)
    : super("No element with index '$index' in file '$filename'.");
}
