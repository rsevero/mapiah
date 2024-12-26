/// Interface for elements that have a [Point]|[Line]|[Area] type attribute.

mixin THHasPLAType {
  String get plaType;

  set plaType(String aPLAType);
}
