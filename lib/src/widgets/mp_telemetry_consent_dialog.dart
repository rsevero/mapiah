// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:markdown_widget/markdown_widget.dart';

class MPTelemetryConsentDialog extends StatefulWidget {
  const MPTelemetryConsentDialog({super.key});

  static bool _isOpen = false;

  static Future<void> show(BuildContext context) async {
    if (_isOpen) {
      return;
    }

    _isOpen = true;

    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (BuildContext ctx) => const MPTelemetryConsentDialog(),
    );

    _isOpen = false;
  }

  @override
  State<MPTelemetryConsentDialog> createState() =>
      _MPTelemetryConsentDialogState();
}

class _MPTelemetryConsentDialogState extends State<MPTelemetryConsentDialog> {
  late final Future<String> _markdownFuture;

  @override
  void initState() {
    super.initState();
    _markdownFuture = _loadMarkdown();
  }

  Future<String> _loadMarkdown() async {
    final String localeID = _getLocaleID();
    final List<String> localeIDs = <String>{
      localeID,
      mpEnglishLocaleID,
    }.toList();

    Object? lastError;

    for (final String id in localeIDs) {
      final String assetPath =
          '$mpHelpPagePath/$id/$mpHelpPageTelemetryConsent.md';

      try {
        final String raw = await rootBundle.loadString(assetPath);

        return raw.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '').trim();
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError ??
        StateError('Unable to load $mpHelpPageTelemetryConsent markdown.');
  }

  String _getLocaleID() {
    final String localIDSetting = mpLocator.mpSettingsController
        .getStringWithDefault(MPSettingID.Main_LocaleID);

    if (localIDSetting != mpDefaultLocaleID) {
      return localIDSetting;
    }

    return WidgetsBinding.instance.platformDispatcher.locale.languageCode;
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
      content: FutureBuilder<String>(
        future: _markdownFuture,
        builder: (BuildContext ctx, AsyncSnapshot<String> snapshot) {
          final Widget bodyWidget;

          if (snapshot.connectionState != ConnectionState.done) {
            bodyWidget = const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            bodyWidget = Text(
              mpLocator.appLocalizations.telemetryConsentDialogBody,
            );
          } else {
            bodyWidget = MarkdownBlock(
              data: snapshot.data ?? '',
              selectable: false,
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              bodyWidget,
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
          );
        },
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
