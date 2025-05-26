import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapiah/main.dart';

class MPHelpDialogWidget extends StatelessWidget {
  final String markdownAssetPath;
  final String title;

  const MPHelpDialogWidget({
    super.key,
    required this.markdownAssetPath,
    required this.title,
  });

  Future<String> _loadMarkdown() async {
    return await rootBundle.loadString(markdownAssetPath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadMarkdown(),
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
          content: SizedBox(
            width: 500,
            height: 400,
            child: Markdown(
              data: snapshot.data ?? '',
              selectable: true,
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
