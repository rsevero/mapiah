// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th2_file_properties_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TH2FilePropertiesController on TH2FilePropertiesControllerBase, Store {
  Computed<String>? _$encodingComputed;

  @override
  String get encoding => (_$encodingComputed ??= Computed<String>(
    () => super.encoding,
    name: 'TH2FilePropertiesControllerBase.encoding',
  )).value;

  late final _$TH2FilePropertiesControllerBaseActionController =
      ActionController(
        name: 'TH2FilePropertiesControllerBase',
        context: context,
      );

  @override
  void applySetEncoding({
    required String fromEncoding,
    required String toEncoding,
  }) {
    final _$actionInfo = _$TH2FilePropertiesControllerBaseActionController
        .startAction(name: 'TH2FilePropertiesControllerBase.applySetEncoding');
    try {
      return super.applySetEncoding(
        fromEncoding: fromEncoding,
        toEncoding: toEncoding,
      );
    } finally {
      _$TH2FilePropertiesControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
encoding: ${encoding}
    ''';
  }
}
