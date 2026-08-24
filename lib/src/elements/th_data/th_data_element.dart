// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// Base class for all elements in a Therion survey data (.th) file.
abstract class THDataElement {
  int lineNumber;

  String originalLine;

  bool isModified;

  THDataElement({
    this.lineNumber = 0,
    this.originalLine = '',
    this.isModified = false,
  });
}
