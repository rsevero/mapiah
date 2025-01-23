import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/stores/th_file_display_store.dart';
import 'package:mapiah/src/stores/th_file_store.dart';
import 'package:mapiah/src/widgets/th_line_widget.dart';
import 'package:mapiah/src/widgets/th_point_widget.dart';

class THScrapWidget extends StatelessWidget {
  final THScrap thScrap;
  final THFileDisplayStore thFileDisplayStore = getIt<THFileDisplayStore>();
  final THFileStore thFileStore;
  final int thFileMapiahID;

  THScrapWidget({
    required this.thScrap,
    required this.thFileStore,
    required this.thFileMapiahID,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Observer(
          builder: (_) {
            final List<Widget> drawableElements = [];
            final List<int> scrapChildrenMapiahIDs = thScrap.childrenMapiahID;
            final THFile thFile = thFileStore.thFile;
            final int thScrapMapiahID = thScrap.mapiahID;

            thFileStore.redrawTrigger[thFileMapiahID];

            for (final int childMapiahID in scrapChildrenMapiahIDs) {
              final THElement child = thFile.elementByMapiahID(childMapiahID);

              switch (child) {
                case THPoint _:
                  drawableElements.add(THPointWidget(
                    point: child,
                    thFileDisplayStore: thFileDisplayStore,
                    thFileStore: thFileStore,
                    thFileMapiahID: thFileMapiahID,
                    thScrapMapiahID: thScrapMapiahID,
                  ));
                  break;
                case THLine _:
                  drawableElements.add(THLineWidget(
                    line: child,
                    thFileDisplayStore: thFileDisplayStore,
                    thFileStore: thFileStore,
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
