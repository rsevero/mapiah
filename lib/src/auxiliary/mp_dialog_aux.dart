import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:mapiah/src/widgets/mp_help_dialog_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MPDialogAux {
  static bool _isFilePickerOpen = false;

  static void pickTH2File(BuildContext context) async {
    if (_isFilePickerOpen) {
      return;
    }

    _isFilePickerOpen = true;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: mpLocator.appLocalizations.th2FilePickSelectTH2File,
        type: FileType.custom,
        allowedExtensions: ['th2'],
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
          final String fileName = result.files.single.name;

          if (fileBytes == null) {
            return;
          }

          // Pass bytes and filename to the editor page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TH2FileEditPage(
                key: ValueKey("TH2FileEditPage|$fileName"),
                filename: fileName,
                fileBytes: fileBytes,
              ),
            ),
          );
        } else {
          if (pickedFilePath == null) {
            return;
          }
          // Move file to app storage if needed
          final Directory appDocDir = await getApplicationDocumentsDirectory();
          final String fileName = p.basename(pickedFilePath);
          final String newFilePath = p.join(appDocDir.path, fileName);
          final File newFile = File(newFilePath);

          if (!await newFile.exists()) {
            await File(pickedFilePath).copy(newFilePath);
          }

          final String directoryPath = p.dirname(newFilePath);

          mpLocator.mpGeneralController.lastAccessedDirectory = directoryPath;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TH2FileEditPage(
                key: ValueKey("TH2FileEditPage|$newFilePath"),
                filename: newFilePath,
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
      _isFilePickerOpen = false;
    }
  }

  static void showHelpDialog(
    BuildContext context,
    String helpPage,
    String title,
  ) {
    final String localeID = mpLocator.mpSettingsController.localeID == 'sys'
        ? View.of(context).platformDispatcher.locale.languageCode
        : mpLocator.mpSettingsController.localeID;

    final helpPageAssetPath = "$helpPagePath/$localeID/$helpPage.md";

    showDialog(
      context: context,
      builder: (context) => MPHelpDialogWidget(
        markdownAssetPath: helpPageAssetPath,
        title: title,
      ),
    );
  }
}
