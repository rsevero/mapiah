import 'dart:convert';

import 'package:mapiah/src/elements/parts/th_part.dart';
import 'package:mapiah/src/exceptions/th_custom_exception.dart';

class THPersonPart extends THPart {
  late final String firstname;
  late final String surname;

  THPersonPart({required this.firstname, required this.surname});

  THPersonPart.fromString({required String name}) {
    if (name.contains('/')) {
      final List<String> names = name.split('/');
      if (names.length != 2) {
        throw THCustomException(
          "Only one slash ('/') allowed in person name at THPersonPart: '$name'",
        );
      }
      firstname = names[0].trim();
      surname = names[1].trim();
    } else if (name.contains(' ')) {
      final last = name.lastIndexOf(' ');
      firstname = name.substring(0, last).trim();
      surname = name.substring(last + 1).trim();
    } else {
      throw THCustomException(
        "Only one space (' ') required in person name at THPersonPart: '$name'",
      );
    }

    if (firstname.isEmpty) {
      throw THCustomException(
        "firstname can´t be empty at THPersonPart: '$name'",
      );
    }
    if (surname.isEmpty) {
      throw THCustomException(
        "surname can´t be empty at THPersonPart: '$name'",
      );
    }
  }

  @override
  THPartType get type => THPartType.person;

  @override
  Map<String, dynamic> toMap() {
    return {'partType': type.name, 'firstname': firstname, 'surname': surname};
  }

  factory THPersonPart.fromMap(Map<String, dynamic> map) {
    return THPersonPart(firstname: map['firstname'], surname: map['surname']);
  }

  factory THPersonPart.fromJson(String jsonString) {
    return THPersonPart.fromMap(jsonDecode(jsonString));
  }

  @override
  THPersonPart copyWith({String? firstname, String? surname}) {
    return THPersonPart(
      firstname: firstname ?? this.firstname,
      surname: surname ?? this.surname,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is THPersonPart &&
        other.firstname == firstname &&
        other.surname == surname;
  }

  @override
  int get hashCode => Object.hash(firstname, surname);

  @override
  String toString() {
    if (firstname.contains(' ') || surname.contains(' ')) {
      return '"$firstname/$surname"';
    } else {
      return '"$firstname $surname"';
    }
  }
}
