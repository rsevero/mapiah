// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/th2_file_edit_state_context_fabs/shared_widgets.dart';

class TH2FileEditAddElementContextFABsPanel extends StatelessWidget {
  final String heroPrefix;
  final TH2FileEditController th2FileEditController;

  const TH2FileEditAddElementContextFABsPanel({
    required this.heroPrefix,
    required this.th2FileEditController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final bool showLineTraceButton =
        th2FileEditController.isInAddLineState &&
        th2FileEditController.lineTraceController.hasAnyImage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TH2FileEditStateContextFABCategoryRow(
          buttons: <Widget>[
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_select_all_elements',
              onPressed: th2FileEditController.enableSelectButton
                  ? () => _onButtonPressed(MPButtonType.selectAllElements)
                  : null,
              category: TH2FileEditStateContextFABCategory.selection,
              icon: Icons.select_all,
              tooltip: appLocalizations.th2FileEditPageSelectAllElements,
            ),
          ],
        ),
        TH2FileEditStateContextFABCategoryRow(
          buttons: <Widget>[
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_paste_elements',
              onPressed: th2FileEditController.hasClipboardContent
                  ? () => _onButtonPressed(MPButtonType.pasteElements)
                  : null,
              category: TH2FileEditStateContextFABCategory.clipboard,
              icon: Icons.content_paste,
              tooltip: appLocalizations.th2FileEditPagePasteElements,
            ),
          ],
        ),
        if (showLineTraceButton)
          TH2FileEditStateContextFABCategoryRow(
            buttons: <Widget>[
              Observer(
                builder: (context) {
                  final bool isTracing =
                      th2FileEditController.lineTraceController.isTracing;
                  final bool canStartTracing =
                      th2FileEditController.lineTraceController.canStartTracing;

                  return TH2FileEditStateContextFABButton(
                    context: context,
                    heroTag: '${heroPrefix}_ctx_toggle_line_tracing',
                    onPressed: isTracing || canStartTracing
                        ? () => th2FileEditController.lineTraceController
                              .toggleTracing()
                        : null,
                    category: TH2FileEditStateContextFABCategory.editTools,
                    icon: isTracing ? Icons.stop : Icons.play_arrow,
                    tooltip: isTracing
                        ? appLocalizations.th2FileEditPageStopTracing
                        : appLocalizations.th2FileEditPageContinueTracing,
                    isActive: isTracing,
                  );
                },
              ),
            ],
          ),
      ],
    );
  }

  void _onButtonPressed(MPButtonType buttonType) {
    th2FileEditController.stateController.onButtonPressed(buttonType);
  }
}
