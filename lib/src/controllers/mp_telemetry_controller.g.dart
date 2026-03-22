// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mp_telemetry_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MPTelemetryController on MPTelemetryControllerBase, Store {
  late final _$consentStateAtom = Atom(
    name: 'MPTelemetryControllerBase.consentState',
    context: context,
  );

  @override
  bool? get consentState {
    _$consentStateAtom.reportRead();
    return super.consentState;
  }

  @override
  set consentState(bool? value) {
    _$consentStateAtom.reportWrite(value, super.consentState, () {
      super.consentState = value;
    });
  }

  late final _$setConsentAsyncAction = AsyncAction(
    'MPTelemetryControllerBase.setConsent',
    context: context,
  );

  @override
  Future<void> setConsent(bool value) {
    return _$setConsentAsyncAction.run(() => super.setConsent(value));
  }

  @override
  String toString() {
    return '''
consentState: ${consentState}
    ''';
  }
}
