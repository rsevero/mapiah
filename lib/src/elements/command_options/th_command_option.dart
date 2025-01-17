import 'dart:convert';

import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

abstract class THCommandOption {
  late final int parentMapiahID;
  late final String _optionType;

  THCommandOption({
    required this.parentMapiahID,
    required String optionType,
  }) : _optionType = optionType;

  THCommandOption.addToOptionParent({
    required THHasOptions optionParent,
    required String optionType,
  })  : _optionType = optionType,
        parentMapiahID = optionParent.mapiahID {
    optionParent.addUpdateOption(this);
  }

  THCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
  });

  Map<String, dynamic> toMap() {
    return {
      'parentMapiahID': parentMapiahID,
      'optionType': optionType,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  @override
  bool operator ==(covariant THCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.optionType == optionType;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
        optionType,
      );

  String get optionType => _optionType;

  THHasOptions optionParent(THFile thFile) =>
      thFile.elementByMapiahID(parentMapiahID) as THHasOptions;

  String specToFile();
}
