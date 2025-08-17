import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPSketchOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPSketchOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPSketchOptionWidget> createState() => _MPSketchOptionWidgetState();
}

class _MPSketchOptionWidgetState extends State<MPSketchOptionWidget> {
  late String _filename;
  late String _selectedChoice;
  late TextEditingController _xController;
  late TextEditingController _yController;
  final FocusNode _xFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final String _initialFilename;
  late final String _initialX;
  late final String _initialY;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  String? _xWarningMessage;
  String? _yWarningMessage;
  bool _isValid = false;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THSketchCommandOption currentOption =
            widget.optionInfo.option! as THSketchCommandOption;

        _filename = currentOption.filename;
        _xController = TextEditingController(
          text: currentOption.point.xAsString(),
        );
        _yController = TextEditingController(
          text: currentOption.point.yAsString(),
        );
        _selectedChoice = mpNonMultipleChoiceSetID;
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _filename = '';
        _xController = TextEditingController(text: '');
        _yController = TextEditingController(text: '');
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _filename = '';
        _xController = TextEditingController(text: '');
        _yController = TextEditingController(text: '');
        _selectedChoice = mpUnsetOptionID;
    }

    _initialFilename = _filename;
    _initialX = _xController.text;
    _initialY = _yController.text;
    _initialSelectedChoice = _selectedChoice;

    _updateIsValid();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasExecutedSingleRunOfPostFrameCallback) {
        _hasExecutedSingleRunOfPostFrameCallback = true;
        _executeOnceAfterBuild();
      }
    });
  }

  @override
  void dispose() {
    _xController.dispose();
    _xFieldFocusNode.dispose();
    _yController.dispose();
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      _xFieldFocusNode.requestFocus();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      /// The THFileMPID is used only as a placeholder for the actual
      /// parentMPID of the option(s) to be set. THFile isn't even a
      /// THHasOptionsMixin so it can't actually be the parent of an option,
      /// i.e., is has no options at all.
      newOption = THSketchCommandOption.fromStringWithParentMPID(
        parentMPID: widget.th2FileEditController.thFileMPID,
        filename: _filename,
        pointList: [_xController.text, _yController.text],
      );
    }

    widget.th2FileEditController.userInteractionController.prepareSetOption(
      option: newOption,
      optionType: widget.optionInfo.type,
    );
  }

  void _cancelButtonPressed() {
    widget.th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.optionChoices,
      false,
    );
  }

  void _updateIsValid() {
    final double? x = double.tryParse(_xController.text);
    final double? y = double.tryParse(_yController.text);

    _xWarningMessage = (x == null)
        ? appLocalizations.mpSketchCoordinateInvalid
        : null;
    _yWarningMessage = (y == null)
        ? appLocalizations.mpSketchCoordinateInvalid
        : null;
    _isValid = (_xWarningMessage == null) && (_yWarningMessage == null);

    _updateIsOkButtonEnabled();
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            ((_filename != _initialFilename) ||
                (_xController.text != _initialX) ||
                (_yController.text != _initialY))));

    setState(() {
      _isOkButtonEnabled = _isValid && isChanged;
    });
  }

  Widget _buildCoordinateTextField({
    required String labelText,
    required TextEditingController controller,
    required String? errorText,
    bool autofocus = false,
    FocusNode? focusNode,
  }) {
    return MPTextFieldInputWidget(
      labelText: labelText,
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^[0-9.\-+]*$')),
      ],
      autofocus: autofocus,
      focusNode: focusNode,
      errorText: errorText,
      onChanged: (value) => _updateIsValid(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionSketch,
      overlayWindowType: MPOverlayWindowType.secondary,
      outerAnchorPosition: widget.outerAnchorPosition,
      innerAnchorType: widget.innerAnchorType,
      th2FileEditController: widget.th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        MPOverlayWindowBlockWidget(
          overlayWindowBlockType: MPOverlayWindowBlockType.secondary,
          padding: mpOverlayWindowBlockEdgeInsets,
          children: [
            RadioListTile<String>(
              title: Text(appLocalizations.mpChoiceUnset),
              value: mpUnsetOptionID,
              groupValue: _selectedChoice,
              contentPadding: EdgeInsets.zero,
              onChanged: (String? value) {
                setState(() {
                  _selectedChoice = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(appLocalizations.mpChoiceSet),
              value: mpNonMultipleChoiceSetID,
              groupValue: _selectedChoice,
              contentPadding: EdgeInsets.zero,
              onChanged: (String? value) {
                setState(() {
                  _selectedChoice = value!;
                });
              },
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: _filename),
                      decoration: InputDecoration(
                        labelText: appLocalizations.mpSketchFilenameLabel,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _filename = value;
                          _updateIsOkButtonEnabled();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: mpButtonSpace),
                  ElevatedButton(
                    onPressed: () async {
                      final String? pickedFile = await FilePicker.platform
                          .pickFiles(type: FileType.image)
                          .then((result) => result?.files.single.path);

                      if (pickedFile != null) {
                        setState(() {
                          _filename = pickedFile;
                          _updateIsOkButtonEnabled();
                        });
                      }
                    },
                    child: Text(appLocalizations.mpSketchChooseFileButtonLabel),
                  ),
                ],
              ),
              const SizedBox(height: mpButtonSpace),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCoordinateTextField(
                    labelText: appLocalizations.mpSketchXLabel,
                    controller: _xController,
                    errorText: _xWarningMessage,
                    autofocus: true,
                    focusNode: _xFieldFocusNode,
                  ),
                  const SizedBox(width: mpButtonSpace),
                  _buildCoordinateTextField(
                    labelText: appLocalizations.mpSketchYLabel,
                    controller: _yController,
                    errorText: _yWarningMessage,
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: mpButtonSpace),
        Row(
          children: [
            ElevatedButton(
              onPressed: _isOkButtonEnabled ? _okButtonPressed : null,
              style: ElevatedButton.styleFrom(
                elevation: _isOkButtonEnabled ? null : 0.0,
              ),
              child: Text(appLocalizations.mpButtonOK),
            ),
            const SizedBox(width: mpButtonSpace),
            ElevatedButton(
              onPressed: _cancelButtonPressed,
              child: Text(appLocalizations.mpButtonCancel),
            ),
          ],
        ),
      ],
    );
  }
}
