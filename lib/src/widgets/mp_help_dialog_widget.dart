// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey, rootBundle;
import 'package:http/http.dart' as http;
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:markdown_widget/markdown_widget.dart';

enum MPHelpPageSource { asset, githubRaw }

class MPHelpDialogWidget extends StatelessWidget {
  final String helpPage;
  final String title;
  final VoidCallback onPressedClose;
  final MPHelpPageSource source;

  const MPHelpDialogWidget({
    super.key,
    required this.helpPage,
    required this.title,
    required this.onPressedClose,
    this.source = MPHelpPageSource.asset,
  });

  String _getLocaleID(BuildContext context) {
    final String localIDSetting = mpLocator.mpSettingsController
        .getStringWithDefault(MPSettingID.Main_LocaleID);

    return (localIDSetting == mpDefaultLocaleID)
        ? View.of(context).platformDispatcher.locale.languageCode
        : localIDSetting;
  }

  List<String> _getPreferredLocaleIDs(String localeID) {
    final Set<String> preferredLocaleIDs = <String>{
      localeID,
      mpEnglishLocaleID,
    };

    return preferredLocaleIDs.toList();
  }

  Future<String> _loadMarkdownFromAssets(String localeID) async {
    final List<String> preferredLocaleIDs = _getPreferredLocaleIDs(localeID);
    Object? lastError;

    for (final String preferredLocaleID in preferredLocaleIDs) {
      final String helpPageAssetPath =
          '$mpHelpPagePath/$preferredLocaleID/$helpPage.md';

      try {
        return await rootBundle.loadString(helpPageAssetPath);
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError ?? StateError('Unable to load help page $helpPage.');
  }

  Future<String?> _loadMarkdownFromWeb(String localeID) async {
    final List<String> preferredLocaleIDs = _getPreferredLocaleIDs(localeID);

    for (final String preferredLocaleID in preferredLocaleIDs) {
      final Uri helpPageUri = Uri.parse(
        '$mpMapiahGithubHelpPagesURLPrefix/$preferredLocaleID/$helpPage.md',
      );

      try {
        final http.Response response = await http.get(helpPageUri);

        if (response.statusCode == mpHttpStatusOk) {
          return response.body;
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  Future<String> _loadMarkdown(BuildContext context) async {
    final String localeID = _getLocaleID(context);
    final String raw;

    if (source == MPHelpPageSource.githubRaw) {
      final String? remoteMarkdown = await _loadMarkdownFromWeb(localeID);

      raw = remoteMarkdown ?? await _loadMarkdownFromAssets(localeID);
    } else {
      raw = await _loadMarkdownFromAssets(localeID);
    }

    return raw.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final double maxDialogWidth =
        screenSize.width -
        (mpOverlayWindowOutsidePadding * 2) -
        (mpOverlayWindowPadding * 2);
    final double maxDialogHeight =
        screenSize.height -
        (mpOverlayWindowOutsidePadding * 2) -
        (mpOverlayWindowPadding * 2);
    final double dialogWidth = math.max(280, math.min(maxDialogWidth, 900));

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
                  actions: <Widget>[
                    TextButton(
                      onPressed: onPressedClose,
                      child: Text(mpLocator.appLocalizations.buttonClose),
                    ),
                  ],
                );
              }
              final ThemeData theme = Theme.of(context);

              return SizedBox(
                width: dialogWidth,
                height: maxDialogHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SingleChildScrollView(
                          child: MarkdownBlock(
                            data: snapshot.data ?? '',
                            selectable: false,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Divider(height: 1),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.35),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(
                            mpOverlayWindowCornerRadius,
                          ),
                          bottomRight: Radius.circular(
                            mpOverlayWindowCornerRadius,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: onPressedClose,
                            child: Text(mpLocator.appLocalizations.buttonClose),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
