// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class MPResponsiveAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget> expandedActions;
  final Widget compactAction;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;
  final double elevation;

  const MPResponsiveAppBar({
    required this.expandedActions,
    required this.compactAction,
    this.title,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.elevation = 0,
    super.key,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double appBarWidth = constraints.maxWidth;
        final List<Widget> actions;

        if (appBarWidth < mpResponsiveAppBarOverflowMenuMinWidth) {
          actions = <Widget>[];
        } else if (appBarWidth < mpResponsiveAppBarExpandedActionsMinWidth) {
          actions = <Widget>[compactAction];
        } else {
          actions = expandedActions;
        }

        return AppBar(
          automaticallyImplyLeading: automaticallyImplyLeading,
          elevation: elevation,
          title: title,
          actions: actions,
          bottom: bottom,
        );
      },
    );
  }
}
