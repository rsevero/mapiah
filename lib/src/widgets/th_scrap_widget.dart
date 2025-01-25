import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/stores/th2_file_edit_store.dart';
import 'package:mapiah/src/widgets/th_line_widget.dart';
import 'package:mapiah/src/widgets/th_point_widget.dart';

class THScrapWidget extends StatelessWidget {
  final THScrap scrap;
  final int scrapMapiahID;
  final TH2FileEditStore th2FileEditStore;
  final int thFileMapiahID;

  THScrapWidget({
    required super.key,
    required this.scrapMapiahID,
    required this.th2FileEditStore,
    required this.thFileMapiahID,
  }) : scrap =
            th2FileEditStore.thFile.elementByMapiahID(scrapMapiahID) as THScrap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Observer(
          builder: (_) {
            final List<Widget> drawableElements = [];
            final List<int> scrapChildrenMapiahIDs = scrap.childrenMapiahID;
            final THFile thFile = th2FileEditStore.thFile;
            final int thScrapMapiahID = scrap.mapiahID;

            th2FileEditStore
                .childrenListLengthChangeTrigger[thScrapMapiahID]!.value;

            for (final int childMapiahID in scrapChildrenMapiahIDs) {
              final THElement child = thFile.elementByMapiahID(childMapiahID);

              switch (child) {
                case THPoint _:
                  drawableElements.add(THPointWidget(
                    key: ValueKey(childMapiahID),
                    pointMapiahID: childMapiahID,
                    th2FileEditStore: th2FileEditStore,
                    thFileMapiahID: thFileMapiahID,
                    thScrapMapiahID: thScrapMapiahID,
                  ));
                  break;
                case THLine _:
                  drawableElements.add(THLineWidget(
                    key: ValueKey(childMapiahID),
                    lineMapiahID: childMapiahID,
                    th2FileEditStore: th2FileEditStore,
                    thFileMapiahID: thFileMapiahID,
                    thScrapMapiahID: thScrapMapiahID,
                  ));
                  break;
              }
            }

            return Stack(
              children: drawableElements,
            );
          },
        );
      },
    );
  }
}
