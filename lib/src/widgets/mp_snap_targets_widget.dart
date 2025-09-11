import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_snap_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';

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
    final Map<String, String> choices = MPTextToUser.getOrderedChoicesMap(
      MPTextToUser.getSnapPointTargetChoices(),
    );
    final Map<String, String> pointTypeChoices =
        MPTextToUser.getOrderedChoicesMap(
          MPTextToUser.getPointTypeChoices(
            elementEditController: th2FileEditController.elementEditController,
          ),
        );

    return MPOverlayWindowBlockWidget(
      title: appLocalizations.mpSnapPointTargetsLabel,
      overlayWindowBlockType: MPOverlayWindowBlockType.choices,
      padding: mpOverlayWindowBlockEdgeInsets,
      children: [
        Observer(
          builder: (_) {
            th2FileEditController.redrawSnapTargetsWindow;

            return RadioGroup(
              groupValue: snapController.snapPointTargetType.name,
              onChanged: (value) {
                if (value != null) {
                  final MPSnapPointTarget target = MPSnapPointTarget.values
                      .byName(value);
                  snapController.setSnapPointTargetType(target);

                  if (target == MPSnapPointTarget.pointByType &&
                      snapController.pointTargetPLATypes.isEmpty) {
                    snapController.setPointTargetPLATypes(
                      pointTypeChoices.keys,
                    );
                  }
                }
              },
              child: Column(
                children: [
                  ...choices.entries.map((entry) {
                    final Widget tile = RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.value),
                      value: entry.key,
                    );

                    if (entry.key == MPSnapPointTarget.pointByType.name) {
                      final bool expanded =
                          snapController.snapPointTargetType ==
                          MPSnapPointTarget.pointByType;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          tile,
                          if (expanded)
                            Padding(
                              padding: const EdgeInsets.only(left: 32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: mpButtonSpace / 2),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          snapController.setPointTargetPLATypes(
                                            pointTypeChoices.keys,
                                          );
                                        },
                                        child: Text(
                                          appLocalizations.mpPLATypeAll,
                                        ),
                                      ),
                                      const SizedBox(width: mpButtonSpace),
                                      TextButton(
                                        onPressed: () {
                                          snapController.setPointTargetPLATypes(
                                            {},
                                          );
                                        },
                                        child: Text(
                                          appLocalizations.mpPLATypeNone,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...pointTypeChoices.entries.map(
                                    (pt) => CheckboxListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(pt.value),
                                      value: snapController.pointTargetPLATypes
                                          .contains(pt.key),
                                      onChanged: (checked) {
                                        if (checked == true) {
                                          snapController.addPointTargetPLAType(
                                            pt.key,
                                          );
                                        } else {
                                          snapController
                                              .removePointTargetPLAType(pt.key);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }

                    return tile;
                  }),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLinePointTargetGroup() {
    final Map<String, String> choices = MPTextToUser.getOrderedChoicesMap(
      MPTextToUser.getSnapLinePointTargetChoices(),
    );
    final Map<String, String> lineTypeChoices =
        MPTextToUser.getOrderedChoicesMap(
          MPTextToUser.getLineTypeChoices(
            elementEditController: th2FileEditController.elementEditController,
          ),
        );

    return MPOverlayWindowBlockWidget(
      title: appLocalizations.mpSnapLinePointTargetsLabel,
      overlayWindowBlockType: MPOverlayWindowBlockType.choices,
      padding: mpOverlayWindowBlockEdgeInsets,
      children: [
        Observer(
          builder: (_) {
            th2FileEditController.redrawSnapTargetsWindow;

            return RadioGroup(
              groupValue: snapController.snapLinePointTargetType.name,
              onChanged: (value) {
                if (value != null) {
                  final MPSnapLinePointTarget target = MPSnapLinePointTarget
                      .values
                      .byName(value);
                  snapController.setSnapLinePointTargetType(target);

                  if (target == MPSnapLinePointTarget.linePointByType &&
                      snapController.linePointTargetPLATypes.isEmpty) {
                    snapController.setLinePointTargetPLATypes(
                      lineTypeChoices.keys,
                    );
                  }
                }
              },
              child: Column(
                children: [
                  ...choices.entries.map((entry) {
                    final Widget tile = RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.value),
                      value: entry.key,
                    );

                    if (entry.key ==
                        MPSnapLinePointTarget.linePointByType.name) {
                      final bool expanded =
                          snapController.snapLinePointTargetType ==
                          MPSnapLinePointTarget.linePointByType;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          tile,
                          if (expanded)
                            Padding(
                              padding: const EdgeInsets.only(left: 32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: mpButtonSpace / 2),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          snapController
                                              .setLinePointTargetPLATypes(
                                                lineTypeChoices.keys,
                                              );
                                        },
                                        child: Text(
                                          appLocalizations.mpPLATypeAll,
                                        ),
                                      ),
                                      const SizedBox(width: mpButtonSpace),
                                      TextButton(
                                        onPressed: () {
                                          snapController
                                              .setLinePointTargetPLATypes({});
                                        },
                                        child: Text(
                                          appLocalizations.mpPLATypeNone,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ...lineTypeChoices.entries.map(
                                    (lt) => CheckboxListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(lt.value),
                                      value: snapController
                                          .linePointTargetPLATypes
                                          .contains(lt.key),
                                      onChanged: (checked) {
                                        if (checked == true) {
                                          snapController
                                              .addLinePointTargetPLAType(
                                                lt.key,
                                              );
                                        } else {
                                          snapController
                                              .removeLinePointTargetPLAType(
                                                lt.key,
                                              );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }

                    return tile;
                  }),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
