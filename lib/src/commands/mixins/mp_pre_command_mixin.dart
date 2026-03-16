// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../mp_command.dart';

mixin MPPreCommandMixin on MPCommand {
  late final MPCommand? preCommand;

  @override
  void _execPrePrepareUndoRedoInfo(
    TH2FileEditController th2FileEditController,
  ) {
    preCommand?.execute(th2FileEditController);
  }
}
