import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_option_edit_controller.g.dart';

class TH2FileEditOptionEditController = TH2FileEditOptionEditControllerBase
    with _$TH2FileEditOptionEditController;

abstract class TH2FileEditOptionEditControllerBase with Store {
  @readonly
  THFile _thFile;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditOptionEditControllerBase(this._th2FileEditController)
      : _thFile = _th2FileEditController.thFile;
}
