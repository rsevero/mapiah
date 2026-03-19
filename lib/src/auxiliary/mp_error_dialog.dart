// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:path/path.dart' as p;

class MPErrorDialog extends StatelessWidget {
  final List<String> errorMessages;
  final String? title;
  final String? filename;

  MPErrorDialog({required this.errorMessages, this.title, this.filename});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final String dialogTitle = title ?? appLocalizations.parsingErrors;

    final List<TextSpan> spans = <TextSpan>[
      TextSpan(
        text: '$dialogTitle\n\n',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      if (filename != null && filename!.isNotEmpty) ...<TextSpan>[
        TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '${appLocalizations.mpErrorDialogFilenameLabel}: ',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '${p.basename(filename!)}\n',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '${appLocalizations.mpErrorDialogFullPathLabel}: ',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: '$filename\n\n',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ],
      ...errorMessages.map(
        (message) => TextSpan(
          text: '$message\n',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ];

    return AlertDialog(
      content: SingleChildScrollView(
        child: SelectableText.rich(TextSpan(children: spans)),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(appLocalizations.buttonClose),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
