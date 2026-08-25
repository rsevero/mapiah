// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:material_ui/material_ui.dart';

/// Draggable splitter between the project-tree sidebar and the tab workspace.
class THProjectTreeResizeDividerWidget extends StatelessWidget {
  const THProjectTreeResizeDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        key: const ValueKey('THProjectTreeResizeDivider'),
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          mpLocator.thProjectTreeUIController.setSidebarWidth(
            mpLocator.thProjectTreeUIController.sidebarWidth + details.delta.dx,
          );
        },
        onDoubleTap: () {
          mpLocator.thProjectTreeUIController.setSidebarCollapsed(
            !mpLocator.thProjectTreeUIController.isSidebarCollapsed,
          );
        },
        child: SizedBox(
          width: mpProjectTreeResizeDividerWidth,
          child: Center(
            child: Container(
              width: 1,
              color: colorScheme.outlineVariant,
            ),
          ),
        ),
      ),
    );
  }
}
