class MPTextAux {
  static String convertCamelCaseToHyphenated(String input) {
    return input.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (Match match) => '-${match.group(0)!.toLowerCase()}',
    );
  }

  static String convertHyphenatedToCamelCase(String input) {
    return input.replaceAllMapped(
      RegExp(r'-([a-z])'),
      (Match match) => match.group(1)!.toUpperCase(),
    );
  }
}
