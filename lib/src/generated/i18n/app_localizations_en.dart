// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String aboutMapiahDialogMapiahVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get aboutMapiahDialogWindowTitle => 'About Mapiah';

  @override
  String get appTitle => 'Mapiah';

  @override
  String get close => 'Close';

  @override
  String get initialPageAboutMapiahDialog => 'About Mapiah';

  @override
  String get initialPageLanguage => 'Language';

  @override
  String get initialPageOpenFile => 'Open file (Ctrl+O)';

  @override
  String get initialPagePresentation => 'Mapiah: an user-friendly graphical interface for cave mapping with Therion';

  @override
  String get fileEditWindowWindowTitle => 'File edit';

  @override
  String languageName(String language) {
    String _temp0 = intl.Intl.selectLogic(
      language,
      {
        'sys': 'System',
        'en': 'English',
        'pt': 'Português',
        'other': 'Unknown',
      },
    );
    return '$_temp0';
  }

  @override
  String get mpAddElementsCommandDescription => 'Add elements';

  @override
  String get mpAddLineCommandDescription => 'Add line';

  @override
  String get mpAddLineSegmentCommandDescription => 'Add line segment';

  @override
  String get mpAddPointCommandDescription => 'Add point';

  @override
  String get mpDeleteElementsCommandDescription => 'Delete elements';

  @override
  String get mpDeleteLineCommandDescription => 'Delete line';

  @override
  String get mpDeleteLineSegmentCommandDescription => 'Delete line segment';

  @override
  String get mpDeletePointCommandDescription => 'Delete point';

  @override
  String get mpEditBezierCurveCommandDescription => 'Edit Bézier curve';

  @override
  String get mpEditLineCommandDescription => 'Edit line';

  @override
  String get mpEditLineSegmentCommandDescription => 'Edit line segment';

  @override
  String get mpLengthUnitCentimeterAbbreviation => 'cm';

  @override
  String get mpLengthUnitFootAbbreviation => 'ft';

  @override
  String get mpLengthUnitInchAbbreviation => 'in';

  @override
  String get mpLengthUnitMeterAbbreviation => 'm';

  @override
  String get mpLengthUnitYardAbbreviation => 'yd';

  @override
  String get mpMoveBezierLineSegmentCommandDescription => 'Move Bézier line segment';

  @override
  String get mpMoveElementsCommandDescription => 'Move elements';

  @override
  String get mpMoveLineCommandDescription => 'Move line';

  @override
  String get mpMovePointCommandDescription => 'Move point';

  @override
  String get mpMoveStraightLineSegmentCommandDescription => 'Move straight line segment';

  @override
  String get parsingErrors => 'Parsing errors';

  @override
  String get th2FileEditPageAddArea => 'Add area (A)';

  @override
  String th2FileEditPageAddAreaStatusBarMessage(Object type) {
    return 'Click to add a $type area';
  }

  @override
  String get th2FileEditPageAddElementOptions => 'Add element';

  @override
  String get th2FileEditPageAddLine => 'Add line (L)';

  @override
  String th2FileEditPageAddLineStatusBarMessage(Object type) {
    return 'Click to add a $type line';
  }

  @override
  String get th2FileEditPageAddPoint => 'Add point (P)';

  @override
  String th2FileEditPageAddPointStatusBarMessage(Object type) {
    return 'Click to add a $type point';
  }

  @override
  String get th2FileEditPageChangeActiveScrapTool => 'Change active scrap (Alt+C)';

  @override
  String get th2FileEditPageDeleteButton => 'Delete (Del)';

  @override
  String get th2FileEditPageEmptySelectionStatusBarMessage => 'Empty selection';

  @override
  String th2FileEditPageNonEmptySelectionOnlyLinesStatusBarMessage(Object amount) {
    return '$amount line(s) selected';
  }

  @override
  String th2FileEditPageNonEmptySelectionOnlyPointsStatusBarMessage(Object amount) {
    return '$amount point(s) selected';
  }

  @override
  String th2FileEditPageNonEmptySelectionPointsAndLinesStatusBarMessage(Object pointsAmount, Object linesAmount) {
    return '$pointsAmount point(s) and $linesAmount line(s) selected';
  }

  @override
  String th2FileEditPageLoadingFile(Object filename) {
    return 'Loading file $filename ...';
  }

  @override
  String get th2FileEditPageNoUndoAvailable => 'No undo available';

  @override
  String get th2FileEditPageNoRedoAvailable => 'No redo available';

  @override
  String get th2FileEditPagePanTool => 'Pan';

  @override
  String get th2FileEditPageSave => 'Save (Ctrl+S)';

  @override
  String get th2FileEditPageSaveAs => 'Save as (Shift+Ctrl+S)';

  @override
  String th2FileEditPageRedo(Object redoDescription) {
    return 'Redo \'$redoDescription\' (Ctrl+Y)';
  }

  @override
  String get th2FileEditPageSelectTool => 'Select (C)';

  @override
  String th2FileEditPageUndo(Object undoDescription) {
    return 'Undo \'$undoDescription\' (Ctrl+Z)';
  }

  @override
  String get th2FileEditPageZoomIn => 'Zoom In (+)';

  @override
  String get th2FileEditPageZoomOneToOne => 'Zoom 1:1 (1)';

  @override
  String get th2FileEditPageZoomOptions => 'Zoom Options';

  @override
  String get th2FileEditPageZoomOut => 'Zoom Out (-)';

  @override
  String get th2FileEditPageZoomOutFile => 'Show file (3)';

  @override
  String get th2FileEditPageZoomOutScrap => 'Show scrap (4)';

  @override
  String get th2FileEditPageZoomToSelection => 'Zoom to selection (2)';

  @override
  String get th2FilePickSelectTH2File => 'Select a TH2 file';

  @override
  String get thElementArea => 'Area';

  @override
  String get thElementAreaBorderTHID => 'Area border ID';

  @override
  String get thElementBezierCurveLineSegment => 'Bézier curve line segment';

  @override
  String get thElementComment => 'Comment';

  @override
  String get thElementEmptyLine => 'Empty line';

  @override
  String get thElementEncoding => 'Encoding';

  @override
  String get thElementEndArea => 'End area';

  @override
  String get thElementEndComment => 'End comment';

  @override
  String get thElementEndLine => 'End line';

  @override
  String get thElementEndScrap => 'End scrap';

  @override
  String get thElementLine => 'Line';

  @override
  String get thElementLineSegment => 'Line segment';

  @override
  String get thElementMultilineCommentContent => 'Multiline comment content';

  @override
  String get thElementMultilineComment => 'Multiline comment';

  @override
  String get thElementPoint => 'Point';

  @override
  String get thElementScrap => 'Scrap';

  @override
  String get thElementStraightLineSegment => 'Straight line segment';

  @override
  String get thElementUnrecognized => 'Unrecognized ';

  @override
  String get thElementXTherionConfig => 'XTherion config';

  @override
  String get thPointAirDraught => 'Air draught';

  @override
  String get thPointAltar => 'Altar';

  @override
  String get thPointAltitude => 'Altitude';

  @override
  String get thPointAnastomosis => 'Anastomosis';

  @override
  String get thPointAnchor => 'Anchor';

  @override
  String get thPointAragonite => 'Aragonite';

  @override
  String get thPointArcheoExcavation => 'Archeo Excavation';

  @override
  String get thPointArcheoMaterial => 'Archeo Material';

  @override
  String get thPointAudio => 'Audio';

  @override
  String get thPointBat => 'Bat';

  @override
  String get thPointBedrock => 'Bedrock';

  @override
  String get thPointBlocks => 'Blocks';

  @override
  String get thPointBones => 'Bones';

  @override
  String get thPointBreakdownChoke => 'Breakdown Choke';

  @override
  String get thPointBridge => 'Bridge';

  @override
  String get thPointCamp => 'Camp';

  @override
  String get thPointCavePearl => 'Cave Pearl';

  @override
  String get thPointClay => 'Clay';

  @override
  String get thPointClayChoke => 'Clay Choke';

  @override
  String get thPointClayTree => 'Clay Tree';

  @override
  String get thPointContinuation => 'Continuation';

  @override
  String get thPointCrystal => 'Crystal';

  @override
  String get thPointCurtain => 'Curtain';

  @override
  String get thPointCurtains => 'Curtains';

  @override
  String get thPointDanger => 'Danger';

  @override
  String get thPointDate => 'Date';

  @override
  String get thPointDebris => 'Debris';

  @override
  String get thPointDig => 'Dig';

  @override
  String get thPointDimensions => 'Dimensions';

  @override
  String get thPointDiscPillar => 'Disc Pillar';

  @override
  String get thPointDiscPillars => 'Disc Pillars';

  @override
  String get thPointDiscStalactite => 'Disc Stalactite';

  @override
  String get thPointDiscStalactites => 'Disc Stalactites';

  @override
  String get thPointDiscStalagmite => 'Disc Stalagmite';

  @override
  String get thPointDiscStalagmites => 'Disc Stalagmites';

  @override
  String get thPointDisk => 'Disk';

  @override
  String get thPointElectricLight => 'Electric Light';

  @override
  String get thPointEntrance => 'Entrance';

  @override
  String get thPointExtra => 'Extra';

  @override
  String get thPointExVoto => 'Ex Voto';

  @override
  String get thPointFixedLadder => 'Fixed Ladder';

  @override
  String get thPointFlowstone => 'Flowstone';

  @override
  String get thPointFlowstoneChoke => 'Flowstone Choke';

  @override
  String get thPointFlute => 'Flute';

  @override
  String get thPointGate => 'Gate';

  @override
  String get thPointGradient => 'Gradient';

  @override
  String get thPointGuano => 'Guano';

  @override
  String get thPointGypsum => 'Gypsum';

  @override
  String get thPointGypsumFlower => 'Gypsum Flower';

  @override
  String get thPointHandrail => 'Handrail';

  @override
  String get thPointHeight => 'Height';

  @override
  String get thPointHelictite => 'Helictite';

  @override
  String get thPointHelictites => 'Helictites';

  @override
  String get thPointHumanBones => 'Human Bones';

  @override
  String get thPointIce => 'Ice';

  @override
  String get thPointIcePillar => 'Ice Pillar';

  @override
  String get thPointIceStalactite => 'Ice Stalactite';

  @override
  String get thPointIceStalagmite => 'Ice Stalagmite';

  @override
  String get thPointKarren => 'Karren';

  @override
  String get thPointLabel => 'Label';

  @override
  String get thPointLowEnd => 'Low End';

  @override
  String get thPointMapConnection => 'Map Connection';

  @override
  String get thPointMasonry => 'Masonry';

  @override
  String get thPointMoonmilk => 'Moonmilk';

  @override
  String get thPointMud => 'Mud';

  @override
  String get thPointMudcrack => 'Mudcrack';

  @override
  String get thPointNamePlate => 'Name Plate';

  @override
  String get thPointNarrowEnd => 'Narrow End';

  @override
  String get thPointNoEquipment => 'No Equipment';

  @override
  String get thPointNoWheelchair => 'No Wheelchair';

  @override
  String get thPointPaleoMaterial => 'Paleo Material';

  @override
  String get thPointPassageHeight => 'Passage Height';

  @override
  String get thPointPebbles => 'Pebbles';

  @override
  String get thPointPendant => 'Pendant';

  @override
  String get thPointPhoto => 'Photo';

  @override
  String get thPointPillar => 'Pillar';

  @override
  String get thPointPillarsWithCurtains => 'Pillars With Curtains';

  @override
  String get thPointPillarWithCurtains => 'Pillar With Curtains';

  @override
  String get thPointPopcorn => 'Popcorn';

  @override
  String get thPointRaft => 'Raft';

  @override
  String get thPointRaftCone => 'Raft Cone';

  @override
  String get thPointRemark => 'Remark';

  @override
  String get thPointRimstoneDam => 'Rimstone Dam';

  @override
  String get thPointRimstonePool => 'Rimstone Pool';

  @override
  String get thPointRoot => 'Root';

  @override
  String get thPointRope => 'Rope';

  @override
  String get thPointRopeLadder => 'Rope Ladder';

  @override
  String get thPointSand => 'Sand';

  @override
  String get thPointScallop => 'Scallop';

  @override
  String get thPointSection => 'Section';

  @override
  String get thPointSeedGermination => 'Seed Germination';

  @override
  String get thPointSink => 'Sink';

  @override
  String get thPointSnow => 'Snow';

  @override
  String get thPointSodaStraw => 'Soda Straw';

  @override
  String get thPointSpring => 'Spring';

  @override
  String get thPointStalactite => 'Stalactite';

  @override
  String get thPointStalactites => 'Stalactites';

  @override
  String get thPointStalactitesStalagmites => 'Stalactites Stalagmites';

  @override
  String get thPointStalactiteStalagmite => 'Stalactite Stalagmite';

  @override
  String get thPointStalagmite => 'Stalagmite';

  @override
  String get thPointStalagmites => 'Stalagmites';

  @override
  String get thPointStation => 'Station';

  @override
  String get thPointStationName => 'Station Name';

  @override
  String get thPointSteps => 'Steps';

  @override
  String get thPointTraverse => 'Traverse';

  @override
  String get thPointTreeTrunk => 'Tree Trunk';

  @override
  String get thPointU => 'user defined';

  @override
  String get thPointVegetableDebris => 'Vegetable Debris';

  @override
  String get thPointViaFerrata => 'Via Ferrata';

  @override
  String get thPointVolcano => 'Volcano';

  @override
  String get thPointWalkway => 'Walkway';

  @override
  String get thPointWallCalcite => 'Wall Calcite';

  @override
  String get thPointWater => 'Water';

  @override
  String get thPointWaterDrip => 'Water Drip';

  @override
  String get thPointWaterFlow => 'Water Flow';

  @override
  String get thPointWheelchair => 'Wheelchair';
}
