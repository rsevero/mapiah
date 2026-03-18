// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

abstract class MPSettingEnumDefinition {
  List<Enum> get values;

  Enum get defaultValue;

  Enum? tryParseStoredValue(String storedValue);

  String storedValue(Enum value);

  String localizedLabel(AppLocalizations appLocalizations, Enum value);
}

class MPSettingEnumDefinitionImpl<T extends Enum>
    implements MPSettingEnumDefinition {
  final List<T> enumValues;
  final T? explicitDefaultValue;
  final T? Function(String storedValue) parser;
  final String Function(AppLocalizations appLocalizations, T value)
  localizedLabelBuilder;

  MPSettingEnumDefinitionImpl({
    required this.enumValues,
    required this.parser,
    required this.localizedLabelBuilder,
    this.explicitDefaultValue,
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

  T _castValue(Enum value) {
    if (value is! T) {
      throw ArgumentError(
        'Enum value $value is not compatible with ${T.toString()}',
      );
    }

    return value;
  }
}
