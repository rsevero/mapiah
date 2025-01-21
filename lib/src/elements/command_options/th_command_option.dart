import 'package:mapiah/src/auxiliary/th_serializeable.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

abstract class THCommandOption implements THSerializable {
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

  String get optionType => _optionType;

  THHasOptions optionParent(THFile thFile) =>
      thFile.elementByMapiahID(parentMapiahID) as THHasOptions;

  String specToFile();
}
