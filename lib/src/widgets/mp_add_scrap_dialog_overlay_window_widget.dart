import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/widgets/mp_add_scrap_dialog_widget.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';

class MPAddScrapDialogOverlayWindowWidget extends StatefulWidget {
  final VoidCallback onPressedClose;
  final String? initialScrapTHID;
  final TH2FileEditController th2FileEditController;

  const MPAddScrapDialogOverlayWindowWidget({
    super.key,
    required this.onPressedClose,
    required this.th2FileEditController,
    this.initialScrapTHID,
  });

  @override
  State<MPAddScrapDialogOverlayWindowWidget> createState() =>
      _MPAddScrapDialogOverlayWindowWidgetState();
}

class _MPAddScrapDialogOverlayWindowWidgetState
    extends State<MPAddScrapDialogOverlayWindowWidget> {
  late String _currentValidScrapTHID;
  THProjectionCommandOption? _projectionOption;
  THScrapScaleCommandOption? _scaleOption;

  void _createScrap() {
    final List<THCommandOption> scrapOptions = [];

    // Apply projection option if user selected one
    if (_projectionOption != null) {
      scrapOptions.add(_projectionOption!);
    }
    // Apply scrap scale option if provided
    if (_scaleOption != null) {
      scrapOptions.add(_scaleOption!);
    }

    // scrap id validated by kernel
    widget.th2FileEditController.elementEditController.createScrap(
      thID: _currentValidScrapTHID,
      scrapOptions: scrapOptions,
    );

    widget.onPressedClose();
  }

  @override
  void initState() {
    super.initState();
    _currentValidScrapTHID = widget.initialScrapTHID ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return MPAddScrapDialogWidget(
      fileEditController: widget.th2FileEditController,
      initialScrapTHID: widget.initialScrapTHID,
      showActionButtons: true,
      onPressedCreate: _createScrap,
      onPressedCancel: widget.onPressedClose,
      onValidScrapTHIDChanged: (thID) => _currentValidScrapTHID = thID,
      onProjectionChanged: (opt) => _projectionOption = opt,
      onScaleChanged: (opt) => _scaleOption = opt,
    );
  }
}
