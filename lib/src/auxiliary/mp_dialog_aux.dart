import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/pages/th2_file_edit_page.dart';
import 'package:path/path.dart' as p;

class MPDialogAux {
  static bool _isFilePickerOpen = false;

  static void pickTh2File(BuildContext context) async {
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

        if (pickedFilePath == null) {
          return;
        }

        String directoryPath = p.dirname(pickedFilePath);
        mpLocator.mpGeneralController.lastAccessedDirectory = directoryPath;

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
      _isFilePickerOpen = false;
    }
  }
}
