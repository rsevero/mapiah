// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of '../th_element.dart';

/// Interface for elements that have a [Point]|[Line]|[Area] type attribute.
mixin THHasPLATypeMixin on THElement {
  String get plaType;

  String _unknownPLAType = '';

  String get unknownPLAType => _unknownPLAType;

  String get typeSubtypeID;
}
