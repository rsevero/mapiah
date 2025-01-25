import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/stores/th_file_edit_store.dart';
import 'package:mapiah/src/widgets/th_line_widget.dart';
import 'package:mapiah/src/widgets/th_point_widget.dart';
import 'package:mapiah/src/widgets/th_scrap_widget.dart';

class THFileWidget extends StatelessWidget {
  final THFileEditStore thFileEditStore;

  late final THFile thFile = thFileEditStore.thFile;
  late final int thFileMapiahID = thFileEditStore.thFileMapiahID;

  THFileWidget({required super.key, required this.thFileEditStore});

  @override
  Widget build(BuildContext context) {
    thFileEditStore.updateDataBoundingBox(thFile.boundingBox());
    thFileEditStore.setCanvasScaleTranslationUndefined(true);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Observer(
          builder: (context) {
            thFileEditStore.updateScreenSize(
                Size(constraints.maxWidth, constraints.maxHeight));

            if (thFileEditStore.canvasScaleTranslationUndefined) {
              thFileEditStore.zoomShowAll();
            }

            thFileEditStore.clearSelectableElements();

            thFileEditStore
                .childrenListLengthChangeTrigger[thFileMapiahID]!.value;

            final List<Widget> childWidgets = [];
            final List<int> fileChildrenMapiahIDs = thFile.childrenMapiahID;

            for (final int childMapiahID in fileChildrenMapiahIDs) {
              final THElement child = thFile.elementByMapiahID(childMapiahID);

              switch (child) {
                case THScrap _:
                  childWidgets.add(THScrapWidget(
                    key: ValueKey(childMapiahID),
                    scrapMapiahID: childMapiahID,
                    thFileEditStore: thFileEditStore,
                    thFileMapiahID: thFileMapiahID,
                  ));
                  break;
                case THPoint _:
                  childWidgets.add(THPointWidget(
                    key: ValueKey(childMapiahID),
                    pointMapiahID: childMapiahID,
                    thFileEditStore: thFileEditStore,
                    thFileMapiahID: thFileMapiahID,
                    thScrapMapiahID: thFileMapiahID,
                  ));
                  break;
                case THLine _:
                  childWidgets.add(THLineWidget(
                    key: ValueKey(childMapiahID),
                    lineMapiahID: childMapiahID,
                    thFileEditStore: thFileEditStore,
                    thFileMapiahID: thFileMapiahID,
                    thScrapMapiahID: thFileMapiahID,
                  ));
                  break;
                default:
                  break;
              }
            }

            return GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Stack(
                children: childWidgets,
              ),
            );
          },
        );
      },
    );
  }

  void _onPanStart(DragStartDetails details) {
    thFileEditStore.onPanStart(details);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    thFileEditStore.onPanUpdate(details);
  }

  void _onPanEnd(DragEndDetails details) {
    thFileEditStore.onPanEnd(details);
  }
}
