import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_id_command_option.mapper.dart';

// id <ext_keyword> . ID of the symbol.
@MappableClass()
class THIDCommandOption extends THCommandOption with THIDCommandOptionMappable {
  static const String _thisOptionType = 'id';
  late String thID;

  /// Constructor necessary for dart_mappable support.
  THIDCommandOption.withExplicitParameters(
    super.parentMapiahID,
    super.optionType,
    this.thID,
  ) : super.withExplicitParameters();

  THIDCommandOption(THHasOptions optionParent, this.thID)
      : super(
          optionParent,
          _thisOptionType,
        ); // TODO: call thFile.addElementWithTHID for the parent of this option. Was done with: optionParent.thFile.addElementWithTHID(optionParent, thID);

  @override
  String specToFile() {
    return thID;
  }
}
