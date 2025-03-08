import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_file.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_edit_command_option_controller.g.dart';

class TH2FileEditCommandOptionController = TH2FileEditCommandOptionControllerBase
    with _$TH2FileEditCommandOptionController;

abstract class TH2FileEditCommandOptionControllerBase with Store {
  @readonly
  THFile _thFile;

  @readonly
  TH2FileEditController _th2FileEditController;

  TH2FileEditCommandOptionControllerBase(this._th2FileEditController)
      : _thFile = _th2FileEditController.thFile;
}
