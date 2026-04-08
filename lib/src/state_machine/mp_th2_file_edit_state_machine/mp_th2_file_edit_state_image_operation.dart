// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

abstract class MPTH2FileEditStateImageOperation extends MPTH2FileEditState {
  final int imageMPID;

  MPTH2FileEditStateImageOperation({
    required super.th2FileEditController,
    required this.imageMPID,
  });

  String get statusBarMessage;

  String get overlayLabel;

  Offset get previewOffset => Offset.zero;

  MPRuntimeImageInsertConfigMixin? get renderedImageConfig => null;

  MPRuntimeImageInsertConfigMixin get imageConfig =>
      th2File.imageByMPID(imageMPID);

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    updateStatusBarMessage();
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  void updateStatusBarMessage() {
    th2FileEditController.setStatusBarMessage(statusBarMessage);
  }

  @override
  bool get keepOverlayOpenOnCanvasClick => true;

  @override
  void onKeyDownEvent(KeyDownEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      th2FileEditController.stateController.setState(
        MPTH2FileEditStateType.selectEmptySelection,
      );
    }
  }
}
