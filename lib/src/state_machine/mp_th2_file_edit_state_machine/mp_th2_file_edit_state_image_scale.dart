// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditStateImageScale extends MPTH2FileEditStateImageOperation {
  MPTH2FileEditStateImageScale({
    required super.th2FileEditController,
    required super.imageMPID,
  });

  @override
  String get statusBarMessage =>
      mpLocator.appLocalizations.th2FileEditPageImageScaleStatusBarMessage;

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.imageScale;
}
