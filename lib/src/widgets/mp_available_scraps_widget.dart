import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPAvailableScrapsWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Offset position;

  const MPAvailableScrapsWidget({
    super.key,
    required this.th2FileEditController,
    required this.position,
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
      position: widget.position,
      positionType: MPWidgetPositionType.rightCenter,
      overlayWindowType: MPOverlayWindowType.availableScraps,
      th2FileEditController: th2FileEditController,
      child: MouseRegion(
        onEnter: (_) =>
            th2FileEditController.setIsMouseOverChangeScrapsOverlayWindow(true),
        onExit: (_) => th2FileEditController
            .setIsMouseOverChangeScrapsOverlayWindow(false),
        child: Material(
          elevation: 4.0,
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.all(mpButtonSpace),
              color: Colors.white,
              child: Observer(
                builder: (_) {
                  th2FileEditController.activeScrapID;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                          Text(
                            AppLocalizations.of(context)
                                .th2FileEditPageChangeActiveScrapTool,
                          )
                        ] +
                        th2FileEditController.availableScraps().map(
                          (scrap) {
                            final int scrapID = scrap.$1;
                            final String scrapName = scrap.$2;
                            final bool isSelected = scrap.$3;

                            return ListTile(
                              dense: true,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 8.0),
                              onTap: () => _onTapSelectScrap(scrapID),
                              title: Row(
                                children: [
                                  Text(scrapName),
                                  SizedBox(width: mpButtonSpace),
                                  Visibility(
                                    visible: isSelected,
                                    maintainSize: true,
                                    maintainAnimation: true,
                                    maintainState: true,
                                    child:
                                        Icon(Icons.check, color: Colors.blue),
                                  ),
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
        ),
      ),
    );
  }

  void _onTapSelectScrap(int scrapID) {
    th2FileEditController.setActiveScrap(scrapID);
  }
}
