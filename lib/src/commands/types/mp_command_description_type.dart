enum MPCommandDescriptionType {
  addElements,
  addLine,
  addLineSegment,
  addPoint,
  editAreasType,
  editAreaType,
  editBezierCurve,
  editLine,
  editLineSegment,
  editLinesType,
  editLineType,
  editPointsType,
  editPointType,
  moveBezierLineSegment,
  moveElements,
  moveLine,
  moveLineSegments,
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
    MPCommandDescriptionType description,
  ) {
    switch (description) {
      case MPCommandDescriptionType.addElements:
        return MPCommandDescriptionType.removeElements;
      case MPCommandDescriptionType.addLine:
        return MPCommandDescriptionType.removeLine;
      case MPCommandDescriptionType.addLineSegment:
        return MPCommandDescriptionType.removeLineSegment;
      case MPCommandDescriptionType.addPoint:
        return MPCommandDescriptionType.removePoint;
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
      default:
        return description;
    }
  }
}
