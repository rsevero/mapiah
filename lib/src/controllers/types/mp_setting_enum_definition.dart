// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

abstract class MPSettingEnumDefinition {
  List<Enum> get values;

  Enum get defaultValue;

  Enum? tryParseStoredValue(String storedValue);

  String storedValue(Enum value);

  String localizedLabel(AppLocalizations appLocalizations, Enum value);

  /// Whether [value] should be offered in the settings UI (e.g. to hide
  /// a not-yet-implemented option from the dropdown without removing it
  /// from the enum itself). Doesn't affect an already-stored setting
  /// still using a disabled value — that value keeps taking effect; this
  /// only affects whether the dropdown lets a user pick it going
  /// forward.
  bool isEnabled(Enum value);
}

class MPSettingEnumDefinitionImpl<T extends Enum>
    implements MPSettingEnumDefinition {
  final List<T> enumValues;
  final T? explicitDefaultValue;
  final T? Function(String storedValue) parser;
  final String Function(AppLocalizations appLocalizations, T value)
  localizedLabelBuilder;
  final bool Function(T value)? enabledPredicate;

  MPSettingEnumDefinitionImpl({
    required this.enumValues,
    required this.parser,
    required this.localizedLabelBuilder,
    this.explicitDefaultValue,
    this.enabledPredicate,
  });

  @override
  List<Enum> get values => List<Enum>.unmodifiable(enumValues);

  @override
  Enum get defaultValue => explicitDefaultValue ?? enumValues.first;

  @override
  Enum? tryParseStoredValue(String storedValue) {
    return parser(storedValue);
  }

  @override
  String storedValue(Enum value) {
    final T typedValue = _castValue(value);

    return typedValue.name;
  }

  @override
  String localizedLabel(AppLocalizations appLocalizations, Enum value) {
    final T typedValue = _castValue(value);

    return localizedLabelBuilder(appLocalizations, typedValue);
  }

  @override
  bool isEnabled(Enum value) {
    final T typedValue = _castValue(value);

    return enabledPredicate?.call(typedValue) ?? true;
  }

  T _castValue(Enum value) {
    if (value is! T) {
      throw ArgumentError(
        'Enum value $value is not compatible with ${T.toString()}',
      );
    }

    return value;
  }
}
