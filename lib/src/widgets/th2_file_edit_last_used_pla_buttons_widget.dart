// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/types/mp_pla_type_subtype.dart';

class TH2FileEditLastUsedPLAButtonsWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;

  const TH2FileEditLastUsedPLAButtonsWidget({
    required this.th2FileEditController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) {
        mpLocator.mpSettingsController.getTrigger(
          MPSettingID.TH2Edit_ShowLastUsedPLATypeButtons,
        );

        if (!_showLastUsedPLAButtons) {
          return const SizedBox.shrink();
        }

        final List<MPPLATypeSubtype> lastUsedAreaLineTypes =
            th2FileEditController.elementEditController.lastUsedAreaLineTypes
                .toList(growable: false);
        final List<MPPLATypeSubtype> lastUsedPointTypes = th2FileEditController
            .elementEditController
            .lastUsedPointTypes
            .toList(growable: false);

        if (lastUsedAreaLineTypes.isEmpty && lastUsedPointTypes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: 0,
          right: 0,
          bottom: mpButtonSpace,
          child: IgnorePointer(
            ignoring: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _TH2FileEditLastUsedPLAButtonsHalfWidget(
                    plaTypes: lastUsedAreaLineTypes.reversed.toList(),
                    alignment: Alignment.centerRight,
                    th2FileEditController: th2FileEditController,
                  ),
                ),
                Expanded(
                  child: _TH2FileEditLastUsedPLAButtonsHalfWidget(
                    plaTypes: lastUsedPointTypes,
                    alignment: Alignment.centerLeft,
                    th2FileEditController: th2FileEditController,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get _showLastUsedPLAButtons {
    return mpLocator.mpSettingsController.getBoolWithDefault(
      MPSettingID.TH2Edit_ShowLastUsedPLATypeButtons,
    );
  }
}

class _TH2FileEditLastUsedPLAButtonsHalfWidget extends StatelessWidget {
  final Alignment alignment;
  final List<MPPLATypeSubtype> plaTypes;
  final TH2FileEditController th2FileEditController;

  const _TH2FileEditLastUsedPLAButtonsHalfWidget({
    required this.alignment,
    required this.plaTypes,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    if (plaTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 44,
      child: ClipRect(
        child: Align(
          alignment: alignment,
          child: UnconstrainedBox(
            constrainedAxis: Axis.vertical,
            alignment: alignment,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final MPPLATypeSubtype plaType in plaTypes) ...[
                  _TH2FileEditLastUsedPLAButtonWidget(
                    plaTypeSubtype: plaType,
                    th2FileEditController: th2FileEditController,
                  ),
                  const SizedBox(width: mpButtonSpace),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TH2FileEditLastUsedPLAButtonWidget extends StatelessWidget {
  final MPPLATypeSubtype plaTypeSubtype;
  final TH2FileEditController th2FileEditController;

  const _TH2FileEditLastUsedPLAButtonWidget({
    required this.plaTypeSubtype,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String buttonIcon = _buttonIconPath(plaTypeSubtype.pla);
    final String label = MPTextToUser.getPLATypeSubtype(plaTypeSubtype);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.94),
        elevation: 1,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => th2FileEditController.elementEditController
              .activatePLATypeSubtypeForNewElement(plaTypeSubtype),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  buttonIcon,
                  width: 18,
                  height: 18,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buttonIconPath(MPPLAType plaType) {
    switch (plaType) {
      case MPPLAType.area:
        return 'assets/icons/add_element-addArea.png';
      case MPPLAType.line:
        return 'assets/icons/add_element-addLine.png';
      case MPPLAType.point:
        return 'assets/icons/add_element-addPoint.png';
    }
  }
}
