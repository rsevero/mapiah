// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/gestures.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th_project_tree_visible_row.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/th_project_tree_row_context_menu_widget.dart';
import 'package:material_ui/material_ui.dart';

/// Detects a second tap on the same TH2 element row, so a single tap acts
/// at once and a double tap only adds its extra steps.
class TH2ElementTreeTapTracker {
  /// Clock used to time taps. Tests may replace it.
  DateTime Function() now = DateTime.now;

  String? _rowId;

  DateTime? _time;

  Offset? _position;

  /// Records a tap on [rowId] at [position] and returns whether it completes
  /// a double tap. A completed double tap resets the tracker.
  bool registerTap({required String rowId, required Offset position}) {
    final DateTime tapTime = now();
    final DateTime? previousTime = _time;
    final Offset? previousPosition = _position;
    final bool isSecondTap =
        (_rowId == rowId) &&
        (previousTime != null) &&
        (previousPosition != null) &&
        (tapTime.difference(previousTime) < kDoubleTapTimeout) &&
        ((position - previousPosition).distance <= kDoubleTapSlop);

    if (isSecondTap) {
      reset();
    } else {
      _rowId = rowId;
      _time = tapTime;
      _position = position;
    }

    return isSecondTap;
  }

  void reset() {
    _rowId = null;
    _time = null;
    _position = null;
  }
}

/// The tap tracker shared by every TH2 element row of the project tree.
final TH2ElementTreeTapTracker th2ElementTreeTapTracker =
    TH2ElementTreeTapTracker();

/// A project-tree row for a TH2 scrap, point, line or area, or for the
/// loading, load-error or broken status of a `.th2` file.
class TH2ElementTreeRowWidget extends StatelessWidget {
  final THProjectTreeVisibleRow row;

  const TH2ElementTreeRowWidget({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    final THProjectTreeVisibleRow currentRow = row;

    return switch (currentRow) {
      TH2ElementTreeRow elementRow => _TH2ElementRow(row: elementRow),
      TH2FileStatusTreeRow statusRow => _TH2FileStatusRow(row: statusRow),
      THProjectTreeNodeRow _ => throw ArgumentError(
        'TH2ElementTreeRowWidget does not render project node rows.',
      ),
    };
  }
}

/// Resolves the registered controller of a loaded valid file, or `null`.
TH2FileEditController? _validControllerFor(String th2FilePath) {
  final TH2FileEditController? controller = mpLocator.mpGeneralController
      .getTH2FileEditControllerIfExists(th2FilePath);

  if ((controller == null) ||
      !controller.isFileLoaded ||
      controller.isBroken ||
      (controller.loadError != null)) {
    return null;
  }

  return controller;
}

class _TH2ElementRow extends StatelessWidget {
  final TH2ElementTreeRow row;

  const _TH2ElementRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Widget shell = SizedBox(
      height: mpProjectTreeRowHeight,
      child: Row(
        children: <Widget>[
          SizedBox(width: row.depth * mpProjectTreeIndent),
          _buildExpandControl(colorScheme),
          ExcludeSemantics(child: _buildIcon()),
          const SizedBox(width: 4),
          Expanded(child: _buildLabel(colorScheme)),
          if (row.isScrap && !row.isExpanded)
            _buildContainsSelectionDot(context),
          const SizedBox(width: 4),
        ],
      ),
    );
    Offset tapPosition = Offset.zero;

    return Observer(
      builder: (_) {
        final bool isHighlighted = _isHighlighted();

        return Material(
          key: ValueKey('TH2ElementTreeRowWidget|${row.rowId}'),
          color: isHighlighted
              ? colorScheme.secondaryContainer
              : Colors.transparent,
          child: InkWell(
            onTapDown: (TapDownDetails details) {
              tapPosition = details.globalPosition;
            },
            onTap: () => _onTap(tapPosition),
            child: shell,
          ),
        );
      },
    );
  }

  /// Selected element rows and the active scrap row are highlighted.
  bool _isHighlighted() {
    final TH2FileEditController? controller = _validControllerFor(
      row.th2FilePath,
    );

    if (controller == null) {
      return false;
    }

    if (row.isScrap) {
      return controller.activeScrapID == row.elementMPID;
    }

    return controller.selectionController.mpSelectedElementsLogical
        .containsKey(row.elementMPID);
  }

  Widget _buildExpandControl(ColorScheme colorScheme) {
    if (!row.isExpandable) {
      return const SizedBox(width: mpSmallIconSize);
    }

    return GestureDetector(
      key: ValueKey('TH2ElementTreeScrapChevron|${row.rowId}'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        mpLocator.thProjectTreeUIController.toggleTH2ScrapCollapsed(row.rowId);
      },
      child: SizedBox(
        width: mpSmallIconSize,
        height: mpProjectTreeRowHeight,
        child: Icon(
          row.isExpanded ? Icons.expand_more : Icons.chevron_right,
          size: mpSmallIconSize,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final String? imagePath = switch (row.elementType) {
      THElementType.point => mpAddPointButtonImagePath,
      THElementType.line => mpAddLineButtonImagePath,
      THElementType.area => mpAddAreaButtonImagePath,
      _ => null,
    };

    if (imagePath == null) {
      return const Icon(Icons.map_outlined, size: mpSmallIconSize);
    }

    return Image.asset(
      imagePath,
      width: mpSmallIconSize,
      height: mpSmallIconSize,
    );
  }

  Widget _buildLabel(ColorScheme colorScheme) {
    final String? thID = row.label.thID;
    final bool hasTHID = (thID != null) && thID.isNotEmpty;
    final bool hasPrimaryText = row.label.primaryText.isNotEmpty;

    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(text: row.label.primaryText),
          if (hasTHID)
            TextSpan(
              text: hasPrimaryText ? ' $thID' : thID,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      semanticsLabel: row.label.plainText,
    );
  }

  /// The dot a collapsed scrap shows while one of its children is selected.
  Widget _buildContainsSelectionDot(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String message = AppLocalizations.of(
      context,
    ).th2ElementTreeScrapContainsSelection;

    return Observer(
      builder: (_) {
        if (!_scrapContainsSelection()) {
          return const SizedBox.shrink();
        }

        return Tooltip(
          key: ValueKey('TH2ElementTreeScrapContainsSelectionDot|${row.rowId}'),
          message: message,
          child: Semantics(
            label: message,
            child: Container(
              width: mpProjectTreeStatusDotSize,
              height: mpProjectTreeStatusDotSize,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Whether any selected element of the file is a child of this scrap.
  bool _scrapContainsSelection() {
    final TH2FileEditController? controller = _validControllerFor(
      row.th2FilePath,
    );

    if (controller == null) {
      return false;
    }

    for (final int selectedMPID
        in controller.selectionController.mpSelectedElementsLogical.keys) {
      final THElement? element = controller.th2File.tryElementByMPID(
        selectedMPID,
      );

      if ((element != null) && (element.parentMPID == row.elementMPID)) {
        return true;
      }
    }

    return false;
  }

  void _onTap(Offset tapPosition) {
    if (row.isScrap) {
      _onScrapTap();

      return;
    }

    final bool isSecondTap = th2ElementTreeTapTracker.registerTap(
      rowId: row.rowId,
      position: tapPosition,
    );
    final TH2FileEditController? controller = _validControllerFor(
      row.th2FilePath,
    );

    if (controller == null) {
      return;
    }

    final THElement? element = controller.th2File.tryElementByMPID(
      row.elementMPID,
    );

    if (element == null) {
      return;
    }

    if (isSecondTap) {
      _applyDoubleTapExtras(controller);
    } else {
      _applySingleTap(controller: controller, element: element);
    }
  }

  /// Does what the Select tool plus a click on the element does, and brings
  /// an open file's tab to the front. A tab-less file stays tab-less.
  void _applySingleTap({
    required TH2FileEditController controller,
    required THElement element,
  }) {
    final MPGeneralController generalController =
        mpLocator.mpGeneralController;

    controller.stateController.onButtonPressed(MPButtonType.select);
    controller.setActiveScrapByChildElement(element);
    controller.selectionController.setSelectedElements(<THElement>[
      element,
    ], setState: true);

    if (generalController.openFileOrder.contains(row.th2FilePath)) {
      generalController.addFileTab(row.th2FilePath);
    }
  }

  /// Opens a tab-less file's tab and zooms to the selection.
  void _applyDoubleTapExtras(TH2FileEditController controller) {
    final MPGeneralController generalController =
        mpLocator.mpGeneralController;

    if (!generalController.openFileOrder.contains(row.th2FilePath)) {
      generalController.addFileTab(row.th2FilePath);
    }

    controller.requestZoomToFit(MPZoomToFitType.selection);
  }

  /// Makes the scrap active; an open file's tab is brought to the front.
  void _onScrapTap() {
    final TH2FileEditController? controller = _validControllerFor(
      row.th2FilePath,
    );

    if (controller == null) {
      return;
    }

    controller.setActiveScrap(row.elementMPID);

    final MPGeneralController generalController =
        mpLocator.mpGeneralController;

    if (generalController.openFileOrder.contains(row.th2FilePath)) {
      generalController.addFileTab(row.th2FilePath);
    }
  }
}

class _TH2FileStatusRow extends StatelessWidget {
  final TH2FileStatusTreeRow row;

  const _TH2FileStatusRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final bool offersReload = row.kind != TH2FileStatusTreeRowKind.loading;
    final Widget content = Material(
      key: ValueKey('TH2FileStatusTreeRow|${row.rowId}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: offersReload ? _openTab : null,
        child: SizedBox(
          height: mpProjectTreeRowHeight,
          child: Row(
            children: <Widget>[
              SizedBox(width: row.depth * mpProjectTreeIndent),
              const SizedBox(width: mpSmallIconSize),
              ExcludeSemantics(child: _buildIcon(colorScheme)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _statusText(appLocalizations),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _statusColor(colorScheme)),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );

    if (!offersReload) {
      return content;
    }

    return THProjectTreeRowContextMenuWidget(
      key: ValueKey('THProjectTreeRowContextMenu|${row.rowId}'),
      rowId: row.rowId,
      menuChildrenBuilder: () => <Widget>[
        THProjectTreeRowContextMenuWidget.reloadMenuItem(
          rowId: row.rowId,
          th2FilePath: row.th2FilePath,
          appLocalizations: appLocalizations,
        ),
      ],
      child: content,
    );
  }

  String _statusText(AppLocalizations appLocalizations) {
    return switch (row.kind) {
      TH2FileStatusTreeRowKind.loading =>
        appLocalizations.th2ElementTreeLoading,
      TH2FileStatusTreeRowKind.loadError =>
        appLocalizations.th2ElementTreeLoadError,
      TH2FileStatusTreeRowKind.broken =>
        appLocalizations.th2ElementTreeBrokenFile,
    };
  }

  Color _statusColor(ColorScheme colorScheme) {
    return (row.kind == TH2FileStatusTreeRowKind.loading)
        ? colorScheme.onSurfaceVariant
        : colorScheme.error;
  }

  Widget _buildIcon(ColorScheme colorScheme) {
    final IconData icon = switch (row.kind) {
      TH2FileStatusTreeRowKind.loading => Icons.hourglass_empty,
      TH2FileStatusTreeRowKind.loadError => Icons.error_outline,
      TH2FileStatusTreeRowKind.broken => Icons.report_problem_outlined,
    };

    return Icon(icon, size: mpSmallIconSize, color: _statusColor(colorScheme));
  }

  /// Opens the file's tab, whose body shows the broken-file panel or the
  /// load-failure dialog.
  void _openTab() {
    final MPGeneralController generalController =
        mpLocator.mpGeneralController;

    generalController.getTH2FileEditController(filename: row.th2FilePath);
    generalController.addFileTab(row.th2FilePath);
  }
}
