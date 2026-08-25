// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_project_tree_ui_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THProjectTreeUIController on THProjectTreeUIControllerBase, Store {
  late final _$expandedNodeIdsAtom = Atom(
    name: 'THProjectTreeUIControllerBase.expandedNodeIds',
    context: context,
  );

  @override
  ObservableSet<String> get expandedNodeIds {
    _$expandedNodeIdsAtom.reportRead();
    return super.expandedNodeIds;
  }

  @override
  set expandedNodeIds(ObservableSet<String> value) {
    _$expandedNodeIdsAtom.reportWrite(value, super.expandedNodeIds, () {
      super.expandedNodeIds = value;
    });
  }

  late final _$filterTextAtom = Atom(
    name: 'THProjectTreeUIControllerBase.filterText',
    context: context,
  );

  @override
  String get filterText {
    _$filterTextAtom.reportRead();
    return super.filterText;
  }

  @override
  set filterText(String value) {
    _$filterTextAtom.reportWrite(value, super.filterText, () {
      super.filterText = value;
    });
  }

  late final _$isSidebarCollapsedAtom = Atom(
    name: 'THProjectTreeUIControllerBase.isSidebarCollapsed',
    context: context,
  );

  @override
  bool get isSidebarCollapsed {
    _$isSidebarCollapsedAtom.reportRead();
    return super.isSidebarCollapsed;
  }

  @override
  set isSidebarCollapsed(bool value) {
    _$isSidebarCollapsedAtom.reportWrite(value, super.isSidebarCollapsed, () {
      super.isSidebarCollapsed = value;
    });
  }

  late final _$sidebarWidthAtom = Atom(
    name: 'THProjectTreeUIControllerBase.sidebarWidth',
    context: context,
  );

  @override
  double get sidebarWidth {
    _$sidebarWidthAtom.reportRead();
    return super.sidebarWidth;
  }

  @override
  set sidebarWidth(double value) {
    _$sidebarWidthAtom.reportWrite(value, super.sidebarWidth, () {
      super.sidebarWidth = value;
    });
  }

  late final _$THProjectTreeUIControllerBaseActionController = ActionController(
    name: 'THProjectTreeUIControllerBase',
    context: context,
  );

  @override
  void toggleExpanded(String nodeId) {
    final _$actionInfo = _$THProjectTreeUIControllerBaseActionController
        .startAction(name: 'THProjectTreeUIControllerBase.toggleExpanded');
    try {
      return super.toggleExpanded(nodeId);
    } finally {
      _$THProjectTreeUIControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void expand(String nodeId) {
    final _$actionInfo = _$THProjectTreeUIControllerBaseActionController
        .startAction(name: 'THProjectTreeUIControllerBase.expand');
    try {
      return super.expand(nodeId);
    } finally {
      _$THProjectTreeUIControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void collapse(String nodeId) {
    final _$actionInfo = _$THProjectTreeUIControllerBaseActionController
        .startAction(name: 'THProjectTreeUIControllerBase.collapse');
    try {
      return super.collapse(nodeId);
    } finally {
      _$THProjectTreeUIControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void expandAncestorsOf(THProjectNode node) {
    final _$actionInfo = _$THProjectTreeUIControllerBaseActionController
        .startAction(name: 'THProjectTreeUIControllerBase.expandAncestorsOf');
    try {
      return super.expandAncestorsOf(node);
    } finally {
      _$THProjectTreeUIControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFilterText(String text) {
    final _$actionInfo = _$THProjectTreeUIControllerBaseActionController
        .startAction(name: 'THProjectTreeUIControllerBase.setFilterText');
    try {
      return super.setFilterText(text);
    } finally {
      _$THProjectTreeUIControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSidebarCollapsed(bool collapsed) {
    final _$actionInfo = _$THProjectTreeUIControllerBaseActionController
        .startAction(name: 'THProjectTreeUIControllerBase.setSidebarCollapsed');
    try {
      return super.setSidebarCollapsed(collapsed);
    } finally {
      _$THProjectTreeUIControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSidebarWidth(double width) {
    final _$actionInfo = _$THProjectTreeUIControllerBaseActionController
        .startAction(name: 'THProjectTreeUIControllerBase.setSidebarWidth');
    try {
      return super.setSidebarWidth(width);
    } finally {
      _$THProjectTreeUIControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _handleProjectRootChanged(THProjectFileNode? root) {
    final _$actionInfo = _$THProjectTreeUIControllerBaseActionController
        .startAction(
          name: 'THProjectTreeUIControllerBase._handleProjectRootChanged',
        );
    try {
      return super._handleProjectRootChanged(root);
    } finally {
      _$THProjectTreeUIControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
expandedNodeIds: ${expandedNodeIds},
filterText: ${filterText},
isSidebarCollapsed: ${isSidebarCollapsed},
sidebarWidth: ${sidebarWidth}
    ''';
  }
}
