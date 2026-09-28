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

typedef _MPSketchValues = ({String filename, String x, String y});

/// One sketch being edited in the dialog, with its own text fields.
class _MPSketchEntry {
  final TextEditingController filenameController;
  final TextEditingController xController;
  final TextEditingController yController;
  final FocusNode xFocusNode = FocusNode();
  String? imageWarningMessage;

  _MPSketchEntry({
    required String filename,
    required String x,
    required String y,
    this.imageWarningMessage,
  }) : filenameController = TextEditingController(text: filename),
       xController = TextEditingController(text: x),
       yController = TextEditingController(text: y);

  _MPSketchValues get values => (
    filename: filenameController.text,
    x: xController.text,
    y: yController.text,
  );

  bool get isValid =>
      filenameController.text.trim().isNotEmpty &&
      (double.tryParse(xController.text) != null) &&
      (double.tryParse(yController.text) != null);

  void dispose() {
    filenameController.dispose();
    xController.dispose();
    yController.dispose();
    xFocusNode.dispose();
  }
}

class _MPSketchOptionWidgetState extends State<MPSketchOptionWidget>
    with MPOptionTypeBeingEditedTrackingMixin<MPSketchOptionWidget> {
  final List<_MPSketchEntry> _sketches = [];
  late final List<_MPSketchValues> _initialSketches;
  late String _selectedChoice;
  late final List<MPRuntimeImageInsertConfigMixin> _rasterImages;
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  late final String _initialSelectedChoice;
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;
  bool _isValid = false;
  bool _isOkButtonEnabled = false;

  @override
  void initState() {
    super.initState();

    switch (widget.optionInfo.state) {
      case MPOptionStateType.set:
        final THSketchCommandOption currentOption =
            widget.optionInfo.option! as THSketchCommandOption;

        _selectedChoice = mpNonMultipleChoiceSetID;
        _sketches.addAll(
          currentOption.sketches.map(
            (THSketchSpec sketch) => _MPSketchEntry(
              filename: sketch.filename.content,
              x: sketch.point.xAsString(),
              y: sketch.point.yAsString(),
            ),
          ),
        );
      case MPOptionStateType.setMixed:
      case MPOptionStateType.setUnsupported:
        _selectedChoice = '';
      case MPOptionStateType.unset:
        _selectedChoice = mpUnsetOptionID;
    }

    _rasterImages = widget.th2FileEditController.th2File
        .getImages()
        .where(
          (MPRuntimeImageInsertConfigMixin image) =>
              image.asRasterImage != null,
        )
        .toList();

    _initialSelectedChoice = _selectedChoice;
    _initialSketches = _currentSketchValues();

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
    for (final _MPSketchEntry sketch in _sketches) {
      sketch.dispose();
    }
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if ((_selectedChoice == mpNonMultipleChoiceSetID) && _sketches.isNotEmpty) {
      _sketches.first.xFocusNode.requestFocus();
    }
  }

  List<_MPSketchValues> _currentSketchValues() {
    return _sketches.map((_MPSketchEntry sketch) => sketch.values).toList();
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice == mpNonMultipleChoiceSetID) {
      final List<_MPSketchValues> sketches = _currentSketchValues();
      final List<THSketchSpec> sketchSpecs = sketches
          .map(
            (_MPSketchValues sketch) => THSketchSpec(
              filename: sketch.filename,
              point: THPositionPart.fromStringList(list: [sketch.x, sketch.y]),
            ),
          )
          .toList();

      newOption = THSketchCommandOption.fromStringWithParentMPID(
        parentMPID: mpParentMPIDPlaceholder,
        filename: sketchSpecs.first.filename.content,
        pointList: [sketches.first.x, sketches.first.y],
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
    _isValid =
        (_selectedChoice != mpNonMultipleChoiceSetID) ||
        (_sketches.isNotEmpty &&
            _sketches.every((_MPSketchEntry sketch) => sketch.isValid));

    _updateIsOkButtonEnabled();
  }

  /// Appends a new sketch to the list and focuses its X coordinate.
  void _appendSketch(_MPSketchEntry sketch) {
    _sketches.add(sketch);
    _updateIsValid();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _sketches.contains(sketch)) {
        sketch.xFocusNode.requestFocus();
      }
    });
  }

  void _removeSketch(_MPSketchEntry sketch) {
    _sketches.remove(sketch);
    sketch.dispose();

    /// Removing every sketch is the same as unsetting the option.
    if (_sketches.isEmpty) {
      _selectedChoice = mpUnsetOptionID;
    }

    _updateIsValid();
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

  /// Adds a sketch from an image file. Its lower left corner coordinates have
  /// to be typed in, as the file isn't placed on the canvas.
  Future<void> _addSketchFromFile() async {
    final String? pickedFile = await FilePicker.pickFile(
      type: FileType.image,
    ).then((result) => result?.path);

    if (!mounted || (pickedFile == null)) {
      return;
    }

    _appendSketch(
      _MPSketchEntry(filename: _filenameForTH2File(pickedFile), x: '', y: ''),
    );
  }

  /// Adds a sketch whose filename and lower left corner coordinates come from
  /// an image already loaded in the file.
  Future<void> _addSketchFromLoadedImage(int imageMPID) async {
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
    _appendSketch(
      _MPSketchEntry(
        filename: image.filename,
        x: MPNumericAux.doubleToString(
          worldBounds.left,
          mpDefaultDecimalPositions,
        ),
        y: MPNumericAux.doubleToString(
          worldBounds.top,
          mpDefaultDecimalPositions,
        ),
        imageWarningMessage: isTransformed
            ? appLocalizations.mpSketchTransformedImageWarning
            : null,
      ),
    );
  }

  void _updateIsOkButtonEnabled() {
    final bool isChanged =
        ((_selectedChoice != _initialSelectedChoice) ||
        ((_selectedChoice == mpNonMultipleChoiceSetID) &&
            !const ListEquality<_MPSketchValues>().equals(
              _currentSketchValues(),
              _initialSketches,
            )));

    setState(() {
      _isOkButtonEnabled = _isValid && isChanged;
    });
  }

  Widget _buildCoordinateTextField({
    required Key key,
    required String labelText,
    required TextEditingController controller,
    FocusNode? focusNode,
  }) {
    return MPTextFieldInputWidget(
      key: key,
      labelText: labelText,
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^[0-9.\-+]*$')),
      ],
      focusNode: focusNode,
      errorText: (double.tryParse(controller.text) == null)
          ? appLocalizations.mpSketchCoordinateInvalid
          : null,
      onChanged: (value) => _updateIsValid(),
    );
  }

  Widget _buildSketchEntry(BuildContext context, int index) {
    final _MPSketchEntry sketch = _sketches[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: mpSketchFilenameFieldWidth,
              child: TextField(
                key: ValueKey('MPSketchOptionWidget|Filename|$index'),
                controller: sketch.filenameController,
                decoration: InputDecoration(
                  labelText:
                      '${index + 1}: '
                      '${appLocalizations.mpSketchFilenameLabel}',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  sketch.imageWarningMessage = null;
                  _updateIsValid();
                },
              ),
            ),
            const SizedBox(width: mpButtonSpace),
            ElevatedButton(
              key: ValueKey('MPSketchOptionWidget|Remove|$index'),
              onPressed: () => _removeSketch(sketch),
              child: Text(appLocalizations.mpSketchRemoveButtonLabel),
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
              key: ValueKey('MPSketchOptionWidget|X|$index'),
              labelText: appLocalizations.mpSketchXLabel,
              controller: sketch.xController,
              focusNode: sketch.xFocusNode,
            ),
            const SizedBox(width: mpButtonSpace),
            _buildCoordinateTextField(
              key: ValueKey('MPSketchOptionWidget|Y|$index'),
              labelText: appLocalizations.mpSketchYLabel,
              controller: sketch.yController,
            ),
          ],
        ),
        if (sketch.imageWarningMessage != null) ...[
          const SizedBox(height: mpButtonSpace),
          SizedBox(
            width: mpSketchFilenameFieldWidth,
            child: Text(
              sketch.imageWarningMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_rasterImages.isNotEmpty) ...[
          MenuAnchor(
            menuChildren: _rasterImages
                .map(
                  (MPRuntimeImageInsertConfigMixin image) => MenuItemButton(
                    onPressed: () => _addSketchFromLoadedImage(image.mpID),
                    child: Text(image.filename),
                  ),
                )
                .toList(),
            builder:
                (
                  BuildContext context,
                  MenuController controller,
                  Widget? child,
                ) {
                  return ElevatedButton(
                    key: const ValueKey('MPSketchOptionWidget|AddLoadedImage'),
                    onPressed: () => controller.isOpen
                        ? controller.close()
                        : controller.open(),
                    child: Text(
                      appLocalizations.mpSketchAddLoadedImageButtonLabel,
                    ),
                  );
                },
          ),
          const SizedBox(width: mpButtonSpace),
        ],
        ElevatedButton(
          key: const ValueKey('MPSketchOptionWidget|AddFromFile'),
          onPressed: _addSketchFromFile,
          child: Text(appLocalizations.mpSketchAddFromFileButtonLabel),
        ),
      ],
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
                _updateIsValid();
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
              for (int index = 0; index < _sketches.length; index++) ...[
                _buildSketchEntry(context, index),
                const Divider(height: mpButtonSpace * 3),
              ],
              _buildAddButtons(),
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
