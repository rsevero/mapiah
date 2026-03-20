// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/auxiliary/mp_search_select_criteria.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_search_controller.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/types/th_area_type.dart';
import 'package:mapiah/src/elements/types/th_line_type.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPSearchSelectDialogWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final VoidCallback onPressedClose;

  const MPSearchSelectDialogWidget({
    super.key,
    required this.th2FileEditController,
    required this.onPressedClose,
  });

  @override
  State<MPSearchSelectDialogWidget> createState() =>
      _MPSearchSelectDialogWidgetState();
}

class _MPSearchSelectDialogWidgetState
    extends State<MPSearchSelectDialogWidget> {
  late final TH2FileEditSearchController _searchController;
  late final MPSearchSelectCriteria _criteria;
  late final AppLocalizations _appLocalizations;

  late final Set<String> _unknownPointTypes;
  late final Set<String> _unknownLineTypes;
  late final Set<String> _unknownAreaTypes;

  late final List<THPointType> _sortedPointTypes;
  late final List<THLineType> _sortedLineTypes;
  late final List<THAreaType> _sortedAreaTypes;

  late final List<THCommandOptionType> _sortedPointOptions;
  late final List<THCommandOptionType> _sortedLineOptions;
  late final List<THCommandOptionType> _sortedLineSegmentOptions;
  late final List<THCommandOptionType> _sortedAreaOptions;

  late final Map<String, Set<String>> _pointSubtypesByType;
  late final Map<String, Set<String>> _lineSubtypesByType;

  final TextEditingController _pointIDController = TextEditingController();
  final TextEditingController _lineIDController = TextEditingController();
  final TextEditingController _areaIDController = TextEditingController();
  final TextEditingController _pointSubtypeController = TextEditingController();
  final TextEditingController _lineSubtypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController = widget.th2FileEditController.searchController;
    _searchController.resetCriteria();
    _criteria = _searchController.criteria;
    _appLocalizations = mpLocator.appLocalizations;

    _unknownPointTypes = _searchController.getUnknownPointTypesInScrap();
    _unknownLineTypes = _searchController.getUnknownLineTypesInScrap();
    _unknownAreaTypes = _searchController.getUnknownAreaTypesInScrap();

    _sortedPointTypes = List<THPointType>.from(THPointType.values);
    _sortedPointTypes.sort(
      (THPointType a, THPointType b) => MPTextToUser.compareStringsUsingLocale(
        MPTextToUser.getPointType(a),
        MPTextToUser.getPointType(b),
      ),
    );

    _sortedLineTypes = List<THLineType>.from(THLineType.values);
    _sortedLineTypes.sort(
      (THLineType a, THLineType b) => MPTextToUser.compareStringsUsingLocale(
        MPTextToUser.getLineType(a),
        MPTextToUser.getLineType(b),
      ),
    );

    _sortedAreaTypes = List<THAreaType>.from(THAreaType.values);
    _sortedAreaTypes.sort(
      (THAreaType a, THAreaType b) => MPTextToUser.compareStringsUsingLocale(
        MPTextToUser.getAreaType(a),
        MPTextToUser.getAreaType(b),
      ),
    );

    _sortedPointOptions = MPCommandOptionAux.getTHCommandOptionTypeOrderedList(
      MPCommandOptionAux.getAllSupportedPointOptions(),
    );
    _sortedLineOptions = MPCommandOptionAux.getTHCommandOptionTypeOrderedList(
      MPCommandOptionAux.getAllSupportedLineOptions(),
    );
    _sortedLineSegmentOptions =
        MPCommandOptionAux.getTHCommandOptionTypeOrderedList(
          MPCommandOptionAux.getAllSupportedLineSegmentOptions(),
        );
    _sortedAreaOptions = MPCommandOptionAux.getTHCommandOptionTypeOrderedList(
      MPCommandOptionAux.getAllSupportedAreaOptions(),
    );

    _pointSubtypesByType = _extractSubtypes('point');
    _lineSubtypesByType = _extractSubtypes('line');
  }

  Map<String, Set<String>> _extractSubtypes(String plaCategory) {
    final Map<String, Set<String>> result = {};
    final Map<String, Map<String, Object>>? categoryMap =
        MPCommandOptionAux.supportedSubtypes[plaCategory];

    if (categoryMap == null) {
      return result;
    }

    for (final MapEntry<String, Map<String, Object>> entry
        in categoryMap.entries) {
      final Object? subtypes = entry.value['subtypes'];

      if (subtypes is Set<String>) {
        result[entry.key] = subtypes;
      }
    }

    return result;
  }

  Set<String> _getAllSubtypesForPLA(String plaCategory) {
    final Map<String, Set<String>> subtypesByType;

    switch (plaCategory) {
      case 'point':
        subtypesByType = _pointSubtypesByType;
      case 'line':
        subtypesByType = _lineSubtypesByType;
      default:
        return {};
    }

    final Set<String> allSubtypes = {};

    for (final Set<String> subtypes in subtypesByType.values) {
      allSubtypes.addAll(subtypes);
    }

    return allSubtypes;
  }

  @override
  void dispose() {
    _pointIDController.dispose();
    _lineIDController.dispose();
    _areaIDController.dispose();
    _pointSubtypeController.dispose();
    _lineSubtypeController.dispose();
    super.dispose();
  }

  void _onCriteriaChanged() {
    setState(() {
      _searchController.updateMatchingCount();
    });
  }

  void _onSetSelection() {
    _searchController.setSelection();
    widget.onPressedClose();
  }

  void _onAddToSelection() {
    _searchController.addToSelection();
    widget.onPressedClose();
  }

  void _onRemoveFromSelection() {
    _searchController.removeFromSelection();
    widget.onPressedClose();
  }

  void _onReset() {
    _searchController.resetCriteria();
    _pointIDController.clear();
    _lineIDController.clear();
    _areaIDController.clear();
    _pointSubtypeController.clear();
    _lineSubtypeController.clear();
    _onCriteriaChanged();
  }

  void _onCancel() {
    widget.onPressedClose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int matchingCount = _searchController.matchingCount;

    return SizedBox(
      width: 720,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _appLocalizations.th2FileEditPageSearchSelectTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: mpButtonSpace),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _appLocalizations.th2FileEditPageSearchSelectMatchCount(
                matchingCount,
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ),

          const SizedBox(height: mpButtonSpace),

          _buildSection(
            title: _appLocalizations.th2FileEditPageSearchSelectPoints,
            section: _criteria.points,
            plaCategory: 'point',
          ),
          _buildSection(
            title: _appLocalizations.th2FileEditPageSearchSelectLines,
            section: _criteria.lines,
            plaCategory: 'line',
          ),
          _buildSection(
            title: _appLocalizations.th2FileEditPageSearchSelectAreas,
            section: _criteria.areas,
            plaCategory: 'area',
          ),

          const SizedBox(height: mpButtonSpace),

          // Action buttons
          Wrap(
            spacing: mpButtonSpace,
            runSpacing: mpButtonSpace,
            alignment: WrapAlignment.end,
            children: [
              TextButton(
                onPressed: _onReset,
                child: Text(_appLocalizations.th2FileEditPageSearchSelectReset),
              ),
              TextButton(
                onPressed: _onCancel,
                child: Text(
                  _appLocalizations.th2FileEditPageSearchSelectCancel,
                ),
              ),
              ElevatedButton(
                onPressed: matchingCount > 0 ? _onRemoveFromSelection : null,
                child: Text(
                  _appLocalizations
                      .th2FileEditPageSearchSelectRemoveFromSelection,
                ),
              ),
              ElevatedButton(
                onPressed: matchingCount > 0 ? _onAddToSelection : null,
                child: Text(
                  _appLocalizations.th2FileEditPageSearchSelectAddToSelection,
                ),
              ),
              ElevatedButton(
                onPressed: matchingCount > 0 ? _onSetSelection : null,
                child: Text(
                  _appLocalizations.th2FileEditPageSearchSelectSetSelection,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required MPSearchSelectSectionCriteria section,
    required String plaCategory,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: section.enabled,
              onChanged: (bool? value) {
                section.enabled = value ?? false;
                _onCriteriaChanged();
              },
            ),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
        if (section.enabled) _buildSectionContent(section, plaCategory),
      ],
    );
  }

  Widget _buildSectionContent(
    MPSearchSelectSectionCriteria section,
    String plaCategory,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // All checkbox
          CheckboxListTile(
            title: Text(_appLocalizations.th2FileEditPageSearchSelectAll),
            value: section.selectAll,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              if (value == true) {
                section.setAllEnabled();
              } else {
                section.disableAll();
              }
              _onCriteriaChanged();
            },
          ),

          // By ID checkbox
          CheckboxListTile(
            title: Text(_appLocalizations.th2FileEditPageSearchSelectByID),
            value: section.byID,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: section.selectAll
                ? null
                : (bool? value) {
                    section.byID = value ?? false;
                    _onCriteriaChanged();
                  },
          ),
          if (section.byID && !section.selectAll)
            _buildIDSubsection(section, plaCategory),

          // By subtype checkbox
          if (plaCategory != 'area')
            CheckboxListTile(
              title: Text(
                _appLocalizations.th2FileEditPageSearchSelectBySubtype,
              ),
              value: section.bySubtype,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: section.selectAll
                  ? null
                  : (bool? value) {
                      section.bySubtype = value ?? false;
                      _onCriteriaChanged();
                    },
            ),
          if (section.bySubtype && !section.selectAll && plaCategory != 'area')
            _buildSubtypeSubsection(section, plaCategory),

          // By type checkbox
          CheckboxListTile(
            title: Text(_appLocalizations.th2FileEditPageSearchSelectByType),
            value: section.byType,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: section.selectAll
                ? null
                : (bool? value) {
                    section.byType = value ?? false;
                    _onCriteriaChanged();
                  },
          ),
          if (section.byType && !section.selectAll)
            _buildTypeSubsection(section, plaCategory),

          // By option checkbox
          CheckboxListTile(
            title: Text(_appLocalizations.th2FileEditPageSearchSelectByOption),
            value: section.byOption,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: section.selectAll
                ? null
                : (bool? value) {
                    section.byOption = value ?? false;
                    _onCriteriaChanged();
                  },
          ),
          if (section.byOption && !section.selectAll)
            _buildOptionSubsection(section, plaCategory),

          // By line segment option checkbox (lines only)
          if (plaCategory == 'line')
            CheckboxListTile(
              title: Text(
                _appLocalizations
                    .th2FileEditPageSearchSelectByLineSegmentOption,
              ),
              value: section.byLineSegmentOption,
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: section.selectAll
                  ? null
                  : (bool? value) {
                      section.byLineSegmentOption = value ?? false;
                      _onCriteriaChanged();
                    },
            ),
          if (plaCategory == 'line' &&
              section.byLineSegmentOption &&
              !section.selectAll)
            _buildLineSegmentOptionSubsection(section),
        ],
      ),
    );
  }

  Widget _buildIDSubsection(
    MPSearchSelectSectionCriteria section,
    String plaCategory,
  ) {
    final TextEditingController textController;

    switch (plaCategory) {
      case 'point':
        textController = _pointIDController;
      case 'line':
        textController = _lineIDController;
      default:
        textController = _areaIDController;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: _appLocalizations.th2FileEditPageSearchSelectByID,
                isDense: true,
              ),
              onChanged: (String value) {
                section.idSearchText = value;
                _onCriteriaChanged();
              },
            ),
          ),
          const SizedBox(width: mpButtonSpace),
          TextButton(
            onPressed: () {
              textController.clear();
              section.idSearchText = '';
              _onCriteriaChanged();
            },
            child: Text(_appLocalizations.th2FileEditPageSearchSelectReset),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtypeSubsection(
    MPSearchSelectSectionCriteria section,
    String plaCategory,
  ) {
    final Set<String> availableSubtypes = _getAllSubtypesForPLA(plaCategory);
    final List<String> sortedSubtypes = availableSubtypes.toList()
      ..sort(MPTextToUser.compareStringsUsingLocale);

    final TextEditingController textController;

    switch (plaCategory) {
      case 'point':
        textController = _pointSubtypeController;
      default:
        textController = _lineSubtypeController;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final String subtype in sortedSubtypes)
                FilterChip(
                  label: Text(subtype),
                  selected: section.selectedSubtypes.contains(subtype),
                  onSelected: (bool selected) {
                    if (selected) {
                      section.selectedSubtypes.add(subtype);
                    } else {
                      section.selectedSubtypes.remove(subtype);
                    }
                    _onCriteriaChanged();
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText:
                        _appLocalizations.th2FileEditPageSearchSelectBySubtype,
                    isDense: true,
                  ),
                  onChanged: (String value) {
                    section.subtypeSearchText = value;
                    _onCriteriaChanged();
                  },
                ),
              ),
              const SizedBox(width: mpButtonSpace),
              TextButton(
                onPressed: () {
                  textController.clear();
                  section.subtypeSearchText = '';
                  section.selectedSubtypes.clear();
                  _onCriteriaChanged();
                },
                child: Text(_appLocalizations.th2FileEditPageSearchSelectReset),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSubsection(
    MPSearchSelectSectionCriteria section,
    String plaCategory,
  ) {
    final List<Widget> chips = [];

    switch (plaCategory) {
      case 'point':
        for (final THPointType pointType in _sortedPointTypes) {
          chips.add(
            FilterChip(
              label: Text(MPTextToUser.getPointType(pointType)),
              selected: section.selectedPointTypes.contains(pointType),
              onSelected: (bool selected) {
                if (selected) {
                  section.selectedPointTypes.add(pointType);
                } else {
                  section.selectedPointTypes.remove(pointType);
                }
                _onCriteriaChanged();
              },
            ),
          );
        }
        for (final String unknownType in _unknownPointTypes) {
          chips.add(
            FilterChip(
              label: Text(unknownType),
              selected: section.selectedUnknownTypes.contains(unknownType),
              onSelected: (bool selected) {
                if (selected) {
                  section.selectedUnknownTypes.add(unknownType);
                } else {
                  section.selectedUnknownTypes.remove(unknownType);
                }
                _onCriteriaChanged();
              },
            ),
          );
        }
      case 'line':
        for (final THLineType lineType in _sortedLineTypes) {
          chips.add(
            FilterChip(
              label: Text(MPTextToUser.getLineType(lineType)),
              selected: section.selectedLineTypes.contains(lineType),
              onSelected: (bool selected) {
                if (selected) {
                  section.selectedLineTypes.add(lineType);
                } else {
                  section.selectedLineTypes.remove(lineType);
                }
                _onCriteriaChanged();
              },
            ),
          );
        }
        for (final String unknownType in _unknownLineTypes) {
          chips.add(
            FilterChip(
              label: Text(unknownType),
              selected: section.selectedUnknownTypes.contains(unknownType),
              onSelected: (bool selected) {
                if (selected) {
                  section.selectedUnknownTypes.add(unknownType);
                } else {
                  section.selectedUnknownTypes.remove(unknownType);
                }
                _onCriteriaChanged();
              },
            ),
          );
        }
      case 'area':
        for (final THAreaType areaType in _sortedAreaTypes) {
          chips.add(
            FilterChip(
              label: Text(MPTextToUser.getAreaType(areaType)),
              selected: section.selectedAreaTypes.contains(areaType),
              onSelected: (bool selected) {
                if (selected) {
                  section.selectedAreaTypes.add(areaType);
                } else {
                  section.selectedAreaTypes.remove(areaType);
                }
                _onCriteriaChanged();
              },
            ),
          );
        }
        for (final String unknownType in _unknownAreaTypes) {
          chips.add(
            FilterChip(
              label: Text(unknownType),
              selected: section.selectedUnknownTypes.contains(unknownType),
              onSelected: (bool selected) {
                if (selected) {
                  section.selectedUnknownTypes.add(unknownType);
                } else {
                  section.selectedUnknownTypes.remove(unknownType);
                }
                _onCriteriaChanged();
              },
            ),
          );
        }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Wrap(spacing: 4, runSpacing: 4, children: chips),
    );
  }

  Widget _buildLineSegmentOptionSubsection(
    MPSearchSelectSectionCriteria section,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final THCommandOptionType optionType
              in _sortedLineSegmentOptions)
            _buildLineSegmentOptionRow(section, optionType),
        ],
      ),
    );
  }

  Widget _buildLineSegmentOptionRow(
    MPSearchSelectSectionCriteria section,
    THCommandOptionType optionType,
  ) {
    final MPOptionSearchState currentState =
        section.lineSegmentOptionStates[optionType] ??
        MPOptionSearchState.undefined;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(MPTextToUser.getCommandOptionType(optionType)),
          ),
          SegmentedButton<MPOptionSearchState>(
            segments: [
              ButtonSegment<MPOptionSearchState>(
                value: MPOptionSearchState.undefined,
                label: Text(
                  _appLocalizations.th2FileEditPageSearchSelectOptionUndefined,
                ),
              ),
              ButtonSegment<MPOptionSearchState>(
                value: MPOptionSearchState.set,
                label: Text(
                  _appLocalizations.th2FileEditPageSearchSelectOptionSet,
                ),
              ),
              ButtonSegment<MPOptionSearchState>(
                value: MPOptionSearchState.unset,
                label: Text(
                  _appLocalizations.th2FileEditPageSearchSelectOptionUnset,
                ),
              ),
            ],
            selected: {currentState},
            onSelectionChanged: (Set<MPOptionSearchState> newSelection) {
              section.lineSegmentOptionStates[optionType] = newSelection.first;
              _onCriteriaChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionSubsection(
    MPSearchSelectSectionCriteria section,
    String plaCategory,
  ) {
    final List<THCommandOptionType> sortedOptions;

    switch (plaCategory) {
      case 'point':
        sortedOptions = _sortedPointOptions;
      case 'line':
        sortedOptions = _sortedLineOptions;
      default:
        sortedOptions = _sortedAreaOptions;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final THCommandOptionType optionType in sortedOptions)
            _buildOptionRow(section, optionType),
        ],
      ),
    );
  }

  Widget _buildOptionRow(
    MPSearchSelectSectionCriteria section,
    THCommandOptionType optionType,
  ) {
    final MPOptionSearchState currentState =
        section.optionStates[optionType] ?? MPOptionSearchState.undefined;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(MPTextToUser.getCommandOptionType(optionType)),
          ),
          SegmentedButton<MPOptionSearchState>(
            segments: [
              ButtonSegment<MPOptionSearchState>(
                value: MPOptionSearchState.undefined,
                label: Text(
                  _appLocalizations.th2FileEditPageSearchSelectOptionUndefined,
                ),
              ),
              ButtonSegment<MPOptionSearchState>(
                value: MPOptionSearchState.set,
                label: Text(
                  _appLocalizations.th2FileEditPageSearchSelectOptionSet,
                ),
              ),
              ButtonSegment<MPOptionSearchState>(
                value: MPOptionSearchState.unset,
                label: Text(
                  _appLocalizations.th2FileEditPageSearchSelectOptionUnset,
                ),
              ),
            ],
            selected: {currentState},
            onSelectionChanged: (Set<MPOptionSearchState> newSelection) {
              section.optionStates[optionType] = newSelection.first;
              _onCriteriaChanged();
            },
          ),
        ],
      ),
    );
  }
}
