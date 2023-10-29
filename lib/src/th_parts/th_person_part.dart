import 'package:mapiah/src/th_exceptions/th_custom_exception.dart';

class THPersonPart {
  late String firstname;
  late String surname;

  THPersonPart(this.firstname, this.surname);

  THPersonPart.fromString(String aName) {
    if (aName.contains('/')) {
      final names = aName.split('/');
      if (names.length != 2) {
        throw THCustomException(
            "Only one slash ('/') allowed in person name at THPersonPart: '$aName'");
      }
      firstname = names[0].trim();
      surname = names[1].trim();
    } else if (aName.contains(' ')) {
      final last = aName.lastIndexOf(' ');
      firstname = aName.substring(0, last).trim();
      surname = aName.substring(last + 1).trim();
    } else {
      throw THCustomException(
          "Only one space (' ') required in person name at THPersonPart: '$aName'");
    }

    if (firstname.isEmpty) {
      throw THCustomException(
          "firstname can´t be empty at THPersonPart: '$aName'");
    }
    if (surname.isEmpty) {
      throw THCustomException(
          "surname can´t be empty at THPersonPart: '$aName'");
    }
  }

  @override
  String toString() {
    if (firstname.contains(' ') || surname.contains(' ')) {
      return '"$firstname/$surname"';
    } else {
      return '$firstname $surname';
    }
  }
}
