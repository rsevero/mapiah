part of 'th_command_option.dart';

/// area:
/// clip <on/off> . specify whether a symbol is clipped by the scrap border.
/// Default is on.
///
/// line:
/// clip <on/off> . specify whether a symbol is clipped by the scrap border.
/// Default is on.
///
/// point:
/// clip <on/off> . specify whether a symbol is clipped by the scrap border. You
/// cannot specify this option for the following symbols: station, station-name,
/// label, remark, date, altitude, height, passage-height. Default is on.
class THClipCommandOption extends THOnOffCommandOption {
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

  THClipCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required super.choice,
  }) : super.forCWJM();

  THClipCommandOption({
    required super.parentMPID,
    required super.choice,
    super.originalLineInTH2File = '',
  }) : super();

  THClipCommandOption.fromString({
    required super.parentMPID,
    required String choice,
    super.originalLineInTH2File = '',
  }) : super(choice: THOptionChoicesOnOffType.values.byName(choice));

  @override
  THCommandOptionType get type => THCommandOptionType.clip;

  factory THClipCommandOption.fromMap(Map<String, dynamic> map) {
    return THClipCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      choice: THOptionChoicesOnOffType.values.byName(map['choice']),
    );
  }

  factory THClipCommandOption.fromJson(String jsonString) {
    return THClipCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THClipCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    THOptionChoicesOnOffType? choice,
  }) {
    return THClipCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      choice: choice ?? this.choice,
    );
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! THClipCommandOption) return false;

    return super.equalsBase(other);
  }
}
