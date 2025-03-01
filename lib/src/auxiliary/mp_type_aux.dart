class MPTypeAux {
  static final RegExp _camelCasePattern = RegExp(r'[A-Z]');
  static final RegExp _hyphenatedPattern = RegExp(r'-([a-z])');

  static String convertCamelCaseToHyphenated(String input) {
    return input.replaceAllMapped(
      _camelCasePattern,
      (Match match) => '-${match.group(0)!.toLowerCase()}',
    );
  }

  static String convertHyphenatedToCamelCase(String input) {
    return input.replaceAllMapped(
      _hyphenatedPattern,
      (Match match) => match.group(1)!.toUpperCase(),
    );
  }
}
