part of 'mp_th2_file_edit_state.dart';

class MPTH2FileEditPageStateEditSingleLine extends MPTH2FileEditState
    with
        MPTH2FileEditStateMoveCanvasMixin,
        MPTH2FileEditStateGetSelectedElementsMixin {
  MPTH2FileEditPageStateEditSingleLine({required super.th2FileEditController});

  @override
  void onStateEnter(MPTH2FileEditState previousState) {
    th2FileEditController.updateSelectableEndAndControlPoints();
    th2FileEditController.triggerEditLineRedraw();
  }

  @override
  void onPrimaryButtonClick(PointerUpEvent event) {
    final bool shiftPressed = MPInteractionAux.isShiftPressed();
    List<MPSelectableEndControlPoint> clickedEndControlPoints =
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
              .removeSelectedLineSegment(clickedEndControlPointLineSegment);
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

    List<THElement> clickedElements =
        th2FileEditController.selectableElementsClicked(event.localPosition);

    if (clickedElements.isNotEmpty) {
      clickedElements = getSelectedElementsWithLineSegmentsConvertedToLines(
        clickedElements,
      );
      final bool clickedElementAlreadySelected =
          th2FileEditController.isElementSelected(clickedElements.first);

      if (clickedElementAlreadySelected) {
        if (shiftPressed) {
          th2FileEditController.removeSelectedElement(clickedElements.first);
          if (th2FileEditController.selectedElements.isEmpty) {
            th2FileEditController
                .setState(MPTH2FileEditStateType.selectEmptySelection);
          }
        }
        return;
      } else {
        if (shiftPressed) {
          th2FileEditController.addSelectedElement(clickedElements.first);
          th2FileEditController
              .setState(MPTH2FileEditStateType.selectNonEmptySelection);
          return;
        } else {
          th2FileEditController.setSelectedElements([clickedElements.first]);
          th2FileEditController.setNonEmptySelectionState();
          return;
        }
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
  MPTH2FileEditStateType get type => MPTH2FileEditStateType.editSingleLine;
}
