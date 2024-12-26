import 'package:dart_mappable/dart_mappable.dart';
import 'package:mapiah/src/elements/th_element.dart';

part 'th_endline.mapper.dart';

@MappableClass()
class THEndline extends THElement with THEndlineMappable {
  THEndline(super.parent) : super.withParent();
}
