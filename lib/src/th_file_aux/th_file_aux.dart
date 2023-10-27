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
}
