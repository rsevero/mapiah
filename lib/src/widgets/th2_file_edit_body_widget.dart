// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/mp_modal_overlay_widget.dart';
import 'package:mapiah/src/widgets/mp_search_select_dialog_widget.dart';
import 'package:mapiah/src/widgets/th_file_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_action_buttons_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_bottom_status_bar_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_last_used_pla_buttons_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_state_context_fabs_widget.dart';

class TH2FileEditBodyWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Future<TH2FileEditControllerCreateResult> loadFuture;

  const TH2FileEditBodyWidget({
    required this.th2FileEditController,
    required this.loadFuture,
    super.key,
  });

  @override
  State<TH2FileEditBodyWidget> createState() => _TH2FileEditBodyWidgetState();
}

class _TH2FileEditBodyWidgetState extends State<TH2FileEditBodyWidget> {
  late final TH2FileEditController th2FileEditController;
  late AppLocalizations appLocalizations;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();

    th2FileEditController = widget.th2FileEditController;
    appLocalizations = mpLocator.appLocalizations;
  }

  @override
  Widget build(BuildContext context) {
    final String heroPrefix = th2FileEditController.th2FileMPID.toString();

    appLocalizations = mpLocator.appLocalizations;
    colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: FutureBuilder<TH2FileEditControllerCreateResult>(
            future: widget.loadFuture,
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<TH2FileEditControllerCreateResult> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text(
                        appLocalizations.th2FileEditPageLoadingFile(
                          th2FileEditController.currentScrapName,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final List<String> errorMessages = snapshot.data!.errors;

                    if (snapshot.data!.isSuccessful) {
                      if (mpDebugMousePosition) {
                        return MouseRegion(
                          onHover: (event) => th2FileEditController
                              .performSetMousePosition(event.localPosition),
                          child: Stack(
                            children: [
                              TH2FileWidget(
                                key: th2FileEditController
                                    .getTH2FileWidgetGlobalKey(),
                                th2FileEditController: th2FileEditController,
                              ),
                              TH2FileEditLastUsedPLAButtonsWidget(
                                th2FileEditController: th2FileEditController,
                              ),
                              _stateActionButtons(heroPrefix),
                              TH2FileEditActionButtonsWidget(
                                heroPrefix: heroPrefix,
                                th2FileEditController: th2FileEditController,
                              ),
                              TH2FileEditStateContextFABsWidget(
                                heroPrefix: heroPrefix,
                                th2FileEditController: th2FileEditController,
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Stack(
                          children: [
                            TH2FileWidget(
                              key: th2FileEditController
                                  .getTH2FileWidgetGlobalKey(),
                              th2FileEditController: th2FileEditController,
                            ),
                            TH2FileEditLastUsedPLAButtonsWidget(
                              th2FileEditController: th2FileEditController,
                            ),
                            _stateActionButtons(heroPrefix),
                            TH2FileEditActionButtonsWidget(
                              heroPrefix: heroPrefix,
                              th2FileEditController: th2FileEditController,
                            ),
                            TH2FileEditStateContextFABsWidget(
                              heroPrefix: heroPrefix,
                              th2FileEditController: th2FileEditController,
                            ),
                          ],
                        );
                      }
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MPErrorDialog(
                              errorMessages: errorMessages,
                              filename: th2FileEditController.th2File.filename,
                            );
                          },
                        ).then((_) {
                          th2FileEditController.close();
                        });
                      });

                      return Container();
                    }
                  } else {
                    throw Exception(
                      'Unexpected snapshot state: ${snapshot.connectionState}',
                    );
                  }
                },
          ),
        ),
        TH2FileEditBottomStatusBarWidget(
          th2FileEditController: th2FileEditController,
        ),
      ],
    );
  }

  void _onDefaultOptionsButtonPressed() {
    th2FileEditController.optionEditController
        .showDefaultOptionsOverlayWindow();
  }

  void onRemovePressed() {
    th2FileEditController.overlayWindowController.clearOverlayWindows();
    th2FileEditController.stateController.onButtonPressed(MPButtonType.remove);
  }

  void onRedoPressed() {
    th2FileEditController.stateController.onButtonPressed(MPButtonType.redo);
  }

  void onUndoPressed() {
    th2FileEditController.stateController.onButtonPressed(MPButtonType.undo);
  }

  Widget _stateActionButtons(String heroPrefix) {
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
            children: [
              FloatingActionButton(
                heroTag: '${heroPrefix}_search_select',
                mini: true,
                tooltip: appLocalizations.th2FileEditPageSearchSelectButton,
                onPressed: () {
                  th2FileEditController.overlayWindowController
                      .clearOverlayWindows();
                  MPModalOverlayWidget.show(
                    context: context,
                    childBuilder: (VoidCallback onPressedClose) =>
                        MPSearchSelectDialogWidget(
                          th2FileEditController: th2FileEditController,
                          onPressedClose: onPressedClose,
                        ),
                  );
                },
                child: const Icon(Icons.search),
              ),
              if (showSnapButton) ...[
                SizedBox(width: mpButtonSpace),
                FloatingActionButton(
                  key:
                      th2FileEditController
                          .overlayWindowController
                          .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType
                          .snapTargetsButton]!,
                  heroTag: '${heroPrefix}_snap',
                  mini: true,
                  tooltip: appLocalizations.th2FileEditPageSnapButton,
                  onPressed: () {
                    th2FileEditController.overlayWindowController
                        .clearOverlayWindows(
                          except: {MPWindowType.snapTargets},
                        );
                    th2FileEditController.overlayWindowController
                        .toggleOverlayWindow(MPWindowType.snapTargets);
                    th2FileEditController.triggerSnapTargetsWindowRedraw();
                  },
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
              SizedBox(width: mpButtonSpace),
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
              if (th2FileEditController.showRemoveButton) ...[
                SizedBox(width: mpButtonSpace),
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
                  onPressed: enableRemoveButton ? onRemovePressed : null,
                  elevation: enableRemoveButton ? 6.0 : 3.0,
                  child: const Icon(Icons.delete_outlined),
                ),
              ],
              if (th2FileEditController.showUndoRedoButtons) ...[
                SizedBox(width: mpButtonSpace),
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
                  onPressed: hasUndo ? onUndoPressed : null,
                  elevation: hasUndo ? 6.0 : 3.0,
                  child: const Icon(Icons.undo),
                ),
                SizedBox(width: mpButtonSpace),
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
                  onPressed: hasRedo ? onRedoPressed : null,
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
}
