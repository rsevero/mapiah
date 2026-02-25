import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THIDWithSpaceException extends THBaseException {
  THIDWithSpaceException(String elementType, String id)
    : super("Spaces not allowed in IDs: '$id'. Element type: '$elementType'");
}
