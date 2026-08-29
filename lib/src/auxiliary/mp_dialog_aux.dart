// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/auxiliary/mp_svg_aux.dart';
import 'package:mapiah/src/auxiliary/mp_url_launcher.dart';
import 'package:mapiah/src/auxiliary/mp_version_check_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/mp_file_read_write/xvi_file_parser.dart';
import 'package:mapiah/src/widgets/mp_help_dialog_widget.dart';
import 'package:mapiah/src/widgets/mp_modal_overlay_widget.dart';
import 'package:mapiah/src/widgets/mp_therion_run_dialog_widget.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class MPDialogAux {
  // Prevent multiple stacked error dialogs
  static bool _isXVIErrorDialogOpen = false;
  static bool _isSVGErrorDialogOpen = false;
  static bool _isUnhandledErrorDialogOpen = false;
  static bool _isUpdateDialogOpen = false;
  static bool _isUpdateCheckRunning = false;

  static final Map<MPFilePickerType, bool> _isFilePickerOpen = {
    for (var type in MPFilePickerType.values) type: false,
  };

  /// Picks an image or XVI file.
  /// Returns:
  ///   - XVIFile (parsed) if an .xvi file was chosen.
  ///   - ui.Image if a raster image (png/jpg/jpeg/webp/gif) was chosen.
  ///   - null if cancelled or error.
  static Future<PickImageFileReturn> pickImageFile(
    BuildContext context, {
    List<String>? allowedExtensions,
  }) async {
    if (_isFilePickerOpen[MPFilePickerType.image] == true) {
      return PickImageFileReturn(type: PickImageFileReturnType.empty);
    }

    _isFilePickerOpen[MPFilePickerType.image] = true;

    allowedExtensions = getMulticaseList(
      (allowedExtensions == null || allowedExtensions.isEmpty)
          ? [
              'gif',
              'jpeg',
              'jpg',
              'png',
              'svg',

              /// PNM and PPM are not supported by dart:ui package.
              // 'pnm',
              // 'ppm',
              'xvi',
            ]
          : allowedExtensions,
    ).toList();

    try {
      final PlatformFile? picked;

      try {
        picked = await FilePicker.pickFile(
          dialogTitle: mpLocator.appLocalizations.th2FilePickSelectImageFile,
          type: FileType.custom,
          allowedExtensions: allowedExtensions,
          linuxOptions: const LinuxOptions(lockParentWindow: true),
          windowsOptions: const WindowsOptions(lockParentWindow: true),
          initialDirectory:
              mpLocator.mpGeneralController.lastAccessedDirectory.isEmpty
              ? (kDebugMode ? thDebugPath : './')
              : mpLocator.mpGeneralController.lastAccessedDirectory,
        );
      } catch (e) {
        mpLocator.mpLog.e(
          'Error picking image/XVI file',
          error: e,
          stackTrace: StackTrace.current,
        );

        return PickImageFileReturn(type: PickImageFileReturnType.empty);
      }

      if (picked == null) {
        mpLocator.mpLog.i('No file selected (image/XVI).');

        return PickImageFileReturn(type: PickImageFileReturnType.empty);
      }

      final String filename = picked.path ?? picked.name;
      final String lowerName = filename.toLowerCase();

      final Uint8List bytes = await picked.readAsBytes();
      final String? pickedPath = picked.path;

      if (pickedPath != null) {
        mpLocator.mpGeneralController.lastAccessedDirectory = p.dirname(
          pickedPath,
        );
      }

      if (lowerName.endsWith('.xvi')) {
        try {
          final XVIFileParser xviParser = XVIFileParser();

          final (xviFile, isSuccessful, errors) = xviParser.parse(
            filename,
            fileBytes: bytes,
          );

          if (!isSuccessful || errors.isNotEmpty || xviFile == null) {
            await showXVIParsingErrorsDialog(context, errors);

            return PickImageFileReturn(type: PickImageFileReturnType.empty);
          }

          return PickImageFileReturn(
            type: PickImageFileReturnType.xviFile,
            xviFile: xviFile,
            filename: filename,
          );
        } catch (e, st) {
          mpLocator.mpLog.e(
            'Failed to parse XVI file',
            error: e,
            stackTrace: st,
          );
          await showXVIParsingErrorsDialog(context, [e.toString()]);

          return PickImageFileReturn(type: PickImageFileReturnType.empty);
        }
      }

      if (lowerName.endsWith(mpSVGExtension)) {
        try {
          final String svgText = utf8.decode(bytes);
          final MPSVGMetadataInfo metadataInfo = MPSVGAux.parseMetadataInfo(
            svgText,
          );
          final MPSVGIntrinsicSizeInfo? intrinsicSizeInfo =
              metadataInfo.hasViewBox || metadataInfo.hasWidthAndHeight
              ? metadataInfo.resolveIntrinsicSizeInfo()
              : await promptSVGImportSize(
                  context: context,
                  metadataInfo: metadataInfo,
                );

          if (intrinsicSizeInfo == null) {
            return PickImageFileReturn(type: PickImageFileReturnType.empty);
          }

          return PickImageFileReturn(
            type: PickImageFileReturnType.svgImage,
            svgIntrinsicSizeInfo: intrinsicSizeInfo,
            filename: filename,
          );
        } catch (e, st) {
          mpLocator.mpLog.e(
            'Failed to parse SVG file',
            error: e,
            stackTrace: st,
          );
          await showSVGImportErrorsDialog(context, <String>[e.toString()]);

          return PickImageFileReturn(type: PickImageFileReturnType.empty);
        }
      }

      Future<ui.Image> decodeImage(Uint8List data) async {
        final ui.Codec codec = await ui.instantiateImageCodec(data);
        final ui.FrameInfo frame = await codec.getNextFrame();

        return frame.image;
      }

      try {
        final ui.Image image = await decodeImage(bytes);

        return PickImageFileReturn(
          type: PickImageFileReturnType.rasterImage,
          image: image,
          filename: filename,
        );
      } catch (e, st) {
        mpLocator.mpLog.e('Failed to decode image', error: e, stackTrace: st);

        return PickImageFileReturn(type: PickImageFileReturnType.empty);
      }
    } catch (e, st) {
      mpLocator.mpLog.e(
        'Error picking image/XVI file',
        error: e,
        stackTrace: st,
      );

      return PickImageFileReturn(type: PickImageFileReturnType.empty);
    } finally {
      _isFilePickerOpen[MPFilePickerType.image] = false;
    }
  }

  static Set<String> getMulticaseList(Iterable<String> items) {
    final Set<String> multicase = {};
    final Set<String> lowerSet = {};

    for (final String item in items) {
      lowerSet.add(item.toLowerCase());
    }
    for (final String item in lowerSet) {
      multicase.add(item);
      multicase.add(item.toUpperCase());
    }

    return multicase;
  }

  static Future<void> showUnhandledErrorDialog(
    Object error,
    StackTrace? stackTrace, {
    BuildContext? context,
  }) async {
    if (_isUnhandledErrorDialogOpen) {
      return;
    }

    _isUnhandledErrorDialogOpen = true;

    final List<String> errorMessages = <String>[
      'Unhandled exception:',
      error.toString(),
    ];

    if (stackTrace != null) {
      final String stack = stackTrace.toString().trimRight();
      if (stack.isNotEmpty) {
        errorMessages.add('');
        errorMessages.add('Stack trace:');
        errorMessages.addAll(stack.split('\n'));
      }
    }

    void showNow() {
      final BuildContext? ctx =
          mpLocator.mpNavigatorKey.currentContext ?? context;
      if (ctx == null) {
        _isUnhandledErrorDialogOpen = false;
        return;
      }

      showDialog<void>(
        context: ctx,
        useRootNavigator: true,
        barrierDismissible: true,
        builder: (ctx2) => MPErrorDialog(
          title: 'Unhandled error',
          errorMessages: errorMessages,
        ),
      ).whenComplete(() {
        _isUnhandledErrorDialogOpen = false;
      });
    }

    final SchedulerPhase phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle) {
      showNow();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => showNow());
    }
  }

  static Future<void> checkForUpdates() async {
    if (_isUpdateCheckRunning) {
      return;
    }

    _isUpdateCheckRunning = true;

    try {
      final SharedPreferencesWithCache prefs =
          mpLocator.mpSettingsController.prefs;
      final int lastNewVersionCheckMS =
          prefs.getInt(MPSettingID.Internal_LastNewVersionCheckMS.name) ?? 0;
      final int lastCheckNumberOfNewerVersions =
          prefs.getInt(
            MPSettingID.Internal_LastCheckNumberOfNewerVersions.name,
          ) ??
          0;
      final DateTime lastNewVersionCheck = DateTime.fromMillisecondsSinceEpoch(
        lastNewVersionCheckMS,
        isUtc: true,
      );
      final DateTime now = DateTime.now().toUtc();
      final Duration timeSinceLastCheck = now.difference(lastNewVersionCheck);
      final bool isDebugVersionOverrideActive =
          mpDebugNewVersionInterfaceCurrentVersion.isNotEmpty;

      if (!isDebugVersionOverrideActive &&
          (timeSinceLastCheck.inSeconds <
              mpSecondsCheckPauseBetweenNewVersionChecks) &&
          (lastCheckNumberOfNewerVersions <=
              mpMaxNumberOfNewerVersionsToRespectCheckPause)) {
        return;
      }

      prefs.setInt(
        MPSettingID.Internal_LastNewVersionCheckMS.name,
        now.millisecondsSinceEpoch,
      );

      final PackageInfo info = await PackageInfo.fromPlatform();
      final String currentVersion = isDebugVersionOverrideActive
          ? mpDebugNewVersionInterfaceCurrentVersion
          : info.version;

      // Fetch the releases summary JSON from the project's raw GitHub
      // content URL and use it as the source of past versions info.
      final List<dynamic>? fetchedSummary =
          await _fetchReleasesSummaryFromWeb();

      if (fetchedSummary == null) {
        _showUpdateCheckFailedDialog(type: MPUpdateCheckFailureType.noAnswer);
        return;
      }

      final List<dynamic> tags = fetchedSummary;

      if (tags.isEmpty) {
        _showUpdateCheckFailedDialog(type: MPUpdateCheckFailureType.parsing);
        return;
      }

      final MPVersionCheckResult? versionCheckResult = summarizeNewerVersions(
        tags: tags,
        currentVersion: currentVersion,
      );

      if ((versionCheckResult == null) ||
          !versionCheckResult.hasStableVersion) {
        return;
      }

      final int newerVersionCount = versionCheckResult.newerVersionCount;

      prefs.setInt(
        MPSettingID.Internal_LastCheckNumberOfNewerVersions.name,
        newerVersionCount,
      );

      if (!mpDebugAlwaysShowVersions && !versionCheckResult.hasNewerVersion) {
        return;
      }

      final String latestVersion = versionCheckResult.latestStableVersion!;
      final String tagName = versionCheckResult.latestStableTagName!;
      final String releaseUrl = '$mpMapiahGithubReleasesURL$tagName';
      final MPInstalledVersionAgeInfo? installedVersionAgeInfo =
          await _getInstalledVersionAgeInfoFromSummary(
            summary: tags,
            currentVersion: currentVersion,
            latestStableTagName: tagName,
          );

      if (mpIsFlathub) {
        _showFlathubUpdateDialog(
          latestVersion: latestVersion,
          currentVersion: currentVersion,
          tagName: tagName,
          releaseUrl: releaseUrl,
          newerVersionCount: newerVersionCount,
          commitsBehind: installedVersionAgeInfo?.commitsBehind,
          daysOld: installedVersionAgeInfo?.daysOld,
        );
        return;
      }

      _showUpdateDialog(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        tagName: tagName,
        releaseUrl: releaseUrl,
        newerVersionCount: newerVersionCount,
        commitsBehind: installedVersionAgeInfo?.commitsBehind,
        daysOld: installedVersionAgeInfo?.daysOld,
      );
    } catch (e, st) {
      mpLocator.mpLog.e('Update check failed', error: e, stackTrace: st);
      _showUpdateCheckFailedDialog(type: MPUpdateCheckFailureType.noAnswer);
    } finally {
      _isUpdateCheckRunning = false;
    }
  }

  static void _showUpdateDialog({
    required String latestVersion,
    required String currentVersion,
    required String tagName,
    required String releaseUrl,
    required int newerVersionCount,
    int? commitsBehind,
    int? daysOld,
  }) {
    if (_isUpdateDialogOpen) {
      return;
    }

    _isUpdateDialogOpen = true;

    final BuildContext? ctx = mpLocator.mpNavigatorKey.currentContext;

    if (ctx == null) {
      _isUpdateDialogOpen = false;

      return;
    }

    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final String dialogTitle = (newerVersionCount > 0)
        ? appLocalizations.updateAvailableTitleWithCount(newerVersionCount)
        : appLocalizations.updateAvailableTitle;
    final String updateBody = appLocalizations.updateAvailableBody(
      currentVersion,
      latestVersion,
      tagName,
      releaseUrl,
    );
    final String versionAgeText = ((commitsBehind != null) && (daysOld != null))
        ? appLocalizations.updateAvailableInstalledVersionAge(
            commitsBehind,
            daysOld,
          )
        : mpEmptyString;
    final String updateBodyWithVersionAge = versionAgeText.isEmpty
        ? updateBody
        : '$updateBody\n\n$versionAgeText';

    showDialog<void>(
      context: ctx,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (ctx2) => AlertDialog(
        title: Text(dialogTitle),
        content: SingleChildScrollView(
          child: _commonUpdateContent(
            ctx2,
            updateBodyWithVersionAge,
            releaseUrl,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx2, rootNavigator: true).pop(),
            child: Text(appLocalizations.buttonClose),
          ),
        ],
      ),
    ).whenComplete(() {
      _isUpdateDialogOpen = false;
    });
  }

  static void _showFlathubUpdateDialog({
    required String latestVersion,
    required String currentVersion,
    required String tagName,
    required String releaseUrl,
    required int newerVersionCount,
    int? commitsBehind,
    int? daysOld,
  }) {
    if (_isUpdateDialogOpen) {
      return;
    }

    _isUpdateDialogOpen = true;

    final BuildContext? ctx = mpLocator.mpNavigatorKey.currentContext;

    if (ctx == null) {
      _isUpdateDialogOpen = false;
      return;
    }

    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final String dialogTitle = (newerVersionCount > 0)
        ? appLocalizations.updateAvailableTitleWithCount(newerVersionCount)
        : appLocalizations.updateAvailableTitle;

    Future<String> loadFlathubMarkdown(BuildContext ctx2) async {
      final String localIDSetting = mpLocator.mpSettingsController
          .getStringWithDefault(MPSettingID.Main_LocaleID);

      final String localeID = (localIDSetting == mpDefaultLocaleID)
          ? View.of(ctx2).platformDispatcher.locale.languageCode
          : localIDSetting;

      final List<String> preferredLocaleIDs = <String>[
        localeID,
        mpEnglishLocaleID,
      ];

      // Try fetching the markdown from the project's GitHub raw URL so the
      // latest version is presented to the user. If the network fetch fails
      // we bubble the error to the caller which will simply omit the help
      // block in the dialog.
      Object? lastError;

      for (final String preferredLocaleID in preferredLocaleIDs) {
        final Uri helpPageUrl = Uri.parse(
          'https://raw.githubusercontent.com/rsevero/mapiah/main/assets/help/$preferredLocaleID/$mpHelpPageFlathubDisabled.md',
        );

        try {
          final Map<String, String> headers = <String, String>{
            mpHttpHeaderAcceptEncoding: mpHttpHeaderAcceptEncodingGzip,
          };

          final http.Response resp = await http
              .get(helpPageUrl, headers: headers)
              .timeout(const Duration(seconds: 10));

          if ((resp.statusCode == 200) && resp.body.isNotEmpty) {
            return resp.body;
          }

          lastError = StateError('HTTP ${resp.statusCode}');
        } catch (error) {
          lastError = error;
        }
      }

      throw lastError ?? StateError('Unable to load Flathub help page.');
    }

    final String updateBody = mpLocator.appLocalizations.updateAvailableBody(
      currentVersion,
      latestVersion,
      tagName,
      releaseUrl,
    );
    final String versionAgeText = ((commitsBehind != null) && (daysOld != null))
        ? mpLocator.appLocalizations.updateAvailableInstalledVersionAge(
            commitsBehind,
            daysOld,
          )
        : mpEmptyString;
    final String updateBodyWithVersionAge = versionAgeText.isEmpty
        ? updateBody
        : '$updateBody\n\n$versionAgeText';

    showDialog<void>(
      context: ctx,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (BuildContext ctx2) => FutureBuilder<String>(
        future: loadFlathubMarkdown(ctx2),
        builder: (BuildContext buildCtx, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AlertDialog(
              title: Text(dialogTitle),
              content: const Center(child: CircularProgressIndicator()),
              actions: <Widget>[
                TextButton(
                  onPressed: () =>
                      Navigator.of(buildCtx, rootNavigator: true).pop(),
                  child: Text(appLocalizations.buttonClose),
                ),
              ],
            );
          }

          final String flathubMarkdown = snapshot.hasData ? snapshot.data! : '';

          return AlertDialog(
            title: Text(dialogTitle),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _commonUpdateContent(
                    buildCtx,
                    updateBodyWithVersionAge,
                    releaseUrl,
                  ),
                  if (flathubMarkdown.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    MarkdownBlock(data: flathubMarkdown, selectable: false),
                  ],
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx2, rootNavigator: true).pop(),
                child: Text(appLocalizations.buttonClose),
              ),
            ],
          );
        },
      ),
    ).whenComplete(() {
      _isUpdateDialogOpen = false;
    });
  }

  static Widget _commonUpdateContent(
    BuildContext ctx2,
    String updateBodyWithVersionAge,
    String releaseUrl,
  ) {
    final int urlIndex = updateBodyWithVersionAge.indexOf(releaseUrl);
    final String beforeUrl = urlIndex >= 0
        ? updateBodyWithVersionAge.substring(0, urlIndex)
        : updateBodyWithVersionAge;
    final String afterUrl = urlIndex >= 0
        ? updateBodyWithVersionAge.substring(urlIndex + releaseUrl.length)
        : '';

    return SelectableText.rich(
      TextSpan(
        style: Theme.of(ctx2).textTheme.bodyLarge,
        children: <TextSpan>[
          TextSpan(text: beforeUrl),
          if (urlIndex >= 0)
            TextSpan(
              text: releaseUrl,
              style: TextStyle(
                color: Theme.of(ctx2).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  MPUrlLauncher.openUrl(Uri.parse(releaseUrl));
                },
            ),
          TextSpan(text: afterUrl),
        ],
      ),
    );
  }

  static Future<List<dynamic>?> _fetchReleasesSummaryFromWeb() async {
    final Uri rawUrl = Uri.parse(mpMapiahReleasesSummaryRawURL);
    final Map<String, String> headers = <String, String>{
      mpHttpHeaderAcceptEncoding: mpHttpHeaderAcceptEncodingGzip,
    };

    try {
      final http.Response response = await http
          .get(rawUrl, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != mpHttpStatusOk) {
        _showUpdateCheckFailedDialog(
          type: MPUpdateCheckFailureType.httpStatus,
          httpStatusCode: response.statusCode,
        );

        return null;
      }

      final dynamic responseBody = jsonDecode(response.body);

      if (responseBody is! List<dynamic>) {
        return null;
      }

      return responseBody;
    } catch (_) {
      return null;
    }
  }

  static Future<MPInstalledVersionAgeInfo?>
  _getInstalledVersionAgeInfoFromSummary({
    required List<dynamic> summary,
    required String currentVersion,
    required String latestStableTagName,
  }) async {
    // The summary is expected to be an ordered list (newest first) of
    // objects with fields: `name` (tag), `datetime` (ISO8601) and `commits`
    // (number of commits since previous release). Compute commits behind
    // by summing `commits` for releases newer than the installed one,
    // and compute days old by subtracting datetimes.

    int? installedIndex;
    int? latestIndex;

    for (int i = 0; i < summary.length; i += 1) {
      final dynamic item = summary[i];
      if (item is! Map<Object?, Object?>) {
        continue;
      }

      final Object? rawName = item['name'];
      final String name = rawName?.toString().trim() ?? '';

      if (name.isEmpty) {
        continue;
      }

      if (name == latestStableTagName) {
        latestIndex = i;
      }

      if (name == currentVersion || ('v$currentVersion' == name)) {
        installedIndex = i;
      }

      if ((installedIndex != null) && (latestIndex != null)) {
        break;
      }
    }

    if ((installedIndex == null) || (latestIndex == null)) {
      return null;
    }

    // If installed is newer or equal to latest, no behind commits.
    if (installedIndex <= latestIndex) {
      return MPInstalledVersionAgeInfo(commitsBehind: 0, daysOld: 0);
    }

    int commitsBehind = 0;
    DateTime? installedDate;
    DateTime? latestDate;

    for (int i = 0; i < summary.length; i += 1) {
      final dynamic item = summary[i];
      if (item is! Map<Object?, Object?>) {
        continue;
      }

      final Object? rawName = item['name'];
      final String name = rawName?.toString().trim() ?? '';

      final Object? rawDatetime = item['datetime'];
      final String datetimeStr = rawDatetime?.toString().trim() ?? '';

      final DateTime? parsedDate = DateTime.tryParse(datetimeStr)?.toUtc();

      if (name == latestStableTagName) {
        latestDate = parsedDate;
      }

      if (name == currentVersion || ('v$currentVersion' == name)) {
        installedDate = parsedDate;
      }

      // Entries with index < installedIndex are newer than installed.
      if (i < installedIndex) {
        final Object? rawCommits = item['commits'];
        final int parsedCommits =
            int.tryParse(rawCommits?.toString() ?? '') ?? 0;
        commitsBehind += parsedCommits;
      }
    }

    if ((installedDate == null) || (latestDate == null)) {
      return null;
    }

    final int daysOld = latestDate.difference(installedDate).inDays;

    return MPInstalledVersionAgeInfo(
      commitsBehind: commitsBehind < 0 ? 0 : commitsBehind,
      daysOld: daysOld < 0 ? 0 : daysOld,
    );
  }

  static void _showUpdateCheckFailedDialog({
    required MPUpdateCheckFailureType type,
    String? tagName,
    int? httpStatusCode,
  }) {
    if (_isUpdateDialogOpen) {
      return;
    }

    _isUpdateDialogOpen = true;

    final BuildContext? ctx = mpLocator.mpNavigatorKey.currentContext;

    if (ctx == null) {
      _isUpdateDialogOpen = false;
      return;
    }

    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final String body = switch (type) {
      MPUpdateCheckFailureType.noAnswer =>
        appLocalizations.updateCheckFailedNoAnswerBody,
      MPUpdateCheckFailureType.httpStatus =>
        appLocalizations.updateCheckFailedHttpStatusBody(httpStatusCode ?? 0),
      MPUpdateCheckFailureType.parsing =>
        (tagName == null)
            ? appLocalizations.updateCheckFailedParsingBody
            : appLocalizations.updateCheckFailedParsingWithTagBody(tagName),
    };

    showDialog<void>(
      context: ctx,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (ctx2) => MPErrorDialog(
        title: appLocalizations.updateCheckFailedTitle,
        errorMessages: <String>[body],
      ),
    ).whenComplete(() {
      _isUpdateDialogOpen = false;
    });
  }

  static Future<void> showXVIParsingErrorsDialog(
    BuildContext context,
    List<String> errors,
  ) async {
    if (errors.isEmpty) {
      return;
    }
    // If one is already open, don’t open another (avoids double-tap to dismiss)
    if (_isXVIErrorDialogOpen) {
      return;
    }
    _isXVIErrorDialogOpen = true;

    final Completer<void> completer = Completer<void>();

    void showNow() {
      final BuildContext ctx =
          mpLocator.mpNavigatorKey.currentContext ?? context;

      showDialog<void>(
        context: ctx,
        useRootNavigator: true, // ensure a single, top-level dialog
        barrierDismissible: true, // allow outside tap to dismiss if desired
        builder: (ctx2) => AlertDialog(
          title: Text(mpLocator.appLocalizations.mpErrorReadingXVIFile),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: errors
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $e',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx2, rootNavigator: true).pop(),
              child: Text(mpLocator.appLocalizations.mpButtonOK),
            ),
          ],
        ),
      ).whenComplete(() {
        _isXVIErrorDialogOpen = false; // clear guard
        if (!completer.isCompleted) completer.complete();
      });
    }

    final SchedulerPhase phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle) {
      showNow();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => showNow());
    }

    return completer.future;
  }

  static Future<void> showSVGImportErrorsDialog(
    BuildContext context,
    List<String> errors,
  ) async {
    if (errors.isEmpty) {
      return;
    }

    if (_isSVGErrorDialogOpen) {
      return;
    }

    _isSVGErrorDialogOpen = true;

    final Completer<void> completer = Completer<void>();

    void showNow() {
      final BuildContext ctx =
          mpLocator.mpNavigatorKey.currentContext ?? context;

      showDialog<void>(
        context: ctx,
        useRootNavigator: true,
        barrierDismissible: true,
        builder: (ctx2) => MPErrorDialog(
          title: mpLocator.appLocalizations.th2FilePickSVGImportErrorTitle,
          errorMessages: errors,
        ),
      ).whenComplete(() {
        _isSVGErrorDialogOpen = false;
        if (!completer.isCompleted) {
          completer.complete();
        }
      });
    }

    final SchedulerPhase phase = SchedulerBinding.instance.schedulerPhase;

    if (phase == SchedulerPhase.idle) {
      showNow();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => showNow());
    }

    return completer.future;
  }

  static Future<MPSVGIntrinsicSizeInfo?> promptSVGImportSize({
    required BuildContext context,
    required MPSVGMetadataInfo metadataInfo,
  }) async {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final TextEditingController widthController = TextEditingController(
      text: metadataInfo.width?.toString() ?? '',
    );
    final FocusNode widthFocusNode = FocusNode();
    final TextEditingController heightController = TextEditingController(
      text: metadataInfo.height?.toString() ?? '',
    );
    final String missingInfo = _describeMissingSVGMetadata(
      metadataInfo: metadataInfo,
      appLocalizations: appLocalizations,
    );

    MPSVGIntrinsicSizeInfo? result;
    String? widthError;
    String? heightError;

    await showDialog<void>(
      context: mpLocator.mpNavigatorKey.currentContext ?? context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widthFocusNode.canRequestFocus) {
            widthFocusNode.requestFocus();
          }
        });

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(appLocalizations.th2FilePickSVGImportErrorTitle),
              content: SizedBox(
                width: 420.0,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(appLocalizations.th2FilePickSVGMissingMetadataBody),
                      const SizedBox(height: 8.0),
                      Text(
                        '${appLocalizations.th2FilePickSVGMissingMetadataLabel}: $missingInfo',
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: widthController,
                        focusNode: widthFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        decoration: InputDecoration(
                          labelText: appLocalizations.th2FilePickSVGWidthLabel,
                          errorText: widthError,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      TextField(
                        controller: heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        decoration: InputDecoration(
                          labelText: appLocalizations.th2FilePickSVGHeightLabel,
                          errorText: heightError,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                  },
                  child: Text(appLocalizations.mpButtonCancel),
                ),
                TextButton(
                  onPressed: () {
                    final double? parsedWidth = double.tryParse(
                      widthController.text.trim(),
                    );
                    final double? parsedHeight = double.tryParse(
                      heightController.text.trim(),
                    );
                    final bool isWidthValid =
                        (parsedWidth != null) && (parsedWidth > 0.0);
                    final bool isHeightValid =
                        (parsedHeight != null) && (parsedHeight > 0.0);

                    if (!isWidthValid || !isHeightValid) {
                      setState(() {
                        widthError = isWidthValid
                            ? null
                            : appLocalizations
                                  .th2FilePickSVGInvalidDimensionError;
                        heightError = isHeightValid
                            ? null
                            : appLocalizations
                                  .th2FilePickSVGInvalidDimensionError;
                      });

                      return;
                    }

                    result = metadataInfo.resolveIntrinsicSizeInfo(
                      fallbackWidth: parsedWidth,
                      fallbackHeight: parsedHeight,
                    );

                    Navigator.of(dialogContext, rootNavigator: true).pop();
                  },
                  child: Text(appLocalizations.mpButtonOK),
                ),
              ],
            );
          },
        );
      },
    );

    widthController.dispose();
    widthFocusNode.dispose();
    heightController.dispose();

    return result;
  }

  static String _describeMissingSVGMetadata({
    required MPSVGMetadataInfo metadataInfo,
    required AppLocalizations appLocalizations,
  }) {
    final List<String> missingItems = <String>[];

    if (!metadataInfo.hasViewBox) {
      missingItems.add(appLocalizations.th2FilePickSVGViewBoxLabel);
    }

    if (!metadataInfo.hasWidthAndHeight) {
      missingItems.add(appLocalizations.th2FilePickSVGWidthHeightLabel);
    }

    return missingItems.join(', ');
  }

  /// Picks the Therion project configuration file and opens it in the
  /// project tree without touching the tab lifecycle.
  ///
  /// The selected file is always treated as a `thconfig` file, regardless of
  /// its extension or whether it has one. TH2FileTabsPage (which hosts the
  /// project tree) is always the app's root route, so no navigation is
  /// needed after the project loads.
  static Future<void> pickProjectFile(BuildContext context) async {
    final PlatformFile? picked = await _pickProjectFilePath();

    if (picked == null) {
      return;
    }

    final String? pickedFilePath = picked.path;

    if (pickedFilePath == null) {
      return;
    }

    await mpLocator.thProjectController.openProject(
      pickedFilePath,
      forceConfigShape: true,
    );
  }

  static Future<PlatformFile?> _pickProjectFilePath() async {
    if (_isFilePickerOpen[MPFilePickerType.project] == true) {
      return null;
    }

    _isFilePickerOpen[MPFilePickerType.project] = true;

    try {
      final PlatformFile? picked = await FilePicker.pickFile(
        dialogTitle:
            mpLocator.appLocalizations.projectTreeSelectProjectDialogTitle,
        type: FileType.any,
        linuxOptions: const LinuxOptions(lockParentWindow: true),
        windowsOptions: const WindowsOptions(lockParentWindow: true),
        initialDirectory:
            mpLocator.mpGeneralController.lastAccessedDirectory.isEmpty
            ? (kDebugMode ? thDebugPath : './')
            : mpLocator.mpGeneralController.lastAccessedDirectory,
      );

      if (picked == null) {
        mpLocator.mpLog.i('No project file selected.');

        return null;
      }

      final String? pickedFilePath = picked.path;

      if (pickedFilePath == null) {
        return null;
      }

      mpLocator.mpGeneralController.lastAccessedDirectory = p.dirname(
        pickedFilePath,
      );

      return picked;
    } catch (e) {
      mpLocator.mpLog.e('Error picking project file', error: e);

      return null;
    } finally {
      _isFilePickerOpen[MPFilePickerType.project] = false;
    }
  }

  static Future<void> runTherion(
    BuildContext context, {
    required String thConfigFilePath,
  }) async {
    final String trimmedPath = thConfigFilePath.trim();

    if (trimmedPath.isEmpty) {
      return;
    }

    final String configuredExecutablePath = mpLocator.mpSettingsController
        .getStringWithDefault(MPSettingID.Therion_ExecutablePath)
        .trim();

    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return MPRunTherionDialogWidget(
          therionExecutablePath: configuredExecutablePath,
          thConfigFilePath: trimmedPath,
        );
      },
    );
  }

  /// Picks a project file, then immediately starts a Therion run against it
  /// while loading it as the open project in the background (see
  /// [runTherionAndOpenProjectInBackground]).
  static Future<void> pickProjectFileAndRunTherion(
    BuildContext context, {
    MPProjectFilePicker? pickFile,
    MPProjectLauncher? launch,
  }) async {
    if (!mpLocator.mpSettingsController.isTherionAvailable) {
      MPDialogAux.showHelpDialog(
        context,
        'no_therion_found',
        mpLocator.appLocalizations.mpNoTherionFound,
      );

      return;
    }

    final MPProjectLauncher launchProjectAndRun =
        launch ?? runTherionAndOpenProjectInBackground;
    final PlatformFile? picked = await (pickFile ?? _pickProjectFilePath)();

    if (picked == null) {
      return;
    }

    final String? pickedFilePath = picked.path;

    if (pickedFilePath == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    await launchProjectAndRun(context, pickedFilePath);
  }

  /// Closes whichever project is currently loaded
  /// (`THProjectController.rootConfigPath`). No-ops if no project is open.
  /// Closes every open tab (canvas or text-editor) that belongs to the
  /// project first, since `THProjectController.closeProject` clears the
  /// node/dependency indexes those tabs' controllers rely on (e.g. saving a
  /// still-open `thconfig`/`.th` text-editor tab would otherwise silently
  /// no-op once its project node lookup fails). `.th2`/text tabs opened
  /// standalone, unrelated to this project, are left untouched.
  static void closeOpenProject(BuildContext context) {
    final THProjectController projectController =
        mpLocator.thProjectController;

    if (projectController.rootConfigPath.isEmpty) {
      return;
    }

    final MPGeneralController generalController =
        mpLocator.mpGeneralController;

    for (final String filename in List<String>.of(
      generalController.openFileOrder,
    )) {
      if (projectController.nodeByCanonicalPath(filename) == null) {
        continue;
      }

      if (isTH2Tab(filename)) {
        generalController.getTH2FileEditControllerIfExists(filename)?.close();
      } else {
        generalController.getTextEditorControllerIfExists(filename)?.close();
      }
    }

    projectController.closeProject();
  }

  /// Runs Therion against whichever project is currently loaded
  /// (`THProjectController.rootConfigPath`), replacing the old
  /// "run with last picked thconfig" flow — the project tree's own state is
  /// now the single source of truth for what "Rerun Therion" targets.
  static Future<void> rerunTherionForOpenProject(BuildContext context) async {
    final String rootConfigPath = mpLocator.thProjectController.rootConfigPath;

    if (rootConfigPath.isEmpty) {
      return;
    }

    if (mpLocator.mpSettingsController.isTherionAvailable) {
      await runTherion(context, thConfigFilePath: rootConfigPath);
    } else {
      MPDialogAux.showHelpDialog(
        context,
        'no_therion_found',
        mpLocator.appLocalizations.mpNoTherionFound,
      );
    }
  }

  /// Starts a Therion run against [thConfigFilePath] immediately, without
  /// waiting for [thConfigFilePath] to also finish loading as the open
  /// project — the project load is kicked off in the background so the
  /// project tree populates concurrently with the compile. Shared by the
  /// "open project and run Therion" picker flow and CLI startup
  /// (`--thconfig`/positional argument).
  static Future<void> runTherionAndOpenProjectInBackground(
    BuildContext context,
    String thConfigFilePath, {
    MPProjectLoader? projectLoader,
    MPRunTherionStarter? runTherionStarter,
  }) {
    final MPProjectLoader loadProject =
        projectLoader ?? mpLocator.thProjectController.openProject;
    final MPRunTherionStarter startRun = runTherionStarter ?? runTherion;

    // Load the project in the background regardless of Therion availability
    // (and without waiting for a run that did start to finish), so "Rerun
    // Therion" becomes enabled the moment the project loads even if Therion
    // itself isn't available yet. TH2FileTabsPage (which hosts the project
    // tree) is always the app's root route, so no navigation is needed once
    // the load completes.
    unawaited(loadProject(thConfigFilePath, forceConfigShape: true));

    if (mpLocator.mpSettingsController.isTherionAvailable) {
      return startRun(context, thConfigFilePath: thConfigFilePath);
    }

    MPDialogAux.showHelpDialog(
      context,
      'no_therion_found',
      mpLocator.appLocalizations.mpNoTherionFound,
    );

    return Future<void>.value();
  }

  static Future<String?> pickExecutableFilePath(
    BuildContext context, {
    required String dialogTitle,
  }) async {
    if (_isFilePickerOpen[MPFilePickerType.executable] == true) {
      return null;
    }

    _isFilePickerOpen[MPFilePickerType.executable] = true;

    try {
      final PlatformFile? picked = await FilePicker.pickFile(
        dialogTitle: dialogTitle,
        type: FileType.any,
        linuxOptions: const LinuxOptions(lockParentWindow: true),
        windowsOptions: const WindowsOptions(lockParentWindow: true),
        initialDirectory:
            mpLocator.mpGeneralController.lastAccessedDirectory.isEmpty
            ? (kDebugMode ? thDebugPath : './')
            : mpLocator.mpGeneralController.lastAccessedDirectory,
      );

      if (picked == null) {
        mpLocator.mpLog.i('No executable selected.');

        return null;
      }

      final String? pickedFilePath = picked.path;

      if (pickedFilePath == null) {
        return null;
      }

      mpLocator.mpGeneralController.lastAccessedDirectory = p.dirname(
        pickedFilePath,
      );

      return pickedFilePath;
    } catch (e) {
      mpLocator.mpLog.e('Error picking executable file', error: e);

      return null;
    } finally {
      _isFilePickerOpen[MPFilePickerType.executable] = false;
    }
  }

  static void showHelpDialog(
    BuildContext context,
    String helpPage,
    String title, {
    MPHelpPageSource source = MPHelpPageSource.asset,
    VoidCallback? onDismissed,
  }) {
    MPModalOverlayWidget.show(
      context: context,
      onDismissed: onDismissed,
      childBuilder: (onPressedClose) => MPHelpDialogWidget(
        helpPage: helpPage,
        title: title,
        onPressedClose: onPressedClose,
        source: source,
      ),
    );
  }
}

enum MPFilePickerType { image, th2, executable, project }

typedef MPProjectFilePicker = Future<PlatformFile?> Function();

typedef MPProjectLauncher =
    Future<void> Function(BuildContext context, String thConfigFilePath);

typedef MPProjectLoader =
    Future<void> Function(String configFilePath, {bool forceConfigShape});

typedef MPRunTherionStarter =
    Future<void> Function(
      BuildContext context, {
      required String thConfigFilePath,
    });

enum MPUpdateCheckFailureType { httpStatus, noAnswer, parsing }

enum PickImageFileReturnType { empty, rasterImage, svgImage, xviFile }

class PickImageFileReturn {
  final PickImageFileReturnType type;
  final ui.Image? image;
  final MPSVGIntrinsicSizeInfo? svgIntrinsicSizeInfo;
  final XVIFile? xviFile;
  final String? filename;

  PickImageFileReturn({
    required this.type,
    this.image,
    this.svgIntrinsicSizeInfo,
    this.xviFile,
    this.filename,
  });
}
