enum MPCommandDescriptionType {
  addArea,
  addAreaBorderTHID,
  addElement,
  addElements,
  addEmptyLine,
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
  removeElement,
  removeElements,
  removeEmptyLine,
  removeLine,
  removeLineSegment,
  removeLineSegments,
  removeOptionFromElement,
  removeOptionFromElements,
  removePoint,
  removeScrap,
  removeXTherionImageInsertConfig,
  replaceLineSegments,
  setOptionToElement,
  setOptionToElements,
  simplifyBezier,
  simplifyLine,
  simplifyLines,
  simplifyStraight,
  simplifyToBezier,
  simplifyToStraight,
  toggleReverseOption;

  static MPCommandDescriptionType getOppositeDescription(
    MPCommandDescriptionType description,
  ) {
    switch (description) {
      case MPCommandDescriptionType.addArea:
        return MPCommandDescriptionType.removeArea;
      case MPCommandDescriptionType.addElement:
        return MPCommandDescriptionType.removeElement;
      case MPCommandDescriptionType.addElements:
        return MPCommandDescriptionType.removeElements;
      case MPCommandDescriptionType.addEmptyLine:
        return MPCommandDescriptionType.removeEmptyLine;
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
      case MPCommandDescriptionType.removeElement:
        return MPCommandDescriptionType.addElement;
      case MPCommandDescriptionType.removeElements:
        return MPCommandDescriptionType.addElements;
      case MPCommandDescriptionType.removeEmptyLine:
        return MPCommandDescriptionType.addEmptyLine;
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
