import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/types/mp_settings_type.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPSettingsPage extends StatefulWidget {
  const MPSettingsPage({super.key});

  @override
  State<MPSettingsPage> createState() => _MPSettingsPageState();
}

class _MPSettingsPageState extends State<MPSettingsPage> {
  final Map<MPSettingsType, dynamic> _draftValues = {};
  final Map<MPSettingsType, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    _reloadDraftFromController();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
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
    final List<MPSettingsType> types = _sortedSettingsInSection(
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
            for (final MPSettingsType type in types) ...[
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
    MPSettingsType type,
  ) {
    final String settingLabel = _localizedSettingName(appLocalizations, type);

    switch (type.type()) {
      case MPSettingsTypeType.bool:
        return _constrainedEditableField(
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
        );
      case MPSettingsTypeType.double:
      case MPSettingsTypeType.int:
      case MPSettingsTypeType.string:
      case MPSettingsTypeType.stringList:
        if (type == MPSettingsType.Main_LocaleID) {
          final List<String> localeIDs = [
            'sys',
            ...AppLocalizations.supportedLocales.map(
              (locale) => locale.languageCode,
            ),
          ];

          final String currentValue = (_draftValues[type] as String?) ?? 'sys';

          return _constrainedEditableField(
            DropdownButtonFormField<String>(
              initialValue: localeIDs.contains(currentValue)
                  ? currentValue
                  : 'sys',
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
          );
        }

        return _constrainedEditableField(
          TextFormField(
            initialValue: (_draftValues[type] as String?) ?? '',
            decoration: InputDecoration(
              labelText: settingLabel,
              errorText: _errors[type],
            ),
            onChanged: (String value) {
              _draftValues[type] = value;
              if (_errors[type] != null) {
                setState(() {
                  _errors[type] = null;
                });
              }
            },
          ),
        );
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

    for (final MPSettingsType type in MPSettingsType.values) {
      if (type.section() == 'Internal') {
        continue;
      }

      switch (type.type()) {
        case MPSettingsTypeType.bool:
          _draftValues[type] = settingsController.getBool(type);
        case MPSettingsTypeType.double:
          _draftValues[type] = settingsController.getDouble(type).toString();
        case MPSettingsTypeType.int:
          _draftValues[type] = settingsController.getInt(type).toString();
        case MPSettingsTypeType.string:
          _draftValues[type] = settingsController.getString(type);
        case MPSettingsTypeType.stringList:
          _draftValues[type] = settingsController
              .getStringList(type)
              .join(', ');
      }
    }
  }

  void _cancelChanges() {
    setState(() {
      _reloadDraftFromController();
    });
  }

  void _closeAndSave() {
    final bool isApplied = _applyChanges();

    if (isApplied) {
      Navigator.of(context).pop();
    }
  }

  bool _applyChanges() {
    final settingsController = mpLocator.mpSettingsController;
    final Map<MPSettingsType, String?> newErrors = {};

    for (final MPSettingsType type in MPSettingsType.values) {
      if (type.section() == 'Internal') {
        continue;
      }

      switch (type.type()) {
        case MPSettingsTypeType.bool:
          settingsController.setBool(
            type,
            (_draftValues[type] as bool?) ?? false,
          );
        case MPSettingsTypeType.double:
          final String raw = (_draftValues[type] as String?)?.trim() ?? '';
          final double? value = double.tryParse(raw);

          if (value == null) {
            newErrors[type] = AppLocalizations.of(
              context,
            ).mpSettingsInvalidNumber;
            continue;
          }

          settingsController.setDouble(type, value);
        case MPSettingsTypeType.int:
          final String raw = (_draftValues[type] as String?)?.trim() ?? '';
          final int? value = int.tryParse(raw);

          if (value == null) {
            newErrors[type] = AppLocalizations.of(
              context,
            ).mpSettingsInvalidInteger;
            continue;
          }

          settingsController.setInt(type, value);
        case MPSettingsTypeType.string:
          settingsController.setString(
            type,
            (_draftValues[type] as String?) ?? '',
          );
        case MPSettingsTypeType.stringList:
          final String raw = (_draftValues[type] as String?) ?? '';
          final List<String> values = raw
              .split(',')
              .map((String entry) => entry.trim())
              .where((String entry) => entry.isNotEmpty)
              .toList();
          settingsController.setStringList(type, values);
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
    final Set<String> sectionSet = MPSettingsType.values
        .map((MPSettingsType type) => type.section())
        .where((String section) => section != 'Internal')
        .toSet();

    final List<String> sections = sectionSet.toList();

    sections.sort((String a, String b) {
      if (a == 'Main' && b != 'Main') {
        return -1;
      }
      if (b == 'Main' && a != 'Main') {
        return 1;
      }

      final String localizedA = _localizedSectionName(appLocalizations, a);
      final String localizedB = _localizedSectionName(appLocalizations, b);

      return localizedA.toLowerCase().compareTo(localizedB.toLowerCase());
    });

    return sections;
  }

  List<MPSettingsType> _sortedSettingsInSection(
    AppLocalizations appLocalizations,
    String section,
  ) {
    final List<MPSettingsType> settings = MPSettingsType.values
        .where((MPSettingsType type) => type.section() == section)
        .toList();

    settings.sort((MPSettingsType a, MPSettingsType b) {
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
      case 'Main':
        return appLocalizations.mpSettingsSectionMain;
      case 'TH2Edit':
        return appLocalizations.mpSettingsSectionTH2Edit;
      default:
        return _camelCaseToLabel(section);
    }
  }

  String _localizedSettingName(
    AppLocalizations appLocalizations,
    MPSettingsType type,
  ) {
    switch (type) {
      case MPSettingsType.Main_LocaleID:
        return appLocalizations.mpSettingsSettingMainLocaleID;
      case MPSettingsType.TH2Edit_LineThickness:
        return appLocalizations.mpSettingsSettingTH2EditLineThickness;
      case MPSettingsType.TH2Edit_PointRadius:
        return appLocalizations.mpSettingsSettingTH2EditPointRadius;
      case MPSettingsType.TH2Edit_SelectionTolerance:
        return appLocalizations.mpSettingsSettingTH2EditSelectionTolerance;
      case MPSettingsType.Internal_LastNewVersionCheckMS:
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
