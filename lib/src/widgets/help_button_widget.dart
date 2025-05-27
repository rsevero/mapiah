import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPHelpButtonWidget extends StatelessWidget {
  final BuildContext context;
  final String helpPage;
  final String title;

  MPHelpButtonWidget(
    this.context,
    this.helpPage,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.help_outline),
      color: Theme.of(context).colorScheme.onSecondaryContainer,
      onPressed: () => MPDialogAux.showHelpDialog(
        context,
        helpPage,
        title,
      ),
      tooltip: AppLocalizations.of(context).helpDialogTooltip,
    );
  }
}
