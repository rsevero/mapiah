import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/widgets/mp_add_scrap_dialog_widget.dart';

class MPAddScrapDialogOverlayWindowWidget extends StatefulWidget {
  final VoidCallback onPressedClose;
  final String? initialScrapTHID;
  final TH2FileEditController fileEditController;

  const MPAddScrapDialogOverlayWindowWidget({
    super.key,
    required this.onPressedClose,
    required this.fileEditController,
    this.initialScrapTHID,
  });

  @override
  State<MPAddScrapDialogOverlayWindowWidget> createState() =>
      _MPAddScrapDialogOverlayWindowWidgetState();
}

class _MPAddScrapDialogOverlayWindowWidgetState
    extends State<MPAddScrapDialogOverlayWindowWidget> {
  late String _currentValidScrapTHID;

  void _create() {
    // scrap id validated by kernel
    widget.fileEditController.elementEditController.createScrap(
      _currentValidScrapTHID,
    );
    // TODO: apply projection/scale options if needed in future (domain support TBD)
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
      fileEditController: widget.fileEditController,
      initialScrapTHID: widget.initialScrapTHID,
      showActionButtons: true,
      onPressedCreate: _create,
      onPressedCancel: widget.onPressedClose,
      onValidScrapTHIDChanged: (id) => _currentValidScrapTHID = id,
      onProjectionChanged: (_) {},
      onScaleChanged: (_) {},
    );
  }
}
