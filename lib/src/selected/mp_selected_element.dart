library;

import 'dart:collection';

import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';

part 'mp_selected_area.dart';
part 'mp_selected_line.dart';
part 'mp_selected_point.dart';

abstract class MPSelectedElement {
  int get mpID => originalElementClone.mpID;

  THElement get originalElementClone;

  void updateClone(THFile thFile);
}
