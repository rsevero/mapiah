import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/command_options/th_multiple_choice_command_option.dart';
import 'package:mapiah/src/elements/th_has_options.dart';

part 'th_clip_command_option.mapper.dart';

@MappableClass()
class THClipCommandOption extends THMultipleChoiceCommandOption
    with THClipCommandOptionMappable {
  static const _thisOptionType = 'clip';
  // static final HashSet<String> _unsupportedPointTypes = HashSet<String>.from({
  //   'altitude',
  //   'date',
  //   'height',
  //   'label',
  //   'passage-height',
  //   'remark',
  //   'station-name',
  //   'station',
  // });

  /// Constructor necessary for dart_mappable support.
  THClipCommandOption.withExplicitParameters(
    super.parentMapiahID,
    super.parentElementType,
    super.optionType,
    super.choice,
  ) : super.withExplicitParameters();

  THClipCommandOption(super.optionParent, super.optionType, super.choice);

  THClipCommandOption.fromChoice(THHasOptions optionParent, String choice)
      : super(optionParent, _thisOptionType, choice);
}
