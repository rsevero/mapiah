import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPAvailableScrapsWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;

  const MPAvailableScrapsWidget({
    super.key,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
  });

  @override
  State<MPAvailableScrapsWidget> createState() =>
      _MPAvailableScrapsWidgetState();
}

class _MPAvailableScrapsWidgetState extends State<MPAvailableScrapsWidget> {
  late final TH2FileEditController th2FileEditController;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: mpLocator.appLocalizations.th2FileEditPageChangeActiveScrapTitle,
      overlayWindowType: MPOverlayWindowType.primary,
      outerAnchorPosition: widget.outerAnchorPosition,
      innerAnchorType: MPWidgetPositionType.centerRight,
      th2FileEditController: th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        Observer(
          builder: (_) {
            th2FileEditController.activeScrapID;

            return MPOverlayWindowBlockWidget(
              overlayWindowBlockType: MPOverlayWindowBlockType.main,
              padding: mpOverlayWindowBlockEdgeInsets,
              children: [
                Builder(
                  builder: (blockContext) {
                    return RadioGroup(
                      groupValue: th2FileEditController.activeScrapID,
                      onChanged: (int? value) {
                        if (value != null) {
                          _onTapSelectScrap(value);
                        }
                      },
                      child: Column(
                        children: th2FileEditController
                            .availableScraps()
                            .entries
                            .map((entry) {
                              final int scrapID = entry.key;
                              final String scrapName = entry.value;

                              return Builder(
                                builder: (listenerContext) {
                                  return Listener(
                                    onPointerDown: (PointerDownEvent event) {
                                      if (event.kind ==
                                              PointerDeviceKind.mouse &&
                                          event.buttons ==
                                              kSecondaryMouseButton) {
                                        _onRightClickSelectScrap(
                                          listenerContext,
                                          scrapID,
                                        );
                                      }
                                    },
                                    child: RadioListTile<int>(
                                      title: Text(
                                        scrapName,
                                        style: DefaultTextStyle.of(
                                          blockContext,
                                        ).style,
                                      ),
                                      value: scrapID,

                                      contentPadding: EdgeInsets.zero,
                                      activeColor: IconTheme.of(
                                        blockContext,
                                      ).color,
                                      dense: true,
                                      visualDensity:
                                          VisualDensity.adaptivePlatformDensity,
                                    ),
                                  );
                                },
                              );
                            })
                            .toList(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _onTapSelectScrap(int scrapID) {
    th2FileEditController.setActiveScrap(scrapID);
  }

  void _onRightClickSelectScrap(BuildContext childContext, int scrapID) {
    Rect? thisBoundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: context,
      ancestorGlobalKey: th2FileEditController.thFileWidgetKey,
    );

    Rect? childBoundingBox = MPInteractionAux.getWidgetRectFromContext(
      widgetContext: childContext,
      ancestorGlobalKey: th2FileEditController.thFileWidgetKey,
    );

    /// Use the left of this widget and the vertical center of the child (taped
    /// option) widget as the outer anchor position for the option edit window.
    final Offset anchorPosition =
        (thisBoundingBox == null) || (childBoundingBox == null)
        ? th2FileEditController.screenBoundingBox.center
        : Offset(thisBoundingBox.left, childBoundingBox.center.dy);

    th2FileEditController.overlayWindowController
        .perfomToggleScrapOptionsOverlayWindow(
          scrapMPID: scrapID,
          outerAnchorPosition: anchorPosition,
        );
  }
}
