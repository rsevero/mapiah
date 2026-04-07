// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
enum MPCommandDescriptionType {
  addArea,
  addAreaBorderTHID,
  addElement,
  addElements,
  addEmptyLine,
  addImageInsertConfig,
  addLine,
  addLines,
  addLineSegment,
  addPoint,
  addScrap,
  copyElements,
  cutElements,
  duplicateElements,
  editAreasType,
  editAreasTypeSubtype,
  editAreaType,
  editAreaTypeSubtype,
  editBezierCurve,
  editLine,
  editLineSegment,
  editLineSegmentsType,
  editLineSegmentType,
  editLinesType,
  editLinesTypeSubtype,
  editLineType,
  editLineTypeSubtype,
  editPointsType,
  editPointsTypeSubtype,
  editPointType,
  editPointTypeSubtype,
  joinLinesAtCoincidingExtremities,
  mergeAreas,
  moveArea,
  moveBezierLineSegment,
  moveElements,
  moveLine,
  moveLines,
  moveLineSegments,
  movePoint,
  moveStraightLineSegment,
  multipleElements,
  pasteElements,
  removeArea,
  removeAreaBorderTHID,
  removeElement,
  removeElements,
  removeEmptyLine,
  removeImageInsertConfig,
  removeLine,
  removeLines,
  removeLineSegment,
  removeLineSegments,
  removeOptionFromElement,
  removeOptionFromElements,
  removePoint,
  removeScrap,
  reorderImages,
  reorderScraps,
  replaceLineSegments,
  setFileEncoding,
  setOptionToElement,
  setOptionToElements,
  simplifyBezier,
  simplifyLine,
  simplifyLines,
  simplifyStraight,
  simplifyToBezier,
  simplifyToStraight,
  splitLineAtSelectedPoints,
  splitLinesAtCrossings,
  toggleReverseOption,
  toggleSmoothOption;

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
      case MPCommandDescriptionType.addImageInsertConfig:
        return MPCommandDescriptionType.removeImageInsertConfig;
      case MPCommandDescriptionType.addLine:
        return MPCommandDescriptionType.removeLine;
      case MPCommandDescriptionType.addLines:
        return MPCommandDescriptionType.removeLines;
      case MPCommandDescriptionType.addLineSegment:
        return MPCommandDescriptionType.removeLineSegment;
      case MPCommandDescriptionType.addPoint:
        return MPCommandDescriptionType.removePoint;
      case MPCommandDescriptionType.addScrap:
        return MPCommandDescriptionType.removeScrap;
      case MPCommandDescriptionType.copyElements:
        return MPCommandDescriptionType.copyElements;
      case MPCommandDescriptionType.cutElements:
        return MPCommandDescriptionType.addElements;
      case MPCommandDescriptionType.duplicateElements:
        return MPCommandDescriptionType.removeElements;
      case MPCommandDescriptionType.pasteElements:
        return MPCommandDescriptionType.removeElements;
      case MPCommandDescriptionType.reorderImages:
        return MPCommandDescriptionType.reorderImages;
      case MPCommandDescriptionType.reorderScraps:
        return MPCommandDescriptionType.reorderScraps;
      case MPCommandDescriptionType.removeArea:
        return MPCommandDescriptionType.addArea;
      case MPCommandDescriptionType.removeElement:
        return MPCommandDescriptionType.addElement;
      case MPCommandDescriptionType.removeElements:
        return MPCommandDescriptionType.addElements;
      case MPCommandDescriptionType.removeEmptyLine:
        return MPCommandDescriptionType.addEmptyLine;
      case MPCommandDescriptionType.removeImageInsertConfig:
        return MPCommandDescriptionType.addImageInsertConfig;
      case MPCommandDescriptionType.removeLine:
        return MPCommandDescriptionType.addLine;
      case MPCommandDescriptionType.removeLines:
        return MPCommandDescriptionType.addLines;
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
      case MPCommandDescriptionType.setOptionToElement:
        return MPCommandDescriptionType.removeOptionFromElement;
      default:
        return description;
    }
  }
}
