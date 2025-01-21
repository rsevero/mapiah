// date: -value <date> sets the date for the date point.
import 'package:dogs_core/dogs_core.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';

@serializable
class THDateValueCommandOption extends THCommandOption
    with Dataclass<THDateValueCommandOption> {
  static const String _thisOptionType = 'value';
  late final THDatetimePart date;

  THDateValueCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.date,
  }) : super();

  THDateValueCommandOption.fromString({
    required super.optionParent,
    required String date,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    this.date = THDatetimePart(date);
  }

  @override
  Map<String, dynamic> toMap() {
    return dogs.toNative<THDateValueCommandOption>(this);
  }

  factory THDateValueCommandOption.fromMap(Map<String, dynamic> map) {
    return dogs.fromNative<THDateValueCommandOption>(map);
  }

  @override
  String toJson() {
    return dogs.toJson<THDateValueCommandOption>(this);
  }

  factory THDateValueCommandOption.fromJson(String jsonString) {
    return dogs.fromJson<THDateValueCommandOption>(jsonString);
  }

  @override
  THDateValueCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THDatetimePart? date,
  }) {
    return THDateValueCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      date: date ?? this.date,
    );
  }

  @override
  String specToFile() {
    return date.toString();
  }
}
