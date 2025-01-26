part of 'th_command_option.dart';

// station-names <prefix> <suffix> . adds given prefix/suffix to all survey stations
// in the current scrap. Saves some typing.
class THStationNamesCommandOption extends THCommandOption {
  late final String prefix;
  late final String suffix;

  THStationNamesCommandOption.forCWJM({
    required super.parentMapiahID,
    required this.prefix,
    required this.suffix,
  }) : super.forCWJM();

  THStationNamesCommandOption({
    required super.optionParent,
    required this.prefix,
    required this.suffix,
  }) : super();

  @override
  THCommandOptionType get optionType => THCommandOptionType.stationNames;

  @override
  String typeToFile() => 'station-names';

  @override
  Map<String, dynamic> toMap() {
    return {
      'optionType': optionType.name,
      'parentMapiahID': parentMapiahID,
      'prefix': prefix,
      'suffix': suffix,
    };
  }

  factory THStationNamesCommandOption.fromMap(Map<String, dynamic> map) {
    return THStationNamesCommandOption.forCWJM(
      parentMapiahID: map['parentMapiahID'],
      prefix: map['prefix'],
      suffix: map['suffix'],
    );
  }

  factory THStationNamesCommandOption.fromJson(String jsonString) {
    return THStationNamesCommandOption.fromMap(jsonDecode(jsonString));
  }

  @override
  THStationNamesCommandOption copyWith({
    int? parentMapiahID,
    String? prefix,
    String? suffix,
  }) {
    return THStationNamesCommandOption.forCWJM(
      parentMapiahID: parentMapiahID ?? this.parentMapiahID,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
    );
  }

  @override
  bool operator ==(covariant THStationNamesCommandOption other) {
    if (identical(this, other)) return true;

    return other.parentMapiahID == parentMapiahID &&
        other.prefix == prefix &&
        other.suffix == suffix;
  }

  @override
  int get hashCode => Object.hash(
        parentMapiahID,
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
