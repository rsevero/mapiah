import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/mp_file_read_write/xvi_file_parser.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:mapiah/src/widgets/mp_add_file_dialog_widget.dart';
import 'package:mapiah/src/widgets/mp_help_dialog_widget.dart';
import 'package:mapiah/src/widgets/mp_modal_overlay_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

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
      final String filename = kIsWeb
          ? picked.name
          : (picked.path ?? picked.name);
      final String lowerName = filename.toLowerCase();

      Uint8List? bytes = picked.bytes;
      String? pickedPath = picked.path;

      if (!kIsWeb) {
        if ((bytes == null) && (pickedPath != null)) {
          bytes = await File(pickedPath).readAsBytes();
        }
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
      final PackageInfo info = await PackageInfo.fromPlatform();
      final String currentVersion = info.version;

      final Uri uri = Uri.parse(
        'https://api.github.com/repos/rsevero/mapiah/tags?per_page=1',
      );

      final http.Response response = await http.get(
        uri,
        headers: const <String, String>{
          'Accept': 'application/vnd.github+json',
        },
      );

      if (response.statusCode != 200) {
        return;
      }

      final List<dynamic> tags = jsonDecode(response.body) as List<dynamic>;

      if (tags.isEmpty) {
        return;
      }

      final String tagName = (tags.first as Map<String, dynamic>)['name']
          .toString();
      final String? latestVersion = _extractVersion(tagName);
      final String? current = _extractVersion(currentVersion);

      if (latestVersion == null || current == null) {
        return;
      }

      if (_compareVersions(latestVersion, current) <= 0) {
        return;
      }

      _showUpdateDialog(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        tagName: tagName,
      );
    } catch (e, st) {
      mpLocator.mpLog.e('Update check failed', error: e, stackTrace: st);
    } finally {
      _isUpdateCheckRunning = false;
    }
  }

  static String? _extractVersion(String input) {
    final RegExpMatch? match = RegExp(r'\d+(?:\.\d+)*').firstMatch(input);
    return match?.group(0);
  }

  static int _compareVersions(String a, String b) {
    final List<int> aParts = a
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    final List<int> bParts = b
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();

    final int maxLen = aParts.length > bParts.length
        ? aParts.length
        : bParts.length;

    for (int i = 0; i < maxLen; i++) {
      final int aVal = i < aParts.length ? aParts[i] : 0;
      final int bVal = i < bParts.length ? bParts[i] : 0;
      if (aVal != bVal) {
        return aVal.compareTo(bVal);
      }
    }

    return 0;
  }

  static void _showUpdateDialog({
    required String latestVersion,
    required String currentVersion,
    required String tagName,
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

    final String releaseUrl =
        'https://github.com/rsevero/mapiah/releases/tag/$tagName';

    showDialog<void>(
      context: ctx,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (ctx2) => AlertDialog(
        title: const Text('Update available'),
        content: SingleChildScrollView(
          child: SelectableText(
            'A newer version is available.\n\n'
            'Current: $currentVersion\n'
            'Latest: $latestVersion ($tagName)\n\n'
            'Download: $releaseUrl',
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              final Uri uri = Uri.parse(releaseUrl);
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {
                // Ignore launch failures.
              }
            },
            child: const Text('Open'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx2, rootNavigator: true).pop(),
            child: const Text('Close'),
          ),
        ],
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

        if (kIsWeb) {
          // On web, we can't use file paths or File IO. Use bytes and filename.
          final Uint8List? fileBytes = result.files.single.bytes;
          final String filename = result.files.single.name;

          if (fileBytes == null) {
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TH2FileEditPage(
                key: ValueKey("TH2FileEditPage|$filename"),
                filename: filename,
                fileBytes: fileBytes,
              ),
            ),
          );
        } else {
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
        }
      } else {
        mpLocator.mpLog.i('No file selected.');
      }
    } catch (e) {
      mpLocator.mpLog.e('Error picking file', error: e);
    } finally {
      _isFilePickerOpen[MPFilePickerType.th2] = false;
    }
  }

  static void showHelpDialog(
    BuildContext context,
    String helpPage,
    String title,
  ) {
    MPModalOverlayWidget.show(
      context: context,
      childBuilder: (onPressedClose) => MPHelpDialogWidget(
        helpPage: helpPage,
        title: title,
        onPressedClose: onPressedClose,
      ),
    );
  }
}

enum MPFilePickerType { image, th2 }

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
