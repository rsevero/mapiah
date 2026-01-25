import 'package:flutter/material.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPErrorDialog extends StatelessWidget {
  final List<String> errorMessages;

  MPErrorDialog({required this.errorMessages});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: SelectableText.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: '${AppLocalizations.of(context).parsingErrors}\n\n',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ...errorMessages.map(
                (message) => TextSpan(
                  text: '$message\n',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
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
