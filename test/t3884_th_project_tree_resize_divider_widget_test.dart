// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_test/flutter_test.dart';
import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/widgets/th_project_tree_resize_divider_widget.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final MPLocator mpLocator = MPLocator();

  setUp(() {
    mpLocator.thProjectTreeUIController.setSidebarCollapsed(false);
    mpLocator.thProjectTreeUIController.setSidebarWidth(
      mpProjectTreeSidebarDefaultWidth,
    );
  });

  Widget buildTestApp() {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 200,
            height: 200,
            child: const THProjectTreeResizeDividerWidget(),
          ),
        ),
      ),
    );
  }

  testWidgets('dragging updates sidebar width within clamped bounds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    await tester.drag(
      find.byKey(const ValueKey('THProjectTreeResizeDivider')),
      const Offset(40, 0),
    );
    await tester.pump();

    expect(
      mpLocator.thProjectTreeUIController.sidebarWidth,
      greaterThan(mpProjectTreeSidebarDefaultWidth),
    );

    await tester.drag(
      find.byKey(const ValueKey('THProjectTreeResizeDivider')),
      const Offset(-1000, 0),
    );
    await tester.pump();

    expect(
      mpLocator.thProjectTreeUIController.sidebarWidth,
      mpProjectTreeSidebarMinWidth,
    );

    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('double tap toggles the collapsed state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestApp());

    final Finder divider = find.byKey(
      const ValueKey('THProjectTreeResizeDivider'),
    );

    await tester.tap(divider);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(divider);
    await tester.pumpAndSettle();

    expect(mpLocator.thProjectTreeUIController.isSidebarCollapsed, isTrue);

    await tester.pump(const Duration(milliseconds: 300));
  });
}
