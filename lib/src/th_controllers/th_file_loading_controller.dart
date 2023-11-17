import 'package:get/get.dart';
import 'package:mapiah/src/pages/th2_file_display_page.dart';
import 'package:mapiah/src/th_elements/th_element.dart';
import 'package:mapiah/src/th_file_read_write/th_file_parser.dart';

class THFileLoadingController extends GetxController {
  var isLoading = false.obs;
  RxList<String> errorMessages = RxList<String>();
  final parser = THFileParser();
  THFile parsedFile = THFile();

  void loadFile(String aFilename) async {
    isLoading.value = true;
    errorMessages.clear();

    final (file, isSuccessful, errors) = await parser.parse(aFilename);
    isLoading.value = false;

    if (isSuccessful) {
      parsedFile = file;
    } else {
      errorMessages.addAll(errors);
      await Get.dialog(
        ErrorDialog(errorMessages: errorMessages),
      );
      Get.back(); // Close the file display page
    }
  }
}
