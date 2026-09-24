// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';

import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Right-click context menu shared by the project tree rows.
///
/// The menu contents are computed on each right-click by
/// [menuChildrenBuilder]; an empty result opens no menu. The menu opens after
/// the next frame, at the pointer, only if this is still the latest request
/// for the same row and the builder still returns items.
class THProjectTreeRowContextMenuWidget extends StatefulWidget {
  final String rowId;

  final Widget child;

  final List<Widget> Function() menuChildrenBuilder;

  const THProjectTreeRowContextMenuWidget({
    super.key,
    required this.rowId,
    required this.child,
    required this.menuChildrenBuilder,
  });

  /// The Reload items for the `.th2` file at [th2FilePath] when it is broken
  /// or failed to load, otherwise none.
  static List<Widget> reloadMenuChildrenIfBrokenOrFailed({
    required String rowId,
    required String th2FilePath,
    required AppLocalizations appLocalizations,
  }) {
    final TH2FileEditController? controller = mpLocator.mpGeneralController
        .getTH2FileEditControllerIfExists(th2FilePath);
    final bool isBrokenOrFailed =
        (controller != null) &&
        (controller.isBroken || (controller.loadError != null));

    if (!isBrokenOrFailed) {
      return const <Widget>[];
    }

    return <Widget>[
      reloadMenuItem(
        rowId: rowId,
        th2FilePath: th2FilePath,
        appLocalizations: appLocalizations,
      ),
    ];
  }

  /// The Reload entry, which replaces the file's controller with a fresh
  /// load from disk. It never opens or activates a tab.
  static Widget reloadMenuItem({
    required String rowId,
    required String th2FilePath,
    required AppLocalizations appLocalizations,
  }) {
    return MenuItemButton(
      key: ValueKey('THProjectTreeRowContextMenuReload|$rowId'),
      leadingIcon: const Icon(Icons.refresh),
      onPressed: () => unawaited(_reloadTH2File(th2FilePath)),
      child: Text(appLocalizations.th2ElementTreeReload),
    );
  }

  /// Reloads [th2FilePath]; a failure is logged and shown by the new
  /// controller's load-error row.
  static Future<void> _reloadTH2File(String th2FilePath) async {
    try {
      await mpLocator.mpGeneralController.reloadTH2File(th2FilePath);
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        'Reload of $th2FilePath from the project tree failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  State<THProjectTreeRowContextMenuWidget> createState() =>
      _THProjectTreeRowContextMenuWidgetState();
}

class _THProjectTreeRowContextMenuWidgetState
    extends State<THProjectTreeRowContextMenuWidget> {
  final MenuController _menuController = MenuController();

  List<Widget> _menuChildren = const <Widget>[];

  int _requestGeneration = 0;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      menuChildren: _menuChildren,
      child: GestureDetector(
        onSecondaryTapUp: _onSecondaryTapUp,
        child: widget.child,
      ),
    );
  }

  /// Stores the current items and opens the menu after they are built.
  void _onSecondaryTapUp(TapUpDetails details) {
    final List<Widget> menuChildren = widget.menuChildrenBuilder();

    if (menuChildren.isEmpty) {
      return;
    }

    if (_menuController.isOpen) {
      _menuController.close();
    }

    final int generation = ++_requestGeneration;
    final String rowId = widget.rowId;
    final Offset position = details.localPosition;

    setState(() {
      _menuChildren = menuChildren;
    });
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _openIfStillCurrent(
        generation: generation,
        rowId: rowId,
        position: position,
      );
    });
  }

  /// Opens the menu unless the request became stale or the row has nothing
  /// to offer anymore.
  void _openIfStillCurrent({
    required int generation,
    required String rowId,
    required Offset position,
  }) {
    final bool isCurrentRequest =
        mounted &&
        (generation == _requestGeneration) &&
        (rowId == widget.rowId);

    if (!isCurrentRequest || widget.menuChildrenBuilder().isEmpty) {
      return;
    }

    _menuController.open(position: position);
  }
}
