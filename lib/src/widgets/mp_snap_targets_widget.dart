import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_snap_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPSnapTargetsWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;

  const MPSnapTargetsWidget({
    super.key,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
  });

  @override
  State<MPSnapTargetsWidget> createState() => _MPSnapTargetsWidgetState();
}

class _MPSnapTargetsWidgetState extends State<MPSnapTargetsWidget> {
  late final TH2FileEditController th2FileEditController;
  late final TH2FileEditSnapController snapController;
  late AppLocalizations appLocalizations;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
    snapController = th2FileEditController.snapController;
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context);

    return MPOverlayWindowWidget(
      title: 'Snap targets',
      overlayWindowType: MPOverlayWindowType.primary,
      outerAnchorPosition: widget.outerAnchorPosition,
      innerAnchorType: MPWidgetPositionType.centerRight,
      th2FileEditController: th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        _buildPointTargetGroup(),
        const SizedBox(height: mpButtonSpace),
        _buildLinePointTargetGroup(),
        const SizedBox(height: mpButtonSpace * 1.5),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              th2FileEditController.overlayWindowController
                  .setShowOverlayWindow(MPWindowType.snapTargets, false);
            },
            child: Text(appLocalizations.buttonClose),
          ),
        ),
      ],
    );
  }

  Widget _buildPointTargetGroup() {
    return Observer(
      builder: (_) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Snap point targets',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            RadioGroup(
              groupValue: snapController.snapPointTargetType,
              onChanged: (value) {
                if (value != null) {
                  snapController.setSnapPointTargetType(value);
                }
              },
              child: Column(
                children: [
                  ...MPSnapPointTarget.values.map(
                    (t) => RadioListTile<MPSnapPointTarget>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.name),
                      value: t,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLinePointTargetGroup() {
    return Observer(
      builder: (_) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Snap line point targets',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            RadioGroup(
              groupValue: snapController.snapLinePointTargetType,
              onChanged: (value) {
                if (value != null) {
                  snapController.setSnapLinePointTargetType(value);
                }
              },
              child: Column(
                children: [
                  ...MPSnapLinePointTarget.values.map(
                    (t) => RadioListTile<MPSnapLinePointTarget>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(t.name),
                      value: t,
                    ),
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
