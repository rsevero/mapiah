class THFileAux {
  static int countCharOccurrences(String text, String charToCount) {
    int count = 0;
    for (int i = 0; i < text.length; i++) {
      if (text[i] == charToCount) {
        count++;
      }
    }
    return count;
  }

  /// Returns the reason why the line continues:
  /// * " for double quotes;
  /// * ] for square brackets;
  /// * \ for backslash.
  ///
  /// Returns an empty string if the line does not continue.
  static String lineContinues(String text) {
    String continuationDelimiter = '';

    for (int i = 0; i < text.length; i++) {
      final String currentChar = text[i];

      if (continuationDelimiter.isEmpty) {
        if (currentChar == '"') {
          continuationDelimiter = '"';
        } else if (currentChar == '[') {
          continuationDelimiter = ']';
        } else if (currentChar == '\\') {
          if (i == text.trimRight().length - 1) {
            continuationDelimiter = '\\';

            break;
          }
        }
      } else {
        if (continuationDelimiter == '"') {
          if (currentChar == '"') {
            if ((i + 1 < text.length) && (text[i + 1] == '"')) {
              i++;
            } else {
              continuationDelimiter = '';
            }
          }
        } else if (continuationDelimiter == ']') {
          if (currentChar == ']') {
            continuationDelimiter = '';
          }
        }
      }
    }

    return continuationDelimiter;
  }
}
