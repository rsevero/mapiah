import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey, rootBundle;
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_settings_type.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MPHelpDialogWidget extends StatelessWidget {
  final String helpPage;
  final String title;
  final VoidCallback onPressedClose;

  const MPHelpDialogWidget({
    super.key,
    required this.helpPage,
    required this.title,
    required this.onPressedClose,
  });

  Future<String> _loadMarkdown(BuildContext context) async {
    final String localIDSetting = mpLocator.mpSettingsController.getString(
      MPSettingsType.Main_LocaleID,
    );
    final String localeID = (localIDSetting == 'sys')
        ? View.of(context).platformDispatcher.locale.languageCode
        : localIDSetting;
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
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              onPressedClose();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: FutureBuilder<String>(
            future: _loadMarkdown(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return AlertDialog(
                  title: Text(title),
                  content: Text(
                    mpLocator.appLocalizations.helpDialogFailureToLoad,
                  ),
                  actions: [
                    TextButton(
                      onPressed: onPressedClose,
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
                    onPressed: onPressedClose,
                    child: Text(mpLocator.appLocalizations.buttonClose),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
