// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/mp_modal_overlay_widget.dart';
import 'package:mapiah/src/widgets/mp_search_select_dialog_widget.dart';

class TH2FileEditStateActionButtonsWidget extends StatelessWidget {
  final String heroPrefix;
  final TH2FileEditController th2FileEditController;

  const TH2FileEditStateActionButtonsWidget({
    required this.heroPrefix,
    required this.th2FileEditController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Observer(
      builder: (_) {
        final bool hasUndo = th2FileEditController.hasUndo;
        final bool hasRedo = th2FileEditController.hasRedo;
        final bool enableRemoveButton =
            th2FileEditController.enableRemoveButton;
        final bool showSnapButton = th2FileEditController.showSnapButton;
        final bool isSomeSnapTargetActive =
            th2FileEditController.snapController.isSomeSnapTargetActive;
        final bool isDefaultOptionsShown = th2FileEditController
            .overlayWindowController
            .showDefaultOptionsOverlayWindow;
        final bool hasAnyDefaultOptions =
            th2FileEditController.defaultOptionsController.hasAnyDefaults;

        th2FileEditController.redrawSnapTargetsWindow;

        return Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: <Widget>[
              FloatingActionButton(
                heroTag: '${heroPrefix}_search_select',
                mini: true,
                tooltip: appLocalizations.th2FileEditPageSearchSelectButton,
                onPressed: () => _onSearchSelectPressed(context),
                child: const Icon(Icons.search),
              ),
              if (showSnapButton) ...<Widget>[
                const SizedBox(width: mpButtonSpace),
                FloatingActionButton(
                  key:
                      th2FileEditController
                          .overlayWindowController
                          .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType
                          .snapTargetsButton]!,
                  heroTag: '${heroPrefix}_snap',
                  mini: true,
                  tooltip: appLocalizations.th2FileEditPageSnapButton,
                  onPressed: _onSnapPressed,
                  backgroundColor: isSomeSnapTargetActive
                      ? null
                      : colorScheme.surfaceContainerLowest,
                  foregroundColor: isSomeSnapTargetActive
                      ? null
                      : colorScheme.surfaceContainerHighest,
                  elevation: isSomeSnapTargetActive ? 6.0 : 3.0,
                  child: Image.asset(
                    'assets/icons/snap-tool.png',
                    width: mpFloatingStateActionZoomIconSize,
                    height: mpFloatingStateActionZoomIconSize,
                    color: isSomeSnapTargetActive
                        ? null
                        : colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
              const SizedBox(width: mpButtonSpace),
              FloatingActionButton(
                heroTag: '${heroPrefix}_default_options',
                mini: true,
                tooltip: appLocalizations.mpDefaultOptionsToolbarTooltip,
                onPressed: _onDefaultOptionsButtonPressed,
                backgroundColor: isDefaultOptionsShown
                    ? (hasAnyDefaultOptions
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerLowest)
                    : (hasAnyDefaultOptions
                          ? null
                          : colorScheme.surfaceContainerLowest),
                foregroundColor: isDefaultOptionsShown
                    ? (hasAnyDefaultOptions
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.surfaceContainerHighest)
                    : (hasAnyDefaultOptions
                          ? null
                          : colorScheme.surfaceContainerHighest),
                elevation: isDefaultOptionsShown
                    ? 1.0
                    : (hasAnyDefaultOptions ? 6.0 : 3.0),
                child: const Icon(Icons.auto_fix_high),
              ),
              if (th2FileEditController.showRemoveButton) ...<Widget>[
                const SizedBox(width: mpButtonSpace),
                FloatingActionButton(
                  heroTag: '${heroPrefix}_remove',
                  mini: true,
                  tooltip: appLocalizations.th2FileEditPageRemoveButton,
                  backgroundColor: enableRemoveButton
                      ? null
                      : colorScheme.surfaceContainerLowest,
                  foregroundColor: enableRemoveButton
                      ? null
                      : colorScheme.surfaceContainerHighest,
                  onPressed: enableRemoveButton ? _onRemovePressed : null,
                  elevation: enableRemoveButton ? 6.0 : 3.0,
                  child: const Icon(Icons.delete_outlined),
                ),
              ],
              if (th2FileEditController.showUndoRedoButtons) ...<Widget>[
                const SizedBox(width: mpButtonSpace),
                FloatingActionButton(
                  heroTag: '${heroPrefix}_undo',
                  mini: true,
                  tooltip: hasUndo
                      ? th2FileEditController.undoDescription
                      : appLocalizations.th2FileEditPageNoUndoAvailable,
                  backgroundColor: hasUndo
                      ? null
                      : colorScheme.surfaceContainerLowest,
                  foregroundColor: hasUndo
                      ? null
                      : colorScheme.surfaceContainerHighest,
                  onPressed: hasUndo ? _onUndoPressed : null,
                  elevation: hasUndo ? 6.0 : 3.0,
                  child: const Icon(Icons.undo),
                ),
                const SizedBox(width: mpButtonSpace),
                FloatingActionButton(
                  heroTag: '${heroPrefix}_redo',
                  mini: true,
                  tooltip: hasRedo
                      ? th2FileEditController.redoDescription
                      : appLocalizations.th2FileEditPageNoRedoAvailable,
                  backgroundColor: hasRedo
                      ? null
                      : colorScheme.surfaceContainerLowest,
                  foregroundColor: hasRedo
                      ? null
                      : colorScheme.surfaceContainerHighest,
                  onPressed: hasRedo ? _onRedoPressed : null,
                  elevation: hasRedo ? 6.0 : 3.0,
                  child: const Icon(Icons.redo),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _onDefaultOptionsButtonPressed() {
    th2FileEditController.optionEditController
        .showDefaultOptionsOverlayWindow();
  }

  void _onRedoPressed() {
    th2FileEditController.stateController.onButtonPressed(MPButtonType.redo);
  }

  void _onRemovePressed() {
    th2FileEditController.overlayWindowController.clearOverlayWindows();
    th2FileEditController.stateController.onButtonPressed(MPButtonType.remove);
  }

  void _onSearchSelectPressed(BuildContext context) {
    th2FileEditController.overlayWindowController.clearOverlayWindows();
    MPModalOverlayWidget.show(
      context: context,
      childBuilder: (VoidCallback onPressedClose) => MPSearchSelectDialogWidget(
        th2FileEditController: th2FileEditController,
        onPressedClose: onPressedClose,
      ),
    );
  }

  void _onSnapPressed() {
    th2FileEditController.overlayWindowController.clearOverlayWindows(
      except: <MPWindowType>{MPWindowType.snapTargets},
    );
    th2FileEditController.overlayWindowController.toggleOverlayWindow(
      MPWindowType.snapTargets,
    );
    th2FileEditController.triggerSnapTargetsWindowRedraw();
  }

  void _onUndoPressed() {
    th2FileEditController.stateController.onButtonPressed(MPButtonType.undo);
  }
}
