import 'package:dart_mappable/dart_mappable.dart';

part 'th_has_id.mapper.dart';

@MappableClass()
abstract class THHasTHID with THHasTHIDMappable {
  String get thID;
}
