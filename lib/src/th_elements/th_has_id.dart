mixin THHasTHID {
  abstract String _thID;

  String get thID {
    return _thID;
  }

  set thID(String aTHID) {
    _thID = aTHID;
  }
}
