// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th2_file.dart';

mixin MPTH2FileReferenceMixin {
  TH2File? _th2File;

  TH2File? get th2File => _th2File;

  void setTH2File(TH2File th2File) {
    _th2File = th2File;
  }
}
