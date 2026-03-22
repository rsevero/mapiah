// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

class MPTelemetryConsentDialog extends StatelessWidget {
  const MPTelemetryConsentDialog({super.key});

  static bool _isOpen = false;

  static void show(BuildContext context) {
    if (_isOpen) {
      return;
    }

    _isOpen = true;

    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (BuildContext ctx) => const MPTelemetryConsentDialog(),
    ).whenComplete(() {
      _isOpen = false;
    });
  }

  void _accept(BuildContext context) {
    Navigator.of(context).pop();
    mpLocator.mpTelemetryController.setConsent(true);
  }

  void _decline(BuildContext context) {
    Navigator.of(context).pop();
    mpLocator.mpTelemetryController.setConsent(false);
  }

  void _openLearnMore(BuildContext context) {
    MPDialogAux.showHelpDialog(
      context,
      mpHelpPageTelemetry,
      mpLocator.appLocalizations.telemetryConsentDialogTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AlertDialog(
      title: Text(mpLocator.appLocalizations.telemetryConsentDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(mpLocator.appLocalizations.telemetryConsentDialogBody),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _openLearnMore(context),
            child: Text(
              mpLocator.appLocalizations.telemetryConsentDialogLearnMore,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => _decline(context),
          child: Text(mpLocator.appLocalizations.telemetryConsentDialogDecline),
        ),
        FilledButton(
          onPressed: () => _accept(context),
          child: Text(mpLocator.appLocalizations.telemetryConsentDialogAccept),
        ),
      ],
    );
  }
}
