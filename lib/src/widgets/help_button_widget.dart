import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPHelpButtonWidget extends StatelessWidget {
  final BuildContext context;
  final String helpPage;
  final String title;
  final IconData? iconData;
  final String? tooltip;

  MPHelpButtonWidget(
    this.context,
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
      onPressed: () => MPDialogAux.showHelpDialog(context, helpPage, title),
      tooltip: tooltip ?? AppLocalizations.of(context).helpDialogTooltip,
    );
  }
}
