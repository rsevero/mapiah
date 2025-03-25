enum MPCommandDescriptionType {
  addElements,
  addLine,
  addLineSegment,
  addPoint,
  editBezierCurve,
  editLine,
  editLineSegment,
  moveBezierLineSegment,
  moveElements,
  moveLine,
  movePoint,
  moveStraightLineSegment,
  multipleElements,
  removeElements,
  removeLine,
  removeLineSegment,
  removeOptionFromElement,
  removeOptionFromElements,
  removePoint,
  setOptionToElement,
  setOptionToElements;

  static MPCommandDescriptionType getOppositeDescription(
      MPCommandDescriptionType description) {
    switch (description) {
      case MPCommandDescriptionType.addElements:
        return MPCommandDescriptionType.removeElements;
      case MPCommandDescriptionType.addLine:
        return MPCommandDescriptionType.removeLine;
      case MPCommandDescriptionType.addLineSegment:
        return MPCommandDescriptionType.removeLineSegment;
      case MPCommandDescriptionType.addPoint:
        return MPCommandDescriptionType.removePoint;
      case MPCommandDescriptionType.editBezierCurve:
        return MPCommandDescriptionType.editBezierCurve;
      case MPCommandDescriptionType.editLine:
        return MPCommandDescriptionType.editLine;
      case MPCommandDescriptionType.editLineSegment:
        return MPCommandDescriptionType.editLineSegment;
      case MPCommandDescriptionType.moveBezierLineSegment:
        return MPCommandDescriptionType.moveBezierLineSegment;
      case MPCommandDescriptionType.moveElements:
        return MPCommandDescriptionType.moveElements;
      case MPCommandDescriptionType.moveLine:
        return MPCommandDescriptionType.moveLine;
      case MPCommandDescriptionType.movePoint:
        return MPCommandDescriptionType.movePoint;
      case MPCommandDescriptionType.moveStraightLineSegment:
        return MPCommandDescriptionType.moveStraightLineSegment;
      case MPCommandDescriptionType.multipleElements:
        return MPCommandDescriptionType.multipleElements;
      case MPCommandDescriptionType.removeElements:
        return MPCommandDescriptionType.addElements;
      case MPCommandDescriptionType.removeLine:
        return MPCommandDescriptionType.addLine;
      case MPCommandDescriptionType.removeLineSegment:
        return MPCommandDescriptionType.addLineSegment;
      case MPCommandDescriptionType.removeOptionFromElement:
        return MPCommandDescriptionType.setOptionToElement;
      case MPCommandDescriptionType.removeOptionFromElements:
        return MPCommandDescriptionType.setOptionToElements;
      case MPCommandDescriptionType.removePoint:
        return MPCommandDescriptionType.addPoint;
      case MPCommandDescriptionType.setOptionToElement:
        return MPCommandDescriptionType.removeOptionFromElement;
      case MPCommandDescriptionType.setOptionToElements:
        return MPCommandDescriptionType.setOptionToElements;
    }
  }
}
