// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';

import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th_text_editor_fold_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/elements/th_project/th_project_parse_error.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

part 'th_text_editor_controller.g.dart';

class THTextEditorController = THTextEditorControllerBase
    with _$THTextEditorController;

/// MobX store owning the state of one open `thconfig`/`.th` text-editor
/// instance: current text, dirty state, cursor/scroll position, fold state,
/// and a diagnostics snapshot filtered from [THProjectController.projectErrors].
///
/// This controller is a UI/data bridge, not a replacement for
/// [THProjectController]: parsing and tree mutation stay there. One instance
/// exists per open editor; it is not a locator singleton.
abstract class THTextEditorControllerBase with Store {
  final THProjectController _projectController;

  THTextEditorControllerBase({THProjectController? projectController})
    : _projectController = projectController ?? mpLocator.thProjectController;

  @observable
  String canonicalPath = '';

  @observable
  String content = '';

  @observable
  bool isDirty = false;

  @observable
  bool isLoading = false;

  @observable
  int cursorLine = 0;

  @observable
  int cursorColumn = 0;

  @observable
  ObservableSet<int> collapsedFoldStarts = ObservableSet<int>();

  @computed
  List<THProjectParseError> get diagnostics => _projectController.projectErrors
      .where((THProjectParseError error) => error.filePath == canonicalPath)
      .toList();

  @computed
  List<THTextEditorFoldRegion> get foldRegions => buildFoldRegions(content);

  Timer? _reparseTimer;

  @action
  Future<void> loadFile(String filePath) async {
    final String resolvedCanonicalPath = THProjectPathResolver.canonicalize(
      p.absolute(filePath),
    );

    canonicalPath = resolvedCanonicalPath;
    isLoading = true;

    try {
      final String? cachedContent =
          _projectController.fileContentsCache[resolvedCanonicalPath];

      content =
          cachedContent ??
          THProjectParser.readFileContent(resolvedCanonicalPath).content;
      isDirty = false;
      cursorLine = 0;
      cursorColumn = 0;
      collapsedFoldStarts = ObservableSet<int>();
    } finally {
      isLoading = false;
    }
  }

  @action
  void setContent(String newContent) {
    content = newContent;
    isDirty = true;

    _reparseTimer?.cancel();
    _reparseTimer = Timer(
      const Duration(milliseconds: mpTextEditorReparseDebounceMilliseconds),
      () {
        _projectController.reparseFile(
          filePath: canonicalPath,
          updatedContent: content,
        );
      },
    );
  }

  @action
  void setCursorPosition({required int line, required int column}) {
    cursorLine = line;
    cursorColumn = column;
  }

  @action
  void toggleFold(int startLine) {
    if (!collapsedFoldStarts.remove(startLine)) {
      collapsedFoldStarts.add(startLine);
    }
  }

  @action
  Future<void> save() async {
    await _projectController.saveProjectFile(canonicalPath);

    if (!_projectController.dirtyFilePaths.contains(canonicalPath)) {
      isDirty = false;
    }
  }

  @action
  Future<void> revert() async {
    _reparseTimer?.cancel();
    await loadFile(canonicalPath);
  }

  void dispose() {
    _reparseTimer?.cancel();
  }
}
