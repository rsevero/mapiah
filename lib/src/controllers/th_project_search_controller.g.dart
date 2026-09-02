// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_project_search_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THProjectSearchController on THProjectSearchControllerBase, Store {
  late final _$queryAtom = Atom(
    name: 'THProjectSearchControllerBase.query',
    context: context,
  );

  @override
  String get query {
    _$queryAtom.reportRead();
    return super.query;
  }

  @override
  set query(String value) {
    _$queryAtom.reportWrite(value, super.query, () {
      super.query = value;
    });
  }

  late final _$replacementAtom = Atom(
    name: 'THProjectSearchControllerBase.replacement',
    context: context,
  );

  @override
  String get replacement {
    _$replacementAtom.reportRead();
    return super.replacement;
  }

  @override
  set replacement(String value) {
    _$replacementAtom.reportWrite(value, super.replacement, () {
      super.replacement = value;
    });
  }

  late final _$caseSensitiveAtom = Atom(
    name: 'THProjectSearchControllerBase.caseSensitive',
    context: context,
  );

  @override
  bool get caseSensitive {
    _$caseSensitiveAtom.reportRead();
    return super.caseSensitive;
  }

  @override
  set caseSensitive(bool value) {
    _$caseSensitiveAtom.reportWrite(value, super.caseSensitive, () {
      super.caseSensitive = value;
    });
  }

  late final _$scopeAtom = Atom(
    name: 'THProjectSearchControllerBase.scope',
    context: context,
  );

  @override
  THProjectSearchScope get scope {
    _$scopeAtom.reportRead();
    return super.scope;
  }

  @override
  set scope(THProjectSearchScope value) {
    _$scopeAtom.reportWrite(value, super.scope, () {
      super.scope = value;
    });
  }

  late final _$isSearchingAtom = Atom(
    name: 'THProjectSearchControllerBase.isSearching',
    context: context,
  );

  @override
  bool get isSearching {
    _$isSearchingAtom.reportRead();
    return super.isSearching;
  }

  @override
  set isSearching(bool value) {
    _$isSearchingAtom.reportWrite(value, super.isSearching, () {
      super.isSearching = value;
    });
  }

  late final _$isReplacingAtom = Atom(
    name: 'THProjectSearchControllerBase.isReplacing',
    context: context,
  );

  @override
  bool get isReplacing {
    _$isReplacingAtom.reportRead();
    return super.isReplacing;
  }

  @override
  set isReplacing(bool value) {
    _$isReplacingAtom.reportWrite(value, super.isReplacing, () {
      super.isReplacing = value;
    });
  }

  late final _$resultsAtom = Atom(
    name: 'THProjectSearchControllerBase.results',
    context: context,
  );

  @override
  ObservableList<THProjectSearchFileResult> get results {
    _$resultsAtom.reportRead();
    return super.results;
  }

  @override
  set results(ObservableList<THProjectSearchFileResult> value) {
    _$resultsAtom.reportWrite(value, super.results, () {
      super.results = value;
    });
  }

  late final _$failuresAtom = Atom(
    name: 'THProjectSearchControllerBase.failures',
    context: context,
  );

  @override
  ObservableList<THProjectSearchFailure> get failures {
    _$failuresAtom.reportRead();
    return super.failures;
  }

  @override
  set failures(ObservableList<THProjectSearchFailure> value) {
    _$failuresAtom.reportWrite(value, super.failures, () {
      super.failures = value;
    });
  }

  late final _$expandedResultPathsAtom = Atom(
    name: 'THProjectSearchControllerBase.expandedResultPaths',
    context: context,
  );

  @override
  ObservableSet<String> get expandedResultPaths {
    _$expandedResultPathsAtom.reportRead();
    return super.expandedResultPaths;
  }

  @override
  set expandedResultPaths(ObservableSet<String> value) {
    _$expandedResultPathsAtom.reportWrite(value, super.expandedResultPaths, () {
      super.expandedResultPaths = value;
    });
  }

  late final _$submitQueryAsyncAction = AsyncAction(
    'THProjectSearchControllerBase.submitQuery',
    context: context,
  );

  @override
  Future<void> submitQuery() {
    return _$submitQueryAsyncAction.run(() => super.submitQuery());
  }

  late final _$runSearchAsyncAction = AsyncAction(
    'THProjectSearchControllerBase.runSearch',
    context: context,
  );

  @override
  Future<void> runSearch() {
    return _$runSearchAsyncAction.run(() => super.runSearch());
  }

  late final _$prepareReplaceAllAsyncAction = AsyncAction(
    'THProjectSearchControllerBase.prepareReplaceAll',
    context: context,
  );

  @override
  Future<THProjectSearchReplacePreflight?> prepareReplaceAll() {
    return _$prepareReplaceAllAsyncAction.run(() => super.prepareReplaceAll());
  }

  late final _$executeReplaceAllAsyncAction = AsyncAction(
    'THProjectSearchControllerBase.executeReplaceAll',
    context: context,
  );

  @override
  Future<THProjectSearchReplaceReport> executeReplaceAll(
    THProjectSearchReplacePreflight preflight,
  ) {
    return _$executeReplaceAllAsyncAction.run(
      () => super.executeReplaceAll(preflight),
    );
  }

  late final _$THProjectSearchControllerBaseActionController = ActionController(
    name: 'THProjectSearchControllerBase',
    context: context,
  );

  @override
  void setQuery(String value) {
    final _$actionInfo = _$THProjectSearchControllerBaseActionController
        .startAction(name: 'THProjectSearchControllerBase.setQuery');
    try {
      return super.setQuery(value);
    } finally {
      _$THProjectSearchControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReplacement(String value) {
    final _$actionInfo = _$THProjectSearchControllerBaseActionController
        .startAction(name: 'THProjectSearchControllerBase.setReplacement');
    try {
      return super.setReplacement(value);
    } finally {
      _$THProjectSearchControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCaseSensitive(bool value) {
    final _$actionInfo = _$THProjectSearchControllerBaseActionController
        .startAction(name: 'THProjectSearchControllerBase.setCaseSensitive');
    try {
      return super.setCaseSensitive(value);
    } finally {
      _$THProjectSearchControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setScope(THProjectSearchScope value) {
    final _$actionInfo = _$THProjectSearchControllerBaseActionController
        .startAction(name: 'THProjectSearchControllerBase.setScope');
    try {
      return super.setScope(value);
    } finally {
      _$THProjectSearchControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleExpanded(String canonicalPath) {
    final _$actionInfo = _$THProjectSearchControllerBaseActionController
        .startAction(name: 'THProjectSearchControllerBase.toggleExpanded');
    try {
      return super.toggleExpanded(canonicalPath);
    } finally {
      _$THProjectSearchControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearForProjectChange() {
    final _$actionInfo = _$THProjectSearchControllerBaseActionController
        .startAction(
          name: 'THProjectSearchControllerBase.clearForProjectChange',
        );
    try {
      return super.clearForProjectChange();
    } finally {
      _$THProjectSearchControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
query: ${query},
replacement: ${replacement},
caseSensitive: ${caseSensitive},
scope: ${scope},
isSearching: ${isSearching},
isReplacing: ${isReplacing},
results: ${results},
failures: ${failures},
expandedResultPaths: ${expandedResultPaths}
    ''';
  }
}
