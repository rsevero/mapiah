import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/controllers/auxiliary/th_line_paint.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/auxiliary/mp_line_segment_mark_info.dart';
import 'package:mapiah/src/elements/auxiliary/mp_line_segment_size_orientation_info.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/th_file.dart';

class THLinePainterLineInfo {
  late final int mpID;
  late final THLinePaint lineDirectionTicksPaint;
  late final bool addLineDirectionTicks;
  late final bool isReversed;
  late final THArea? parentArea;
  late final Map<int, MPLineSegmentSizeOrientationInfo>
  lineSegmentsWithLSizeOrientation;
  late final Map<int, MPLineSegmentMarkInfo> lineSegmentsWithMark;
  final bool showMarksOnLineSegments;
  final bool showSizeOrientationOnLineSegments;

  THLinePainterLineInfo({
    required THLine line,
    required bool showLineDirectionTicks,
    required this.showMarksOnLineSegments,
    required this.showSizeOrientationOnLineSegments,
    required TH2FileEditController th2FileEditController,
  }) {
    mpID = line.mpID;
    isReversed = MPCommandOptionAux.isReversed(line);
    lineDirectionTicksPaint = th2FileEditController.visualController
        .getLineDirectionTickPaint(line: line, reverse: isReversed);
    addLineDirectionTicks =
        showLineDirectionTicks && th2FileEditController.isFromActiveScrap(line);
    lineSegmentsWithLSizeOrientation = line.lineSegmentsWithLSizeOrientation;
    lineSegmentsWithMark = line.lineSegmentsWithMark;

    final THFile thFile = th2FileEditController.thFile;
    final int? areaMPID = thFile.getAreaMPIDByLineMPID(mpID);

    parentArea = (areaMPID == null) ? null : thFile.areaByMPID(areaMPID);
  }
}
