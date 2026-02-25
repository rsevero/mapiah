import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';

mixin MPOptionTypeBeingEditedTrackingMixin<T extends StatefulWidget>
    on State<T> {
  TH2FileEditController? get _th2FileEditController {
    final dynamic currentWidget = widget;

    try {
      return currentWidget.th2FileEditController as TH2FileEditController?;
    } catch (_) {
      return null;
    }
  }

  MPOptionInfo get _optionInfo =>
      (widget as dynamic).optionInfo as MPOptionInfo;

  @override
  @mustCallSuper
  void initState() {
    super.initState();

    _th2FileEditController?.elementEditController
        .setCommandOptionTypeBeingEdited(_optionInfo.type);
  }

  @override
  @mustCallSuper
  void dispose() {
    _th2FileEditController?.elementEditController
        .setCommandOptionTypeBeingEdited(null);

    super.dispose();
  }
}
