// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey, rootBundle;
import 'package:http/http.dart' as http;
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_url_launcher.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/widgets/mp_dialog_bottom_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return _MPHelpDialogBody(
      helpPage: helpPage,
      title: title,
      onPressedClose: onPressedClose,
      source: source,
    );
  }
}

class _MPHelpDialogLoadResult {
  final String markdown;
  final Map<String, int> headingAnchorToIndex;

  const _MPHelpDialogLoadResult({
    required this.markdown,
    required this.headingAnchorToIndex,
  });
}

class _MPHelpDialogBody extends StatefulWidget {
  final String helpPage;
  final String title;
  final VoidCallback onPressedClose;
  final MPHelpPageSource source;

  const _MPHelpDialogBody({
    required this.helpPage,
    required this.title,
    required this.onPressedClose,
    required this.source,
  });

  @override
  State<_MPHelpDialogBody> createState() => _MPHelpDialogBodyState();
}

class _MPHelpDialogBodyState extends State<_MPHelpDialogBody> {
  final TocController _tocController = TocController();

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
          '$mpHelpPagePath/$preferredLocaleID/${widget.helpPage}.md';

      try {
        return await rootBundle.loadString(helpPageAssetPath);
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError ??
        StateError('Unable to load help page ${widget.helpPage}.');
  }

  Future<String?> _loadMarkdownFromWeb(String localeID) async {
    final List<String> preferredLocaleIDs = _getPreferredLocaleIDs(localeID);

    for (final String preferredLocaleID in preferredLocaleIDs) {
      final Uri helpPageUri = Uri.parse(
        '$mpMapiahGithubHelpPagesURLPrefix/$preferredLocaleID/${widget.helpPage}.md',
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

  Future<_MPHelpDialogLoadResult> _loadMarkdown(BuildContext context) async {
    final String localeID = _getLocaleID(context);
    final String raw;

    if (widget.source == MPHelpPageSource.githubRaw) {
      final String? remoteMarkdown = await _loadMarkdownFromWeb(localeID);

      raw = remoteMarkdown ?? await _loadMarkdownFromAssets(localeID);
    } else {
      raw = await _loadMarkdownFromAssets(localeID);
    }

    final String markdown = raw
        .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '')
        .trim();

    return _MPHelpDialogLoadResult(
      markdown: markdown,
      headingAnchorToIndex: mpBuildHelpHeadingAnchorToIndexMap(markdown),
    );
  }

  @override
  void dispose() {
    _tocController.dispose();
    super.dispose();
  }

  Future<void> _handleLinkTap(
    String url,
    Map<String, int> headingAnchorToIndex,
  ) async {
    final String trimmedUrl = url.trim();

    if (trimmedUrl.isEmpty) {
      return;
    }

    final Uri? uri = Uri.tryParse(trimmedUrl);
    final String fragment = (uri?.fragment ?? '').trim();
    final bool isInternalFragment = trimmedUrl.startsWith('#');

    if (isInternalFragment && fragment.isNotEmpty) {
      final String normalizedFragment = Uri.decodeComponent(
        fragment,
      ).toLowerCase();
      final int? headingIndex = headingAnchorToIndex[normalizedFragment];

      if ((headingIndex != null) &&
          (_tocController.tocList.length > headingIndex)) {
        _tocController.jumpToIndex(
          _tocController.tocList[headingIndex].widgetIndex,
        );
      }

      return;
    }

    if (uri != null) {
      await MPUrlLauncher.openUrl(uri);
    }
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
              widget.onPressedClose();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: FutureBuilder<_MPHelpDialogLoadResult>(
            future: _loadMarkdown(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return AlertDialog(
                  title: Text(widget.title),
                  content: Text(
                    mpLocator.appLocalizations.helpDialogFailureToLoad,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: widget.onPressedClose,
                      child: Text(mpLocator.appLocalizations.buttonClose),
                    ),
                  ],
                );
              }

              final _MPHelpDialogLoadResult loadResult = snapshot.data!;

              return SizedBox(
                width: dialogWidth,
                height: maxDialogHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: MarkdownWidget(
                          data: loadResult.markdown,
                          selectable: false,
                          tocController: _tocController,
                          config: MarkdownConfig(
                            configs: <WidgetConfig>[
                              LinkConfig(
                                onTap: (String url) {
                                  _handleLinkTap(
                                    url,
                                    loadResult.headingAnchorToIndex,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    MPDialogBottomWidget(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: widget.onPressedClose,
                          child: Text(mpLocator.appLocalizations.buttonClose),
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

@visibleForTesting
Map<String, int> mpBuildHelpHeadingAnchorToIndexMap(String markdown) {
  final Map<String, int> headingAnchorToIndex = <String, int>{};
  final Map<String, int> slugCounts = <String, int>{};
  final List<String> lines = markdown.split('\n');
  int headingIndex = 0;

  for (final String line in lines) {
    final RegExpMatch? match = RegExp(
      r'^\s{0,3}#{1,6}\s+(.+?)\s*$',
    ).firstMatch(line);

    if (match == null) {
      continue;
    }

    final String headingText = mpStripMarkdownFormattingFromHeading(
      match.group(1)!,
    );
    final String baseSlug = mpSlugifyHelpHeading(headingText);

    if (baseSlug.isEmpty) {
      continue;
    }

    final int duplicateCount = slugCounts[baseSlug] ?? 0;
    slugCounts[baseSlug] = duplicateCount + 1;

    final String fullSlug = (duplicateCount == 0)
        ? baseSlug
        : '$baseSlug-$duplicateCount';

    headingAnchorToIndex[fullSlug] = headingIndex;
    headingIndex++;
  }

  return headingAnchorToIndex;
}

@visibleForTesting
String mpStripMarkdownFormattingFromHeading(String text) {
  String stripped = text.trim();

  stripped = stripped.replaceAll(RegExp(r'\s+#+\s*$'), '');
  stripped = stripped.replaceAllMapped(
    RegExp(r'!\[([^\]]*)\]\([^)]+\)'),
    (Match match) => match.group(1) ?? '',
  );
  stripped = stripped.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\([^)]+\)'),
    (Match match) => match.group(1) ?? '',
  );
  stripped = stripped.replaceAll(RegExp(r'[`*_~]'), '');

  return stripped.trim();
}

@visibleForTesting
String mpSlugifyHelpHeading(String text) {
  final String lowerCased = text.toLowerCase();
  final String withoutPunctuation = lowerCased.replaceAll(
    RegExp(r'[^\p{L}\p{N}\s-]', unicode: true),
    '',
  );
  final String normalizedWhitespace = withoutPunctuation.replaceAll(
    RegExp(r'\s+'),
    '-',
  );

  return normalizedWhitespace
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
