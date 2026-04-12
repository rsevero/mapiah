// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/th2_file_edit_state_context_fabs/shared_widgets.dart';

class TH2FileEditImageOperationContextFABsPanel extends StatelessWidget {
  final String heroPrefix;
  final TH2FileEditController th2FileEditController;

  const TH2FileEditImageOperationContextFABsPanel({
    required this.heroPrefix,
    required this.th2FileEditController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TH2FileEditStateContextFABCategoryRow(
          buttons: <Widget>[
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_flip_image_horizontally',
              onPressed: () =>
                  _onButtonPressed(MPButtonType.flipImageHorizontally),
              category: TH2FileEditStateContextFABCategory.editTools,
              icon: Icons.flip,
              tooltip: appLocalizations.th2FileEditPageFlipImageHorizontally,
            ),
            TH2FileEditStateContextFABButton(
              context: context,
              heroTag: '${heroPrefix}_ctx_flip_image_vertically',
              onPressed: () =>
                  _onButtonPressed(MPButtonType.flipImageVertically),
              category: TH2FileEditStateContextFABCategory.editTools,
              icon: Icons.flip_camera_android,
              child: const TH2FileEditVerticalFlipFABIcon(),
              tooltip: appLocalizations.th2FileEditPageFlipImageVertically,
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
