enum MPCommandDescriptionType {
  addArea,
  addAreaBorderTHID,
  addElements,
  addLine,
  addLineSegment,
  addPoint,
  addScrap,
  addXTherionImageInsertConfig,
  editAreasType,
  editAreaType,
  editBezierCurve,
  editLine,
  editLineSegment,
  editLineSegmentsType,
  editLineSegmentType,
  editLinesType,
  editLineType,
  editPointsType,
  editPointType,
  moveArea,
  moveBezierLineSegment,
  moveElements,
  moveLine,
  moveLines,
  moveLineSegments,
  movePoint,
  moveStraightLineSegment,
  multipleElements,
  removeArea,
  removeAreaBorderTHID,
  removeElements,
  removeLine,
  removeLineSegment,
  removeLineSegments,
  removeOptionFromElement,
  removeOptionFromElements,
  removePoint,
  removeScrap,
  removeXTherionImageInsertConfig,
  setOptionToElement,
  setOptionToElements;

  static MPCommandDescriptionType getOppositeDescription(
    MPCommandDescriptionType description,
  ) {
    switch (description) {
      case MPCommandDescriptionType.addArea:
        return MPCommandDescriptionType.removeArea;
      case MPCommandDescriptionType.addElements:
        return MPCommandDescriptionType.removeElements;
      case MPCommandDescriptionType.addLine:
        return MPCommandDescriptionType.removeLine;
      case MPCommandDescriptionType.addLineSegment:
        return MPCommandDescriptionType.removeLineSegment;
      case MPCommandDescriptionType.addPoint:
        return MPCommandDescriptionType.removePoint;
      case MPCommandDescriptionType.addScrap:
        return MPCommandDescriptionType.removeScrap;
      case MPCommandDescriptionType.addXTherionImageInsertConfig:
        return MPCommandDescriptionType.removeXTherionImageInsertConfig;
      case MPCommandDescriptionType.removeArea:
        return MPCommandDescriptionType.addArea;
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
      case MPCommandDescriptionType.removeScrap:
        return MPCommandDescriptionType.addScrap;
      case MPCommandDescriptionType.removeXTherionImageInsertConfig:
        return MPCommandDescriptionType.addXTherionImageInsertConfig;
      case MPCommandDescriptionType.setOptionToElement:
        return MPCommandDescriptionType.removeOptionFromElement;
      default:
        return description;
    }
  }
}
