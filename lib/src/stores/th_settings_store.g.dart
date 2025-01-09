// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_settings_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THSettingsStore on THSettingsStoreBase, Store {
  Computed<Locale>? _$localeComputed;

  @override
  Locale get locale =>
      (_$localeComputed ??= Computed<Locale>(() => super.locale,
              name: 'THSettingsStoreBase.locale'))
          .value;

  late final _$_localeIDAtom =
      Atom(name: 'THSettingsStoreBase._localeID', context: context);

  String get localeID {
    _$_localeIDAtom.reportRead();
    return super._localeID;
  }

  @override
  String get _localeID => localeID;

  @override
  set _localeID(String value) {
    _$_localeIDAtom.reportWrite(value, super._localeID, () {
      super._localeID = value;
    });
  }

  late final _$THSettingsStoreBaseActionController =
      ActionController(name: 'THSettingsStoreBase', context: context);

  @override
  void setLocaleID(String aLocaleID) {
    final _$actionInfo = _$THSettingsStoreBaseActionController.startAction(
        name: 'THSettingsStoreBase.setLocaleID');
    try {
      return super.setLocaleID(aLocaleID);
    } finally {
      _$THSettingsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
locale: ${locale}
    ''';
  }
}
