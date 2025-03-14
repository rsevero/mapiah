import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPAvailableScrapsWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset position;
  final GlobalKey globalKey;
  final MPWidgetPositionType positionType;

  const MPAvailableScrapsWidget({
    super.key,
    required this.th2FileEditController,
    required this.position,
    required this.globalKey,
    required this.positionType,
  });

  @override
  State<MPAvailableScrapsWidget> createState() =>
      _MPAvailableScrapsWidgetState();
}

class _MPAvailableScrapsWidgetState extends State<MPAvailableScrapsWidget> {
  late final TH2FileEditController th2FileEditController;
  late final int zOrder;

  @override
  void initState() {
    super.initState();
    th2FileEditController = widget.th2FileEditController;
    zOrder = th2FileEditController.overlayWindowController.getNewZOrder();
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      globalKey: widget.globalKey,
      position: widget.position,
      positionType: widget.positionType,
      th2FileEditController: th2FileEditController,
      child: Material(
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          width: 230,
          color: Colors.white,
          child: Observer(
            builder: (_) {
              th2FileEditController.activeScrapID;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: th2FileEditController.availableScraps().map(
                  (scrap) {
                    final int scrapID = scrap.$1;
                    final String scrapName = scrap.$2;
                    final bool isSelected = scrap.$3;

                    return PopupMenuItem<int>(
                      value: scrapID,
                      // onTap: () =>
                      //     _selectActiveScrapPressed(
                      //         scrapID),
                      child: Row(
                        children: [
                          Text(scrapName),
                          if (isSelected) ...[
                            SizedBox(width: 8),
                            Icon(Icons.check, color: Colors.blue),
                          ],
                        ],
                      ),
                    );
                  },
                ).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
