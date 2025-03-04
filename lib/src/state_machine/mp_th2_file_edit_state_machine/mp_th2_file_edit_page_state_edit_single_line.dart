part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditPageStateEditSingleLine extends MPTH2FileEditState
    with
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateGetSelectedElementsMixin,
        MPTH2FileEditStateClearSelectionOnExitMixin {
  MPTH2FileEditPageStateEditSingleLine({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.updateSelectableEndAndControlPoints();
    th2FileEditController.triggerEditLineRedraw();
    th2FileEditController.setStatusBarMessage('');
  }

  @override
  void onStateExit(MPTH2FileEditState nextState) {
    if (nextState is MPTH2FileEditStateMovingEndControlPoints) {
      return;
    }

    th2FileEditController.clearSelectedLineSegments();
    th2FileEditController.updateSelectableEndAndControlPoints();
    th2FileEditController.triggerEditLineRedraw();
  }

  @override
  void onPrimaryButtonClick(PointerUpEvent event) {
    final bool shiftPressed = MPInteractionAux.isShiftPressed();
    final Set<MPSelectableEndControlPoint> clickedEndControlPoints =
        th2FileEditController.selectableEndControlPointsClicked(
      event.localPosition,
      false,
    );

    if (clickedEndControlPoints.isNotEmpty) {
      /// TODO: deal with multiple end points returned on same click.
      final MPSelectableEndControlPoint clickedEndControlPoint =
          clickedEndControlPoints.first;
      final THLineSegment clickedEndControlPointLineSegment =
          clickedEndControlPoint.element as THLineSegment;
      final bool clickedEndControlPointAlreadySelected = th2FileEditController
          .isEndpointSelected(clickedEndControlPointLineSegment);

      if (shiftPressed) {
        if (clickedEndControlPointAlreadySelected) {
          th2FileEditController
              .removeSelectedLineSegments([clickedEndControlPointLineSegment]);
        } else {
          th2FileEditController
              .addSelectedLineSegments([clickedEndControlPointLineSegment]);
        }
      } else {
        th2FileEditController
            .setSelectedLineSegments([clickedEndControlPointLineSegment]);
      }

      th2FileEditController.updateSelectableEndAndControlPoints();
      th2FileEditController.triggerEditLineRedraw();
      return;
    }

    final Set<THElement> clickedElements =
        th2FileEditController.selectableElementsClicked(event.localPosition);

    if (clickedElements.isNotEmpty) {
      final Set<THElement> clickedPointsLines =
          getSelectedElementsWithLineSegmentsConvertedToLines(
        clickedElements,
      );

      /// TODO: deal with multiple end points returned on same click.
      final bool clickedElementAlreadySelected =
          th2FileEditController.isElementSelected(clickedPointsLines.first);

      if (clickedElementAlreadySelected) {
        final THLineSegment clickedLineSegment =
            clickedElements.first as THLineSegment;
        final List<THLineSegment> lineSegments =
            th2FileEditController.getLineSegmentAndPrevious(clickedLineSegment);

        if (shiftPressed) {
          final bool firstLineSegmentSelected =
              th2FileEditController.isEndpointSelected(lineSegments.first);
          final bool secondLineSegmentSelected =
              th2FileEditController.isEndpointSelected(lineSegments.last);

          if (firstLineSegmentSelected && secondLineSegmentSelected) {
            th2FileEditController.removeSelectedLineSegments(lineSegments);
          } else {
            th2FileEditController.addSelectedLineSegments(lineSegments);
          }
        } else {
          th2FileEditController.setSelectedLineSegments(lineSegments);
        }
        th2FileEditController.updateSelectableEndAndControlPoints();
        th2FileEditController.triggerEditLineRedraw();
        return;
      } else {
        late bool stateChanged;

        if (shiftPressed) {
          /// TODO: deal with multiple end points returned on same click.
          stateChanged = th2FileEditController.addSelectedElement(
            clickedPointsLines.first,
            setState: true,
          );
        } else {
          /// TODO: deal with multiple end points returned on same click.
          stateChanged = th2FileEditController.setSelectedElements(
            {clickedPointsLines.first},
            setState: true,
          );
        }

        if (!stateChanged) {
          th2FileEditController.updateSelectableEndAndControlPoints();
          th2FileEditController.triggerEditLineRedraw();
        }

        return;
      }
    } else {
      if (!shiftPressed) {
        th2FileEditController.clearSelectedElements();
        th2FileEditController
            .setState(MPTH2FileEditStateType.selectEmptySelection);
      }
    }
  }

  @override
  void onPrimaryButtonDragStart(PointerDownEvent event) {
    th2FileEditController.setDragStartCoordinates(event.localPosition);

    final bool shiftPressed = MPInteractionAux.isShiftPressed();
    final Set<MPSelectableEndControlPoint> clickedEndControlPoints =
        th2FileEditController.selectableEndControlPointsClicked(
      event.localPosition,
      false,
    );

    if (clickedEndControlPoints.isNotEmpty) {
      if (!shiftPressed) {
        bool alreadySelected = false;
        final Set<THLineSegment> newlySelectedEndPoints = {};

        for (final MPSelectableEndControlPoint endControlPoint
            in clickedEndControlPoints) {
          final THLineSegment element =
              endControlPoint.element as THLineSegment;
          if (th2FileEditController.isEndpointSelected(element)) {
            alreadySelected = true;
          } else {
            newlySelectedEndPoints.add(element);
          }
        }
        if (!alreadySelected) {
          th2FileEditController.setSelectedElements(newlySelectedEndPoints);
        }
        th2FileEditController
            .setState(MPTH2FileEditStateType.movingEndControlPoints);
      }
    }
  }

  @override
  void onPrimaryButtonDragUpdate(PointerMoveEvent event) {
    th2FileEditController
        .setSelectionWindowScreenEndCoordinates(event.localPosition);
  }

  @override
  void onPrimaryButtonDragEnd(PointerUpEvent event) {
    final Offset panDeltaOnCanvas =
        th2FileEditController.offsetScreenToCanvas(event.localPosition) -
            th2FileEditController.dragStartCanvasCoordinates;
    late MPCommand lineEdit;

    // if (selectedCount == 1) {
    //   final MPSelectedElement selected =
    //       th2FileEditController.selectedElements.values.first;
    //   final THElement selectedElement = selected.originalElementClone;

    //   switch (selected) {
    //     case MPSelectedPoint _:
    //       moveCommand = MPMovePointCommand.fromDelta(
    //         pointMapiahID: selectedElement.mapiahID,
    //         originalCoordinates:
    //             (selectedElement as THPoint).position.coordinates,
    //         deltaOnCanvas: panDeltaOnCanvas,
    //       );
    //       break;
    //     case MPSelectedLine _:
    //       moveCommand = MPMoveLineCommand.fromDelta(
    //         lineMapiahID: selectedElement.mapiahID,
    //         originalLineSegmentsMap: selected.originalLineSegmentsMapClone,
    //         deltaOnCanvas: panDeltaOnCanvas,
    //       );
    //       break;
    //   }
    // } else if (selectedCount > 1) {
    //   final List<MPMoveCommandOriginalParams>
    //       moveCommandOriginalParametersList = th2FileEditController
    //           .selectedElements.values
    //           .map<MPMoveCommandOriginalParams>((MPSelectedElement selected) {
    //     final THElement selectedElement = selected.originalElementClone;
    //     switch (selected) {
    //       case MPSelectedPoint _:
    //         return MPMoveCommandPointOriginalParams(
    //           mapiahID: selectedElement.mapiahID,
    //           coordinates: (selectedElement as THPoint).position.coordinates,
    //         );
    //       case MPSelectedLine _:
    //         return MPMoveCommandLineOriginalParams(
    //           mapiahID: selectedElement.mapiahID,
    //           lineSegmentsMap: selected.originalLineSegmentsMapClone,
    //         );
    //       default:
    //         throw UnimplementedError();
    //     }
    //   }).toList();

    //   moveCommand = MPMoveElementsCommand.fromDelta(
    //     moveCommandOriginalParametersList: moveCommandOriginalParametersList,
    //     deltaOnCanvas: panDeltaOnCanvas,
    //   );
    // }

    // th2FileEditController.execute(moveCommand);
    // th2FileEditController.updateSelectedElementsClones();
    // th2FileEditController.triggerSelectedElementsRedraw();
    // th2FileEditController.setNonEmptySelectionState();
  }

  @override
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.editSingleLine;
}
