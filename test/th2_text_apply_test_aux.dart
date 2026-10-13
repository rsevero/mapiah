// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:convert';
import 'dart:typed_data';

import 'package:mapiah/src/auxiliary/mp_locator.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_snap_controller.dart';
import 'package:mapiah/src/elements/parts/th_position_part.dart';
import 'package:mapiah/src/elements/types/mp_pla_type_subtype.dart';

/// Shared helpers of the TH2 text apply tests (t3964–t3971, t3985).
class TH2TextApplyTestAux {
  static const String defaultFilename = '/tmp/th2_text_apply_test.th2';

  /// Loads [contents] (as UTF-8 bytes) into a registered controller, as a
  /// file open does.
  static Future<TH2FileEditController> load(
    String contents, {
    String filename = defaultFilename,
  }) {
    return loadBytes(
      Uint8List.fromList(utf8.encode(contents)),
      filename: filename,
    );
  }

  static Future<TH2FileEditController> loadBytes(
    Uint8List bytes, {
    String filename = defaultFilename,
  }) async {
    final TH2FileEditController controller = MPLocator().mpGeneralController
        .getTH2FileEditController(filename: filename, fileBytes: bytes);

    await controller.load();

    return controller;
  }

  /// The controller state a valid load sets, in a JSON-encodable form.
  static Map<String, dynamic> loadStateSnapshot(
    TH2FileEditController controller,
  ) {
    List<String> types(List<MPPLATypeSubtype> typeSubtypes) => <String>[
      for (final MPPLATypeSubtype typeSubtype in typeSubtypes)
        '${typeSubtype.pla.name}:${typeSubtype.type}:${typeSubtype.subtype}',
    ];
    String position(THPositionPart position) =>
        '${position.coordinates.dx},${position.coordinates.dy}';

    return <String, dynamic>{
      'activeScrapID': controller.activeScrapID,
      'hasMultipleScraps': controller.hasMultipleScraps,
      'currentScrapName': controller.currentScrapName,
      'enableSelectButton': controller.enableSelectButton,
      'isSelected': (controller.selectionController.isSelected.toList()
        ..sort()),
      'selectableElements':
          (controller.selectionController
                  .getMPSelectableElements()
                  .keys
                  .toList()
                ..sort())
              .toList(),
      'snapPointTargetType': controller.snapController.snapPointTargetType.name,
      'snapLinePointTargetType':
          controller.snapController.snapLinePointTargetType.name,
      'snapXVIFileTargets':
          (controller.snapController.snapXVIFileTargets
                  .map((MPSnapXVIFileTarget target) => target.name)
                  .toList()
                ..sort())
              .toList(),
      'snapPointTargets': <String>[
        for (final THPositionPart target
            in controller.snapController.snapPointTargets)
          position(target),
      ],
      'snapLineTargets': <String>[
        for (final ({dynamic start, dynamic end}) target
            in controller.snapController.snapLineTargets)
          '${target.start}-${target.end}',
      ],
      'mostUsedAreaTypes': types(
        controller.elementEditController.mostUsedAreaTypes,
      ),
      'mostUsedLineTypes': types(
        controller.elementEditController.mostUsedLineTypes,
      ),
      'mostUsedPointTypes': types(
        controller.elementEditController.mostUsedPointTypes,
      ),
      'lastUsedAreaTypes': types(
        controller.elementEditController.lastUsedAreaTypes,
      ),
      'lastUsedLineTypes': types(
        controller.elementEditController.lastUsedLineTypes,
      ),
      'lastUsedPointTypes': types(
        controller.elementEditController.lastUsedPointTypes,
      ),
    };
  }
}
