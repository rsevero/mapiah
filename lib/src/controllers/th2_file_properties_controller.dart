// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mobx/mobx.dart';

part 'th2_file_properties_controller.g.dart';

class TH2FilePropertiesController = TH2FilePropertiesControllerBase
    with _$TH2FilePropertiesController;

abstract class TH2FilePropertiesControllerBase with Store {
  final TH2FileEditController _th2FileEditController;

  TH2FilePropertiesControllerBase(this._th2FileEditController);

  @computed
  String get encoding => _th2FileEditController.th2File.encoding;

  void prepareSetEncoding(String newEncoding) {
    final String normalized = newEncoding.trim().toUpperCase();

    if (normalized.isEmpty || (normalized == encoding)) {
      return;
    }

    final MPSetFileEncodingCommand command = MPSetFileEncodingCommand(
      fromEncoding: encoding,
      toEncoding: normalized,
    );

    _th2FileEditController.execute(command);
  }

  @action
  void applySetEncoding({
    required String fromEncoding,
    required String toEncoding,
  }) {
    final TH2File th2File = _th2FileEditController.th2File;

    th2File.encoding = toEncoding;

    final THElement? encodingElement = _findEncodingElement(th2File);

    if (encodingElement != null) {
      final THEncoding updated = (encodingElement as THEncoding).copyWith(
        encoding: toEncoding,
        originalLineInTH2File: '',
      );

      th2File.substituteElement(updated);
    } else {
      final THEncoding newEncodingElement = THEncoding(
        parentMPID: th2File.mpID,
        encoding: toEncoding,
      );

      th2File.addElement(newEncodingElement);
      th2File.addElementToParent(
        newEncodingElement,
        elementPositionInParent: 0,
      );
    }
  }

  THElement? _findEncodingElement(TH2File th2File) {
    if (th2File.childrenMPIDs.isEmpty) {
      return null;
    }

    final THElement firstChild = th2File.elementByMPID(
      th2File.childrenMPIDs.first,
    );

    return (firstChild is THEncoding) ? firstChild : null;
  }
}
