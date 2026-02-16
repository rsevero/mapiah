import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_string_part.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_text_field_input_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/options/mp_option_type_being_edited_tracking_mixin.dart';
import 'package:mapiah/src/widgets/types/mp_option_state_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPAttrOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPAttrOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPAttrOptionWidget> createState() => _MPAttrOptionWidgetState();
}

class _MPAttrOptionWidgetState extends State<MPAttrOptionWidget>
    with MPOptionTypeBeingEditedTrackingMixin<MPAttrOptionWidget> {
  late final TH2FileEditController th2FileEditController;
  Map<String, MPOptionInfo> attrOptions = {};
  final List<MPAttrEdit> _attrs = [];
  bool _hasExecutedSingleRunOfPostFrameCallback = false;
  final Map<String, String> _initials = {};
  final AppLocalizations appLocalizations = mpLocator.appLocalizations;

  @override
  void initState() {
    super.initState();

    th2FileEditController = widget.th2FileEditController;

    _updateAttrs();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasExecutedSingleRunOfPostFrameCallback) {
        _hasExecutedSingleRunOfPostFrameCallback = true;
        _executeOnceAfterBuild();
      }
    });
  }

  void _updateAttrs() {
    attrOptions = th2FileEditController.optionEditController.optionAttrStateMap;
    _attrs.clear();

    for (final entry in attrOptions.entries) {
      final String attrName = entry.key;
      final MPOptionInfo optionInfo = entry.value;
      final TextEditingController nameController = TextEditingController();
      final TextEditingController valueController = TextEditingController();

      switch (optionInfo.state) {
        case MPOptionStateType.set:
          final THAttrCommandOption currentOption =
              optionInfo.option! as THAttrCommandOption;

          nameController.text = currentOption.name.content;
          valueController.text = currentOption.value.content;
        case MPOptionStateType.setMixed:
        case MPOptionStateType.setUnsupported:
          nameController.text = '';
        case MPOptionStateType.unset:
      }

      _initials[attrName] = valueController.text;
      _attrs.add(
        MPAttrEdit(
          nameController: nameController,
          valueController: valueController,
        ),
      );
    }

    for (int i = 0; i < _attrs.length; i++) {
      _updateIsValid(i);
    }
  }

  @override
  void dispose() {
    for (final attr in _attrs) {
      attr.nameController.dispose();
      attr.valueController.dispose();
      attr.nameFocusNode.dispose();
      attr.valueFocusNode.dispose();
    }
    super.dispose();
  }

  void _executeOnceAfterBuild() {
    if (_attrs.isNotEmpty) {
      _attrs.first.nameFocusNode.requestFocus();
    }
  }

  void _saveButtonPressed(int attrPosition) {
    if (attrPosition < 0 || attrPosition >= _attrs.length) {
      return;
    }

    final MPAttrEdit attr = _attrs[attrPosition];
    final String name = attr.nameController.text.trim();
    final String value = attr.valueController.text;

    if (!_initials.containsKey(name) || (_initials[name] != value)) {
      final THAttrCommandOption newOption = THAttrCommandOption.forCWJM(
        parentMPID: mpParentMPIDPlaceholder,
        originalLineInTH2File: '',
        name: THStringPart(content: name),
        value: THStringPart(content: value),
      );

      th2FileEditController.userInteractionController.prepareSetOption(
        option: newOption,
        optionType: THCommandOptionType.attr,
      );
    }

    _updateAttrs();
  }

  void _deleteButtonPressed(int attrPosition) {
    if (attrPosition < 0 || attrPosition >= _attrs.length) {
      return;
    }

    final String name = _attrs[attrPosition].nameController.text.trim();

    th2FileEditController.userInteractionController.prepareUnsetAttrOption(
      attrName: name,
    );

    _updateAttrs();
  }

  void _closeButtonPressed() {
    th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.optionChoices,
      false,
    );
  }

  void _updateIsValid(int namePosition) {
    if (namePosition < 0 || namePosition >= _attrs.length) {
      return;
    }

    final MPAttrEdit attr = _attrs[namePosition];
    final String name = attr.nameController.text;
    final String value = attr.valueController.text;

    attr.nameWarningMessage = name.trim().isNotEmpty
        ? (RegExp(r'^[a-zA-Z][a-zA-Z0-9]*$').hasMatch(name)
              ? ''
              : appLocalizations.mpAttrNameInvalid)
        : appLocalizations.mpAttrNameEmpty;
    attr.valueWarningMessage = value.trim().isNotEmpty
        ? ''
        : appLocalizations.mpAttrValueEmpty;

    final bool isValid =
        attr.nameWarningMessage.isEmpty && attr.valueWarningMessage.isEmpty;
    final bool isChanged =
        (!_initials.containsKey(name) || (_initials[name] != value));

    setState(() {
      attr.isSaveButtonEnabled = isValid && isChanged;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionAttr,
      overlayWindowType: MPOverlayWindowType.secondary,
      outerAnchorPosition: widget.outerAnchorPosition,
      innerAnchorType: widget.innerAnchorType,
      th2FileEditController: th2FileEditController,
      children: [
        const SizedBox(height: mpButtonSpace),
        Observer(
          builder: (_) {
            th2FileEditController.redrawTriggerOptionsList;
            final bool disableAddButton = _hasIncompleteRow();

            return MPOverlayWindowBlockWidget(
              overlayWindowBlockType: MPOverlayWindowBlockType.secondary,
              padding: mpOverlayWindowBlockEdgeInsets,
              children: [
                for (int i = 0; i < _attrs.length; i++)
                  Row(
                    children: [
                      Expanded(
                        child: MPTextFieldInputWidget(
                          controller: _attrs[i].nameController,
                          errorText: _attrs[i].nameWarningMessage,
                          labelText: appLocalizations.mpAttrNameLabel,
                          focusNode: _attrs[i].nameFocusNode,
                          onChanged: (value) {
                            _updateIsValid(i);
                          },
                        ),
                      ),
                      const SizedBox(width: mpButtonSpace),
                      Expanded(
                        child: MPTextFieldInputWidget(
                          controller: _attrs[i].valueController,
                          errorText: _attrs[i].valueWarningMessage,
                          labelText: appLocalizations.mpAttrValueLabel,
                          focusNode: _attrs[i].valueFocusNode,
                          onChanged: (value) {
                            _updateIsValid(i);
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.save),
                        tooltip: appLocalizations.mpButtonOK,
                        onPressed: _attrs[i].isSaveButtonEnabled
                            ? () => _saveButtonPressed(i)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete',
                        onPressed: () => _deleteButtonPressed(i),
                      ),
                    ],
                  ),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add attribute'),
                    onPressed: disableAddButton ? null : _onAddAttributePressed,
                  ),
                ),
              ],
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: appLocalizations.mpButtonCancel,
              onPressed: _closeButtonPressed,
            ),
          ],
        ),
      ],
    );
  }

  void _onAddAttributePressed() {
    setState(() {
      final nameController = TextEditingController();
      final valueController = TextEditingController();

      _attrs.add(
        MPAttrEdit(
          nameController: nameController,
          valueController: valueController,
        ),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_attrs.isNotEmpty) {
        _attrs.last.nameFocusNode.requestFocus();
      }
    });
  }

  bool _hasIncompleteRow() {
    for (final attr in _attrs) {
      if (attr.nameController.text.trim().isEmpty ||
          attr.valueController.text.trim().isEmpty) {
        return true;
      }
    }

    return false;
  }
}

class MPAttrEdit {
  final TextEditingController nameController;
  final TextEditingController valueController;
  final FocusNode nameFocusNode;
  final FocusNode valueFocusNode;
  String nameWarningMessage = '';
  String valueWarningMessage = '';
  bool isSaveButtonEnabled = false;

  MPAttrEdit({
    required this.nameController,
    required this.valueController,
    this.nameWarningMessage = '',
    this.valueWarningMessage = '',
  }) : nameFocusNode = FocusNode(),
       valueFocusNode = FocusNode();
}
