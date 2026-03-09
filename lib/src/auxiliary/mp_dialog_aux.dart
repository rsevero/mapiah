import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/auxiliary/mp_url_launcher.dart';
import 'package:mapiah/src/auxiliary/mp_version_check_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/mp_file_read_write/xvi_file_parser.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:mapiah/src/widgets/mp_add_file_dialog_widget.dart';
import 'package:mapiah/src/widgets/mp_help_dialog_widget.dart';
import 'package:mapiah/src/widgets/mp_modal_overlay_widget.dart';
import 'package:mapiah/src/widgets/mp_run_therion_dialog_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class MPDialogAux {
  // Prevent multiple stacked error dialogs
  static bool _isXVIErrorDialogOpen = false;
  static bool _isUnhandledErrorDialogOpen = false;
  static bool _isUpdateDialogOpen = false;
  static bool _isUpdateCheckRunning = false;

  static final Map<MPFilePickerType, bool> _isFilePickerOpen = {
    for (var type in MPFilePickerType.values) type: false,
  };

  static void newFile(BuildContext context) async {
    MPModalOverlayWidget.show(
      context: context,
      childBuilder: (onPressedClose) =>
          MPAddFileDialogWidget(onPressedClose: onPressedClose),
    );
  }

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

              /// PNM and PPM are not supported by dart:ui package.
              // 'pnm',
              // 'ppm',
              'xvi',
            ]
          : allowedExtensions,
    ).toList();

    try {
      final FilePickerResult? result;

      try {
        result = await FilePicker.platform.pickFiles(
          dialogTitle: mpLocator.appLocalizations.th2FilePickSelectImageFile,
          type: FileType.custom,
          allowedExtensions: allowedExtensions,
          lockParentWindow: true,
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

      if (result == null) {
        mpLocator.mpLog.i('No file selected (image/XVI).');

        return PickImageFileReturn(type: PickImageFileReturnType.empty);
      }

      final PlatformFile picked = result.files.single;
      final String filename = picked.path ?? picked.name;
      final String lowerName = filename.toLowerCase();

      Uint8List? bytes = picked.bytes;
      String? pickedPath = picked.path;

      if ((bytes == null) && (pickedPath != null)) {
        bytes = await File(pickedPath).readAsBytes();
      }

      if (pickedPath != null) {
        mpLocator.mpGeneralController.lastAccessedDirectory = p.dirname(
          pickedPath,
        );
      }

      if (bytes == null) {
        mpLocator.mpLog.e('Picked file has no bytes available.');

        return PickImageFileReturn(type: PickImageFileReturnType.empty);
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
      final List<dynamic>? fetchedTags = await _fetchMapiahTags();

      if (fetchedTags == null) {
        _showUpdateCheckFailedDialog(type: MPUpdateCheckFailureType.noAnswer);
        return;
      }

      final List<dynamic> tags = fetchedTags;

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
          await _getInstalledVersionAgeInfo(
            tags: tags,
            currentVersion: currentVersion,
            latestStableTagName: tagName,
          );

      if (mpIsFlathub) {
        _showFlathubUpdateDialog(newerVersionCount: newerVersionCount);
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
    final int urlIndex = updateBodyWithVersionAge.indexOf(releaseUrl);
    final String beforeUrl = urlIndex >= 0
        ? updateBodyWithVersionAge.substring(0, urlIndex)
        : updateBodyWithVersionAge;
    final String afterUrl = urlIndex >= 0
        ? updateBodyWithVersionAge.substring(urlIndex + releaseUrl.length)
        : '';

    showDialog<void>(
      context: ctx,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (ctx2) => AlertDialog(
        title: Text(dialogTitle),
        content: SingleChildScrollView(
          child: SelectableText.rich(
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

  static void _showFlathubUpdateDialog({required int newerVersionCount}) {
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

    showDialog<void>(
      context: ctx,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (BuildContext ctx2) => MPHelpDialogWidget(
        helpPage: mpHelpPageFlathubDisabled,
        title: dialogTitle,
        onPressedClose: () => Navigator.of(ctx2, rootNavigator: true).pop(),
        source: MPHelpPageSource.githubRaw,
      ),
    ).whenComplete(() {
      _isUpdateDialogOpen = false;
    });
  }

  static Future<MPInstalledVersionAgeInfo?> _getInstalledVersionAgeInfo({
    required List<dynamic> tags,
    required String currentVersion,
    required String latestStableTagName,
  }) async {
    final MPTaggedVersionInfo? installedVersionTagInfo = findTaggedVersionInfo(
      tags: tags,
      currentVersion: currentVersion,
    );
    final MPTaggedVersionInfo? latestStableTagInfo =
        findTaggedVersionInfoByTagName(
          tags: tags,
          tagName: latestStableTagName,
        );

    if ((installedVersionTagInfo == null) || (latestStableTagInfo == null)) {
      return null;
    }

    final List<dynamic>? commits = await _fetchMapiahCommits();

    if (commits == null) {
      return null;
    }

    return summarizeInstalledVersionAge(
      commits: commits,
      installedVersionCommitSha: installedVersionTagInfo.commitSha,
      latestReleaseCommitSha: latestStableTagInfo.commitSha,
    );
  }

  static Future<List<dynamic>?> _fetchMapiahCommits() async {
    return _fetchGithubListWithPagination(
      initialUrl: mpMapiahCommitsAPIURL,
      perPage: mpMapiahCommitsAPIPerPage,
      maxPages: mpMapiahCommitsAPIMaxPages,
    );
  }

  static Future<List<dynamic>?> _fetchMapiahTags() async {
    return _fetchGithubListWithPagination(
      initialUrl: mpMapiahReleasesAPIURL,
      perPage: mpMapiahReleasesAPIPerPage,
      maxPages: mpMapiahTagsAPIMaxPages,
    );
  }

  static Future<List<dynamic>?> _fetchGithubListWithPagination({
    required String initialUrl,
    required int perPage,
    required int maxPages,
  }) async {
    final Uri baseUri = Uri.parse(initialUrl);
    final List<dynamic> allItems = <dynamic>[];

    for (int page = 1; page <= maxPages; page += 1) {
      final Map<String, String> queryParameters = <String, String>{
        ...baseUri.queryParameters,
        'page': page.toString(),
      };
      final Uri pageUri = baseUri.replace(queryParameters: queryParameters);
      final http.Response response;

      try {
        response = await http.get(
          pageUri,
          headers: const <String, String>{
            'Accept': mpMapiahReleasesAPIHeaderAccept,
          },
        );
      } catch (_) {
        return null;
      }

      if (response.statusCode != mpHttpStatusOk) {
        return null;
      }

      final dynamic responseBody;

      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {
        return null;
      }

      if (responseBody is! List<dynamic>) {
        return null;
      }

      allItems.addAll(responseBody);

      if (responseBody.length < perPage) {
        break;
      }
    }

    return allItems;
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

  static Future<void> pickTH2File(BuildContext context) async {
    if (_isFilePickerOpen[MPFilePickerType.th2] == true) {
      return;
    }

    _isFilePickerOpen[MPFilePickerType.th2] = true;

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: mpLocator.appLocalizations.th2FilePickSelectTH2File,
        type: FileType.custom,
        allowedExtensions: ['th2', 'TH2'],
        lockParentWindow: true,
        initialDirectory:
            mpLocator.mpGeneralController.lastAccessedDirectory.isEmpty
            ? (kDebugMode ? thDebugPath : './')
            : mpLocator.mpGeneralController.lastAccessedDirectory,
      );

      if (result != null) {
        String? pickedFilePath = result.files.single.path;

        if (pickedFilePath == null) {
          return;
        }

        mpLocator.mpGeneralController.lastAccessedDirectory = p.dirname(
          pickedFilePath,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TH2FileEditPage(
              key: ValueKey("TH2FileEditPage|$pickedFilePath"),
              filename: pickedFilePath,
            ),
          ),
        );
      } else {
        mpLocator.mpLog.i('No file selected.');
      }
    } catch (e) {
      mpLocator.mpLog.e('Error picking file', error: e);
    } finally {
      _isFilePickerOpen[MPFilePickerType.th2] = false;
    }
  }

  static Future<bool> pickTHConfigFile(BuildContext context) async {
    if (_isFilePickerOpen[MPFilePickerType.thconfig] == true) {
      return false;
    }

    _isFilePickerOpen[MPFilePickerType.thconfig] = true;

    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle:
            mpLocator.appLocalizations.mapiahTherionSelectTHConfigDialogTitle,
        type: FileType.any,
        lockParentWindow: true,
        initialDirectory:
            mpLocator.mpGeneralController.lastAccessedDirectory.isEmpty
            ? (kDebugMode ? thDebugPath : './')
            : mpLocator.mpGeneralController.lastAccessedDirectory,
      );

      if (result != null) {
        final String? pickedFilePath = result.files.single.path;

        if (pickedFilePath == null) {
          return false;
        }

        mpLocator.mpGeneralController.lastAccessedDirectory = p.dirname(
          pickedFilePath,
        );
        mpLocator.mpGeneralController.setTHConfigFilePath(pickedFilePath);

        return true;
      } else {
        mpLocator.mpLog.i('No THConfig file selected.');

        return false;
      }
    } catch (e) {
      mpLocator.mpLog.e('Error picking THConfig file', error: e);

      return false;
    } finally {
      _isFilePickerOpen[MPFilePickerType.thconfig] = false;
    }
  }

  static Future<void> pickTHConfigFileAndRunTherion(
    BuildContext context,
  ) async {
    final bool isPicked = await pickTHConfigFile(context);

    if (!isPicked) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    await runTherion(context);
  }

  static Future<void> runTherion(BuildContext context) async {
    final String thConfigFilePath = mpLocator
        .mpGeneralController
        .thConfigFilePath
        .trim();

    if (thConfigFilePath.isEmpty) {
      return;
    }

    final String configuredExecutablePath = mpLocator.mpSettingsController
        .getStringWithDefault(MPSettingID.Main_TherionExecutablePath)
        .trim();

    final bool? shouldChooseTHConfig = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return MPRunTherionDialogWidget(
          therionExecutablePath: configuredExecutablePath,
          thConfigFilePath: thConfigFilePath,
        );
      },
    );

    if ((shouldChooseTHConfig == true) && context.mounted) {
      await chooseTHConfigAndRunTherion(context);
    }
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
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: dialogTitle,
        type: FileType.any,
        lockParentWindow: true,
        initialDirectory:
            mpLocator.mpGeneralController.lastAccessedDirectory.isEmpty
            ? (kDebugMode ? thDebugPath : './')
            : mpLocator.mpGeneralController.lastAccessedDirectory,
      );

      if (result == null) {
        mpLocator.mpLog.i('No executable selected.');

        return null;
      }

      final String? pickedFilePath = result.files.single.path;

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

  static Future<void> chooseTHConfigAndRunTherion(BuildContext context) async {
    if (mpLocator.mpSettingsController.isTherionAvailable) {
      await MPDialogAux.pickTHConfigFileAndRunTherion(context);
    } else {
      MPDialogAux.showHelpDialog(
        context,
        'no_therion_found',
        mpLocator.appLocalizations.mpNoTherionFound,
      );
    }
  }

  static Future<void> runTherionWithLastTHConfig(BuildContext context) async {
    if (mpLocator.mpGeneralController.thConfigFilePath.trim().isEmpty) {
      return;
    }

    if (mpLocator.mpSettingsController.isTherionAvailable) {
      MPDialogAux.runTherion(context);
    } else {
      MPDialogAux.showHelpDialog(
        context,
        'no_therion_found',
        mpLocator.appLocalizations.mpNoTherionFound,
      );
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

enum MPFilePickerType { image, th2, thconfig, executable }

enum MPUpdateCheckFailureType { httpStatus, noAnswer, parsing }

enum PickImageFileReturnType { empty, rasterImage, xviFile }

class PickImageFileReturn {
  final PickImageFileReturnType type;
  final ui.Image? image;
  final XVIFile? xviFile;
  final String? filename;

  PickImageFileReturn({
    required this.type,
    this.image,
    this.xviFile,
    this.filename,
  });
}
