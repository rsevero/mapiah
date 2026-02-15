import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THCreateObjectFromNullValueException extends THBaseException {
  final String objectType;

  THCreateObjectFromNullValueException(this.objectType)
    : super("Can´t create object of type '$objectType' from null.");
}
