// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/th_text_editor_widget.dart';
import 'package:material_ui/material_ui.dart';

/// The body of a `.th2` tab in text mode: the "can't apply" banner while it
/// applies, then the text editor with a _Canvas_ button.
class TH2TextEditBodyWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;

  const TH2TextEditBodyWidget({
    required this.th2FileEditController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Observer(
      builder: (BuildContext context) {
        final TH2TextEditController? textEditController =
            th2FileEditController.textEditController;

        if (textEditController == null) {
          return const SizedBox.shrink();
        }

        return Column(
          children: <Widget>[
            if (th2FileEditController.showTextApplyRejection)
              MaterialBanner(
                key: const ValueKey<String>(
                  'TH2TextEditBodyWidget|CantApplyBanner',
                ),
                content: Text(appLocalizations.th2TextCantApplyBanner),
                leading: const Icon(Icons.error_outline),
                actions: <Widget>[
                  TextButton(
                    key: const ValueKey<String>(
                      'TH2TextEditBodyWidget|KeepEditingButton',
                    ),
                    onPressed: th2FileEditController.keepEditingAfterRejection,
                    child: Text(appLocalizations.th2TextKeepEditingButton),
                  ),
                  TextButton(
                    key: const ValueKey<String>(
                      'TH2TextEditBodyWidget|DiscardButton',
                    ),
                    onPressed: th2FileEditController.requestDiscardTextEdits,
                    child: Text(appLocalizations.th2TextDiscardChangesButton),
                  ),
                ],
              ),
            Expanded(
              child: THTextEditorWidget(
                controller: textEditController,
                leadingToolbarActions: <Widget>[
                  IconButton(
                    key: const ValueKey<String>(
                      'TH2TextEditBodyWidget|CanvasButton',
                    ),
                    icon: const Icon(Icons.draw_outlined),
                    tooltip: appLocalizations.th2EditModeCanvasTooltip,
                    onPressed: th2FileEditController.requestToggleEditMode,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
