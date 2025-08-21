import 'package:flutter/material.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPErrorDialog extends StatelessWidget {
  final List<String> errorMessages;

  MPErrorDialog({required this.errorMessages});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).parsingErrors),
      content: SingleChildScrollView(
        child: ListBody(
          children: errorMessages
              .map((message) => SelectableText(message))
              .toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(AppLocalizations.of(context).buttonClose),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
