part of '../mp_th2_file_edit_state.dart';

mixin MPTH2FileEditPageSingleElementSelectedMixin on MPTH2FileEditState {
  String _getStatusBarMessageForSingleSelectedElement() {
    final THElement element = getSingleSelectedElement();

    switch (element) {
      case THPoint _:
        return getStatusBarMessageForSingleSelectedPoint(element);
      case THLine _:
        return getStatusBarMessageForSingleSelectedLine(element);
      case THArea _:
        return getStatusBarMessageForSingleSelectedArea(element);
      default:
        return 'Unsupported element type at MPTH2FileEditPageSingleElementSelectedMixin.getStatusBarMessageForSingleSelectedElement().';
    }
  }

  String getStatusBarMessageForSingleSelectedPoint(THPoint point) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    String pointType = appLocalizations
        .mpStatusBarMessageSingleSelectedPointType(
          MPTextToUser.getPointType(point.pointType),
        );

    if (point.pointType == THPointType.unknown) {
      pointType += ' (${point.unknownPLAType})';
    }

    String message = getStatusBarMainMessage(
      elementType: pointType,
      element: point,
    );

    message += getStatusBarMessageElementOptions(point);

    return message;
  }

  String getStatusBarMessageForSingleSelectedLine(THLine line) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    String lineType = appLocalizations.mpStatusBarMessageSingleSelectedLineType(
      MPTextToUser.getLineType(line.lineType),
    );

    if (line.lineType == THLineType.unknown) {
      lineType += ' (${line.unknownPLAType})';
    }

    String message = getStatusBarMainMessage(
      elementType: lineType,
      element: line,
    );

    final int? parentAreaMPID = thFile.getAreaMPIDByLineMPID(line.mpID);

    if (parentAreaMPID != null) {
      final THArea parentArea = thFile.elementByMPID(parentAreaMPID) as THArea;
      final String areaType = mpLocator.appLocalizations
          .mpStatusBarMessageSingleSelectedAreaType(
            MPTextToUser.getAreaType(parentArea.areaType),
          );

      message += appLocalizations
          .mpStatusBarMessageSingleSelectedLineParentArea(areaType);

      if (parentArea.hasOption(THCommandOptionType.id)) {
        message += appLocalizations.mpStatusBarMessageSingleSelectedElementID(
          (parentArea.getOption(THCommandOptionType.id)! as THIDCommandOption)
              .thID,
        );
      }
    }

    /// Skiping the first as it's not actually a line segment, it's just the
    /// starting point of the line.
    final Iterable<THLineSegment> lineSegments = line
        .getLineSegments(thFile)
        .skip(1);

    if (lineSegments.isEmpty) {
      message +=
          appLocalizations.mpStatusBarMessageSingleSelectedLineNoLineSegments;
    } else {
      int straightLineSegmentsCount = 0;
      int bezierLineSegmentsCount = 0;

      for (final THLineSegment lineSegment in lineSegments) {
        switch (lineSegment.elementType) {
          case THElementType.straightLineSegment:
            straightLineSegmentsCount++;
          case THElementType.bezierCurveLineSegment:
            bezierLineSegmentsCount++;
          default:
        }
      }

      message += appLocalizations
          .mpStatusBarMessageSingleSelectedLineLineSegmentsCount(
            lineSegments.length,
            straightLineSegmentsCount,
            bezierLineSegmentsCount,
          );
    }

    message += getStatusBarMessageElementOptions(line);

    return message;
  }

  String getStatusBarMessageForSingleSelectedArea(THArea area) {
    /// Example output:
    /// Area type TYPE [no subtype|subtype SUBTYPE] - XX lines: line THIDs list - [no options|options: OPTION1=VALUE1, OPTION2=VALUE2, ...]
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    String areaType = appLocalizations.mpStatusBarMessageSingleSelectedAreaType(
      MPTextToUser.getAreaType(area.areaType),
    );

    if (area.areaType == THAreaType.unknown) {
      areaType += ' (${area.unknownPLAType})';
    }

    String message = getStatusBarMainMessage(
      elementType: areaType,
      element: area,
    );

    final List<THAreaBorderTHID> areaBorders = area.getAreaBorderTHIDs(thFile);

    if (areaBorders.isEmpty) {
      message +=
          appLocalizations.mpStatusBarMessageSingleSelectedAreaNoAreaBorders;
    } else {
      String lineTHIDsList = '';

      for (final THAreaBorderTHID areaBorder in areaBorders) {
        lineTHIDsList += ', ';
        lineTHIDsList += areaBorder.thID;
      }

      if (lineTHIDsList.isNotEmpty) {
        lineTHIDsList = lineTHIDsList.substring(2);
      }

      message += appLocalizations
          .mpStatusBarMessageSingleSelectedAreaAreaBordersList(
            areaBorders.length,
            lineTHIDsList,
          );
    }

    message += getStatusBarMessageElementOptions(area);

    return message;
  }

  String getStatusBarMessageElementOptions(THHasOptionsMixin element) {
    final SplayTreeMap<THCommandOptionType, THCommandOption> elementOptions =
        element.optionsMap;
    final List<THCommandOption> optionsToInclude = <THCommandOption>[];

    String message;

    for (final THCommandOptionType optionType in elementOptions.keys) {
      if ((optionType != THCommandOptionType.id) &&
          (optionType != THCommandOptionType.subtype)) {
        optionsToInclude.add(elementOptions[optionType]!);
      }
    }

    optionsToInclude.addAll(element.attrOptionsMap.values);

    if (optionsToInclude.isEmpty) {
      message = '';
    } else {
      final List<String> optionsStrings = [];

      for (final THCommandOption option in optionsToInclude) {
        final String typeToFile = option.typeToFile();
        final String spec = option.specToFile();

        optionsStrings.add("$typeToFile $spec");
      }

      optionsStrings.sort();
      message = ' - ';
      message += optionsStrings.join(', ');
    }

    return message;
  }

  String getStatusBarMainMessage({
    required String elementType,
    required THHasOptionsMixin element,
  }) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    String message = elementType;

    if (element.hasOption(THCommandOptionType.subtype)) {
      message += appLocalizations
          .mpStatusBarMessageSingleSelectedElementSubtype(
            MPTextToUser.getSubtypeAsString(
              (element.getOption(THCommandOptionType.subtype)!
                      as THSubtypeCommandOption)
                  .subtype,
            ),
          );
    }
    if (element.hasOption(THCommandOptionType.id)) {
      message += appLocalizations.mpStatusBarMessageSingleSelectedElementID(
        (element.getOption(THCommandOptionType.id)! as THIDCommandOption).thID,
      );
    }

    return message;
  }

  THElement getSingleSelectedElement() {
    final Iterable<MPSelectedElement> selectedElements =
        selectionController.mpSelectedElementsLogical.values;

    if (selectedElements.length != 1) {
      throw StateError(
        'Expected exactly one selected element at MPTH2FileEditPageSingleElementSelectedMixin.getSingleSelectedElement(), but found ${selectedElements.length}.',
      );
    }

    final THElement selectedElement = thFile.elementByMPID(
      selectedElements.first.mpID,
    );

    return selectedElement;
  }
}
