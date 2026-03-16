// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/elements/th_file.dart';

mixin MPTHFileReferenceMixin {
  THFile? _thFile;

  THFile? get thFile => _thFile;

  void setTHFile(THFile thFile) {
    _thFile = thFile;
  }
}
