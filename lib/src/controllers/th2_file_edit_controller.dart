// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_directory_aux.dart';
import 'package:mapiah/src/auxiliary/mp_interaction_aux.dart';
import 'package:mapiah/src/auxiliary/mp_numeric_aux.dart';
import 'package:mapiah/src/auxiliary/th2_text_apply_session.dart';
import 'package:mapiah/src/auxiliary/th2_text_element_locator.dart';
import 'package:mapiah/src/auxiliary/th2_text_identity_matcher.dart';
import 'package:mapiah/src/auxiliary/th2_text_line_map.dart';
import 'package:mapiah/src/auxiliary/th2_text_validator.dart';
import 'package:mapiah/src/commands/mp_command.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_default_options_controller.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/mp_undo_redo_controller.dart';
import 'package:mapiah/src/controllers/mp_visual_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_area_line_creation_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_copy_paste_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_freehand_line_creation_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_move_scale_rotate_element_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_option_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_overlay_window_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_search_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_selection_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_snap_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_split_merge_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_state_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_user_interaction_controller.dart';
import 'package:mapiah/src/controllers/th2_file_hide_element_controller.dart';
import 'package:mapiah/src/controllers/th2_file_operation_gate.dart';
import 'package:mapiah/src/controllers/th2_file_properties_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_text_edit_owner.dart';
import 'package:mapiah/src/controllers/th_project_controller.dart';
import 'package:mapiah/src/controllers/th_text_file_save_result.dart';
import 'package:mapiah/src/controllers/types/mp_global_key_widget_type.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/controllers/types/mp_zoom_to_fit_type.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mapiah/src/elements/command_options/th_command_option.dart';
import 'package:mapiah/src/elements/mixins/th_is_parent_mixin.dart';
import 'package:mapiah/src/elements/parts/types/th_length_unit_type.dart';
import 'package:mapiah/src/elements/th2_file.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/mp_end_control_point_type.dart';
import 'package:mapiah/src/exceptions/th2_unsupported_line_ending_exception.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_parser.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_writer.dart';
import 'package:mapiah/src/mp_file_read_write/th_project_path_resolver.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';
import 'package:mapiah/src/selected/mp_selected_element.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state.dart';
import 'package:mapiah/src/state_machine/mp_th2_file_edit_state_machine/types/mp_button_type.dart';
import 'package:mapiah/src/widgets/mp_interactive_line_simplification_dialog_widget.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart';
import 'package:path/path.dart' as p;

part 'th2_file_edit_controller.g.dart';

class TH2FileEditController = TH2FileEditControllerBase
    with _$TH2FileEditController;

abstract class TH2FileEditControllerBase with Store implements TH2TextEditOwner {
  bool _disposed = false;

  /// Whether this controller was created by [createForDetachedParse].
  bool _isDetachedParse = false;


  /// Admits one gated operation at a time (mode switches, Discard, Save,
  /// Save As, canvas history in text mode and image insertion).
  late final TH2FileOperationGate _operationGate = TH2FileOperationGate(
    isOwnerDisposed: () => _disposed,
  );

  /// Whether a gated operation is running. Observable.
  bool get isOperationBusy => _operationGate.isBusy;

  @override
  bool get isDisposed => _disposed;

  /// The operation-owned text buffer lock.
  final Observable<bool> _isBufferLocked = Observable<bool>(
    false,
    name: 'TH2FileEditController.isBufferLocked',
  );

  /// Depth of [runAuthorizedMutation] calls in progress.
  int _authorizedMutationDepth = 0;

  @readonly
  TH2EditMode _editMode = TH2EditMode.canvas;

  /// The text editor of text mode: created on the first entry, reused by
  /// later entries and disposed in [dispose].
  @readonly
  TH2TextEditController? _textEditController;

  /// The last rejected text and its diagnostics, for the "can't apply"
  /// banner. Cleared by _Keep editing_ and by any session end or
  /// replacement.
  @readonly
  TH2TextApplyRejection? _textApplyRejection;

  /// A selection reveal requested before the canvas was laid out.
  bool _pendingRevealSelection = false;

  late final MPDefaultOptionsController defaultOptionsController;
  late final TH2FilePropertiesController propertiesController;
  late final TH2FileEditAreaLineCreationController areaLineCreationController;
  late final TH2FileEditFreehandLineCreationController
  freehandLineCreationController;
  late final TH2FileHideElementController hideElementController;
  late final MPUndoRedoController undoRedoController;
  late final MPVisualController visualController;
  late final TH2FileEditCopyPasteController copyPasteController;
  late final TH2FileEditElementEditController elementEditController;
  late final TH2FileEditMoveScaleRotateElementController
  moveScaleRotateElementController;
  late final TH2FileEditSplitMergeController splitMergeController;
  late final TH2FileEditOptionEditController optionEditController;
  late final TH2FileEditOverlayWindowController overlayWindowController;
  late final TH2FileEditSearchController searchController;
  late final TH2FileEditSelectionController selectionController;
  late final TH2FileEditSnapController snapController;
  late final TH2FileEditStateController stateController;
  late final TH2FileEditUserInteractionController userInteractionController;

  final List<ReactionDisposer> _disposers = [];

  /// 'screen' is related to actual pixels on the screen.
  /// 'canvas' is the virtual canvas used to draw.
  /// 'data' is the actual data to be drawn.
  /// 'canvas' and 'data' are on the same scale. They are both scaled and
  /// translated to be shown on the screen.

  @readonly
  Size _screenSize = Size.zero;

  @readonly
  Size _canvasSize = Size.zero;

  @readonly
  double _canvasScale = 1.0;

  double devicePixelRatio = 1.0;

  @computed
  String get canvasScaleAsPercentageText =>
      MPNumericAux.roundScaleAsTextPercentage(_canvasScale);

  @readonly
  Offset _canvasTranslation = Offset.zero;

  @readonly
  Rect _canvasBoundingBox = Rect.zero;

  @readonly
  Rect _screenBoundingBox = Rect.zero;

  @readonly
  bool _isLoading = false;

  @readonly
  int _structureRevision = 0;

  @readonly
  bool _isFileLoaded = false;

  @readonly
  bool _isBroken = false;

  /// Always replaced by a new unmodifiable list, never mutated in place.
  @readonly
  List<TH2FileProblem> _problems = const <TH2FileProblem>[];

  /// The unexpected exception thrown by the last [load], if any. A failed
  /// load is only retried by replacing this controller (Reload).
  @readonly
  Object? _loadError;

  Future<TH2FileEditControllerCreateResult>? _loadFuture;

  @readonly
  late TH2File _th2File;

  late final int _th2FileMPID;

  @override
  int get th2FileMPID => _th2FileMPID;

  @readonly
  bool _hasUndo = false;

  @readonly
  bool _hasRedo = false;

  @readonly
  String _undoDescription = '';

  @readonly
  String _redoDescription = '';

  @readonly
  String _currentScrapName = '';

  @readonly
  Offset? _movingMousePosition;

  @readonly
  bool _isAddElementMode = false;

  @readonly
  bool _isEditLineMode = false;

  @readonly
  bool _enableNodeEditButton = false;

  @readonly
  bool _isSelectMode = false;

  @readonly
  bool _enableSelectButton = false;

  @readonly
  bool _isZoomButtonsHovered = false;

  @readonly
  bool _isAddElementButtonsHovered = false;

  @readonly
  MouseCursor _canvasCursor = SystemMouseCursors.basic;

  @computed
  MPButtonType get activeAddElementButton {
    switch (stateController.state) {
      case MPTH2FileEditStateAddPoint _:
        return MPButtonType.addPoint;
      case MPTH2FileEditStateAddLine _:
        return MPButtonType.addLine;
      case MPTH2FileEditStateAddArea _:
        return MPButtonType.addArea;
      case MPTH2FileEditStateAddFreehandLine _:
        return MPButtonType.addFreehandLine;
      default:
        return MPButtonType.addElement;
    }
  }

  @readonly
  int _currentDecimalPositions = mpDefaultDecimalPositions;

  @readonly
  double _currentSnapOnCanvasDistanceSquaredLimit =
      mpDefaultSnapOnScreenDistance * mpDefaultSnapOnScreenDistance;

  @readonly
  double _currentSnapGridCellSize =
      mpDefaultSnapOnScreenDistance * mpSnapGridCellSizeFactor;

  @readonly
  int _activeScrapID = 0;

  @readonly
  bool _hasMultipleScraps = false;

  @readonly
  double _lineThicknessOnCanvas = mpLocator.mpSettingsController
      .getDoubleWithDefault(MPSettingID.TH2Edit_LineThickness);

  @readonly
  double _controlLineThicknessOnCanvas =
      mpLocator.mpSettingsController.getDoubleWithDefault(
        MPSettingID.TH2Edit_LineThickness,
      ) *
      mpControlLineThicknessFactor;

  @readonly
  double _xviLineThicknessOnCanvas = mpXVILineThickness;

  @readonly
  double _lineDirectionTickLengthOnCanvas = mpLineDirectionTickLength;

  @readonly
  double _pointRadiusOnCanvas = mpLocator.mpSettingsController
      .getDoubleWithDefault(MPSettingID.TH2Edit_PointRadius);

  @readonly
  double _selectionToleranceOnCanvas = mpLocator.mpSettingsController
      .getDoubleWithDefault(MPSettingID.TH2Edit_SelectionTolerance);

  @readonly
  double _selectionToleranceSquaredOnCanvas =
      (mpLocator.mpSettingsController.getDoubleWithDefault(
        MPSettingID.TH2Edit_SelectionTolerance,
      ) *
      mpLocator.mpSettingsController.getDoubleWithDefault(
        MPSettingID.TH2Edit_SelectionTolerance,
      ));

  @readonly
  bool _canvasScaleTranslationUndefined = true;

  /// A zoom requested before the canvas was laid out. Only layout reads it,
  /// so it is not observable.
  MPZoomToFitType? _pendingZoomToFitType;

  @readonly
  Paint _selectionWindowFillPaint = mpSelectionWindowFillPaint;

  @readonly
  Paint _selectionWindowBorderPaint = mpSelectionWindowBorderPaint;

  @computed
  Paint get selectionWindowBorderPaintComplete =>
      _selectionWindowBorderPaint
        ..strokeWidth = mpSelectionWindowBorderPaintStrokeWidth / _canvasScale;

  @readonly
  double _selectionWindowBorderPaintDashInterval =
      mpSelectionWindowBorderPaintDashInterval;

  @computed
  double get selectionWindowBorderPaintDashIntervalOnCanvas =>
      _selectionWindowBorderPaintDashInterval / _canvasScale;

  @readonly
  double _selectionHandleSizeOnCanvas = mpSelectionHandleSize;

  @readonly
  double _selectionHandleDistanceOnCanvas = mpSelectionHandleDistance;

  @readonly
  double _selectionHandleLineThicknessOnCanvas = mpSelectionHandleLineThickness;

  @readonly
  bool _showImages = true;

  @computed
  Paint get selectionHandlePaint =>
      mpSelectionHandleFillPaint
        ..strokeWidth = _selectionHandleLineThicknessOnCanvas;

  @computed
  bool get showAddLine =>
      (areaLineCreationController.newLine != null) ||
      (areaLineCreationController.lineStartScreenPosition != null);

  @computed
  bool get showAddFreehandLine => freehandLineCreationController.isCapturing;

  @computed
  bool get showEditLineSegment => _isEditLineMode;

  @computed
  bool get showMultipleElementsClickedHighlight =>
      selectionController.multipleElementsClickedHighlightedMPID != null;

  @computed
  bool get showMultipleEndControlPointsClickedHighlight =>
      selectionController
          .multipleEndControlPointsClickedHighlightedChoice
          .type !=
      MPMultipleEndControlPointsClickedType.none;

  @computed
  bool get showRemoveButton {
    final MPTH2FileEditState state = stateController.state;
    final bool isManagementOverlayOpen =
        overlayWindowController.showChangeImageOverlayWindow;

    return !isManagementOverlayOpen &&
        ((state is MPTH2FileEditStateSelectEmptySelection) ||
            (state is MPTH2FileEditStateSelectNonEmptySelection));
  }

  @computed
  bool get showScrapScale {
    return !_isLoading && scrapHasScaleOption;
  }

  @computed
  bool get showSelectedElements =>
      selectionController.mpSelectedElementsLogical.isNotEmpty &&
      !_isEditLineMode;

  @computed
  bool get showSelectionHandles => showSelectedElements && _isSelectMode;

  @computed
  bool get showSelectionWindow =>
      selectionController.selectionWindowCanvasRect.value != Rect.zero;

  @computed
  bool get showUndoRedoButtons {
    final MPTH2FileEditStateType stateType = stateController.state.type;

    return _isAddElementMode ||
        _isSelectMode ||
        _isEditLineMode ||
        MPTH2FileEditState.isImageOperationType(stateType);
  }

  @computed
  bool get showSnapButton =>
      !overlayWindowController.showChangeImageOverlayWindow;

  @computed
  bool get enableRemoveButton =>
      selectionController.mpSelectedElementsLogical.isNotEmpty;

  @computed
  bool get isInEditSingleLineState =>
      stateController.state is MPTH2FileEditStateEditSingleLine;

  @computed
  bool get isInSelectNonEmptySelectionState =>
      stateController.state is MPTH2FileEditStateSelectNonEmptySelection;

  @computed
  bool get isInElementRotateState =>
      stateController.state is MPTH2FileEditStateElementRotate;

  @computed
  bool get isInSelectEmptySelectionState =>
      stateController.state is MPTH2FileEditStateSelectEmptySelection;

  @computed
  bool get isInAddElementState =>
      (stateController.state is MPTH2FileEditStateAddArea) ||
      (stateController.state is MPTH2FileEditStateAddLine) ||
      (stateController.state is MPTH2FileEditStateAddPoint);

  @computed
  bool get hasSelectedEndPoints =>
      selectionController.selectedEndControlPoints.isNotEmpty;

  bool get hasMultipleSelectedEndPoints =>
      selectionController.selectedEndControlPoints.length > 1;

  bool get hasSelectedNonStartEndPoints {
    if (selectionController.selectedEndControlPoints.isEmpty) {
      return false;
    }

    final Iterable<MPSelectedEndControlPoint> selectedEndControlPoints =
        selectionController.selectedEndControlPoints.values;
    final THLine line = _th2File.lineByMPID(
      selectedEndControlPoints.first.originalLineSegmentClone.parentMPID,
    );
    final Map<int, int> positionsByMPID = line
        .getLineSegmentPositionsByLineSegmentMPID(_th2File);

    for (final MPSelectedEndControlPoint selectedEndControlPoint
        in selectedEndControlPoints) {
      if ((selectedEndControlPoint.type ==
              MPEndControlPointType.controlPoint1) ||
          (selectedEndControlPoint.type ==
              MPEndControlPointType.controlPoint2)) {
        continue;
      }

      final THLineSegment lineSegment =
          selectedEndControlPoint.originalLineSegmentClone;
      final int? lineSegmentPosition = positionsByMPID[lineSegment.mpID];

      if ((lineSegmentPosition != null) && (lineSegmentPosition > 0)) {
        return true;
      }
    }

    return false;
  }

  @computed
  bool get areAllEndPointsSelected {
    final int selectableCount =
        selectionController.selectableEndControlPoints.length;

    if (selectableCount == 0) {
      return false;
    }

    return selectionController.selectedEndControlPoints.length ==
        selectableCount;
  }

  @computed
  bool get hasSelectedLines => selectionController
      .mpSelectedElementsLogical
      .values
      .any((final MPSelectedElement e) => e is MPSelectedLine);

  @computed
  bool get hasAtLeastTwoSelectedLines {
    int lineCount = 0;

    for (final MPSelectedElement element
        in selectionController.mpSelectedElementsLogical.values) {
      if (element is MPSelectedLine) {
        lineCount++;
        if (lineCount >= 2) {
          return true;
        }
      }
    }

    return false;
  }

  @computed
  bool get canMergeAreas {
    final Set<int> areaMPIDs = {};

    for (final MPSelectedElement element
        in selectionController.mpSelectedElementsLogical.values) {
      if (element is MPSelectedArea) {
        areaMPIDs.add(element.mpID);
      } else if (element is MPSelectedLine) {
        final int? areaMPID = _th2File.getAreaMPIDByLineMPID(element.mpID);

        if (areaMPID != null) {
          areaMPIDs.add(areaMPID);
        }
      }
    }

    if (areaMPIDs.length > 1) {
      return true;
    }

    int totalBorderCount = 0;

    for (final int areaMPID in areaMPIDs) {
      final THArea area = _th2File.areaByMPID(areaMPID);

      totalBorderCount += area.getLineMPIDs(_th2File).length;
      if (totalBorderCount >= 2) {
        return true;
      }
    }

    return false;
  }

  @computed
  bool get areAllElementsSelected {
    if (_activeScrapID <= 0) {
      return false;
    }

    final THScrap scrap = _th2File.scrapByMPID(_activeScrapID);
    int selectableCount = 0;

    for (final int elementMPID in scrap.childrenMPIDs) {
      final THElement element = _th2File.elementByMPID(elementMPID);

      if ((element is THPoint) || (element is THLine)) {
        selectableCount++;
      }
    }

    if (selectableCount == 0) {
      return false;
    }

    return selectionController.mpSelectedElementsLogical.length ==
        selectableCount;
  }

  @computed
  bool get hasClipboardContent =>
      mpLocator.mpGeneralController.hasClipboardContent;

  @computed
  bool get enableSaveButton => !_isBroken && _hasUndo && !_th2File.isNewFile;

  /// Whether the model or the text buffer has changes that aren't saved.
  @computed
  bool get hasUnsavedChanges =>
      enableSaveButton || (_textEditController?.isDirty ?? false);

  /// Whether Save can run: unsaved changes in a file that has a name.
  @override
  @computed
  bool get canSave => hasUnsavedChanges && !_th2File.isNewFile;

  @readonly
  String _statusBarMessage = '';

  @computed
  bool get scrapHasScaleOption {
    if (_activeScrapID <= 0) {
      return false;
    }

    final THScrap scrap = _th2File.scrapByMPID(_activeScrapID);

    return scrap.hasOption(THCommandOptionType.scrapScale);
  }

  @computed
  THLengthUnitType get scrapLengthUnitType {
    if (scrapHasScaleOption) {
      final THScrap scrap = _th2File.scrapByMPID(_activeScrapID);

      return (scrap.getOption(THCommandOptionType.scrapScale)
              as THScrapScaleCommandOption)
          .unitPart
          .unit;
    } else {
      return THLengthUnitType.meter;
    }
  }

  @computed
  double get scrapLengthUnitsPerPoint {
    if (scrapHasScaleOption) {
      final THScrap scrap = _th2File.scrapByMPID(_activeScrapID);

      return (scrap.getOption(THCommandOptionType.scrapScale)
              as THScrapScaleCommandOption)
          .lengthUnitsPerPoint;
    } else {
      return 1.0;
    }
  }

  @computed
  double get scrapLengthUnitsOnGraphicalScale {
    double scrapLengthUnitsOnScreen =
        scrapLengthUnitsPerPointOnScreen *
        mpDesiredGraphicalScaleScreenPointLength;

    scrapLengthUnitsOnScreen = MPNumericAux.roundNumber(
      scrapLengthUnitsOnScreen,
    );

    return scrapLengthUnitsOnScreen;
  }

  @computed
  double get scrapLengthUnitsPerPointOnScreen {
    return scrapLengthUnitsPerPoint / _canvasScale;
  }

  @readonly
  int _redrawTriggerSelectedElementsListChanged = mpMinimumInt;

  @readonly
  int _redrawTriggerSelectedElements = mpMinimumInt;

  @readonly
  int _redrawTriggerNonSelectedElements = mpMinimumInt;

  @readonly
  int _redrawTriggerAllElements = mpMinimumInt;

  @readonly
  int _redrawTriggerImages = mpMinimumInt;

  @readonly
  int _redrawTriggerNewLine = mpMinimumInt;

  @readonly
  int _redrawTriggerFreehandLine = mpMinimumInt;

  @readonly
  int _redrawTriggerEditLine = mpMinimumInt;

  @readonly
  int _redrawTriggerOptionsList = mpMinimumInt;

  @readonly
  int _redrawSnapTargetsWindow = mpMinimumInt;

  @readonly
  Offset _mousePosition = Offset.zero;

  @readonly
  double _canvasCenterX = 0.0;
  @readonly
  double _canvasCenterY = 0.0;

  double _dataWidth = 0.0;
  double _dataHeight = 0.0;

  final FocusNode th2FileFocusNode = FocusNode();
  final ValueNotifier<bool> isInteractiveLineSimplificationDialogOpen =
      ValueNotifier<bool>(false);

  final List<String> errorMessages = <String>[];

  /// This is a factory constructor that creates a new instance of
  /// TH2FileEditController with an empty TH2File.
  static TH2FileEditController create(String filename, {Uint8List? fileBytes}) {
    final TH2FileEditController th2FileEditController =
        TH2FileEditController._create();
    final TH2File th2File = TH2File();

    th2File.filename = filename;
    th2File.fileBytes = fileBytes;
    th2FileEditController._basicInitialization(th2File);

    return th2FileEditController;
  }

  /// This is a factory constructor that creates a new instance of
  /// TH2FileEditController with an newly created TH2File.
  static TH2FileEditController createFromNewTH2File(TH2File th2File) {
    final TH2FileEditController th2FileEditController =
        TH2FileEditController._create();

    th2FileEditController._basicInitialization(th2File);

    /// Its model refresh bumps the structure revision once.
    th2FileEditController._finalFilePreparations(th2File);

    return th2FileEditController;
  }

  /// Creates an unregistered controller for a detached parse of the text of
  /// the file [filename], whose `TH2File` has [th2FileMPID] and
  /// [lineEnding].
  ///
  /// It is never registered, never gets a tab, and never runs
  /// [_finalFilePreparations] or [_initializeReactions]: it shares the real
  /// file's filename, so the dirty-mirroring reaction would add or remove the
  /// real file's path in `THProjectController.dirtyFilePaths`.
  static TH2FileEditController createForDetachedParse({
    required String filename,
    required int th2FileMPID,
    required String lineEnding,
  }) {
    final TH2FileEditController th2FileEditController =
        TH2FileEditController._create();
    final TH2File th2File = TH2File.withMPID(th2FileMPID)
      ..filename = filename
      ..lineEnding = lineEnding;

    th2FileEditController._basicInitialization(th2File);
    th2FileEditController._isDetachedParse = true;

    return th2FileEditController;
  }

  TH2FileEditControllerBase._create();

  void _basicInitialization(TH2File file) {
    _th2File = file;
    defaultOptionsController = MPDefaultOptionsController()..loadFromSettings();
    propertiesController = TH2FilePropertiesController(
      this as TH2FileEditController,
    );
    areaLineCreationController = TH2FileEditAreaLineCreationController(
      this as TH2FileEditController,
    );
    freehandLineCreationController = TH2FileEditFreehandLineCreationController(
      this as TH2FileEditController,
    );
    hideElementController = TH2FileHideElementController(
      this as TH2FileEditController,
    );
    copyPasteController = TH2FileEditCopyPasteController(
      this as TH2FileEditController,
    );
    elementEditController = TH2FileEditElementEditController(
      this as TH2FileEditController,
    );
    moveScaleRotateElementController =
        TH2FileEditMoveScaleRotateElementController(
          this as TH2FileEditController,
        );
    splitMergeController = TH2FileEditSplitMergeController(
      this as TH2FileEditController,
    );
    optionEditController = TH2FileEditOptionEditController(
      this as TH2FileEditController,
    );
    overlayWindowController = TH2FileEditOverlayWindowController(
      this as TH2FileEditController,
    );
    searchController = TH2FileEditSearchController(
      this as TH2FileEditController,
    );
    selectionController = TH2FileEditSelectionController(
      this as TH2FileEditController,
    );
    snapController = TH2FileEditSnapController(this as TH2FileEditController);
    undoRedoController = MPUndoRedoController(this as TH2FileEditController);
    visualController = MPVisualController(this as TH2FileEditController);
    userInteractionController = TH2FileEditUserInteractionController(
      this as TH2FileEditController,
    );
    stateController = TH2FileEditStateController(this as TH2FileEditController);
    _th2FileMPID = _th2File.mpID;
  }

  @action
  void _preParseInitialize() {
    _isLoading = true;
    errorMessages.clear();
  }

  /// Returns the controller's single shared file-load operation.
  ///
  /// A failed load stays cached, so calling this again never parses again.
  Future<TH2FileEditControllerCreateResult> load() {
    final Future<TH2FileEditControllerCreateResult>? existingLoad = _loadFuture;

    if (existingLoad != null) {
      return existingLoad;
    }

    final Future<TH2FileEditControllerCreateResult> newLoad =
        _loadOnceRecordingErrors();

    _loadFuture = newLoad;

    return newLoad;
  }

  /// Runs [_loadOnce], recording an unexpected exception in [loadError]
  /// before rethrowing it.
  Future<TH2FileEditControllerCreateResult> _loadOnceRecordingErrors() async {
    try {
      return await _loadOnce();
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        'Failed to load TH2 file ${_th2File.filename}',
        error: error,
        stackTrace: stackTrace,
      );
      _commitLoadError(error);
      rethrow;
    }
  }

  /// Parses and initializes this controller once.
  Future<TH2FileEditControllerCreateResult> _loadOnce() async {
    _preParseInitialize();

    final TH2FileParser parser = TH2FileParser();
    final (_, isSuccessful, errors) = await parser.parse(
      _th2File.filename,
      fileBytes: _th2File.fileBytes,
      forceNewController: false,
    );

    return _commitLoadResult(
      parsedFile: _th2File,
      isSuccessful: isSuccessful,
      errors: errors,
      parsedProblems: parser.problems,
    );
  }

  /// Commits a finished parse as one observable transition, bumping the
  /// structure revision last. A disposed controller commits nothing.
  @action
  TH2FileEditControllerCreateResult _commitLoadResult({
    required TH2File parsedFile,
    required bool isSuccessful,
    required List<String> errors,
    required List<TH2FileProblem> parsedProblems,
  }) {
    final List<TH2FileProblem> loadedProblems =
        List<TH2FileProblem>.unmodifiable(parsedProblems);
    final bool loadedIsBroken = loadedProblems.isNotEmpty || !isSuccessful;
    final TH2FileEditControllerCreateResult result =
        TH2FileEditControllerCreateResult(
          isSuccessful && !loadedIsBroken,
          errors,
          loadedProblems,
        );

    if (_disposed) {
      return result;
    }

    _problems = loadedProblems;
    _isBroken = loadedIsBroken;
    _finalFilePreparations(parsedFile);
    _isFileLoaded = true;

    if (!isSuccessful) {
      errorMessages.addAll(errors);
    }

    bumpStructureRevision();

    return result;
  }

  /// Records an unexpected load exception. A disposed controller records
  /// nothing.
  @action
  void _commitLoadError(Object error) {
    if (_disposed) {
      return;
    }

    _loadError = error;
    _isLoading = false;
  }

  void _finalFilePreparations(TH2File parsedFile) {
    _initializeReactions();

    if (!_isBroken) {
      syncControllersWithModel(initialSetup: true);
    }

    setFilename(_th2File.filename);
    _isLoading = false;
  }

  /// Brings the sub-controllers in line with the whole model: the only place
  /// that does so, after a load ([initialSetup]) and after every file
  /// contents replacement (apply, undo and redo of a text edit).
  @action
  void syncControllersWithModel({required bool initialSetup}) {
    /// 1. Selection.
    selectionController.pruneToModel();
    selectionController.refreshSelectionFromModel();

    /// 2. Hidden.
    hideElementController.pruneToModel();

    /// 3. Active scrap.
    if (_th2File.tryElementByMPID(_activeScrapID) is! THScrap) {
      final List<int> scrapMPIDs = _th2File.scrapMPIDs;

      _activeScrapID = scrapMPIDs.isEmpty ? 0 : scrapMPIDs.first;
    }

    if (_activeScrapID != 0) {
      hideElementController.ensureScrapVisible(_activeScrapID);
    }

    selectionController.resetSelectableElements();
    selectionController.updateSelectableEndAndControlPoints();
    updateHasMultipleScraps();
    _updateCurrentScrapName();

    /// 4. Snap targets. A load computes them once.
    if (initialSetup && _th2File.scrapMPIDs.isNotEmpty) {
      snapController.setSnapTargets(
        pointTarget: MPSnapPointTarget.point,
        linePointTarget: MPSnapLinePointTarget.linePoint,
        xviTargets: [MPSnapXVIFileTarget.shot],
      );
    } else {
      snapController.updateSnapTargets();
    }

    /// 5. Station caches: images may have been added, removed or replaced.
    if (!initialSetup) {
      userInteractionController
        ..markTherionStationPointNameCoordinateCacheDirty()
        ..markXVIStationPointNameCoordinateCacheDirty();
    }

    /// 6. Used types.
    if (initialSetup) {
      elementEditController.initializeUsedTypes();
    }

    /// 7.
    updateEnableSelectButton();
    triggerAllElementsRedraw();
    bumpStructureRevision();
  }

  @visibleForTesting
  void initializeReactionsForTesting() {
    _initializeReactions();
  }

  void _initializeReactions() {
    assert(
      !_isDetachedParse,
      'A detached parse controller must never install reactions.',
    );

    _disposers.add(
      autorun((_) {
        final double snapOnCanvasDistance =
            mpDefaultSnapOnScreenDistance / _canvasScale;

        _currentSnapOnCanvasDistanceSquaredLimit =
            snapOnCanvasDistance * snapOnCanvasDistance;
        _currentSnapGridCellSize =
            snapOnCanvasDistance * mpSnapGridCellSizeFactor;
        snapController.updateSnapTargetsGrid();
      }),
    );

    _disposers.add(
      autorun((_) {
        final double magnitude = MPNumericAux.log10(_canvasScale);
        final int newDecimalPositions = magnitude.ceil() + 1;

        _currentDecimalPositions = newDecimalPositions < 0
            ? 0
            : newDecimalPositions;
      }),
    );

    _disposers.add(
      autorun((_) {
        _screenBoundingBox = MPNumericAux.orderedRectFromLTWH(
          top: 0,
          left: 0,
          width: _screenSize.width,
          height: _screenSize.height,
        );
      }),
    );

    _disposers.add(
      autorun((_) {
        final Offset topLeft = _canvasTranslation;
        final Offset bottomRight =
            topLeft + Offset(_canvasSize.width, _canvasSize.height);

        _canvasBoundingBox = MPNumericAux.orderedRectFromPoints(
          point1: topLeft,
          point2: bottomRight,
        );
      }),
    );

    _disposers.add(
      autorun((_) {
        final MPTH2FileEditState state = stateController.state;

        _isAddElementMode =
            ((state is MPTH2FileEditStateAddArea) ||
            (state is MPTH2FileEditStateAddFreehandLine) ||
            (state is MPTH2FileEditStateAddLine) ||
            (state is MPTH2FileEditStateAddPoint));
      }),
    );

    _disposers.add(
      autorun((_) {
        final MPTH2FileEditState state = stateController.state;

        _isEditLineMode =
            ((state is MPTH2FileEditStateEditSingleLine) ||
            (state is MPTH2FileEditStateMovingEndControlPoints) ||
            (state is MPTH2FileEditStateMovingSingleControlPoint));
      }),
    );

    _disposers.add(
      autorun((_) {
        _enableNodeEditButton =
            (selectionController.mpSelectedElementsLogical.length == 1) &&
            (selectionController.mpSelectedElementsLogical[selectionController
                    .mpSelectedElementsLogical
                    .keys
                    .first]
                is MPSelectedLine);
      }),
    );

    _disposers.add(
      autorun((_) {
        final MPTH2FileEditState state = stateController.state;

        _isSelectMode =
            ((state is MPTH2FileEditStateSelectEmptySelection) ||
            (state is MPTH2FileEditStateSelectNonEmptySelection) ||
            (state is MPTH2FileEditStateElementRotate) ||
            (state is MPTH2FileEditStateMovingElements));
      }),
    );

    _disposers.add(
      autorun((_) {
        _lineThicknessOnCanvas =
            mpLocator.mpSettingsController.getDoubleWithDefault(
              MPSettingID.TH2Edit_LineThickness,
            ) /
            (_canvasScale * devicePixelRatio);
        _lineDirectionTickLengthOnCanvas =
            mpLineDirectionTickLength / (_canvasScale * devicePixelRatio);
        _xviLineThicknessOnCanvas =
            mpXVILineThickness / (_canvasScale * devicePixelRatio);
      }),
    );

    _disposers.add(
      autorun((_) {
        _controlLineThicknessOnCanvas =
            _lineThicknessOnCanvas * mpControlLineThicknessFactor;
      }),
    );

    _disposers.add(
      autorun((_) {
        _pointRadiusOnCanvas =
            mpLocator.mpSettingsController.getDoubleWithDefault(
              MPSettingID.TH2Edit_PointRadius,
            ) /
            (_canvasScale * devicePixelRatio);
      }),
    );

    _disposers.add(
      autorun((_) {
        _selectionToleranceOnCanvas =
            mpLocator.mpSettingsController.getDoubleWithDefault(
              MPSettingID.TH2Edit_SelectionTolerance,
            ) /
            (_canvasScale * devicePixelRatio);
      }),
    );

    _disposers.add(
      autorun((_) {
        _selectionToleranceSquaredOnCanvas =
            (_selectionToleranceOnCanvas * _selectionToleranceOnCanvas);
      }),
    );

    _disposers.add(
      autorun((_) {
        _selectionHandleSizeOnCanvas =
            mpSelectionHandleSize / (_canvasScale * devicePixelRatio);
      }),
    );

    _disposers.add(
      autorun((_) {
        _selectionHandleDistanceOnCanvas =
            mpSelectionHandleDistance / (_canvasScale * devicePixelRatio);
      }),
    );

    _disposers.add(
      autorun((_) {
        _selectionHandleLineThicknessOnCanvas =
            mpSelectionHandleLineThickness / (_canvasScale * devicePixelRatio);
      }),
    );

    _disposers.add(
      reaction(
        (_) => canSave,
        (bool isDirty) {
          final THProjectController projectController =
              mpLocator.thProjectController;
          final String canonicalPath = THProjectPathResolver.canonicalize(
            p.absolute(_th2File.filename),
          );

          if (isDirty) {
            projectController.dirtyFilePaths.add(canonicalPath);
          } else {
            projectController.dirtyFilePaths.remove(canonicalPath);
          }
        },
      ),
    );
  }

  void _disposeReactions() {
    for (final disposer in _disposers) {
      disposer();
    }
    _disposers.clear();
  }

  /// Runs [body] as a gated operation: returns `null` without running it
  /// while another gated operation runs or after disposal.
  Future<T?> runGatedOperation<T>(Future<T> Function() body) =>
      _operationGate.run<T>(body);

  /// Whether the text buffer is locked by a running operation. Observable.
  @override
  bool get isBufferLocked => _isBufferLocked.value;

  /// Takes the buffer lock. Taking it while held changes nothing.
  @override
  void acquireBufferLock() {
    if (_isBufferLocked.value) {
      return;
    }

    runInAction(() => _isBufferLocked.value = true);
  }

  /// Releases the buffer lock. Releasing it when not held changes nothing.
  @override
  void releaseBufferLock() {
    if (!_isBufferLocked.value) {
      return;
    }

    runInAction(() => _isBufferLocked.value = false);
  }

  /// Whether a command may change the model or the undo/redo stacks: always
  /// on the canvas, and in text mode only inside [runAuthorizedMutation].
  bool get isModelMutationAllowed =>
      (_editMode == TH2EditMode.canvas) || (_authorizedMutationDepth > 0);

  /// Runs the synchronous [body] with model mutations authorized. Never
  /// retain the authorization across an await.
  T runAuthorizedMutation<T>(T Function() body) {
    _authorizedMutationDepth++;

    try {
      return body();
    } finally {
      _authorizedMutationDepth--;
    }
  }

  @action
  void setShowImages(bool shouldShow) {
    _showImages = shouldShow;
  }

  @action
  void performSetZoomButtonsHovered(bool isHovered) {
    _isZoomButtonsHovered = isHovered;
  }

  @action
  void performSetAddElementButtonsHovered(bool isHovered) {
    _isAddElementButtonsHovered = isHovered;
  }

  @action
  void setCanvasCursor(MouseCursor cursor) {
    _canvasCursor = cursor;
  }

  @action
  void setStatusBarMessage(String message) {
    _statusBarMessage = message;
  }

  THScrap getActiveScrap() {
    return _th2File.scrapByMPID(_activeScrapID);
  }

  int getNextAvailableScrapID() {
    final List<int> scrapIDs = _th2File.scrapMPIDs.toList();
    final int currentIndex = scrapIDs.indexOf(_activeScrapID);

    if (currentIndex == -1 || scrapIDs.isEmpty) {
      throw Exception('Current active scrap ID not found in scrapIDs');
    }

    final int nextIndex = (currentIndex + 1) % scrapIDs.length;

    return scrapIDs[nextIndex];
  }

  bool isFromActiveScrap(THElement element) {
    return element.parentMPID == _activeScrapID;
  }

  bool isFromActiveScrapByParentMPID(int parentMPID) {
    return parentMPID == _activeScrapID;
  }

  /// Makes [scrapMPID] the active scrap and shows it: the active scrap is
  /// always visible.
  @action
  void setActiveScrap(int scrapMPID) {
    if (scrapMPID != 0) {
      hideElementController.ensureScrapVisible(scrapMPID);
    }

    if (scrapMPID == _activeScrapID) {
      return;
    }

    _activeScrapID = scrapMPID;
    _updateCurrentScrapName();
    selectionController.resetSelectableElements();
    final bool stateChanged = stateController.setState(
      MPTH2FileEditStateType.selectEmptySelection,
    );

    if (!stateChanged) {
      selectionController.clearSelectedElements();
      selectionController.clearSelectedEndControlPoints();
      selectionController.clearSelectedLineSegments();
    }

    snapController.updateSnapTargets();
    updateEnableSelectButton();
  }

  void setActiveScrapByChildElement(THElement element) {
    THIsParentMixin parent = (element is THIsParentMixin)
        ? element as THIsParentMixin
        : element.parent(th2File: _th2File);

    while (parent is THElement) {
      if (parent is THScrap) {
        setActiveScrap(parent.mpID);
        return;
      }

      parent = (parent as THElement).parent(th2File: _th2File);
    }
  }

  void setActiveScrapForScrapRemoval(int removedScrapMPID) {
    if (_activeScrapID != removedScrapMPID) {
      return;
    }

    final List<THScrap> availableScraps = _th2File.getScraps().toList();

    if (availableScraps.length == 1) {
      setActiveScrap(0);
    } else {
      final int currentIndex = availableScraps.indexWhere(
        (s) => s.mpID == removedScrapMPID,
      );
      final int newIndex = (currentIndex < availableScraps.length - 1)
          ? currentIndex + 1
          : currentIndex - 1;

      setActiveScrap(availableScraps[newIndex].mpID);
    }
  }

  Map<int, String> availableScraps() {
    final Map<int, String> scraps = {};

    for (final int scrapMPID in _th2File.scrapMPIDs) {
      final THScrap scrap = _th2File.scrapByMPID(scrapMPID);

      scraps[scrapMPID] = scrap.thID;
    }

    return scraps;
  }

  @action
  void toggleToNextAvailableScrap() {
    final int nextAvailableScrapID = getNextAvailableScrapID();

    setActiveScrap(nextAvailableScrapID);
  }

  bool offsetsInSelectionTolerance(Offset offset1, Offset offset2) {
    final double dx = offset1.dx - offset2.dx;
    final double dy = offset1.dy - offset2.dy;

    return ((dx * dx) + (dy * dy)) < _selectionToleranceSquaredOnCanvas;
  }

  void updateScreenSize(Size newSize) {
    if (_screenSize == newSize) {
      return;
    }
    _updateScreenSize(newSize);
  }

  @action
  void _updateScreenSize(Size newSize) {
    _screenSize = newSize;
    _screenBoundingBox = MPNumericAux.orderedRectFromLTWH(
      top: 0,
      left: 0,
      width: _screenSize.width,
      height: _screenSize.height,
    );
    _canvasSize = newSize / _canvasScale;
    _calculateCanvasOffset();
    userInteractionController.markStationPointNameCoordinateCacheDirty();
  }

  Offset offsetScaleScreenToCanvas(Offset screenCoordinate) {
    return Offset(
      screenCoordinate.dx / _canvasScale,
      screenCoordinate.dy / (-_canvasScale),
    );
  }

  Offset offsetScaleCanvasToScreen(Offset canvasCoordinate) {
    return Offset(
      canvasCoordinate.dx * _canvasScale,
      canvasCoordinate.dy * (-_canvasScale),
    );
  }

  Offset offsetScreenToCanvas(Offset screenCoordinate) {
    // Apply the inverse of the translation
    final double canvasX =
        (screenCoordinate.dx / _canvasScale) - _canvasTranslation.dx;
    final double canvasY =
        _canvasTranslation.dy - (screenCoordinate.dy / _canvasScale);

    return Offset(canvasX, canvasY);
  }

  Offset offsetCanvasToScreen(Offset canvasCoordinate) {
    // Apply the translation and scaling
    final double screenX =
        (_canvasTranslation.dx + canvasCoordinate.dx) * _canvasScale;
    final double screenY =
        (_canvasTranslation.dy - canvasCoordinate.dy) * _canvasScale;

    return Offset(screenX, screenY);
  }

  double scaleScreenToCanvas(double screenValue) {
    return screenValue / _canvasScale;
  }

  double scaleCanvasToScreen(double canvasValue) {
    return canvasValue * _canvasScale;
  }

  @action
  void onAltClickSelectScrap(PointerUpEvent event) {
    final List<int> scrapMPIDs = _th2File.scrapMPIDs;

    if (scrapMPIDs.length < 2) {
      return;
    }

    for (final int scrapMPID in scrapMPIDs) {
      if (scrapMPID == _activeScrapID) {
        continue;
      }

      final THScrap scrap = _th2File.scrapByMPID(scrapMPID);
      final Rect scrapBoundingBox = MPInteractionAux.getScrapBackgroundRect(
        scrap: scrap,
        th2FileEditController: this as TH2FileEditController,
      );

      if (scrapBoundingBox.contains(
        offsetScreenToCanvas(event.localPosition),
      )) {
        setActiveScrap(scrapMPID);
        stateController.setState(MPTH2FileEditStateType.selectEmptySelection);

        return;
      }
    }
  }

  @action
  void onPointerMoveUpdateMoveCanvasMode(PointerMoveEvent event) {
    _canvasTranslation += (event.delta / _canvasScale);
    _setCanvasCenterFromCurrent();
    _changedCanvasTransform();
  }

  @action
  void triggerAllElementsRedraw() {
    selectionController
        .clearSelectedElementsBoundingBoxAndSelectionHandleCenters();
    _redrawTriggerAllElements++;
  }

  @action
  void triggerSelectedElementsRedraw({bool setState = false}) {
    selectionController
        .clearSelectedElementsBoundingBoxAndSelectionHandleCenters();
    _redrawTriggerSelectedElements++;

    if (setState) {
      selectionController.setSelectionState();
    }
  }

  @action
  void triggerNonSelectedElementsRedraw() {
    _redrawTriggerNonSelectedElements++;
  }

  @action
  void triggerSelectedListChanged() {
    selectionController
        .clearSelectedElementsBoundingBoxAndSelectionHandleCenters();
    _redrawTriggerSelectedElementsListChanged++;
  }

  @action
  void triggerNewLineRedraw() {
    _redrawTriggerNewLine++;
  }

  @action
  void triggerFreehandLineRedraw() {
    _redrawTriggerFreehandLine++;
  }

  @action
  void triggerEditLineRedraw() {
    _redrawTriggerEditLine++;
  }

  @action
  void triggerOptionsListRedraw() {
    _redrawTriggerOptionsList++;
  }

  @action
  void triggerImagesRedraw() {
    _redrawTriggerImages++;
  }

  @action
  void triggerSnapTargetsWindowRedraw() {
    _redrawSnapTargetsWindow++;
  }

  void _setCanvasCenterFromCurrent() {
    mpLocator.mpLog.finer("Current center: $_canvasCenterX, $_canvasCenterY");
    _canvasCenterX =
        -(_canvasTranslation.dx - (_screenSize.width / 2.0 / _canvasScale));
    _canvasCenterY =
        _canvasTranslation.dy - (_screenSize.height / 2.0 / _canvasScale);
    mpLocator.mpLog.finer("New center: $_canvasCenterX, $_canvasCenterY");
  }

  @action
  void setCanvasScale(double newScale) {
    _canvasScale = newScale;

    _changedCanvasTransform();
  }

  @action
  void zoomIn({bool fineZoom = false, Offset? zoomCenter}) {
    final double newScale = MPNumericAux.calculateNextZoomLevel(
      scale: _canvasScale,
      factor: fineZoom ? mpFineZoomFactor : mpRegularZoomFactor,
      isIncrease: true,
    );

    if (selectionController.mpSelectedElementsLogical.isNotEmpty) {
      _setCanvasCenterOnZoom(zoomToFitType: MPZoomToFitType.selection);
    } else if (zoomCenter != null) {
      final Offset newCenter = _calculateCanvasCenterForZoom(
        zoomCenterScreen: zoomCenter,
        newScale: newScale,
      );

      _setCanvasCenter(newCenter);
    }
    setCanvasScale(newScale);
  }

  @action
  void zoomOut({bool fineZoom = false, Offset? zoomCenter}) {
    final double newScale = MPNumericAux.calculateNextZoomLevel(
      scale: _canvasScale,
      factor: fineZoom ? mpFineZoomFactor : mpRegularZoomFactor,
      isIncrease: false,
    );

    if (selectionController.mpSelectedElementsLogical.isNotEmpty) {
      _setCanvasCenterOnZoom(zoomToFitType: MPZoomToFitType.selection);
    } else if (zoomCenter != null) {
      final Offset newCenter = _calculateCanvasCenterForZoom(
        zoomCenterScreen: zoomCenter,
        newScale: newScale,
      );

      _setCanvasCenter(newCenter);
    }
    setCanvasScale(newScale);
  }

  @action
  void zoomOneToOne() {
    if (selectionController.mpSelectedElementsLogical.isNotEmpty) {
      _setCanvasCenterOnZoom(zoomToFitType: MPZoomToFitType.selection);
    }
    setCanvasScale(1);
  }

  @action
  void zoomToFit({required MPZoomToFitType zoomFitToType}) {
    if ((zoomFitToType == MPZoomToFitType.selection) &&
        selectionController.mpSelectedElementsLogical.isEmpty) {
      return;
    }

    final double screenWidth = _screenSize.width;
    final double screenHeight = _screenSize.height;

    _getFileDrawingSize(zoomToFitType: zoomFitToType);

    final double scaleWidth =
        (screenWidth * (1.0 - mpCanvasVisibleMargin)) / _dataWidth;
    final double scaleHeight =
        (screenHeight * (1.0 - mpCanvasVisibleMargin)) / _dataHeight;

    _setCanvasCenterOnZoom(zoomToFitType: zoomFitToType);
    setCanvasScale(
      MPNumericAux.roundScale(
        (scaleWidth < scaleHeight) ? scaleWidth : scaleHeight,
      ),
    );
  }

  @action
  void zoomToSelectionWindow(Rect selectionWindow) {
    final double screenWidth = _screenSize.width;
    final double screenHeight = _screenSize.height;

    if ((screenWidth <= 0) || (screenHeight <= 0)) {
      return;
    }

    final double selectionWidth =
        (selectionWindow.width < mpMinimumSizeForDrawing)
        ? mpMinimumSizeForDrawing
        : selectionWindow.width;
    final double selectionHeight =
        (selectionWindow.height < mpMinimumSizeForDrawing)
        ? mpMinimumSizeForDrawing
        : selectionWindow.height;
    final double scaleWidth =
        (screenWidth * (1.0 - mpCanvasVisibleMargin)) / selectionWidth;
    final double scaleHeight =
        (screenHeight * (1.0 - mpCanvasVisibleMargin)) / selectionHeight;
    final double targetScale = (scaleWidth < scaleHeight)
        ? scaleWidth
        : scaleHeight;

    if (!targetScale.isFinite || (targetScale <= 0)) {
      return;
    }

    _setCanvasCenter(selectionWindow.center);
    setCanvasScale(MPNumericAux.roundScale(targetScale));
  }

  void _changedCanvasTransform() {
    _canvasSize = _screenSize / _canvasScale;
    _calculateCanvasOffset();
    _canvasScaleTranslationUndefined = false;
    userInteractionController.markStationPointNameCoordinateCacheDirty();
    selectionController.warmSelectableElementsCanvasScaleChanged();
    selectionController
        .clearSelectedElementsBoundingBoxAndSelectionHandleCenters();
    triggerAllElementsRedraw();
  }

  /// Closes this file's tab. The reactions stay alive: the controller may be
  /// kept tab-less for the sidebar tree, and [dispose] disposes them when the
  /// controller is removed.
  void close() {
    overlayWindowController.clearOverlayWindows();
    visualController.patternCache.clear();
    mpLocator.mpGeneralController.removeFileTab(filename: _th2File.filename);
  }

  /// Zooms to [type] now if the canvas is laid out, otherwise on the canvas'
  /// first layout, instead of the default zoom to the whole file.
  void requestZoomToFit(MPZoomToFitType type) {
    final bool isLaidOut =
        !_screenSize.isEmpty && !_canvasScaleTranslationUndefined;

    if (isLaidOut) {
      zoomToFit(zoomFitToType: type);

      return;
    }

    _pendingZoomToFitType = type;
  }

  /// Returns and clears the zoom requested before the first layout.
  MPZoomToFitType? takePendingZoomToFitType() {
    final MPZoomToFitType? pendingType = _pendingZoomToFitType;

    _pendingZoomToFitType = null;

    return pendingType;
  }

  @action
  void bumpStructureRevision() {
    selectionController.pruneSelectedScraps();
    if (!_isLoading) _structureRevision++;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _disposeReactions();
    _textEditController?.dispose();
    isInteractiveLineSimplificationDialogOpen.dispose();
    if (th2FileFocusNode.context == null) {
      th2FileFocusNode.dispose();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        th2FileFocusNode.dispose();
      });
      WidgetsBinding.instance.scheduleFrame();
    }
  }

  @action
  void _calculateCanvasOffset() {
    final double xOffset = (_canvasSize.width / 2.0) - _canvasCenterX;
    final double yOffset = (_canvasSize.height / 2.0) + _canvasCenterY;

    _canvasTranslation = Offset(xOffset, yOffset);
  }

  @action
  void moveCanvasVertically({required bool up}) {
    double delta = _canvasSize.height * mpCanvasMovementFactor;
    if (up) {
      delta = -delta;
    }
    _canvasCenterY += delta;
    _calculateCanvasOffset();
    _changedCanvasTransform();
  }

  @action
  void moveCanvasHorizontally({required bool left}) {
    double delta = _canvasSize.width * mpCanvasMovementFactor;
    if (!left) {
      delta = -delta;
    }
    _canvasCenterX += delta;
    _calculateCanvasOffset();
    _changedCanvasTransform();
  }

  void _getFileDrawingSize({required MPZoomToFitType zoomToFitType}) {
    final Rect dataBoundingBox = _getZoomToFitBoundingBox(
      zoomFitToType: zoomToFitType,
    );

    _dataWidth = (dataBoundingBox.width < mpMinimumSizeForDrawing)
        ? mpMinimumSizeForDrawing
        : dataBoundingBox.width;

    _dataHeight = (dataBoundingBox.height < mpMinimumSizeForDrawing)
        ? mpMinimumSizeForDrawing
        : dataBoundingBox.height;
  }

  Rect _getZoomToFitBoundingBox({required MPZoomToFitType zoomFitToType}) {
    switch (zoomFitToType) {
      case MPZoomToFitType.file:
        return _th2File.getBoundingBox(this as TH2FileEditController)!;
      case MPZoomToFitType.scrap:
        return (_activeScrapID > 0)
            ? (_th2File.scrapByMPID(
                _activeScrapID,
              )).getBoundingBox(this as TH2FileEditController)!
            : _th2File.getBoundingBox(this as TH2FileEditController)!;
      case MPZoomToFitType.selection:
        return selectionController.getSelectedElementsBoundingBoxOnCanvas();
    }
  }

  void _setCanvasCenterOnZoom({required MPZoomToFitType zoomToFitType}) {
    final Rect dataBoundingBox = _getZoomToFitBoundingBox(
      zoomFitToType: zoomToFitType,
    );
    final Offset dataBoundingBoxCenter = dataBoundingBox.center;

    // mpLocator.mpLog.finer("Current center: $_canvasCenterX, $_canvasCenterY");
    _setCanvasCenter(dataBoundingBoxCenter);
    // mpLocator.mpLog.finer(
    //   "New center to center drawing in canvas: $_canvasCenterX, $_canvasCenterY",
    // );
  }

  void _setCanvasCenter(Offset center) {
    _canvasCenterX = center.dx;
    _canvasCenterY = center.dy;
  }

  Offset _calculateCanvasCenterForZoom({
    required Offset zoomCenterScreen,
    required double newScale,
  }) {
    final Offset zoomCenterCanvas = offsetScreenToCanvas(zoomCenterScreen);
    final double halfScreenWidthOnCanvas = _screenSize.width / (2.0 * newScale);
    final double halfScreenHeightOnCanvas =
        _screenSize.height / (2.0 * newScale);
    final double centerX =
        zoomCenterCanvas.dx +
        halfScreenWidthOnCanvas -
        (zoomCenterScreen.dx / newScale);
    final double centerY =
        zoomCenterCanvas.dy +
        (zoomCenterScreen.dy / newScale) -
        halfScreenHeightOnCanvas;

    return Offset(centerX, centerY);
  }

  void transformCanvas(Canvas canvas, {bool invert = true}) {
    /// Transformations are applied on the order they are defined.
    canvas.scale(_canvasScale);
    canvas.translate(_canvasTranslation.dx, _canvasTranslation.dy);
    if (invert) {
      canvas.scale(1, -1);
    }
  }

  /// The text session, when text mode has an open one.
  TH2TextEditController? get _openTextSession {
    final TH2TextEditController? session = _textEditController;

    if ((_editMode != TH2EditMode.text) ||
        (session == null) ||
        !session.isOpen) {
      return null;
    }

    return session;
  }

  /// The focus node a tab activation focuses: the text field while text
  /// mode has an open session, the canvas otherwise.
  FocusNode get activeFocusNode =>
      (_openTextSession?.textFieldFocusNode) ?? th2FileFocusNode;

  /// Whether the "can't apply" banner shows: while the buffer still equals
  /// the rejected text.
  @computed
  bool get showTextApplyRejection {
    final TH2TextApplyRejection? rejection = _textApplyRejection;
    final TH2TextEditController? session = _textEditController;

    return (rejection != null) &&
        (session != null) &&
        session.isOpen &&
        (session.content == rejection.content);
  }

  @override
  String get filename => _th2File.filename;

  @override
  String get defaultLineEnding => _th2File.lineEnding;

  /// The text controller's Save: logs failures, as the page's Save does.
  @override
  Future<void> save() async {
    try {
      await saveTH2File();
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        '[TH2FileEditController] save failed for ${_th2File.filename}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Switches between the canvas and text mode. Broken files are left
  /// alone.
  Future<void> toggleEditMode() async {
    if (_editMode == TH2EditMode.canvas) {
      await enterTextMode();
    } else {
      await leaveTextMode();
    }
  }

  /// For UI callbacks: [toggleEditMode], unawaited, logging failures.
  void requestToggleEditMode() {
    _runLoggedUIOperation(toggleEditMode, 'toggle the edit mode');
  }

  /// For UI callbacks: [enterTextMode], unawaited, logging failures.
  void requestEnterTextMode() {
    _runLoggedUIOperation(enterTextMode, 'enter text mode');
  }

  /// For UI callbacks: [discardTextEdits], unawaited, logging failures.
  void requestDiscardTextEdits() {
    _runLoggedUIOperation(discardTextEdits, 'discard the text edits');
  }

  void _runLoggedUIOperation(
    Future<void> Function() operation,
    String description,
  ) {
    unawaited(
      operation().catchError((Object error, StackTrace stackTrace) {
        mpLocator.mpLog.e(
          'Failed to $description for ${_th2File.filename}',
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  }

  /// Enters text mode, as a gated operation.
  Future<void> enterTextMode() async {
    await _operationGate.run<void>(_enterTextModeGated);
  }

  Future<void> _enterTextModeGated() async {
    /// A new file is never loaded: it has a model from its creation.
    if (_disposed ||
        (!_isFileLoaded && !_th2File.isNewFile) ||
        (_loadError != null) ||
        !mpLocator.mpGeneralController.hasOpenTab(_th2File.filename) ||
        (_editMode == TH2EditMode.text) ||
        _isBroken) {
      return;
    }

    assert(
      !isInteractiveLineSimplificationDialogOpen.value,
      'Text mode entered while the line simplification dialog is open.',
    );

    /// The text source check, before any state changes.
    try {
      serializeForTextMode();
    } on TH2UnsupportedLineEndingException catch (error, stackTrace) {
      mpLocator.mpLog.e(
        'Text mode refused for ${_th2File.filename}',
        error: error,
        stackTrace: stackTrace,
      );
      _showUserMessage(
        mpLocator.appLocalizations.th2TextUnsupportedLineEndingMessage,
      );

      return;
    }

    /// Leaves the canvas state as the tree does; finishing a line or area
    /// being drawn may run its normal canvas commands.
    if (!_isEditLineMode) {
      stateController.onButtonPressed(MPButtonType.select);
    }
    overlayWindowController.clearOverlayWindows();

    final String content;
    final TH2TextLineMap lineMap;

    try {
      (content, lineMap) = serializeForTextMode();
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        'Text mode serialization failed for ${_th2File.filename}',
        error: error,
        stackTrace: stackTrace,
      );
      _showUserMessage(_textSessionFailureMessage(error));

      return;
    }

    final int? cursorLine = _entryCursorLine(lineMap);
    final TH2TextEditBaseline baseline;

    if (cursorLine == null) {
      baseline = TH2TextEditBaseline(content: content, lineMap: lineMap);
    } else {
      final _TH2TextPosition position = _TH2TextPosition.atFirstNonBlank(
        content,
        cursorLine,
      );

      baseline = TH2TextEditBaseline(
        content: content,
        lineMap: lineMap,
        cursorLine: position.line,
        cursorColumn: position.column,
        selection: TextRange.collapsed(position.offset),
        selectionRequestsFocus: true,
      );
    }

    _installTextSessionOnEntry(baseline);
    _focusActiveNodeAfterFrame(TH2EditMode.text);
  }

  @action
  void _installTextSessionOnEntry(TH2TextEditBaseline baseline) {
    final TH2TextEditController textEditController =
        _textEditController ??
        TH2TextEditController(owner: this as TH2FileEditController);

    _textEditController = textEditController;
    _textApplyRejection = null;
    textEditController.installBaseline(baseline);
    _editMode = TH2EditMode.text;
  }

  /// The entry cursor line: the selected element nearest the top, or the
  /// edited line in _Line edit_ mode; `null` with no selection.
  int? _entryCursorLine(TH2TextLineMap lineMap) {
    final Map<int, MPSelectedEndControlPoint> selectedEndControlPoints =
        selectionController.selectedEndControlPoints;

    /// In _Line edit_ mode the selected line points, or the edited line
    /// when none is selected.
    final Set<int> mpIDs = _isEditLineMode
        ? <int>{
            for (final MPSelectedEndControlPoint endControlPoint
                in selectedEndControlPoints.values)
              endControlPoint.originalLineSegmentClone.mpID,
            if (selectedEndControlPoints.isEmpty &&
                selectionController.isSingleLineSelected())
              selectionController.getSelectedLine().mpID,
          }
        : <int>{
            ...selectionController.mpSelectedElementsLogical.keys,
            for (final MPSelectedEndControlPoint endControlPoint
                in selectedEndControlPoints.values)
              endControlPoint.originalLineSegmentClone.mpID,
            ...selectionController.selectedScrapMPIDs,
          };

    int? cursorLine;

    for (final int mpID in mpIDs) {
      final int? line = lineMap.firstOwnLineOf(mpID);

      if ((line != null) && ((cursorLine == null) || (line < cursorLine))) {
        cursorLine = line;
      }
    }

    return cursorLine;
  }

  /// Leaves text mode, applying the buffer, as a gated operation.
  Future<void> leaveTextMode() async {
    await _operationGate.run<void>(_leaveTextModeGated);
  }

  Future<void> _leaveTextModeGated() async {
    final TH2TextEditController? session = _openTextSession;

    if (session == null) {
      return;
    }

    acquireBufferLock();

    try {
      final TH2TextApplyResult result = await applyTextContent(
        session.content,
        session: session,
        lockBufferOnAccept: true,
      );

      if (_disposed || !session.isOpen) {
        return;
      }

      final TH2TextLineMap lineMap;
      final int cursorLine;

      switch (result) {
        case TH2TextApplyRejected():
          _publishTextApplyRejection(session, result);

          return;
        case TH2TextApplyCancelled():
          return;
        case TH2TextApplyApplied():
          lineMap = result.lineMap;
          cursorLine = result.cursorLine;
        case TH2TextApplyUnchanged():
          lineMap = result.lineMap;
          cursorLine = result.cursorLine;
      }

      final TH2TextLocation location = TH2TextElementLocator.locate(
        line: cursorLine,
        lineMap: lineMap,
        th2File: _th2File,
      );

      _returnToCanvas();
      applyTextLocation(location);
      _revealSelectionAfterFrame();
      _focusActiveNodeAfterFrame(TH2EditMode.canvas);
    } finally {
      releaseBufferLock();
    }
  }

  /// Ends the session without an apply and returns to the canvas, as a
  /// gated operation. The model is untouched.
  @override
  Future<void> discardTextEdits() async {
    await _operationGate.run<void>(_discardTextEditsGated);
  }

  Future<void> _discardTextEditsGated() async {
    final TH2TextEditController? session = _openTextSession;

    if (session == null) {
      return;
    }

    acquireBufferLock();

    try {
      _returnToCanvas();
      _focusActiveNodeAfterFrame(TH2EditMode.canvas);
    } finally {
      releaseBufferLock();
    }
  }

  /// Hides the "can't apply" banner and focuses the text field.
  @action
  void keepEditingAfterRejection() {
    _textApplyRejection = null;
    _openTextSession?.textFieldFocusNode.requestFocus();
  }

  /// Called for every closing tab: ends the session and returns to the
  /// canvas at once, even while a gated operation runs. Applies nothing.
  @action
  void onTabClosed() {
    final TH2TextEditController? session = _textEditController;

    if ((session != null) && session.isOpen) {
      session.endSession();
    }
    _textApplyRejection = null;
    _editMode = TH2EditMode.canvas;
  }

  @action
  void _returnToCanvas() {
    _textEditController?.endSession();
    _textApplyRejection = null;
    _editMode = TH2EditMode.canvas;
  }

  @action
  void _publishTextApplyRejection(
    TH2TextEditController session,
    TH2TextApplyRejected rejected,
  ) {
    _textApplyRejection = TH2TextApplyRejection(
      content: rejected.content,
      diagnostics: rejected.diagnostics,
    );
    session.showDiagnostics(rejected.diagnostics, content: rejected.content);
  }

  /// Selects on the canvas what the text cursor named when leaving text
  /// mode. The cursor decides the active scrap, since only the active
  /// scrap's elements can be selected.
  @action
  void applyTextLocation(TH2TextLocation location) {
    /// Entry keeps _Line edit_ mode; any target but a line point leaves it
    /// first, as `Esc` does, so no line edit state outlives its line.
    if (_isEditLineMode && (location is! TH2TextLocationSelectLinePoint)) {
      stateController.setState(MPTH2FileEditStateType.selectEmptySelection);
    }

    switch (location) {
      case TH2TextLocationSelectElement():
        setActiveScrap(location.scrapMPID);
        selectionController.setSelectedElements(<THElement>[
          _th2File.elementByMPID(location.mpID),
        ], setState: true);
      case TH2TextLocationSelectLinePoint():
        setActiveScrap(location.scrapMPID);
        selectionController.setSelectedElements(<THElement>[
          _th2File.lineByMPID(location.lineMPID),
        ], setState: true);
        stateController.setState(MPTH2FileEditStateType.editSingleLine);

        for (final MPSelectableEndControlPoint endControlPoint
            in selectionController.getMPSelectableEndControlPoints()) {
          if ((endControlPoint.lineSegment.mpID == location.lineSegmentMPID) &&
              ((endControlPoint.type ==
                      MPEndControlPointType.endPointStraight) ||
                  (endControlPoint.type ==
                      MPEndControlPointType.endPointBezierCurve))) {
            selectionController.setSelectedEndControlPoint(endControlPoint);
            break;
          }
        }
        selectionController.updateSelectableEndAndControlPoints();
        triggerEditLineRedraw();
      case TH2TextLocationActivateScrap():
        setActiveScrap(location.scrapMPID);
        selectionController.setSelectedElements(
          const <THElement>[],
          setState: true,
        );
      case TH2TextLocationFileLevel():
        selectionController.setSelectedElements(
          const <THElement>[],
          setState: true,
        );
    }
  }

  /// Centers the canvas on the selection, at the current scale, when the
  /// selection isn't fully visible.
  @action
  void revealSelection() {
    if (_screenSize.isEmpty || _canvasScaleTranslationUndefined) {
      _pendingRevealSelection = true;

      return;
    }

    final Rect? target = _selectionRevealRect();

    if (target == null) {
      return;
    }

    final Rect visible = Rect.fromPoints(
      offsetScreenToCanvas(Offset.zero),
      offsetScreenToCanvas(Offset(_screenSize.width, _screenSize.height)),
    );

    if ((visible.contains(target.topLeft) &&
        visible.contains(target.bottomRight))) {
      return;
    }

    _setCanvasCenter(target.center);
    _changedCanvasTransform();
  }

  /// Returns and clears a reveal requested before the first layout.
  bool takePendingRevealSelection() {
    final bool isPending = _pendingRevealSelection;

    _pendingRevealSelection = false;

    return isPending;
  }

  /// The selected line point's position, or the selection's bounding box.
  Rect? _selectionRevealRect() {
    final Map<int, MPSelectedEndControlPoint> selectedEndControlPoints =
        selectionController.selectedEndControlPoints;

    if (_isEditLineMode && selectedEndControlPoints.isNotEmpty) {
      final THLineSegment lineSegment =
          selectedEndControlPoints.values.first.originalLineSegmentClone;
      final Offset position = lineSegment.endPoint.coordinates;

      return Rect.fromCenter(center: position, width: 0, height: 0);
    }

    if (selectionController.mpSelectedElementsLogical.isEmpty) {
      return null;
    }

    return selectionController.getSelectedElementsBoundingBoxOnCanvas();
  }

  void _revealSelectionAfterFrame() {
    final TH2EditMode expectedMode = _editMode;

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (_disposed || (_editMode != expectedMode)) {
        return;
      }

      revealSelection();
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  /// Focuses [activeFocusNode] after the frame, unless the controller was
  /// disposed or the mode is no longer [expectedMode].
  void _focusActiveNodeAfterFrame(TH2EditMode expectedMode) {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (_disposed || (_editMode != expectedMode)) {
        return;
      }

      activeFocusNode.requestFocus();
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  /// The message shown when a text session couldn't be prepared.
  String _textSessionFailureMessage(Object error) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return (error is TH2UnsupportedLineEndingException)
        ? appLocalizations.th2TextUnsupportedLineEndingMessage
        : appLocalizations.th2TextEditorReopenFailedMessage;
  }

  /// Moves the text cursor to [mpID]'s first own line, at its first
  /// non-blank column, mapped through the buffer's edits. Does nothing while
  /// a gated operation runs or without an open session.
  @action
  void moveTextCursorToElement(int mpID, {bool requestFocus = true}) {
    final TH2TextEditController? session = _openTextSession;

    if (_operationGate.isBusy || (session == null)) {
      return;
    }

    final int? initialLine = session.initialLineMap.firstOwnLineOf(mpID);

    if (initialLine == null) {
      return;
    }

    final String content = session.content;
    int line = initialLine;

    if (content != session.initialContent) {
      line = session.lineTracker?.currentLineOf(initialLine) ?? 0;
    }

    final _TH2TextPosition position = _TH2TextPosition.atFirstNonBlank(
      content,
      line,
    );

    session.scrollToLine(position.line);
    session.revealRange(
      TextRange.collapsed(position.offset),
      requestFocus: requestFocus,
    );
  }

  /// Copies the text of [mpIDs] from the session's baseline to the system
  /// clipboard: each element's lines with its descendants, in text order,
  /// with an area's border lines before it, as the canvas copy adds them.
  /// Mapiah's own clipboard is not touched; failures are only logged.
  Future<void> copyTextFragment(List<int> mpIDs) async {
    final TH2TextEditController? session = _openTextSession;

    if (session == null) {
      return;
    }

    final String fragment = _textFragmentOf(
      mpIDs,
      content: session.initialContent,
      lineMap: session.initialLineMap,
    );

    if (fragment.isEmpty) {
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: fragment));
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        'Failed to copy the text of ${mpIDs.length} element(s)',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String _textFragmentOf(
    List<int> mpIDs, {
    required String content,
    required TH2TextLineMap lineMap,
  }) {
    final List<int> requested =
        mpIDs.where((int mpID) => lineMap.rangeOf(mpID) != null).toList()
          ..sort(
            (int a, int b) =>
                lineMap.rangeOf(a)!.$1.compareTo(lineMap.rangeOf(b)!.$1),
          );

    bool isInsideAnother(int mpID, Iterable<int> others) {
      final (int first, int last) = lineMap.rangeOf(mpID)!;

      for (final int other in others) {
        if (other == mpID) {
          continue;
        }

        final (int otherFirst, int otherLast) = lineMap.rangeOf(other)!;

        if ((otherFirst <= first) &&
            (last <= otherLast) &&
            ((otherFirst != first) || (otherLast != last))) {
          return true;
        }
      }

      return false;
    }

    final List<int> topLevel = requested
        .where((int mpID) => !isInsideAnother(mpID, requested))
        .toList();
    final List<int> blocks = <int>[];
    final Set<int> added = <int>{};

    for (final int mpID in topLevel) {
      final THElement? element = _th2File.tryElementByMPID(mpID);

      if (element is THArea) {
        for (final int borderLineMPID
            in copyPasteController.borderLineMPIDsOfArea(element)) {
          if ((lineMap.rangeOf(borderLineMPID) == null) ||
              isInsideAnother(borderLineMPID, topLevel) ||
              topLevel.contains(borderLineMPID) ||
              !added.add(borderLineMPID)) {
            continue;
          }

          blocks.add(borderLineMPID);
        }
      }

      if (added.add(mpID)) {
        blocks.add(mpID);
      }
    }

    final List<int> lineStarts = _TH2TextPosition._lineStarts(content);
    final StringBuffer fragment = StringBuffer();

    for (int index = 0; index < blocks.length; index++) {
      final (int first, int last) = lineMap.rangeOf(blocks[index])!;
      final int start = lineStarts[first.clamp(0, lineStarts.length - 1)];
      final int end = (last + 1 < lineStarts.length)
          ? lineStarts[last + 1]
          : content.length;
      final String block = content.substring(start, max(start, end));

      fragment.write(block);

      if ((index < blocks.length - 1) && !block.endsWith('\n')) {
        fragment.write(_th2File.lineEnding);
      }
    }

    return fragment.toString();
  }

  /// Called at the start of [_prepareTextSession].
  @visibleForTesting
  static void Function()? beforePrepareTextSessionForTesting;

  /// A baseline from the live model, with the cursor at [cursorLine]
  /// clamped (or at [anchor]'s own line when it still owns lines), without
  /// touching the installed session. Throws what serialization throws.
  TH2TextEditBaseline _prepareTextSession({
    required int cursorLine,
    int? cursorColumn,
    ({int mpID, int ownLineIndex})? anchor,
  }) {
    beforePrepareTextSessionForTesting?.call();

    final (String content, TH2TextLineMap lineMap) = serializeForTextMode();
    int line = cursorLine;
    int? column = cursorColumn;

    if (anchor != null) {
      final List<int> ownLines = lineMap.ownLinesOf(anchor.mpID);

      if (ownLines.isNotEmpty) {
        line = ownLines[min(anchor.ownLineIndex, ownLines.length - 1)];
      }
    }

    final _TH2TextPosition position = (column == null)
        ? _TH2TextPosition.atFirstNonBlank(content, line)
        : _TH2TextPosition.at(content, line, column);
    final TH2TextEditController? session = _textEditController;
    final bool requestsFocus =
        (session != null) && session.textFieldFocusNode.hasFocus;

    return TH2TextEditBaseline(
      content: content,
      lineMap: lineMap,
      cursorLine: position.line,
      cursorColumn: position.column,
      selection: TextRange.collapsed(position.offset),
      selectionRequestsFocus: requestsFocus,
    );
  }

  /// Replaces the open session by one prepared from the live model. When
  /// preparation fails, returns to the canvas with a message instead.
  /// Runs inside a gated operation that holds the buffer lock.
  void _replaceTextSession({
    required int cursorLine,
    int? cursorColumn,
    ({int mpID, int ownLineIndex})? anchor,
  }) {
    final TH2TextEditController? session = _textEditController;

    if (session == null) {
      return;
    }

    try {
      final TH2TextEditBaseline baseline = _prepareTextSession(
        cursorLine: cursorLine,
        cursorColumn: cursorColumn,
        anchor: anchor,
      );

      _installReplacementBaseline(session, baseline);
    } catch (error, stackTrace) {
      _exitTextModeAfterRegenerationFailure(error, stackTrace);
    }
  }

  @action
  void _installReplacementBaseline(
    TH2TextEditController session,
    TH2TextEditBaseline baseline,
  ) {
    _textApplyRejection = null;
    session.installBaseline(baseline);
  }

  /// A replacement session couldn't be prepared: back to the canvas. The
  /// model holds the applied text, so nothing is lost.
  void _exitTextModeAfterRegenerationFailure(
    Object error,
    StackTrace stackTrace,
  ) {
    mpLocator.mpLog.e(
      'The text editor of ${_th2File.filename} could not be reopened',
      error: error,
      stackTrace: stackTrace,
    );
    _returnToCanvas();
    _showUserMessage(_textSessionFailureMessage(error));
    _focusActiveNodeAfterFrame(TH2EditMode.canvas);
  }

  /// The canvas undo or redo of a session before its first text edit, as
  /// a gated operation.
  @override
  Future<void> requestCanvasHistory({required bool redo}) async {
    await _operationGate.run<void>(
      () => _requestCanvasHistoryGated(redo: redo),
    );
  }

  Future<void> _requestCanvasHistoryGated({required bool redo}) async {
    final TH2TextEditController? session = _openTextSession;

    if ((session == null) || session.hasTextEdits || _isBroken) {
      return;
    }

    if (redo ? !undoRedoController.hasRedo : !undoRedoController.hasUndo) {
      return;
    }

    acquireBufferLock();

    try {
      final int cursorLine = session.cursorLine;
      final int cursorColumn = session.cursorColumn;
      final TH2TextLineMap lineMap = session.initialLineMap;
      final int? ownerMPID = lineMap.ownerOfLine(cursorLine);
      ({int mpID, int ownLineIndex})? anchor;

      if ((ownerMPID != null) && (ownerMPID != _th2File.mpID)) {
        final int ownLineIndex = lineMap.ownLinesOf(ownerMPID).indexOf(
          cursorLine,
        );

        anchor = (mpID: ownerMPID, ownLineIndex: max(ownLineIndex, 0));
      }

      try {
        runAuthorizedMutation<void>(() {
          if (redo) {
            this.redo();
          } else {
            undo();
          }
        });
        syncControllersWithModel(initialSetup: false);

        final TH2TextEditBaseline baseline = _prepareTextSession(
          cursorLine: cursorLine,
          cursorColumn: cursorColumn,
          anchor: anchor,
        );

        _installReplacementBaseline(session, baseline);
      } catch (error, stackTrace) {
        _exitTextModeAfterRegenerationFailure(error, stackTrace);
      }
    } finally {
      releaseBufferLock();
      _focusActiveNodeAfterFrame(_editMode);
    }
  }

  /// The writer options of Save, shared by text mode so its text is the
  /// saved text.
  static const bool _savedIncludeEmptyLines = true;
  static const bool _savedUseOriginalRepresentation = true;

  Uint8List _encodedFileContents() {
    final TH2FileWriter th2FileWriter = TH2FileWriter();
    final Uint8List fileBytes = th2FileWriter.toBytes(
      _th2File,
      includeEmptyLines: _savedIncludeEmptyLines,
      useOriginalRepresentation: _savedUseOriginalRepresentation,
    );

    return fileBytes;
  }

  /// The live model's text, as Save writes it, and its writer map.
  ///
  /// Throws [TH2UnsupportedLineEndingException] when the text would contain a
  /// lone `\r`.
  (String, TH2TextLineMap) serializeForTextMode() {
    return TH2FileWriter().serializeWithLineMap(
      _th2File,
      includeEmptyLines: _savedIncludeEmptyLines,
      useOriginalRepresentation: _savedUseOriginalRepresentation,
    );
  }

  /// Applies the text buffer [content] of [session] to the model as one
  /// canvas undo step.
  ///
  /// Validation is the only asynchronous part: when the session ends, is
  /// replaced or the controller is disposed meanwhile, nothing changes and
  /// the result is [TH2TextApplyCancelled]; when the buffer changed
  /// meanwhile, the current buffer is validated instead. From the final
  /// check on everything is synchronous. With [lockBufferOnAccept], the
  /// session's buffer lock is taken for an applied or unchanged result,
  /// before any model change. The session is never ended or replaced here.
  Future<TH2TextApplyResult> applyTextContent(
    String content, {
    required TH2TextApplySession session,
    bool lockBufferOnAccept = false,
  }) async {
    assert(
      _operationGate.isBusy,
      'applyTextContent outside a gated operation.',
    );
    assert(!_isBroken, 'applyTextContent on a broken file.');
    if (_isBroken) {
      return TH2TextApplyRejected(const <TH2TextDiagnostic>[
        TH2TextDiagnostic.error(
          line: null,
          kind: TH2TextDiagnosticKind.unreadableText,
        ),
      ], content: content);
    }

    final int revision = session.sessionRevision;
    late TH2TextValidationResult result;

    while (true) {
      /// Unchanged text.
      if (content == session.initialContent) {
        if (lockBufferOnAccept) {
          session.lockBuffer();
        }

        return TH2TextApplyUnchanged(
          session.initialLineMap,
          session.cursorLine,
        );
      }

      result = await session.validationCache.validate(
        content,
        filename: _th2File.filename,
        th2FileMPID: _th2File.mpID,
        lineEnding: _th2File.lineEnding,
      );

      /// Staleness.
      if (_disposed ||
          !session.isOpen ||
          (session.sessionRevision != revision)) {
        return const TH2TextApplyCancelled();
      }

      if (session.content == content) {
        break;
      }

      content = session.content;
    }

    if (!result.isValid) {
      return TH2TextApplyRejected(result.diagnostics, content: content);
    }

    /// From here on everything is synchronous.
    if (lockBufferOnAccept) {
      session.lockBuffer();
    }

    final int cursorLine = result.cursorMapper.mapRawLine(session.cursorLine);

    /// The text normalizes back to the live text: the line numbers carry
    /// over.
    if (result.normalizedText == session.initialContent) {
      return TH2TextApplyUnchanged(session.initialLineMap, cursorLine);
    }

    final Map<String, dynamic> before = _th2File.toMap();

    /// The matcher reads the live side from the session, which is only right
    /// while the session describes the live model.
    assert(serializeForTextMode().$1 == session.initialContent);

    final Map<int, int> matching = TH2TextIdentityMatcher.match(
      live: (_th2File, session.initialContent, session.initialLineMap),
      detached: (result.detachedFile, result.normalizedText, result.writerMap),
    );
    final Map<String, dynamic> after = TH2TextMPIDRemapper.remap(
      result.detachedFile.toMap(),
      matching,
    );

    assert(
      TH2FileWriter().serialize(
            TH2File.fromMap(after),
            includeEmptyLines: _savedIncludeEmptyLines,
            useOriginalRepresentation: _savedUseOriginalRepresentation,
          ) ==
          result.normalizedText,
      'The remapped snapshot does not write the normalized text.',
    );

    runAuthorizedMutation<void>(
      () => execute(
        MPReplaceTH2FileContentsCommand(before: before, after: after),
      ),
    );

    final (String liveText, TH2TextLineMap liveMap) = serializeForTextMode();

    assert(
      liveText == result.normalizedText,
      'The applied model does not write the normalized text.',
    );

    return TH2TextApplyApplied(liveMap, cursorLine);
  }

  /// Called just before Save As renames the picked file to add `.th2`.
  @visibleForTesting
  static void Function()? beforeSaveAsExtensionRenameForTesting;

  /// Called just before Save As rebases the image paths.
  @visibleForTesting
  static void Function()? beforeSaveAsImageRebaseForTesting;

  /// Called just before [_writeFile] writes.
  @visibleForTesting
  static void Function()? beforeWriteFileForTesting;

  /// Receives every message shown to the user through a `SnackBar`.
  @visibleForTesting
  static void Function(String message)? onUserMessageForTesting;

  /// Saves the file, as a gated operation.
  Future<TH2FileSaveStatus> saveTH2File() async {
    final TH2FileSaveStatus? status = await _operationGate.run(
      _saveTH2FileGated,
    );

    return status ?? TH2FileSaveStatus.cancelled;
  }

  Future<TH2FileSaveStatus> _saveTH2FileGated() async {
    if (_th2File.isNewFile) {
      return TH2FileSaveStatus.saveFailed;
    }

    final TH2TextEditController? session = _openTextSession;

    if (session != null) {
      acquireBufferLock();
    }

    try {
      int? acceptedCursorLine;

      if (session != null) {
        final TH2TextApplyResult result = await applyTextContent(
          session.content,
          session: session,
          lockBufferOnAccept: true,
        );

        if (_disposed || !session.isOpen) {
          return TH2FileSaveStatus.cancelled;
        }

        switch (result) {
          case TH2TextApplyRejected():
            _publishTextApplyRejection(session, result);

            return TH2FileSaveStatus.textHasProblems;
          case TH2TextApplyCancelled():
            return TH2FileSaveStatus.cancelled;
          case TH2TextApplyApplied():
            acceptedCursorLine = result.cursorLine;
          case TH2TextApplyUnchanged():
            acceptedCursorLine = result.cursorLine;
        }
      }

      if (_isBroken) {
        return TH2FileSaveStatus.saveFailed;
      }

      try {
        _writeFile(_localFile());
        _commitSave();
        _th2File.isNewFile = false;
        overlayWindowController.closeAutoDismissOverlayWindows();
      } finally {
        /// Whether the write succeeded or threw, the session describes the
        /// live model, which holds the accepted text.
        if (acceptedCursorLine != null) {
          _replaceTextSession(cursorLine: acceptedCursorLine);
        }
      }

      return TH2FileSaveStatus.saved;
    } finally {
      releaseBufferLock();
    }
  }

  /// Saves the file under a name chosen in the file dialog, as a gated
  /// operation for its whole length, the dialog included.
  Future<TH2FileSaveStatus> saveAsTH2File() async {
    final TH2FileSaveStatus? status = await _operationGate.run(
      _saveAsTH2FileGated,
    );

    return status ?? TH2FileSaveStatus.cancelled;
  }

  Future<TH2FileSaveStatus> _saveAsTH2FileGated() async {
    final TH2TextEditController? session = _openTextSession;

    if (session == null) {
      if (_isBroken) {
        return TH2FileSaveStatus.saveFailed;
      }

      return _saveAsTH2FileBody(null);
    }

    /// The buffer stays read-only from here, the file dialog included, so
    /// the text applied after the dialog is the text validated before it.
    acquireBufferLock();

    try {
      return await _saveAsTH2FileBody(session);
    } finally {
      releaseBufferLock();
    }
  }

  Future<TH2FileSaveStatus> _saveAsTH2FileBody(
    TH2TextEditController? session,
  ) async {
    if (session != null) {
      final String content = session.content;

      if (content != session.initialContent) {
        final TH2TextValidationResult validation = await session
            .validationCache
            .validate(
              content,
              filename: _th2File.filename,
              th2FileMPID: _th2File.mpID,
              lineEnding: _th2File.lineEnding,
            );

        if (_disposed || !session.isOpen) {
          return TH2FileSaveStatus.cancelled;
        }

        if (!validation.isValid) {
          _publishTextApplyRejection(
            session,
            TH2TextApplyRejected(validation.diagnostics, content: content),
          );

          return TH2FileSaveStatus.textHasProblems;
        }
      }
    }

    /// The controller's registry key: a placeholder for a new file.
    final String originalFilename = _th2File.filename;
    final String filename = _th2File.isNewFile ? '' : originalFilename;
    final MPGeneralController mpGeneralController =
        mpLocator.mpGeneralController;
    final String? initialDirectory =
        mpGeneralController.lastAccessedDirectory.isEmpty
        ? (filename.isEmpty ? null : p.dirname(filename))
        : mpGeneralController.lastAccessedDirectory;
    final String initialFileName = filename.isEmpty
        ? 'untitled.th2'
        : p.basename(filename);

    final Uri? savedFileUri = await FilePicker.saveFile(
      dialogTitle: mpLocator.appLocalizations.th2FileEditPageSaveAsDialogTitle,
      fileName: initialFileName,
      initialDirectory: initialDirectory,
      type: FileType.custom,
      allowedExtensions: <String>['th2'],
      bytes: Uint8List(0),
    );
    final String? pickedPath = savedFileUri?.toFilePath();

    if ((pickedPath == null) ||
        _disposed ||
        ((session != null) && !session.isOpen)) {
      return TH2FileSaveStatus.cancelled;
    }

    final bool appendsExtension = !pickedPath.toLowerCase().endsWith('.th2');
    final String filePath = appendsExtension ? '$pickedPath.th2' : pickedPath;

    if (_handleSaveAsTargetCollision(
      filePath: filePath,
      appendsExtension: appendsExtension,
    )) {
      return TH2FileSaveStatus.cancelled;
    }

    int? acceptedCursorLine;

    if (session != null) {
      final TH2TextApplyResult result = await applyTextContent(
        session.content,
        session: session,
        lockBufferOnAccept: true,
      );

      if (_disposed || !session.isOpen) {
        return TH2FileSaveStatus.cancelled;
      }

      switch (result) {
        case TH2TextApplyRejected():
          _publishTextApplyRejection(session, result);

          return TH2FileSaveStatus.textHasProblems;
        case TH2TextApplyCancelled():
          return TH2FileSaveStatus.cancelled;
        case TH2TextApplyApplied():
          acceptedCursorLine = result.cursorLine;
        case TH2TextApplyUnchanged():
          acceptedCursorLine = result.cursorLine;
      }
    }

    /// From here to the end of the write everything is synchronous.
    final String previousFilename = _th2File.isNewFile ? '' : originalFilename;
    final List<THElement> replacedImages = <THElement>[];

    try {
      if (appendsExtension) {
        beforeSaveAsExtensionRenameForTesting?.call();

        final File selectedFile = File(pickedPath);

        if (selectedFile.existsSync()) {
          selectedFile.renameSync(filePath);
        }
      }

      _th2File.filename = filePath;
      beforeSaveAsImageRebaseForTesting?.call();
      _rebaseImportedImagePathsForSaveAs(
        oldTH2Filename: previousFilename,
        newTH2Filename: filePath,
        replacedImages: replacedImages,
      );
      _writeFile(File(filePath));
    } catch (_) {
      _restoreAfterFailedSaveAs(
        originalFilename: originalFilename,
        replacedImages: replacedImages,
      );

      if (acceptedCursorLine != null) {
        _replaceTextSession(cursorLine: acceptedCursorLine);
      }
      rethrow;
    }

    mpGeneralController.renameFileController(
      oldFilename: originalFilename,
      newFilename: filePath,
    );
    _commitSave();

    if (acceptedCursorLine != null) {
      _replaceTextSession(cursorLine: acceptedCursorLine);
    }
    _th2File.isNewFile = false;
    _markLoadedAfterSaveAs();
    mpGeneralController.lastAccessedDirectory = p.dirname(filePath);
    overlayWindowController.closeAutoDismissOverlayWindows();

    return TH2FileSaveStatus.saved;
  }

  /// Whether [filePath] is the registered file of another open TH2
  /// controller. Then nothing is applied or renamed here; the file dialog
  /// already emptied the picked file, so a clean other controller's file is
  /// rewritten from its model, and the user is told.
  bool _handleSaveAsTargetCollision({
    required String filePath,
    required bool appendsExtension,
  }) {
    final TH2FileEditController? other = mpLocator.mpGeneralController
        .getTH2FileEditControllerIfExists(filePath);

    if ((other == null) || identical(other, this)) {
      return false;
    }

    bool restored = false;

    if (other.isFileLoaded &&
        !other.isBroken &&
        (other.loadError == null) &&
        !other.hasUnsavedChanges) {
      try {
        other._writeFile(File(other.th2File.filename));
        restored = true;
      } catch (error, stackTrace) {
        mpLocator.mpLog.e(
          'Failed to restore ${other.th2File.filename} after a Save As '
          'collision',
          error: error,
          stackTrace: stackTrace,
        );
      }
    } else if (other.hasUnsavedChanges) {
      /// Already marked dirty: saving it from its tab writes it again.
      restored = true;
    }

    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final String displayName = p.basename(filePath);

    _showUserMessage(
      (restored || appendsExtension)
          ? appLocalizations.th2SaveAsTargetOpenMessage(displayName)
          : appLocalizations.th2SaveAsTargetOpenEmptiedMessage(displayName),
    );

    return true;
  }

  /// Puts back what a failed Save As changed before or during its write.
  void _restoreAfterFailedSaveAs({
    required String originalFilename,
    required List<THElement> replacedImages,
  }) {
    try {
      for (final THElement image in replacedImages) {
        _th2File.substituteElement(image);
      }
      _th2File.filename = originalFilename;
    } catch (error, stackTrace) {
      mpLocator.mpLog.e(
        'Failed to restore ${_th2File.filename} after a failed Save As',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Shows [message] in a `SnackBar` through the app's navigator.
  void _showUserMessage(String message) {
    onUserMessageForTesting?.call(message);

    final BuildContext? context = mpLocator.mpNavigatorKey.currentContext;

    if (context == null) {
      return;
    }

    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }

  /// Marks a file saved under a new name as loaded, in one transition.
  @action
  void _markLoadedAfterSaveAs() {
    _isFileLoaded = true;
    setFilename(_th2File.filename);
  }

  /// Rebases the image paths for the new file name, adding each replaced
  /// image object to [replacedImages].
  void _rebaseImportedImagePathsForSaveAs({
    required String oldTH2Filename,
    required String newTH2Filename,
    required List<THElement> replacedImages,
  }) {
    final List<MPRuntimeImageInsertConfigMixin> images = _th2File
        .getImages()
        .toList();

    for (final MPRuntimeImageInsertConfigMixin image in images) {
      final String rebasedFilename = oldTH2Filename.isEmpty
          ? MPDirectoryAux.relativePathFromReferencePath(
              referencePath: newTH2Filename,
              targetPath: image.filename,
            )
          : MPDirectoryAux.rebaseRelativePath(
              oldReferencePath: oldTH2Filename,
              newReferencePath: newTH2Filename,
              filename: image.filename,
            );

      if (rebasedFilename == image.filename) {
        continue;
      }

      final MPRuntimeImageInsertConfigMixin updatedImage = image
          .copyWithImageInsertConfigBase(
            filename: rebasedFilename,
            originalLineInTH2File: '',
          );

      image.copyRuntimeImageCacheTo(
        targetImage: updatedImage,
        th2FileEditController: this as TH2FileEditController,
      );

      replacedImages.add(image as THElement);
      _th2File.substituteElement(updatedImage as THElement);
    }
  }

  /// Encodes the model and writes it to [file]. Changes nothing else.
  void _writeFile(File file) {
    final Uint8List encodedContent = _encodedFileContents();

    beforeWriteFileForTesting?.call();
    file.writeAsBytesSync(encodedContent, flush: true);
  }

  /// The bookkeeping of a successful write.
  void _commitSave() {
    undoRedoController.clearUndoRedoStack();
    updateUndoRedoStatus();
  }

  File _localFile() {
    final String filename = _th2File.filename;

    return File(filename);
  }

  @action
  void updateHasMultipleScraps() {
    _hasMultipleScraps = _th2File.scrapMPIDs.length > 1;
  }

  @action
  void execute(MPCommand command) {
    undoRedoController.execute(command);
    elementEditController.updateControllersAfterElementEditPartial();
    elementEditController.updateControllersAfterElementEditFinal();
    updateUndoRedoStatus();
  }

  @action
  void executeSubstitutingLastUndo(MPCommand command) {
    undoRedoController.executeSubstitutingLastUndo(command);
    updateUndoRedoStatus();
  }

  @action
  void updateUndoRedoStatus() {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    _hasUndo = undoRedoController.hasUndo;
    _hasRedo = undoRedoController.hasRedo;
    _undoDescription = appLocalizations.th2FileEditPageUndo(
      undoRedoController.undoDescription,
    );
    _redoDescription = appLocalizations.th2FileEditPageRedo(
      undoRedoController.redoDescription,
    );
  }

  @action
  void _undoRedoDone() {
    updateUndoRedoStatus();
    selectionController.clearSelectedElementsAndSelectionHandleCenters();
    overlayWindowController.clearOverlayWindows();
  }

  /// Does nothing in text mode, outside an authorized canvas traversal.
  void undo() {
    if (!isModelMutationAllowed) {
      return;
    }

    undoRedoController.undo();
    _undoRedoDone();
  }

  /// Does nothing in text mode, outside an authorized canvas traversal.
  void redo() {
    if (!isModelMutationAllowed) {
      return;
    }

    undoRedoController.redo();
    _undoRedoDone();
  }

  int get undoCount => undoRedoController.undoCount;

  void revertLastUndoWithoutRedo() {
    undoRedoController.revertLastUndoWithoutRedo();
    updateUndoRedoStatus();
  }

  Future<void> openInteractiveLineSimplificationDialog() async {
    if (isInteractiveLineSimplificationDialogOpen.value) {
      return;
    }

    final bool canOpen =
        hasSelectedLines ||
        (stateController.state is MPTH2FileEditStateEditSingleLine);

    if (!canOpen) {
      return;
    }

    overlayWindowController.clearOverlayWindows();

    elementEditController.startInteractiveLineSimplification();
    isInteractiveLineSimplificationDialogOpen.value = true;

    final BuildContext context = getTH2FileWidgetBuildContext();
    final MPInteractiveLineSimplificationDialogResult? result =
        await showDialog<MPInteractiveLineSimplificationDialogResult>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext dialogContext) {
            return MPInteractiveLineSimplificationDialogWidget(
              th2FileEditController: this as TH2FileEditController,
            );
          },
        );

    final MPInteractiveLineSimplificationDialogResult finalResult =
        result ?? MPInteractiveLineSimplificationDialogResult.close;

    switch (finalResult) {
      case MPInteractiveLineSimplificationDialogResult.close:
        elementEditController.finishInteractiveLineSimplification();
      case MPInteractiveLineSimplificationDialogResult.cancel:
        elementEditController.cancelInteractiveLineSimplification();
    }

    isInteractiveLineSimplificationDialogOpen.value = false;
  }

  @action
  void performSetMousePosition(Offset position) {
    _mousePosition = position;
    stateController.state.setCursor();
  }

  @action
  void executeMPCommandList(
    List<MPCommand> commandList,
    MPMultipleElementsCommandCompletionType completionType,
  ) {
    for (final MPCommand command in commandList) {
      command.execute(this as TH2FileEditController);
    }

    switch (completionType) {
      case MPMultipleElementsCommandCompletionType.elementsEdited:
      case MPMultipleElementsCommandCompletionType.elementsListChanged:
      case MPMultipleElementsCommandCompletionType.optionsEdited:
      case MPMultipleElementsCommandCompletionType.lineSegmentsEdited:
        elementEditController.updateControllersAfterElementEditPartial();
    }
  }

  @action
  void setFilename(String filename) {
    _th2File.filename = filename;

    _updateCurrentScrapName();
  }

  /// Updates the displayed scrap name to match the active scrap.
  void _updateCurrentScrapName() {
    if (_activeScrapID > 0) {
      final THScrap scrap = _th2File.scrapByMPID(_activeScrapID);

      _currentScrapName = scrap.thID;
    } else {
      _currentScrapName = '';
    }
  }

  @action
  void setMovingMousePosition(Offset? position) {
    _movingMousePosition = position;
  }

  @action
  void updateEnableSelectButton() {
    final bool newEnableSelectButton = selectionController
        .getMPSelectableElements()
        .isNotEmpty;

    if (newEnableSelectButton == _enableSelectButton) {
      return;
    }

    _enableSelectButton = newEnableSelectButton;
  }

  double getScrapBackgroundPaddingOnCanvas() {
    final Rect fileBoundingBox = _th2File.getBoundingBox(
      this as TH2FileEditController,
    )!;
    final double largerDimension = max(
      fileBoundingBox.width,
      fileBoundingBox.height,
    );
    final double canvasPadding = largerDimension * mpScrapBackgroundPadding;

    return canvasPadding;
  }

  GlobalKey<State<StatefulWidget>> getTH2FileWidgetGlobalKey() {
    if (!overlayWindowController.globalKeyWidgetKeyByType.containsKey(
      MPGlobalKeyWidgetType.th2FileWidget,
    )) {
      throw Exception(
        'At TH2FileEditController.getTH2FileWidgetGlobalKey(): TH2FileWidget global key not found in overlayWindowController.',
      );
    }

    return overlayWindowController
        .globalKeyWidgetKeyByType[MPGlobalKeyWidgetType.th2FileWidget]!;
  }

  BuildContext getTH2FileWidgetBuildContext() {
    final GlobalKey<State<StatefulWidget>> globalKey =
        getTH2FileWidgetGlobalKey();

    if (globalKey.currentContext == null) {
      throw Exception(
        'At TH2FileEditController.getTH2FileWidgetBuildContext(): TH2FileWidget global key context is null.',
      );
    }

    return globalKey.currentContext!;
  }
}

class TH2FileEditControllerCreateResult {
  final bool isSuccessful;
  final List<String> errors;
  final List<TH2FileProblem> problems;

  TH2FileEditControllerCreateResult(
    this.isSuccessful,
    this.errors, [
    this.problems = const <TH2FileProblem>[],
  ]);
}

/// A position in a TH2 text: 0-based line and column, and its offset.
class _TH2TextPosition {
  final int line;

  final int column;

  final int offset;

  const _TH2TextPosition._(this.line, this.column, this.offset);

  /// The start offset of each line of [text].
  static List<int> _lineStarts(String text) {
    final List<int> starts = <int>[0];

    for (int index = 0; index < text.length; index++) {
      if (text.codeUnitAt(index) == 0x0A) {
        starts.add(index + 1);
      }
    }

    return starts;
  }

  /// The length of [line]'s content, without its line ending.
  static int _contentLength(String text, List<int> starts, int line) {
    final int start = starts[line];
    int end = (line + 1 < starts.length) ? starts[line + 1] : text.length;

    if ((end > start) && (text.codeUnitAt(end - 1) == 0x0A)) {
      end--;
    }
    if ((end > start) && (text.codeUnitAt(end - 1) == 0x0D)) {
      end--;
    }

    return end - start;
  }

  /// [line], clamped to the text, at [column] clamped to its content.
  factory _TH2TextPosition.at(String text, int line, int column) {
    final List<int> starts = _lineStarts(text);
    final int clampedLine = line.clamp(0, starts.length - 1);
    final int clampedColumn = column.clamp(
      0,
      _contentLength(text, starts, clampedLine),
    );

    return _TH2TextPosition._(
      clampedLine,
      clampedColumn,
      starts[clampedLine] + clampedColumn,
    );
  }

  /// [line], clamped to the text, at its first non-blank column.
  factory _TH2TextPosition.atFirstNonBlank(String text, int line) {
    final List<int> starts = _lineStarts(text);
    final int clampedLine = line.clamp(0, starts.length - 1);
    final int start = starts[clampedLine];
    final int length = _contentLength(text, starts, clampedLine);
    int column = 0;

    while ((column < length) &&
        ((text.codeUnitAt(start + column) == 0x20) ||
            (text.codeUnitAt(start + column) == 0x09))) {
      column++;
    }

    return _TH2TextPosition._(clampedLine, column, start + column);
  }
}
