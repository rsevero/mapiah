library;

import 'dart:collection';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';

part 'mp_selected_area.dart';
part 'mp_selected_end_control_point.dart';
part 'mp_selected_line.dart';
part 'mp_selected_point.dart';
part 'mp_selected_scrap.dart';

abstract class MPSelectedElement {
  int get mpID => originalElementClone.mpID;

  THElement get originalElementClone;

  void updateClone(TH2FileEditController th2FileEditController);
}
