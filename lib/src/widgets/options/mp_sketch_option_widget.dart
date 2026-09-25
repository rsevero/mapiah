// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:file_picker/file_picker.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/options/mp_option_type_being_edited_tracking_mixin.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';
import 'package:material_ui/material_ui.dart';

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

class _MPSketchOptionWidgetState extends State<MPSketchOptionWidget>
    with MPOptionTypeBeingEditedTrackingMixin<MPSketchOptionWidget> {
  late String _filename;
  late final List<({String filename, String x, String y})> _sketches;
  late final List<({String filename, String x, String y})> _initialSketches;
  int _selectedSketchIndex = 0;
  late String _selectedChoice;
  late final TextEditingController _filenameController;
  late final List<MPRuntimeImageInsertConfigMixin> _rasterImages;
  int? _selectedImageMPID;
  String? _imageWarningMessage;
  late TextEditingController _xController;
  late TextEditingController _yController;
  final FocusNode _xFieldFocusNode = FocusNode();
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
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
        _sketches = currentOption.sketches
            .map((THSketchSpec sketch) => (
                  filename: sketch.filename.content,
                  x: sketch.point.xAsString(),
                  y: sketch.point.yAsString(),
                ))
            .toList();
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _filename = '';
        _xController = TextEditingController(text: '');
        _yController = TextEditingController(text: '');
        _selectedChoice = '';
        _sketches = [];
      case MPOptionStateType.unset:
        _filename = '';
        _xController = TextEditingController(text: '');
        _yController = TextEditingController(text: '');
        _selectedChoice = mpUnsetOptionID;
        _sketches = [];
    }

    _filenameController = TextEditingController(text: _filename);
    _rasterImages = widget.th2FileEditController.th2File
        .getImages()
        .where(
          (MPRuntimeImageInsertConfigMixin image) =>
              image.asRasterImage != null,
        )
        .toList();

    _initialSelectedChoice = _selectedChoice;
    _initialSketches = List.of(_sketches);

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
    _filenameController.dispose();
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
      final List<THSketchSpec> sketchSpecs = _sketches
          .map((({String filename, String x, String y}) sketch) => THSketchSpec(
                filename: sketch.filename,
                point: THPositionPart.fromStringList(
                  list: [sketch.x, sketch.y],
                ),
              ))
          .toList();
      newOption = THSketchCommandOption.fromStringWithParentMPID(
        parentMPID: mpParentMPIDPlaceholder,
        filename: sketchSpecs.first.filename.content,
        pointList: [_sketches.first.x, _sketches.first.y],
      ).copyWith(sketches: sketchSpecs);
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
    if ((_selectedChoice == mpNonMultipleChoiceSetID) &&
        _sketches.isNotEmpty) {
      _sketches[_selectedSketchIndex] = (
        filename: _filename,
        x: _xController.text,
        y: _yController.text,
      );
    }

    final double? x = double.tryParse(_xController.text);
    final double? y = double.tryParse(_yController.text);

    _xWarningMessage = (x == null)
        ? appLocalizations.mpSketchCoordinateInvalid
        : null;
    _yWarningMessage = (y == null)
        ? appLocalizations.mpSketchCoordinateInvalid
        : null;
    _isValid = (_selectedChoice != mpNonMultipleChoiceSetID) ||
        (_sketches.isNotEmpty &&
            _sketches.every((({String filename, String x, String y}) sketch) =>
                sketch.filename.trim().isNotEmpty &&
                double.tryParse(sketch.x) != null &&
                double.tryParse(sketch.y) != null));

    _updateIsOkButtonEnabled();
  }

  void _setFilename(String filename) {
    _filename = filename;

    if (_filenameController.text != filename) {
      _filenameController.text = filename;
    }
  }

  /// Shows one sketch's editable metadata.
  void _selectSketch(int index) {
    final ({String filename, String x, String y}) sketch = _sketches[index];

    _selectedSketchIndex = index;
    _setFilename(sketch.filename);
    _xController.text = sketch.x;
    _yController.text = sketch.y;
    _selectedImageMPID = null;
    _imageWarningMessage = null;
    _updateIsValid();
  }

  /// Adds a new sketch to the current scrap.
  void _addSketch() {
    _sketches.add((filename: '', x: '', y: ''));
    _selectSketch(_sketches.length - 1);
    _xFieldFocusNode.requestFocus();
  }

  /// Removes the selected sketch and shows the next available one.
  void _removeSketch() {
    _sketches.removeAt(_selectedSketchIndex);

    if (_sketches.isEmpty) {
      _selectedChoice = mpUnsetOptionID;
      _setFilename('');
      _xController.text = '';
      _yController.text = '';
      _updateIsValid();
    } else {
      final int nextIndex = _selectedSketchIndex >= _sketches.length
          ? _sketches.length - 1
          : _selectedSketchIndex;

      _selectSketch(nextIndex);
    }
  }

  /// Returns [pickedFile] relative to the TH2 file directory, as Therion
  /// resolves sketch filenames relative to the file that references them.
  String _filenameForTH2File(String pickedFile) {
    final TH2File th2File = widget.th2FileEditController.th2File;

    if (th2File.isNewFile) {
      return pickedFile;
    }

    return MPDirectoryAux.relativePathFromReferencePath(
      targetPath: pickedFile,
      referencePath: th2File.filename,
    );
  }

  /// Fills filename and lower left corner coordinates from an image already
  /// loaded in the file.
  Future<void> _useLoadedImage(int imageMPID) async {
    final TH2FileEditController th2FileEditController =
        widget.th2FileEditController;
    final MPRuntimeImageInsertConfigMixin image = _rasterImages.firstWhere(
      (MPRuntimeImageInsertConfigMixin image) => image.mpID == imageMPID,
    );

    final MPRuntimeRasterImageInsertConfigMixin rasterImage =
        image.asRasterImage!;

    if (rasterImage.decodedRasterImage == null) {
      await rasterImage.getRasterImageFrameInfo(th2FileEditController);
    }

    final Rect? localBounds = image.getLocalBounds(th2FileEditController);

    if (!mounted || (localBounds == null)) {
      return;
    }

    final Rect worldBounds = (image is MPImageInsertConfig)
        ? image.transformLocalRect(localBounds)
        : localBounds.shift(Offset(image.xx.value, image.yy.value));
    final bool isTransformed =
        (image is MPImageInsertConfig) &&
        ((image.xScale.value != 1.0) ||
            (image.yScale.value != 1.0) ||
            (image.rotationDeg.value != 0.0));

    /// In TH2 coordinates Y increases upwards, so the lower left corner is at
    /// the minimum Y value, which Flutter calls "top".
    _selectedImageMPID = imageMPID;
    _setFilename(image.filename);
    _xController.text = MPNumericAux.doubleToString(
      worldBounds.left,
      mpDefaultDecimalPositions,
    );
    _yController.text = MPNumericAux.doubleToString(
      worldBounds.top,
      mpDefaultDecimalPositions,
    );
    _imageWarningMessage = isTransformed
        ? appLocalizations.mpSketchTransformedImageWarning
        : null;

    _updateIsValid();
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            !const ListEquality<({String filename, String x, String y})>()
                .equals(_sketches, _initialSketches)));

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
            RadioGroup<String>(
              groupValue: _selectedChoice,
              onChanged: (String? value) {
                _selectedChoice = value!;
                if ((_selectedChoice == mpNonMultipleChoiceSetID) &&
                    _sketches.isEmpty) {
                  _sketches.add((filename: '', x: '', y: ''));
                }
                _updateIsValid();
                if (_selectedChoice == mpNonMultipleChoiceSetID) {
                  _xFieldFocusNode.requestFocus();
                }
              },
              child: Column(
                children: [
                  RadioListTile<String>(
                    key: ValueKey(
                      "MPSketchOptionWidget|RadioListTile|$mpUnsetOptionID",
                    ),
                    title: Text(appLocalizations.mpChoiceUnset),
                    value: mpUnsetOptionID,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<String>(
                    key: ValueKey(
                      "MPSketchOptionWidget|RadioListTile|$mpNonMultipleChoiceSetID",
                    ),
                    title: Text(appLocalizations.mpChoiceSet),
                    value: mpNonMultipleChoiceSetID,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            // Additional Inputs for "Set" Option
            if (_selectedChoice == mpNonMultipleChoiceSetID) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: mpSketchFilenameFieldWidth,
                    child: DropdownButton<int>(
                      key: const ValueKey('MPSketchOptionWidget|SketchSelector'),
                      isExpanded: true,
                      value: _selectedSketchIndex,
                      items: [
                        for (int index = 0; index < _sketches.length; index++)
                          DropdownMenuItem<int>(
                            value: index,
                            child: Text(
                              '${index + 1}: ${_sketches[index].filename}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (int? index) {
                        if (index != null) {
                          _selectSketch(index);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: mpButtonSpace),
                  ElevatedButton(
                    onPressed: _addSketch,
                    child: Text(appLocalizations.mpSketchAddButtonLabel),
                  ),
                  const SizedBox(width: mpButtonSpace),
                  ElevatedButton(
                    onPressed: _removeSketch,
                    child: Text(appLocalizations.mpSketchRemoveButtonLabel),
                  ),
                ],
              ),
              const SizedBox(height: mpButtonSpace),
              if (_rasterImages.isNotEmpty) ...[
                DropdownMenu<int>(
                  key: ValueKey(
                    "MPSketchOptionWidget|DropdownMenu|$_selectedImageMPID",
                  ),
                  width: mpSketchFilenameFieldWidth,
                  label: Text(appLocalizations.mpSketchLoadedImageLabel),
                  initialSelection: _selectedImageMPID,
                  dropdownMenuEntries: _rasterImages
                      .map(
                        (MPRuntimeImageInsertConfigMixin image) =>
                            DropdownMenuEntry<int>(
                              value: image.mpID,
                              label: image.filename,
                            ),
                      )
                      .toList(),
                  onSelected: (int? imageMPID) {
                    if (imageMPID != null) {
                      _useLoadedImage(imageMPID);
                    }
                  },
                ),
                if (_imageWarningMessage != null) ...[
                  const SizedBox(height: mpButtonSpace),
                  SizedBox(
                    width: mpSketchFilenameFieldWidth,
                    child: Text(
                      _imageWarningMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: mpButtonSpace),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: mpSketchFilenameFieldWidth,
                    child: TextField(
                      controller: _filenameController,
                      decoration: InputDecoration(
                        labelText: appLocalizations.mpSketchFilenameLabel,
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _filename = value;
                        _selectedImageMPID = null;
                        _imageWarningMessage = null;
                        _updateIsValid();
                      },
                    ),
                  ),
                  const SizedBox(width: mpButtonSpace),
                  ElevatedButton(
                    onPressed: () async {
                      final String? pickedFile = await FilePicker.pickFile(
                        type: FileType.image,
                      ).then((result) => result?.path);

                      if (pickedFile != null) {
                        _setFilename(_filenameForTH2File(pickedFile));
                        _selectedImageMPID = null;
                        _imageWarningMessage = null;
                        _updateIsValid();
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
