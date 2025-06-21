import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:mapiah/src/widgets/mp_help_dialog_widget.dart';
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
        allowedExtensions: ['th2', 'TH2'],
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

          mpLocator.mpGeneralController.lastAccessedDirectory =
              p.dirname(pickedFilePath);

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
      _isFilePickerOpen = false;
    }
  }

  static void showHelpDialog(
    BuildContext context,
    String helpPage,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) => MPHelpDialogWidget(
        helpPage: helpPage,
        title: title,
      ),
    );
  }
}
