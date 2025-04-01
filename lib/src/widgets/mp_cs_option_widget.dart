import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_window_type.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/parts/th_cs_part.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/inputs/mp_int_range_input.widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_block_widget.dart';
import 'package:mapiah/src/widgets/mp_overlay_window_widget.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_block_type.dart';
import 'package:mapiah/src/widgets/types/mp_overlay_window_type.dart';
import 'package:mapiah/src/widgets/types/mp_widget_position_type.dart';

class MPCSOptionWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final MPOptionInfo optionInfo;
  final Offset outerAnchorPosition;
  final MPWidgetPositionType innerAnchorType;

  const MPCSOptionWidget({
    super.key,
    required this.th2FileEditController,
    required this.optionInfo,
    required this.outerAnchorPosition,
    required this.innerAnchorType,
  });

  @override
  State<MPCSOptionWidget> createState() => _MPCSOptionWidgetState();
}

class _MPCSOptionWidgetState extends State<MPCSOptionWidget> {
  String? _selectedChoice;
  String _currentValue = '';
  String _osgbMajor = '';
  String _osgbMinor = '';
  int _utmZone = 0;
  String _utmHemisphere = 'N';
  int _eptgESRIETRSIdentifier = 0;
  bool _forOutput = false;

  @override
  void initState() {
    super.initState();
    _selectedChoice = _determineInitialOption(
      widget.optionInfo.option == null
          ? null
          : (widget.optionInfo.option as THCSCommandOption).cs.name,
    );
  }

  String _determineInitialOption(String? initialValue) {
    if (initialValue == null || initialValue.isEmpty) {
      return mpUnsetOptionID;
    }

    final String matchingEntry = THCSPart.csList.firstWhere(
      (entry) => entry.toLowerCase() == initialValue.toLowerCase(),
      orElse: () => '',
    );

    if (matchingEntry.isNotEmpty) {
      return matchingEntry;
    }

    for (final entry in THCSPart.csRegexes.entries) {
      if (entry.value.hasMatch(initialValue)) {
        if (entry.key == 'EPSG' || entry.key == 'ESRI' || entry.key == 'ETRS') {
          final match = RegExp(r'\d+').firstMatch(initialValue);

          if (match != null) {
            _eptgESRIETRSIdentifier = int.tryParse(match.group(0)!) ?? 0;
          } else {
            _eptgESRIETRSIdentifier = 0;
          }
        } else if (entry.key == 'OSGB') {
          final match = RegExp(
            r'OSGB:([HNOST])([A-HJ-Z])',
            caseSensitive: false,
          ).firstMatch(initialValue);

          if (match != null) {
            _osgbMajor = match.group(1)!.toUpperCase();
            _osgbMinor = match.group(2)!.toUpperCase();
          }
        } else if (entry.key == 'UTM') {
          final match = RegExp(
            r'UTM(\d{1,2})([NS]?)',
            caseSensitive: false,
          ).firstMatch(initialValue);
          if (match != null) {
            _utmZone = int.tryParse(match.group(1)!) ?? 0;
            _utmHemisphere = match.group(2)?.isNotEmpty == true
                ? match.group(2)!.toUpperCase()
                : 'N';
          }
        }
        return entry.key;
      }
    }

    return mpUnrecognizedOptionID;
  }

  Widget _buildFormForOption(String option) {
    switch (option) {
      case mpUnsetOptionID:
        return const SizedBox.shrink();
      case mpUnrecognizedOptionID:
        return Padding(
          padding: const EdgeInsets.only(left: mpButtonSpace),
          child: Text(widget.optionInfo.option!.toString()),
        );
      case 'EPSG':
      case 'ESRI':
        return Padding(
          padding: const EdgeInsets.only(left: mpButtonSpace),
          child: MPIntRangeInputWidget(
            label: '$option identifier (1-99999)',
            min: 1,
            max: 99999,
            onChanged: (value) {
              if (value != null) {
                _eptgESRIETRSIdentifier = value;
                _updateCurrentValue();
              }
            },
          ),
        );
      case 'ETRS':
        return Padding(
          padding: const EdgeInsets.only(left: mpButtonSpace),
          child: MPIntRangeInputWidget(
            label: 'Optional ETRS identifier (28-37)',
            min: 28,
            max: 37,
            initialValue: _eptgESRIETRSIdentifier,
            allowEmpty: true,
            onChanged: (value) {
              _eptgESRIETRSIdentifier = (value == null) ? 0 : value;
              _updateCurrentValue();
            },
          ),
        );
      case 'iJTSK':
      case 'iJTSK03':
      case 'JTSK':
      case 'JTSK03':
        return const SizedBox.shrink();
      case 'OSGB':
        return Padding(
          padding: const EdgeInsets.only(left: mpButtonSpace),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OSGB major'),
                  DropdownMenu<String>(
                    initialSelection: _osgbMajor,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 'H', label: 'H'),
                      DropdownMenuEntry(value: 'N', label: 'N'),
                      DropdownMenuEntry(value: 'O', label: 'O'),
                      DropdownMenuEntry(value: 'S', label: 'S'),
                      DropdownMenuEntry(value: 'T', label: 'T'),
                    ],
                    onSelected: (value) {
                      if (value != null && value.isNotEmpty) {
                        _osgbMajor = value;
                        _updateCurrentValue();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(width: mpButtonSpace),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('OSGB minor'),
                  DropdownMenu<String>(
                    initialSelection: _osgbMinor,
                    dropdownMenuEntries: List.generate(
                      26,
                      (index) {
                        final char = String.fromCharCode(65 + index);
                        if (char == 'I') return null; // Skip 'I'
                        return DropdownMenuEntry(value: char, label: char);
                      },
                    ).whereType<DropdownMenuEntry<String>>().toList(),
                    onSelected: (value) {
                      if (value != null && value.isNotEmpty) {
                        _osgbMinor = value;
                        _updateCurrentValue();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      case 'UTM':
        return Padding(
          padding: const EdgeInsets.only(left: mpButtonSpace),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              MPIntRangeInputWidget(
                label: 'Zone number (1-60)',
                min: 1,
                max: 60,
                initialValue: _utmZone,
                onChanged: (value) {
                  if (value != null) {
                    _utmZone = value;
                    _updateCurrentValue();
                  }
                },
              ),
              const SizedBox(width: mpButtonSpace),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile<String>(
                      title: const Text('NORTH'),
                      value: 'N',
                      groupValue: _utmHemisphere,
                      dense: true,
                      onChanged: (value) {
                        if (value != null) {
                          setState(
                            () {
                              _utmHemisphere = value;
                              _updateCurrentValue();
                            },
                          );
                        }
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('SOUTH'),
                      value: 'S',
                      groupValue: _utmHemisphere,
                      dense: true,
                      onChanged: (value) {
                        if (value != null) {
                          setState(
                            () {
                              _utmHemisphere = value;
                              _updateCurrentValue();
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _okButtonPressed() {
    THCommandOption? newOption;

    if (_selectedChoice != mpUnsetOptionID) {
      if (_currentValue.isNotEmpty) {
        /// The THFileMPID is used only as a placeholder for the actual
        /// parentMPID of the option(s) to be set. THFile isn't even a
        /// THHasOptionsMixin so it can't actually be the parent of an option,
        /// i.e., is has no options at all.
        newOption = THCSCommandOption.fromStringWithParentMPID(
          parentMPID: widget.th2FileEditController.thFileMPID,
          csString: _currentValue,
          forOutputOnly: _forOutput,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mpLocator.appLocalizations.mpAuthorInvalidValueErrorMessage,
            ),
          ),
        );
        return;
      }
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

  void _updateCurrentValue() {
    switch (_selectedChoice) {
      case 'EPSG':
      case 'ESRI':
        _currentValue = "$_selectedChoice:$_eptgESRIETRSIdentifier";
      case 'ETRS':
        _currentValue = _eptgESRIETRSIdentifier > 0
            ? "$_selectedChoice:$_eptgESRIETRSIdentifier"
            : 'ETRS';
      case 'OSGB':
        _currentValue = 'OSGB:$_osgbMajor$_osgbMinor';
      case 'UTM':
        _currentValue = 'UTM$_utmZone$_utmHemisphere';

      /// In case of unrecognized option, we keep the current value.
      case mpUnrecognizedOptionID:
        break;
      default:
        _currentValue = _selectedChoice ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    List<String> allOptions = [
      ...THCSPart.csList,
      'EPSG',
      'ESRI',
      'ETRS',
      'iJTSK',
      'iJTSK03',
      'JTSK',
      'JTSK03',
      'OSGB',
      'UTM',
    ];

    allOptions.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    if (_selectedChoice == mpUnrecognizedOptionID) {
      allOptions.insert(0, mpUnrecognizedOptionID);
    }

    final bool isSet =
        ((_selectedChoice != null) && (_selectedChoice != mpUnsetOptionID));
    final List<Widget> optionWidgets = [];

    if (isSet) {
      optionWidgets.add(
        Row(
          children: [
            Text('For output'),
            const SizedBox(width: mpButtonSpace),
            Switch(
              value: _forOutput,
              onChanged: (value) {
                setState(
                  () {
                    _forOutput = value;
                  },
                );
              },
            ),
          ],
        ),
      );

      for (final String option in allOptions) {
        if (_forOutput && THCSPart.isCSNotForOutput(option)) {
          continue;
        }

        optionWidgets.add(
          RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: _selectedChoice,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              setState(() {
                _selectedChoice = value;
                _updateCurrentValue();
              });
            },
          ),
        );
        if (_selectedChoice == option) {
          optionWidgets.add(_buildFormForOption(option));
        }
      }
    }

    return MPOverlayWindowWidget(
      title: appLocalizations.thCommandOptionCopyright,
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
              title: Text(mpLocator.appLocalizations.mpChoiceUnset),
              value: mpUnsetOptionID,
              groupValue: _selectedChoice,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(
                  () {
                    _selectedChoice = value;
                    _updateCurrentValue();
                  },
                );
              },
            ),
            RadioListTile<String>(
              title: Text(mpLocator.appLocalizations.mpChoiceSet),
              value: mpNonMultipleChoiceSetID,
              groupValue: isSet ? mpNonMultipleChoiceSetID : _selectedChoice,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) {
                setState(
                  () {
                    _selectedChoice = value;
                    _updateCurrentValue();
                  },
                );
              },
            ),
            if (isSet)
              MPOverlayWindowBlockWidget(
                overlayWindowBlockType: MPOverlayWindowBlockType.secondarySet,
                padding: mpOverlayWindowBlockEdgeInsets,
                children: optionWidgets,
              ),
          ],
        ),
        const SizedBox(height: mpButtonSpace),
        Row(
          children: [
            ElevatedButton(
              onPressed: _okButtonPressed,
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
