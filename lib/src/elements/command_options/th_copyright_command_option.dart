import 'package:dogs_core/dogs_core.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_has_text.dart';
import 'package:mapiah/src/elements/parts/th_datetime_part.dart';

// copyright <date> <string> . copyright date and name
@serializable
class THCopyrightCommandOption extends THCommandOption
    with Dataclass<THCopyrightCommandOption>, THHasText {
  static const String _thisOptionType = 'copyright';
  late THDatetimePart datetime;

  /// Constructor necessary for dart_mappable support.
  THCopyrightCommandOption({
    required super.parentMapiahID,
    required super.optionType,
    required this.datetime,
    required String copyrightMessage,
  }) : super() {
    text = copyrightMessage;
  }

  THCopyrightCommandOption.addToOptionParent({
    required super.optionParent,
    required this.datetime,
    required String copyrightMessage,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    text = copyrightMessage;
  }

  THCopyrightCommandOption.fromString({
    required super.optionParent,
    required String datetime,
    required String text,
  }) : super.addToOptionParent(optionType: _thisOptionType) {
    this.datetime = THDatetimePart(datetime);
    this.text = text;
  }

  @override
  Map<String, dynamic> toMap() {
    return dogs.toNative<THCopyrightCommandOption>(this);
  }

  factory THCopyrightCommandOption.fromMap(Map<String, dynamic> map) {
    return dogs.fromNative<THCopyrightCommandOption>(map);
  }

  @override
  String toJson() {
    return dogs.toJson<THCopyrightCommandOption>(this);
  }

  factory THCopyrightCommandOption.fromJson(String jsonString) {
    return dogs.fromJson<THCopyrightCommandOption>(jsonString);
  }

  @override
  THCopyrightCommandOption copyWith({
    int? parentMapiahID,
    String? optionType,
    THDatetimePart? datetime,
    String? copyrightMessage,
  }) {
    return THCopyrightCommandOption(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      optionType: optionType ?? this.optionType,
      datetime: datetime ?? this.datetime,
      copyrightMessage: copyrightMessage ?? this.copyrightMessage,
    );
  }

  @override
  String specToFile() {
    return '$datetime ${textToFile()}';
  }

  String get copyrightMessage => text;
}
