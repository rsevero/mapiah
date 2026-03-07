import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPSettingsPage extends StatefulWidget {
  const MPSettingsPage({super.key});

  @override
  State<MPSettingsPage> createState() => _MPSettingsPageState();
}

class _MPSettingsPageState extends State<MPSettingsPage> {
  final Map<MPSettingID, dynamic> _draftValues = {};
  final Map<MPSettingID, String?> _errors = {};
  final Map<MPSettingID, int> _fieldRebuildCounters = {};

  @override
  void initState() {
    super.initState();
    _reloadDraftFromController();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final List<String> sections = _sortedSections(appLocalizations);

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.mpSettingsPageTitle)),
      body: ListView(
        padding: const EdgeInsets.all(mpSettingsPageOuterPadding),
        children: [
          for (final String section in sections) ...[
            _buildSectionCard(
              appLocalizations: appLocalizations,
              section: section,
            ),
            const SizedBox(height: mpSettingsPageSectionSpacing),
          ],
          const SizedBox(height: mpSettingsPageSectionSpacing),
          Row(
            children: [
              ElevatedButton(
                onPressed: _closeAndSave,
                child: Text(appLocalizations.mpButtonSaveAndClose),
              ),
              const SizedBox(width: mpSettingsPageButtonSpacing),
              ElevatedButton(
                onPressed: _applyChanges,
                child: Text(appLocalizations.mpButtonApply),
              ),
              const SizedBox(width: mpSettingsPageButtonSpacing),
              ElevatedButton(
                onPressed: _cancelChanges,
                child: Text(appLocalizations.mpButtonCancel),
              ),
              const SizedBox(width: mpSettingsPageButtonSpacing),
              ElevatedButton(
                onPressed: _resetAllSettings,
                child: Text(appLocalizations.mpButtonResetAllSettings),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required AppLocalizations appLocalizations,
    required String section,
  }) {
    final List<MPSettingID> types = _sortedSettingsInSection(
      appLocalizations,
      section,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(mpSettingsPageCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _localizedSectionName(appLocalizations, section),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: mpSettingsPageFieldSpacing),
            for (final MPSettingID type in types) ...[
              _buildSettingField(appLocalizations, type),
              const SizedBox(height: mpSettingsPageFieldSpacing),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingField(
    AppLocalizations appLocalizations,
    MPSettingID type,
  ) {
    final String settingLabel = _localizedSettingName(appLocalizations, type);

    switch (type.type()) {
      case MPSettingType.bool:
        return _buildSettingFieldWithReset(
          appLocalizations: appLocalizations,
          type: type,
          field: _constrainedEditableField(
            SwitchListTile(
              value: (_draftValues[type] as bool?) ?? false,
              title: Text(settingLabel),
              onChanged: (bool value) {
                setState(() {
                  _draftValues[type] = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ),
        );
      case MPSettingType.filePickerExec:
        return _buildSettingFieldWithReset(
          appLocalizations: appLocalizations,
          type: type,
          field: _constrainedEditableField(
            TextFormField(
              key: ValueKey<int>(_fieldRebuildCounters[type] ?? 0),
              initialValue: (_draftValues[type] as String?) ?? '',
              readOnly: true,
              decoration: InputDecoration(
                labelText: settingLabel,
                errorText: _errors[type],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: () => _pickExecutableForSetting(type),
                ),
              ),
              onTap: () => _pickExecutableForSetting(type),
            ),
          ),
        );
      case MPSettingType.double:
      case MPSettingType.int:
      case MPSettingType.string:
      case MPSettingType.stringList:
        if (type == MPSettingID.Main_LocaleID) {
          final List<String> localeIDs = [
            mpDefaultLocaleID,
            ...AppLocalizations.supportedLocales.map(
              (locale) => locale.languageCode,
            ),
          ];

          final String currentValue =
              (_draftValues[type] as String?) ?? mpDefaultLocaleID;

          return _buildSettingFieldWithReset(
            appLocalizations: appLocalizations,
            type: type,
            field: _constrainedEditableField(
              DropdownButtonFormField<String>(
                key: ValueKey<int>(_fieldRebuildCounters[type] ?? 0),
                initialValue: localeIDs.contains(currentValue)
                    ? currentValue
                    : mpDefaultLocaleID,
                decoration: InputDecoration(labelText: settingLabel),
                items: localeIDs
                    .map(
                      (String localeID) => DropdownMenuItem<String>(
                        value: localeID,
                        child: Text(appLocalizations.languageName(localeID)),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _draftValues[type] = value;
                    _errors[type] = null;
                  });
                },
              ),
            ),
          );
        }

        return _buildSettingFieldWithReset(
          appLocalizations: appLocalizations,
          type: type,
          field: _constrainedEditableField(
            TextFormField(
              key: ValueKey<int>(_fieldRebuildCounters[type] ?? 0),
              initialValue: (_draftValues[type] as String?) ?? '',
              decoration: InputDecoration(
                labelText: settingLabel,
                errorText: _errors[type],
              ),
              onChanged: (String value) {
                setState(() {
                  _draftValues[type] = value;
                  _errors[type] = _validateTextDraftValue(
                    appLocalizations,
                    type,
                    value,
                  );
                });
              },
            ),
          ),
        );
    }
  }

  Future<void> _pickExecutableForSetting(MPSettingID type) async {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final String dialogTitle = _localizedSettingName(appLocalizations, type);
    final String? pickedPath = await MPDialogAux.pickExecutableFilePath(
      context,
      dialogTitle: dialogTitle,
    );

    if (!mounted || (pickedPath == null)) {
      return;
    }

    setState(() {
      _draftValues[type] = pickedPath;
      _errors[type] = null;
      _incrementFieldRebuildCounter(type);
    });
  }

  Widget _buildSettingFieldWithReset({
    required AppLocalizations appLocalizations,
    required MPSettingID type,
    required Widget field,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: field),
        const SizedBox(width: mpSettingsPageButtonSpacing),
        IconButton(
          onPressed: () => _resetSingleSetting(type),
          tooltip: appLocalizations.thMultipleChoicePlaceDefault,
          icon: const Icon(Icons.restart_alt),
        ),
      ],
    );
  }

  String? _validateTextDraftValue(
    AppLocalizations appLocalizations,
    MPSettingID type,
    String value,
  ) {
    final String raw = value.trim();

    switch (type.type()) {
      case MPSettingType.double:
        return double.tryParse(raw) == null
            ? appLocalizations.mpSettingsInvalidNumber
            : null;
      case MPSettingType.int:
        return int.tryParse(raw) == null
            ? appLocalizations.mpSettingsInvalidInteger
            : null;
      case MPSettingType.bool:
      case MPSettingType.string:
      case MPSettingType.stringList:
      case MPSettingType.filePickerExec:
        return null;
    }
  }

  Widget _constrainedEditableField(Widget child) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double minWidth = mpSettingsEditableFieldMinWidth;
        final double maxWidth = constraints.maxWidth;

        return Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: minWidth <= maxWidth ? minWidth : maxWidth,
              maxWidth: maxWidth,
            ),
            child: IntrinsicWidth(child: child),
          ),
        );
      },
    );
  }

  void _reloadDraftFromController() {
    final settingsController = mpLocator.mpSettingsController;

    _draftValues.clear();
    _errors.clear();

    for (final MPSettingID type in MPSettingID.values) {
      if (type.section() == mpSettingsInternalSection) {
        continue;
      }

      switch (type.type()) {
        case MPSettingType.bool:
          _draftValues[type] = settingsController.getBoolWithDefault(type);
        case MPSettingType.double:
          _draftValues[type] = settingsController
              .getDoubleWithDefault(type)
              .toString();
        case MPSettingType.int:
          _draftValues[type] = settingsController
              .getIntWithDefault(type)
              .toString();
        case MPSettingType.string:
          _draftValues[type] = settingsController.getStringWithDefault(type);
        case MPSettingType.stringList:
          _draftValues[type] = settingsController
              .getStringListWithDefault(type)
              .join(mpSettingsStringListSeparator);
        case MPSettingType.filePickerExec:
          _draftValues[type] = settingsController.getStringWithDefault(type);
      }

      _incrementFieldRebuildCounter(type);
    }
  }

  void _resetSingleSetting(MPSettingID type) {
    final MPSettingsController settingsController =
        mpLocator.mpSettingsController;

    setState(() {
      switch (type.type()) {
        case MPSettingType.bool:
          _draftValues[type] = settingsController.getDefaultBool(type);
        case MPSettingType.double:
          _draftValues[type] = settingsController
              .getDefaultDouble(type)
              .toString();
        case MPSettingType.int:
          _draftValues[type] = settingsController
              .getDefaultInt(type)
              .toString();
        case MPSettingType.string:
          _draftValues[type] = settingsController.getDefaultString(type);
        case MPSettingType.stringList:
          _draftValues[type] = settingsController
              .getDefaultStringList(type)
              .join(mpSettingsStringListSeparator);
        case MPSettingType.filePickerExec:
          _draftValues[type] = settingsController.getDefaultString(type);
      }

      _errors[type] = null;
      _incrementFieldRebuildCounter(type);
    });
  }

  void _resetAllSettings() {
    final MPSettingsController settingsController =
        mpLocator.mpSettingsController;

    setState(() {
      _errors.clear();

      for (final MPSettingID type in MPSettingID.values) {
        if (type.section() == mpSettingsInternalSection) {
          continue;
        }

        switch (type.type()) {
          case MPSettingType.bool:
            _draftValues[type] = settingsController.getDefaultBool(type);
          case MPSettingType.double:
            _draftValues[type] = settingsController
                .getDefaultDouble(type)
                .toString();
          case MPSettingType.int:
            _draftValues[type] = settingsController
                .getDefaultInt(type)
                .toString();
          case MPSettingType.string:
            _draftValues[type] = settingsController.getDefaultString(type);
          case MPSettingType.stringList:
            _draftValues[type] = settingsController
                .getDefaultStringList(type)
                .join(mpSettingsStringListSeparator);
          case MPSettingType.filePickerExec:
            _draftValues[type] = settingsController.getDefaultString(type);
        }

        _incrementFieldRebuildCounter(type);
      }
    });
  }

  void _incrementFieldRebuildCounter(MPSettingID type) {
    final int current = _fieldRebuildCounters[type] ?? mpMinimumInt;

    _fieldRebuildCounters[type] = current + 1;
  }

  void _cancelChanges() {
    Navigator.of(context).pop();
  }

  void _closeAndSave() {
    final bool isApplied = _applyChanges();

    if (isApplied) {
      Navigator.of(context).pop();
    }
  }

  bool _applyChanges() {
    final MPSettingsController settingsController =
        mpLocator.mpSettingsController;
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final Map<MPSettingID, String?> newErrors = {};

    for (final MPSettingID type in MPSettingID.values) {
      if (type.section() == mpSettingsInternalSection) {
        continue;
      }

      switch (type.type()) {
        case MPSettingType.bool:
          settingsController.setBool(
            type,
            (_draftValues[type] as bool?) ?? false,
          );
        case MPSettingType.double:
          final String raw = (_draftValues[type] as String?)?.trim() ?? '';
          final String? error = _validateTextDraftValue(
            appLocalizations,
            type,
            raw,
          );

          if (error != null) {
            newErrors[type] = error;
            continue;
          }

          final double? value = double.tryParse(raw);

          if (value == null) {
            continue;
          }

          settingsController.setDouble(type, value);
        case MPSettingType.int:
          final String raw = (_draftValues[type] as String?)?.trim() ?? '';
          final String? error = _validateTextDraftValue(
            appLocalizations,
            type,
            raw,
          );

          if (error != null) {
            newErrors[type] = error;
            continue;
          }

          final int? value = int.tryParse(raw);

          if (value == null) {
            continue;
          }

          settingsController.setInt(type, value);
        case MPSettingType.string:
          settingsController.setString(
            type,
            (_draftValues[type] as String?) ?? '',
          );
        case MPSettingType.stringList:
          final String raw = (_draftValues[type] as String?) ?? '';
          final List<String> values = raw
              .split(',')
              .map((String entry) => entry.trim())
              .where((String entry) => entry.isNotEmpty)
              .toList();
          settingsController.setStringList(type, values);
        case MPSettingType.filePickerExec:
          settingsController.setString(
            type,
            (_draftValues[type] as String?) ?? '',
          );
      }
    }

    setState(() {
      _errors
        ..clear()
        ..addAll(newErrors);
    });

    return newErrors.isEmpty;
  }

  List<String> _sortedSections(AppLocalizations appLocalizations) {
    final Set<String> sectionSet = MPSettingID.values
        .map((MPSettingID type) => type.section())
        .where((String section) => section != mpSettingsInternalSection)
        .toSet();

    final List<String> sections = sectionSet.toList();

    sections.sort((String a, String b) {
      if ((a == mpSettingsMainSection) && (b != mpSettingsMainSection)) {
        return -1;
      }
      if ((a != mpSettingsMainSection) && (b == mpSettingsMainSection)) {
        return 1;
      }

      final String localizedA = _localizedSectionName(appLocalizations, a);
      final String localizedB = _localizedSectionName(appLocalizations, b);

      return localizedA.toLowerCase().compareTo(localizedB.toLowerCase());
    });

    return sections;
  }

  List<MPSettingID> _sortedSettingsInSection(
    AppLocalizations appLocalizations,
    String section,
  ) {
    final List<MPSettingID> settings = MPSettingID.values
        .where((MPSettingID type) => type.section() == section)
        .toList();

    settings.sort((MPSettingID a, MPSettingID b) {
      final String localizedA = _localizedSettingName(appLocalizations, a);
      final String localizedB = _localizedSettingName(appLocalizations, b);

      return localizedA.toLowerCase().compareTo(localizedB.toLowerCase());
    });

    return settings;
  }

  String _localizedSectionName(
    AppLocalizations appLocalizations,
    String section,
  ) {
    switch (section) {
      case mpSettingsMainSection:
        return appLocalizations.mpSettingsSectionMain;
      case mpSettingsTH2EditSection:
        return appLocalizations.mpSettingsSectionTH2Edit;
      default:
        return _camelCaseToLabel(section);
    }
  }

  String _localizedSettingName(
    AppLocalizations appLocalizations,
    MPSettingID type,
  ) {
    switch (type) {
      case MPSettingID.Internal_LastCheckNumberOfNewerVersions:
      case MPSettingID.Internal_LastNewVersionCheckMS:
        return _camelCaseToLabel(type.id());
      case MPSettingID.Main_LocaleID:
        return appLocalizations.mpSettingsSettingMainLocaleID;
      case MPSettingID.Main_TherionExecutablePath:
        return appLocalizations.mpSettingsSettingMainTherionExecutablePath;
      case MPSettingID.TH2Edit_LineThickness:
        return appLocalizations.mpSettingsSettingTH2EditLineThickness;
      case MPSettingID.TH2Edit_PointRadius:
        return appLocalizations.mpSettingsSettingTH2EditPointRadius;
      case MPSettingID.TH2Edit_SelectionTolerance:
        return appLocalizations.mpSettingsSettingTH2EditSelectionTolerance;
    }
  }

  String _camelCaseToLabel(String value) {
    final String separated = value
        .replaceAll('_', ' ')
        .replaceAllMapped(
          RegExp(r'(?<!^)([A-Z])'),
          (Match m) => ' ${m.group(1)}',
        );

    if (separated.isEmpty) {
      return separated;
    }

    return '${separated[0].toUpperCase()}${separated.substring(1)}';
  }
}
