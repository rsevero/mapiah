// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/exceptions/th_base_exception.dart';

class THCreateObjectWithoutListException extends THBaseException {
  final String objectType;
  final dynamic originalInfo;

  THCreateObjectWithoutListException(this.objectType, this.originalInfo)
    : super("Can´t create object of type '$objectType' from '$originalInfo.");
}
