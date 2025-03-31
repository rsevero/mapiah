import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
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
      innerAnchorType: MPWidgetPositionType.rightCenter,
      th2FileEditController: th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        Observer(
          builder: (_) {
            th2FileEditController.activeScrapID;
            return MPOverlayWindowBlockWidget(
              overlayWindowBlockType: MPOverlayWindowBlockType.main,
              children: [
                Builder(builder: (blockContext) {
                  return Column(
                    children:
                        th2FileEditController.availableScraps().entries.map(
                      (entry) {
                        final int scrapID = entry.key;
                        final String scrapName = entry.value;

                        return RadioListTile<int>(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: mpTileWidgetEdgeInset,
                          ),
                          value: scrapID,
                          groupValue: th2FileEditController.activeScrapID,
                          onChanged: (int? value) {
                            if (value != null) {
                              _onTapSelectScrap(value);
                            }
                          },
                          title: Text(
                            scrapName,
                            style: DefaultTextStyle.of(blockContext).style,
                          ),
                          activeColor: IconTheme.of(blockContext).color,
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ).toList(),
                  );
                }),
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
}
