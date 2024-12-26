import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_command_option.mapper.dart';

@MappableClass()
abstract class THCommandOption with THCommandOptionMappable {
  final THHasOptions optionParent;

  THCommandOption(this.optionParent) {
    optionParent.addUpdateOption(this);
  }

  String get optionType;

  String specToFile();
}
