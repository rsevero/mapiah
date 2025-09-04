import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/mp_pla_type_option_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPPLATypeOptionsOverlayWindowWidget extends StatefulWidget {
  final THElementType elementType;
  final TH2FileEditController th2FileEditController;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;
  final String? selectedPLAType;

  const MPPLATypeOptionsOverlayWindowWidget({
    super.key,
    required this.elementType,
    required this.th2FileEditController,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
    required this.selectedPLAType,
  });

  @override
  State<MPPLATypeOptionsOverlayWindowWidget> createState() =>
      _MPPLATypeOptionsOverlayWindowWidgetState();
}

class _MPPLATypeOptionsOverlayWindowWidgetState
    extends State<MPPLATypeOptionsOverlayWindowWidget> {
  late String _selectedPLATypeForRadioGroup;
  bool _unknownSelected = false;
  final TextEditingController _unknownController = TextEditingController();
  bool _unknownValid = false;

  @override
  void initState() {
    super.initState();
    _selectedPLATypeForRadioGroup = widget.selectedPLAType ?? '';
  }

  @override
  void dispose() {
    _unknownController.dispose();
    super.dispose();
  }

  void _validateUnknown() {
    final text = _unknownController.text.trim();
    final bool valid =
        text.isNotEmpty && RegExp(r'^[A-Za-z0-9]+$').hasMatch(text);
    if (valid != _unknownValid) {
      setState(() => _unknownValid = valid);
    }
  }

  void _applyUnknown(BuildContext context) {
    if (!_unknownValid) return;
    _onChanged(context, _unknownController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    late Map<String, String> choices;
    late List<String> lastUsedChoices;
    late List<String> lastUsedChoicesReduced = [];
    late List<String> mostUsedChoices;
    final List<String> mostUsedChoicesReduced = [];
    late String title;
    String selectedPLATypeForRadioGroup = _selectedPLATypeForRadioGroup;

    switch (widget.elementType) {
      case THElementType.area:
        title = mpLocator.appLocalizations.mpPLATypeAreaTitle;
        choices = MPTextToUser.getOrderedChoicesMap(
          MPTextToUser.getAreaTypeChoices(),
        );
        lastUsedChoices = widget
            .th2FileEditController
            .elementEditController
            .lastUsedAreaTypes;
        mostUsedChoices = widget
            .th2FileEditController
            .elementEditController
            .mostUsedAreaTypes;
      case THElementType.line:
        title = mpLocator.appLocalizations.mpPLATypeLineTitle;
        choices = MPTextToUser.getOrderedChoicesMap(
          MPTextToUser.getLineTypeChoices(),
        );
        lastUsedChoices = widget
            .th2FileEditController
            .elementEditController
            .lastUsedLineTypes;
        mostUsedChoices = widget
            .th2FileEditController
            .elementEditController
            .mostUsedLineTypes;
      case THElementType.point:
        title = mpLocator.appLocalizations.mpPLATypePointTitle;
        choices = MPTextToUser.getOrderedChoicesMap(
          MPTextToUser.getPointTypeChoices(),
        );
        lastUsedChoices = widget
            .th2FileEditController
            .elementEditController
            .lastUsedPointTypes;
        mostUsedChoices = widget
            .th2FileEditController
            .elementEditController
            .mostUsedPointTypes;
      default:
        return const SizedBox.shrink();
    }

    if (selectedPLATypeForRadioGroup.isNotEmpty &&
        !choices.containsKey(selectedPLATypeForRadioGroup)) {
      selectedPLATypeForRadioGroup = mpUnknownPLAType;
    }

    final bool initiallyUnknown =
        (widget.selectedPLAType != null &&
        widget.selectedPLAType!.isNotEmpty &&
        !choices.containsKey(widget.selectedPLAType));
    if (initiallyUnknown && !_unknownSelected) {
      _unknownSelected = true;
      _selectedPLATypeForRadioGroup = mpUnknownPLAType;
      _unknownController.text = widget.selectedPLAType!;
      _validateUnknown();
    }

    for (final String choice in lastUsedChoices) {
      if (choice == widget.selectedPLAType) {
        continue;
      }

      lastUsedChoicesReduced.add(choice);

      if (lastUsedChoicesReduced.length >= mpMaxLastUsedTypes) {
        break;
      }
    }

    for (final String choice in mostUsedChoices) {
      if (lastUsedChoicesReduced.contains(choice) ||
          (choice == widget.selectedPLAType)) {
        continue;
      }

      mostUsedChoicesReduced.add(choice);

      if (mostUsedChoicesReduced.length >= mpMaxMostUsedTypes) {
        break;
      }
    }

    return MPOverlayWindowWidget(
      title: title,
      overlayWindowType: MPOverlayWindowType.secondary,
      outerAnchorPosition: widget.outerAnchorPosition,
      innerAnchorType: widget.innerAnchorType,
      th2FileEditController: widget.th2FileEditController,
      children: [
        Column(
          children: [
            if ((widget.selectedPLAType != null) &&
                (widget.selectedPLAType != '')) ...[
              const SizedBox(height: mpButtonSpace),
              SizedBox(
                width: double.infinity,
                child: MPOverlayWindowBlockWidget(
                  title: mpLocator.appLocalizations.mpPLATypeCurrent,
                  overlayWindowBlockType: MPOverlayWindowBlockType.choiceSet,
                  padding: mpOverlayWindowBlockEdgeInsets,
                  children: [Text(widget.selectedPLAType!)],
                ),
              ),
            ],
            if (lastUsedChoicesReduced.isNotEmpty) ...[
              const SizedBox(height: mpButtonSpace),
              MPOverlayWindowBlockWidget(
                title: mpLocator.appLocalizations.mpPLATypeLastUsed,
                overlayWindowBlockType: MPOverlayWindowBlockType.choices,
                padding: mpOverlayWindowBlockEdgeInsets,
                children: [
                  RadioGroup(
                    groupValue: widget.selectedPLAType,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _onChanged(context, newValue);
                      }
                    },
                    child: Column(
                      children: [
                        ...lastUsedChoicesReduced.map((String choice) {
                          return MPPLATypeOptionWidget(
                            value: choice,
                            label: choices[choice]!,
                            valueKeyID: 'lastUsedChoices',
                            th2FileEditController: widget.th2FileEditController,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (mostUsedChoicesReduced.isNotEmpty) ...[
              const SizedBox(height: mpButtonSpace),
              MPOverlayWindowBlockWidget(
                title: mpLocator.appLocalizations.mpPLATypeMostUsed,
                overlayWindowBlockType: MPOverlayWindowBlockType.choices,
                padding: mpOverlayWindowBlockEdgeInsets,
                children: [
                  RadioGroup(
                    groupValue: widget.selectedPLAType,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _onChanged(context, newValue);
                      }
                    },
                    child: Column(
                      children: [
                        ...mostUsedChoicesReduced.map((String choice) {
                          return MPPLATypeOptionWidget(
                            value: choice,
                            label: choices[choice]!,
                            valueKeyID: 'mostUsedChoices',
                            th2FileEditController: widget.th2FileEditController,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: mpButtonSpace),
            MPOverlayWindowBlockWidget(
              title: mpLocator.appLocalizations.mpPLATypeAll,
              overlayWindowBlockType: MPOverlayWindowBlockType.choices,
              padding: mpOverlayWindowBlockEdgeInsets,
              children: [
                RadioGroup(
                  groupValue: _selectedPLATypeForRadioGroup,
                  onChanged: (String? newValue) {
                    if (newValue == null) return;
                    if (newValue == mpUnknownPLAType) {
                      setState(() {
                        _selectedPLATypeForRadioGroup = mpUnknownPLAType;
                        _unknownSelected = true;
                        if (_unknownController.text.isEmpty &&
                            !initiallyUnknown) {
                          _unknownController.text = '';
                        }
                        _validateUnknown();
                      });
                    } else {
                      _unknownSelected = false;
                      _selectedPLATypeForRadioGroup = newValue;
                      _onChanged(context, newValue);
                    }
                  },
                  child: Column(
                    children: [
                      ...choices.entries.map((MapEntry<String, String> entry) {
                        final bool isUnknown = entry.key == mpUnknownPLAType;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MPPLATypeOptionWidget(
                              value: entry.key,
                              label: entry.value,
                              valueKeyID: 'choices',
                              th2FileEditController:
                                  widget.th2FileEditController,
                            ),
                            if (isUnknown &&
                                _unknownSelected &&
                                _selectedPLATypeForRadioGroup ==
                                    mpUnknownPLAType)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 32,
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _unknownController,
                                        autofocus: true,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'[A-Za-z0-9]'),
                                          ),
                                        ],
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 8,
                                              ),
                                          border: const OutlineInputBorder(),
                                          labelText: mpLocator
                                              .appLocalizations
                                              .mpPLATypeUnknownLabel,
                                          errorText:
                                              _unknownController.text.isEmpty
                                              ? null
                                              : (!_unknownValid
                                                    ? mpLocator
                                                          .appLocalizations
                                                          .mpPLATypeUnknownInvalid
                                                    : null),
                                        ),
                                        onChanged: (_) => _validateUnknown(),
                                        onSubmitted: (_) {
                                          if (_unknownValid) {
                                            _applyUnknown(context);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: _unknownValid
                                          ? () => _applyUnknown(context)
                                          : null,
                                      child: Text(
                                        mpLocator.appLocalizations.mpButtonOK,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _onChanged(BuildContext context, String newValue) {
    widget.th2FileEditController.userInteractionController.prepareSetPLAType(
      elementType: widget.elementType,
      newPLAType: newValue,
    );
    widget.th2FileEditController.overlayWindowController.setShowOverlayWindow(
      MPWindowType.plaTypes,
      false,
    );
  }
}
