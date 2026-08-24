// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

/// Base class for all elements in a Therion configuration (thconfig) file.
abstract class THConfigElement {
  int lineNumber;

  String originalLine;

  bool isModified;

  THConfigElement({
    this.lineNumber = 0,
    this.originalLine = '',
    this.isModified = false,
  });
}
