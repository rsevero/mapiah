part of 'th_command_option.dart';

// station-names <prefix> <suffix> . adds given prefix/suffix to all survey
// stations in the current scrap. Saves some typing.
class THStationNamesCommandOption extends THCommandOption {
  late final String prefix;
  late final String suffix;

  THStationNamesCommandOption.forCWJM({
    required super.parentMPID,
    required super.originalLineInTH2File,
    required this.prefix,
    required this.suffix,
  }) : super.forCWJM();

  THStationNamesCommandOption({
    required super.optionParent,
    required this.prefix,
    required this.suffix,
    super.originalLineInTH2File = '',
  }) : super();

  @override
  THCommandOptionType get type => THCommandOptionType.stationNames;

  @override
  String typeToFile() => 'station-names';

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = super.toMap();

    map.addAll({
      'prefix': prefix,
      'suffix': suffix,
    });

    return map;
  }

  factory THStationNamesCommandOption.fromMap(Map<String, dynamic> map) {
    return THStationNamesCommandOption.forCWJM(
      parentMPID: map['parentMPID'],
      originalLineInTH2File: map['originalLineInTH2File'],
      prefix: map['prefix'],
      suffix: map['suffix'],
    );
  }

  factory THStationNamesCommandOption.fromJson(String jsonString) {
    return THStationNamesCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THStationNamesCommandOption copyWith({
    int? parentMPID,
    String? originalLineInTH2File,
    String? prefix,
    String? suffix,
  }) {
    return THStationNamesCommandOption.forCWJM(
      parentMPID: parentMPID ?? this.parentMPID,
      originalLineInTH2File:
          originalLineInTH2File ?? this.originalLineInTH2File,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
    );
  }

  @override
  bool operator ==(covariant THStationNamesCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMPID == parentMPID &&
        other.originalLineInTH2File == originalLineInTH2File &&
        other.prefix == prefix &&
        other.suffix == suffix;
  }

  @override
  int get hashCode =>
      super.hashCode ^
      Object.hash(
        prefix,
        suffix,
      );

  // set preffix(String preffix) {
  //   if (preffix.contains(' ')) {
  //     throw THCustomException(
  //         "Preffix can't contain spaces in THStationNamesCommandOption: '$preffix'");
  //   }

  //   _prefix = preffix;
  // }

  // set suffix(String suffix) {
  //   if (suffix.contains(' ')) {
  //     throw THCustomException(
  //         "Suffix can't contain spaces in THStationNamesCommandOption: '$suffix'");
  //   }

  //   _suffix = suffix;
  // }

  @override
  String specToFile() {
    return '$prefix $suffix';
  }
}
