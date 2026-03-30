// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';

class MPHelpButtonWidget extends StatelessWidget {
  final BuildContext parentContext;
  final String helpPage;
  final String title;
  final IconData? iconData;
  final String? tooltip;

  MPHelpButtonWidget(
    this.parentContext,
    this.helpPage,
    this.title, {
    this.iconData,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: ValueKey('$helpPage HelpPageButton'),
      icon: Icon(iconData ?? Icons.help_outline),
      color: Theme.of(context).colorScheme.onSecondaryContainer,
      onPressed: () =>
          MPDialogAux.showHelpDialog(parentContext, helpPage, title),
      tooltip: tooltip ?? mpLocator.appLocalizations.helpDialogTooltip,
    );
  }
}
