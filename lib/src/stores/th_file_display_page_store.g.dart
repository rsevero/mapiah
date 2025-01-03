// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'th_file_display_page_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$THFileDisplayPageStore on THFileDisplayPageStoreBase, Store {
  late final _$_isLoadingAtom =
      Atom(name: 'THFileDisplayPageStoreBase._isLoading', context: context);

  bool get isLoading {
    _$_isLoadingAtom.reportRead();
    return super._isLoading;
  }

  @override
  bool get _isLoading => isLoading;

  @override
  set _isLoading(bool value) {
    _$_isLoadingAtom.reportWrite(value, super._isLoading, () {
      super._isLoading = value;
    });
  }

  late final _$_thFileAtom =
      Atom(name: 'THFileDisplayPageStoreBase._thFile', context: context);

  THFile get thFile {
    _$_thFileAtom.reportRead();
    return super._thFile;
  }

  @override
  THFile get _thFile => thFile;

  @override
  set _thFile(THFile value) {
    _$_thFileAtom.reportWrite(value, super._thFile, () {
      super._thFile = value;
    });
  }

  late final _$loadFileAsyncAction =
      AsyncAction('THFileDisplayPageStoreBase.loadFile', context: context);

  @override
  Future<void> loadFile(BuildContext context, String aFilename) {
    return _$loadFileAsyncAction.run(() => super.loadFile(context, aFilename));
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
