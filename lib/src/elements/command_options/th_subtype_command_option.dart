import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_subtype_command_option.mapper.dart';

// subtype <keyword> . determines the object’s subtype. The following subtypes for
// given types are supported:
// station: 21 temporary (default), painted, natural, fixed;
// air-draught: winter, summer, undefined (default);
// water-flow: permanent (default), intermittent, paleo.
// The subtype may be specified also directly in <type> specification using ‘:’ as a
// separator.22
// Any subtype specification can be used with user defined type (u). In this case you need
// also to define corresponding metapost symbol (see the chapter New map symbols).
@MappableClass()
class THSubtypeCommandOption extends THCommandOption
    with THSubtypeCommandOptionMappable {
  static const String _thisOptionType = 'subtype';
  String subtype;

  // static final Map<String, Map<String, Map<String, Object>>> _allowedSubtypes =
  //     {
  //   'point': {
  //     'air-draught': {
  //       'default': 'undefined',
  //       'subtypes': <String>{
  //         'winter',
  //         'summer',
  //         'undefined',
  //       },
  //     },
  //     'station': {
  //       'default': 'temporary',
  //       'subtypes': <String>{
  //         'temporary',
  //         'painted',
  //         'natural',
  //         'fixed',
  //       },
  //     },
  //     'water-flow': {
  //       'default': 'permanent',
  //       'subtypes': <String>{
  //         'permanent',
  //         'intermittent',
  //         'paleo',
  //       },
  //     },
  //   },
  //   'line': {
  //     'border': {
  //       'default': 'visible',
  //       'subtypes': <String>{
  //         'invisible',
  //         'presumed',
  //         'temporary',
  //         'visible',
  //       },
  //     },
  //     'survey': {
  //       'default': 'cave',
  //       'subtypes': <String>{
  //         'cave',
  //         'surface',
  //       },
  //     },
  //     'wall': {
  //       'default': 'bedrock',
  //       'subtypes': <String>{
  //         'bedrock',
  //         'blocks',
  //         'clay',
  //         'debris',
  //         'flowstone',
  //         'ice',
  //         'invisible',
  //         'moonmilk',
  //         'overlying',
  //         'pebbles',
  //         'pit',
  //         'presumed',
  //         'sand',
  //         'underlying',
  //         'unsurveyed',
  //       },
  //     },
  //     'water-flow': {
  //       'default': 'permanent',
  //       'subtypes': <String>{
  //         'permanent',
  //         'conjectural',
  //         'intermittent',
  //       },
  //     },
  //   },
  // };

  /// Constructor necessary for dart_mappable support.
  THSubtypeCommandOption.withExplicitParameters(
    super.parentMapiahID,
    super.optionType,
    this.subtype,
  ) : super.withExplicitParameters();

  THSubtypeCommandOption(THHasOptions optionParent, this.subtype)
      : super(optionParent, _thisOptionType);

  @override
  String specToFile() {
    return subtype;
  }
}
