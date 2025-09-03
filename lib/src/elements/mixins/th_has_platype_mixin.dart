part of '../th_element.dart';

/// Interface for elements that have a [Point]|[Line]|[Area] type attribute.
mixin THHasPLATypeMixin on THElement {
  String get plaType;

  String _unknownPLAType = '';

  String get unknownPLAType => _unknownPLAType;
}
