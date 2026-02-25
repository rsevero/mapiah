import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THConvertFromStringException extends THBaseException {
  final String objectNameToCreate;
  final String originalString;

  THConvertFromStringException(this.objectNameToCreate, this.originalString)
    : super(
        "Creation of a '$objectNameToCreate' from string '$originalString' failed.",
      );
}
