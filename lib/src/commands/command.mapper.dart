// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'command.dart';

class CommandMapper extends ClassMapperBase<Command> {
  CommandMapper._();

  static CommandMapper? _instance;
  static CommandMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CommandMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Command';

  static String _$description(Command v) => v.description;
  static const Field<Command, String> _f$description =
      Field('description', _$description);
  static String _$oppositeCommandJson(Command v) => v.oppositeCommandJson;
  static const Field<Command, String> _f$oppositeCommandJson =
      Field('oppositeCommandJson', _$oppositeCommandJson);

  @override
  final MappableFields<Command> fields = const {
    #description: _f$description,
    #oppositeCommandJson: _f$oppositeCommandJson,
  };

  static Command _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('Command');
  }

  @override
  final Function instantiate = _instantiate;

  static Command fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Command>(map);
  }

  static Command fromJson(String json) {
    return ensureInitialized().decodeJson<Command>(json);
  }
}

mixin CommandMappable {
  String toJson();
  Map<String, dynamic> toMap();
  CommandCopyWith<Command, Command, Command> get copyWith;
}

abstract class CommandCopyWith<$R, $In extends Command, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? description, String? oppositeCommandJson});
  CommandCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}
