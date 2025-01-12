import "package:dart_mappable/dart_mappable.dart";
import "package:mapiah/src/elements/th_element.dart";
import "package:mapiah/src/elements/th_has_id.dart";
import "package:mapiah/src/elements/th_has_options.dart";

part 'th_scrap.mapper.dart';

// Description: Scrap is a piece of 2D map, which doesn’t contain overlapping passages
// (i.e. all the passages may be drawn on the paper without overlapping). For small and
// simple caves, the whole cave may belong to one scrap. In complicated systems, a scrap is
// 21usually one chamber or one passage. Ideally, a scrap contains about 100 m of the cave.5
// Each scrap is processed separately by METAPOST; scraps which are too large may exceed
// METAPOST’s memory and cause errors.
// Scrap consists of point, line and area map symbols. See chapter How the map is put
// together for explanation how and in which order are they displayed.
// Scrap border consists of lines with the -outline out or -outline in options (passage
// walls have -outline out by default). These lines shouldn’t intersect—otherwise Therion
// (METAPOST) can’t determine the interior of the scrap and METAPOST issues a warning
// message “scrap outline intersects itself”.
// Each scrap has its own local cartesian coordinate system, which usually corresponds with
// the millimeter paper (if you measure the coordinates of map symbols by hand) or pixels
// of the scanned image (if you use XTherion). Therion does the transformation from this
// local coordinate system to the real coordinates using the positions of survey stations,
// which are specified both in the scrap as point map symbols and in centreline data. If the
// scrap doesn’t contain at least two survey stations with the -name reference, you have to
// use the -scale option for calibrating the scrap. (This is usual for cross sections.)
@MappableClass()
class THScrap extends THElement
    with THScrapMappable, THHasOptions, THParent
    implements THHasTHID {
  String _thID;

  THScrap(super.parent, String thID)
      : _thID = thID,
        super.addToParent();

  @override
  String get thID {
    return _thID;
  }

  @override
  set thID(String aTHID) {
    thFile.updateTHID(this, aTHID);
    _thID = aTHID;
  }
}
