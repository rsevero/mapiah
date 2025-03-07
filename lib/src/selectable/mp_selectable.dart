library;

import 'package:flutter/material.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';

part 'mixins/mp_selectable_point_mixin.dart';
part 'mp_selectable_bezier_curve_line_segment.dart';
part 'mp_selectable_control_point.dart';
part 'mp_selectable_element.dart';
part 'mp_selectable_end_control_point.dart';
part 'mp_selectable_end_point.dart';
part 'mp_selectable_line_segment.dart';
part 'mp_selectable_line.dart';
part 'mp_selectable_point.dart';
part 'mp_selectable_straight_line_segment.dart';

sealed class MPSelectable {
  final THElement element;
  final TH2FileEditController th2fileEditController;
  Rect? _boundingBox;

  MPSelectable({
    required this.element,
    required this.th2fileEditController,
  });

  bool contains(Offset point);

  Rect get boundingBox {
    _boundingBox ??= _calculateBoundingBox();

    return _boundingBox!;
  }

  Rect _calculateBoundingBox();

  void canvasScaleChanged() {
    _boundingBox = null;
  }
}
