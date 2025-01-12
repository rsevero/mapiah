import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";

part 'th_endcomment.mapper.dart';

@MappableClass()
class THEndcomment extends THElement with THEndcommentMappable {
  THEndcomment(super.parent) : super.addToParent();
}
