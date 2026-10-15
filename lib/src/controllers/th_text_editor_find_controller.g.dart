// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_text_editor_find_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THTextEditorFindController on THTextEditorFindControllerBase, Store {
  Computed<List<TextRange>>? _$findMatchesComputed;

  @override
  List<TextRange> get findMatches =>
      (_$findMatchesComputed ??= Computed<List<TextRange>>(
        () => super.findMatches,
        name: 'THTextEditorFindControllerBase.findMatches',
      )).value;

  late final _$findQueryAtom = Atom(
    name: 'THTextEditorFindControllerBase.findQuery',
    context: context,
  );

  @override
  String get findQuery {
    _$findQueryAtom.reportRead();
    return super.findQuery;
  }

  @override
  set findQuery(String value) {
    _$findQueryAtom.reportWrite(value, super.findQuery, () {
      super.findQuery = value;
    });
  }

  late final _$replaceQueryAtom = Atom(
    name: 'THTextEditorFindControllerBase.replaceQuery',
    context: context,
  );

  @override
  String get replaceQuery {
    _$replaceQueryAtom.reportRead();
    return super.replaceQuery;
  }

  @override
  set replaceQuery(String value) {
    _$replaceQueryAtom.reportWrite(value, super.replaceQuery, () {
      super.replaceQuery = value;
    });
  }

  late final _$findCaseSensitiveAtom = Atom(
    name: 'THTextEditorFindControllerBase.findCaseSensitive',
    context: context,
  );

  @override
  bool get findCaseSensitive {
    _$findCaseSensitiveAtom.reportRead();
    return super.findCaseSensitive;
  }

  @override
  set findCaseSensitive(bool value) {
    _$findCaseSensitiveAtom.reportWrite(value, super.findCaseSensitive, () {
      super.findCaseSensitive = value;
    });
  }

  late final _$isFindBarVisibleAtom = Atom(
    name: 'THTextEditorFindControllerBase.isFindBarVisible',
    context: context,
  );

  @override
  bool get isFindBarVisible {
    _$isFindBarVisibleAtom.reportRead();
    return super.isFindBarVisible;
  }

  @override
  set isFindBarVisible(bool value) {
    _$isFindBarVisibleAtom.reportWrite(value, super.isFindBarVisible, () {
      super.isFindBarVisible = value;
    });
  }

  late final _$activeMatchIndexAtom = Atom(
    name: 'THTextEditorFindControllerBase.activeMatchIndex',
    context: context,
  );

  @override
  int? get activeMatchIndex {
    _$activeMatchIndexAtom.reportRead();
    return super.activeMatchIndex;
  }

  @override
  set activeMatchIndex(int? value) {
    _$activeMatchIndexAtom.reportWrite(value, super.activeMatchIndex, () {
      super.activeMatchIndex = value;
    });
  }

  late final _$THTextEditorFindControllerBaseActionController =
      ActionController(
        name: 'THTextEditorFindControllerBase',
        context: context,
      );

  @override
  void openFindBar() {
    final _$actionInfo = _$THTextEditorFindControllerBaseActionController
        .startAction(name: 'THTextEditorFindControllerBase.openFindBar');
    try {
      return super.openFindBar();
    } finally {
      _$THTextEditorFindControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void closeFindBar() {
    final _$actionInfo = _$THTextEditorFindControllerBaseActionController
        .startAction(name: 'THTextEditorFindControllerBase.closeFindBar');
    try {
      return super.closeFindBar();
    } finally {
      _$THTextEditorFindControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFindQuery(String query) {
    final _$actionInfo = _$THTextEditorFindControllerBaseActionController
        .startAction(name: 'THTextEditorFindControllerBase.setFindQuery');
    try {
      return super.setFindQuery(query);
    } finally {
      _$THTextEditorFindControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReplaceQuery(String query) {
    final _$actionInfo = _$THTextEditorFindControllerBaseActionController
        .startAction(name: 'THTextEditorFindControllerBase.setReplaceQuery');
    try {
      return super.setReplaceQuery(query);
    } finally {
      _$THTextEditorFindControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFindCaseSensitive(bool value) {
    final _$actionInfo = _$THTextEditorFindControllerBaseActionController
        .startAction(
          name: 'THTextEditorFindControllerBase.setFindCaseSensitive',
        );
    try {
      return super.setFindCaseSensitive(value);
    } finally {
      _$THTextEditorFindControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void findNext() {
    final _$actionInfo = _$THTextEditorFindControllerBaseActionController
        .startAction(name: 'THTextEditorFindControllerBase.findNext');
    try {
      return super.findNext();
    } finally {
      _$THTextEditorFindControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void findPrevious() {
    final _$actionInfo = _$THTextEditorFindControllerBaseActionController
        .startAction(name: 'THTextEditorFindControllerBase.findPrevious');
    try {
      return super.findPrevious();
    } finally {
      _$THTextEditorFindControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void replaceActiveMatch() {
    final _$actionInfo = _$THTextEditorFindControllerBaseActionController
        .startAction(name: 'THTextEditorFindControllerBase.replaceActiveMatch');
    try {
      return super.replaceActiveMatch();
    } finally {
      _$THTextEditorFindControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void replaceAllMatches() {
    final _$actionInfo = _$THTextEditorFindControllerBaseActionController
        .startAction(name: 'THTextEditorFindControllerBase.replaceAllMatches');
    try {
      return super.replaceAllMatches();
    } finally {
      _$THTextEditorFindControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$THTextEditorFindControllerBaseActionController
        .startAction(name: 'THTextEditorFindControllerBase.reset');
    try {
      return super.reset();
    } finally {
      _$THTextEditorFindControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clampActiveMatchIndex() {
    final _$actionInfo = _$THTextEditorFindControllerBaseActionController
        .startAction(
          name: 'THTextEditorFindControllerBase.clampActiveMatchIndex',
        );
    try {
      return super.clampActiveMatchIndex();
    } finally {
      _$THTextEditorFindControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
findQuery: ${findQuery},
replaceQuery: ${replaceQuery},
findCaseSensitive: ${findCaseSensitive},
isFindBarVisible: ${isFindBarVisible},
activeMatchIndex: ${activeMatchIndex},
findMatches: ${findMatches}
    ''';
  }
}
