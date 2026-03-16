// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
part of 'mp_selectable.dart';

abstract class MPSelectableElement extends MPSelectable {
  MPSelectableElement({
    required super.element,
    required super.th2fileEditController,
  }) : super();

  List<THElement> get selectedElements;
}
