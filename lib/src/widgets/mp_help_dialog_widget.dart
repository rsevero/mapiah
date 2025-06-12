import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MPHelpDialogWidget extends StatelessWidget {
  final String helpPage;
  final String title;

  const MPHelpDialogWidget({
    super.key,
    required this.helpPage,
    required this.title,
  });

  Future<String> _loadMarkdown(BuildContext context) async {
    final String localeID = mpLocator.mpSettingsController.localeID == 'sys'
        ? View.of(context).platformDispatcher.locale.languageCode
        : mpLocator.mpSettingsController.localeID;
    final String helpPageAssetPath = "$mpHelpPagePath/$localeID/$helpPage.md";

    try {
      return await rootBundle.loadString(helpPageAssetPath);
    } catch (_) {
      final String fallbackPath = '$mpHelpPagePath/en/$helpPage.md';

      return await rootBundle.loadString(fallbackPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadMarkdown(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return AlertDialog(
            title: Text(title),
            content: Text(mpLocator.appLocalizations.helpDialogFailureToLoad),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(mpLocator.appLocalizations.buttonClose),
              ),
            ],
          );
        }
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: MarkdownBlock(
              data: snapshot.data ?? '',
              selectable: false,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(mpLocator.appLocalizations.buttonClose),
            ),
          ],
        );
      },
    );
  }
}
