import 'package:mapiah/src/th_elements/command_options/th_command_option.dart';

// value . value of height, passage-height, altitude, dimensions or date
// height: according to the sign of the value (positive, negative or unsigned), this type of
// symbol represents chimney height, pit depth or step height in general. The numeric
// value can be optionally followed by ‘?’, if the value is presumed and units can be added
// (e.g. -value [40? ft]).
// passage-height: the following four forms of value are supported: +<number> (the height
// of the ceiling), -<number> (the depth of the floor or water depth), <number> (the dis-
// tance between floor and ceiling) and [+<number> -<number>] (the distance to ceiling
// and distance to floor).
// altitude: the value specified is the altitude difference from the nearest station. The
// value will be set to 0 if defined as ‘-’, ‘.’, ‘nan’, ‘NAN’ or ‘NaN’. If the altitude value is
// prefixed by ‘fix’ (e.g. -value [fix 1300]), this value is used as an absolute altitude.
// The value can optionally be followed by length units.
// dimensions: -value [<above> <below> [<units>]] specifies passage dimensions a-
// bove/below centerline plane used in 3D model.
// date: -value <date> sets the date for the date point.
abstract class THValueCommandOption extends THCommandOption {
  THValueCommandOption(super.parentOption);

  @override
  String get optionType => 'value';
}
