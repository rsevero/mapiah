import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:mapiah/src/widgets/th_line_widget.dart';
import 'package:mapiah/src/widgets/th_point_widget.dart';
import 'package:mapiah/src/widgets/th_scrap_widget.dart';

class THFileWidget extends StatelessWidget {
  final TH2FileEditStore th2FileEditStore;

  late final THFile thFile = th2FileEditStore.thFile;
  late final int thFileMapiahID = th2FileEditStore.thFileMapiahID;

  THFileWidget({required super.key, required this.th2FileEditStore});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Observer(
          builder: (context) {
            th2FileEditStore.updateScreenSize(
                Size(constraints.maxWidth, constraints.maxHeight));

            if (th2FileEditStore.canvasScaleTranslationUndefined) {
              th2FileEditStore.zoomAll();
            }

            th2FileEditStore.clearSelectableElements();

            th2FileEditStore
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
                    th2FileEditStore: th2FileEditStore,
                    thFileMapiahID: thFileMapiahID,
                  ));
                  break;
                case THPoint _:
                  childWidgets.add(THPointWidget(
                    key: ValueKey(childMapiahID),
                    pointMapiahID: childMapiahID,
                    th2FileEditStore: th2FileEditStore,
                    thFileMapiahID: thFileMapiahID,
                    thScrapMapiahID: thFileMapiahID,
                  ));
                  break;
                case THLine _:
                  childWidgets.add(THLineWidget(
                    key: ValueKey(childMapiahID),
                    lineMapiahID: childMapiahID,
                    th2FileEditStore: th2FileEditStore,
                    thFileMapiahID: thFileMapiahID,
                    thScrapMapiahID: thFileMapiahID,
                  ));
                  break;
                default:
                  break;
              }
            }

            return GestureDetector(
              onTapUp: _onTapUp,
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

  void _onTapUp(TapUpDetails details) {
    th2FileEditStore.onTapUp(details);
  }

  void _onPanStart(DragStartDetails details) {
    th2FileEditStore.onPanStart(details);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    th2FileEditStore.onPanUpdate(details);
  }

  void _onPanEnd(DragEndDetails details) {
    th2FileEditStore.onPanEnd(details);
  }
}
