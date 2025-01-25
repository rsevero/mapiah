import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mapiah/src/elements/th_line.dart';
import 'package:mapiah/src/elements/th_point.dart';
import 'package:mapiah/src/elements/th_scrap.dart';
import 'package:mapiah/src/stores/th_file_edit_store.dart';
import 'package:mapiah/src/widgets/th_line_widget.dart';
import 'package:mapiah/src/widgets/th_point_widget.dart';

class THScrapWidget extends StatelessWidget {
  final THScrap thScrap;
  final THFileEditStore thFileEditStore;
  final int thFileMapiahID;

  THScrapWidget({
    required super.key,
    required this.thScrap,
    required this.thFileEditStore,
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
            final THFile thFile = thFileEditStore.thFile;
            final int thScrapMapiahID = thScrap.mapiahID;

            thFileEditStore
                .childrenListLengthChangeTrigger[thScrapMapiahID]!.value;

            for (final int childMapiahID in scrapChildrenMapiahIDs) {
              final THElement child = thFile.elementByMapiahID(childMapiahID);

              switch (child) {
                case THPoint _:
                  drawableElements.add(THPointWidget(
                    key: ValueKey(childMapiahID),
                    point: child,
                    thFileEditStore: thFileEditStore,
                    thFileMapiahID: thFileMapiahID,
                    thScrapMapiahID: thScrapMapiahID,
                  ));
                  break;
                case THLine _:
                  drawableElements.add(THLineWidget(
                    key: ValueKey(childMapiahID),
                    line: child,
                    thFileEditStore: thFileEditStore,
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
