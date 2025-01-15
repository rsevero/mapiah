import 'package:dart_mappable/dart_mappable.dart';

part 'command_type.mapper.dart';

@MappableEnum()
enum CommandType {
  moveBezierLineSegment,
  moveLine,
  movePoint,
  moveStraightLineSegment,
}
