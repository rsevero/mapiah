import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_dialog_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_settings_controller.dart';
import 'package:mapiah/src/controllers/auxiliary/mp_settings.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPSettingsPage extends StatefulWidget {
  const MPSettingsPage({super.key});

  @override
  State<MPSettingsPage> createState() => _MPSettingsPageState();
}

class _MPSettingsPageState extends State<MPSettingsPage> {
  final Map<MPSetting, dynamic> _draftValues = {};
  final Map<MPSetting, String?> _errors = {};
  final Map<MPSetting, int> _fieldRebuildCounters = {};

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
    final List<MPSetting> types = _sortedSettingsInSection(
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
            for (final MPSetting type in types) ...[
              _buildSettingField(appLocalizations, type),
              const SizedBox(height: mpSettingsPageFieldSpacing),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingField(AppLocalizations appLocalizations, MPSetting type) {
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
        if (type == MPSetting.Main_LocaleID) {
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

  Future<void> _pickExecutableForSetting(MPSetting type) async {
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
    required MPSetting type,
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
    MPSetting type,
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

    for (final MPSetting setting in MPSetting.values) {
      if (setting.section() == mpSettingsInternalSection) {
        continue;
      }

      switch (setting.type()) {
        case MPSettingType.bool:
          _draftValues[setting] = settingsController.getBool(setting);
        case MPSettingType.double:
          _draftValues[setting] = settingsController
              .getDouble(setting)
              .toString();
        case MPSettingType.int:
          _draftValues[setting] = settingsController.getInt(setting).toString();
        case MPSettingType.string:
          _draftValues[setting] = settingsController.getString(setting);
        case MPSettingType.stringList:
          _draftValues[setting] = settingsController
              .getStringList(setting)
              .join(mpSettingsStringListSeparator);
        case MPSettingType.filePickerExec:
          _draftValues[setting] = settingsController.getString(setting);
      }

      _incrementFieldRebuildCounter(setting);
    }
  }

  void _resetSingleSetting(MPSetting setting) {
    final MPSettingsController settingsController =
        mpLocator.mpSettingsController;

    setState(() {
      switch (setting.type()) {
        case MPSettingType.bool:
          _draftValues[setting] = settingsController.getDefaultBool(setting);
        case MPSettingType.double:
          _draftValues[setting] = settingsController
              .getDefaultDouble(setting)
              .toString();
        case MPSettingType.int:
          _draftValues[setting] = settingsController
              .getDefaultInt(setting)
              .toString();
        case MPSettingType.string:
          _draftValues[setting] = settingsController.getDefaultString(setting);
        case MPSettingType.stringList:
          _draftValues[setting] = settingsController
              .getDefaultStringList(setting)
              .join(mpSettingsStringListSeparator);
        case MPSettingType.filePickerExec:
          _draftValues[setting] = settingsController.getDefaultString(setting);
      }

      _errors[setting] = null;
      _incrementFieldRebuildCounter(setting);
    });
  }

  void _resetAllSettings() {
    final MPSettingsController settingsController =
        mpLocator.mpSettingsController;

    setState(() {
      _errors.clear();

      for (final MPSetting setting in MPSetting.values) {
        if (setting.section() == mpSettingsInternalSection) {
          continue;
        }

        switch (setting.type()) {
          case MPSettingType.bool:
            _draftValues[setting] = settingsController.getDefaultBool(setting);
          case MPSettingType.double:
            _draftValues[setting] = settingsController
                .getDefaultDouble(setting)
                .toString();
          case MPSettingType.int:
            _draftValues[setting] = settingsController
                .getDefaultInt(setting)
                .toString();
          case MPSettingType.string:
            _draftValues[setting] = settingsController.getDefaultString(
              setting,
            );
          case MPSettingType.stringList:
            _draftValues[setting] = settingsController
                .getDefaultStringList(setting)
                .join(mpSettingsStringListSeparator);
          case MPSettingType.filePickerExec:
            _draftValues[setting] = settingsController.getDefaultString(
              setting,
            );
        }

        _incrementFieldRebuildCounter(setting);
      }
    });
  }

  void _incrementFieldRebuildCounter(MPSetting setting) {
    final int current = _fieldRebuildCounters[setting] ?? mpMinimumInt;

    _fieldRebuildCounters[setting] = current + 1;
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
    final Map<MPSetting, String?> newErrors = {};

    for (final MPSetting setting in MPSetting.values) {
      if (setting.section() == mpSettingsInternalSection) {
        continue;
      }

      switch (setting.type()) {
        case MPSettingType.bool:
          settingsController.setBool(
            setting,
            (_draftValues[setting] as bool?) ?? false,
          );
        case MPSettingType.double:
          final String raw = (_draftValues[setting] as String?)?.trim() ?? '';
          final String? error = _validateTextDraftValue(
            appLocalizations,
            setting,
            raw,
          );

          if (error != null) {
            newErrors[setting] = error;
            continue;
          }

          final double? value = double.tryParse(raw);

          if (value == null) {
            continue;
          }

          settingsController.setDouble(setting, value);
        case MPSettingType.int:
          final String raw = (_draftValues[setting] as String?)?.trim() ?? '';
          final String? error = _validateTextDraftValue(
            appLocalizations,
            setting,
            raw,
          );

          if (error != null) {
            newErrors[setting] = error;
            continue;
          }

          final int? value = int.tryParse(raw);

          if (value == null) {
            continue;
          }

          settingsController.setInt(setting, value);
        case MPSettingType.string:
          settingsController.setString(
            setting,
            (_draftValues[setting] as String?) ?? '',
          );
        case MPSettingType.stringList:
          final String raw = (_draftValues[setting] as String?) ?? '';
          final List<String> values = raw
              .split(',')
              .map((String entry) => entry.trim())
              .where((String entry) => entry.isNotEmpty)
              .toList();
          settingsController.setStringList(setting, values);
        case MPSettingType.filePickerExec:
          settingsController.setString(
            setting,
            (_draftValues[setting] as String?) ?? '',
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
    final Set<String> sectionSet = MPSetting.values
        .map((MPSetting setting) => setting.section())
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

  List<MPSetting> _sortedSettingsInSection(
    AppLocalizations appLocalizations,
    String section,
  ) {
    final List<MPSetting> settings = MPSetting.values
        .where((MPSetting setting) => setting.section() == section)
        .toList();

    settings.sort((MPSetting a, MPSetting b) {
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
    MPSetting type,
  ) {
    switch (type) {
      case MPSetting.Main_LocaleID:
        return appLocalizations.mpSettingsSettingMainLocaleID;
      case MPSetting.Main_TherionExecutablePath:
        return _camelCaseToLabel(type.id());
      case MPSetting.TH2Edit_LineThickness:
        return appLocalizations.mpSettingsSettingTH2EditLineThickness;
      case MPSetting.TH2Edit_PointRadius:
        return appLocalizations.mpSettingsSettingTH2EditPointRadius;
      case MPSetting.TH2Edit_SelectionTolerance:
        return appLocalizations.mpSettingsSettingTH2EditSelectionTolerance;
      case MPSetting.Internal_LastNewVersionCheckMS:
        return _camelCaseToLabel(type.id());
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
