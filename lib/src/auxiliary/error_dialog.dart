import 'package:flutter/material.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class ErrorDialog extends StatelessWidget {
  final List<String> errorMessages;

  ErrorDialog({required this.errorMessages});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).parsingErrors),
      content: SingleChildScrollView(
        child: ListBody(
          children: errorMessages.map((message) => Text(message)).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
