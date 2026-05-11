// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_command_option_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/elements/th_element.dart';
import 'package:mapiah/src/elements/types/th_point_type.dart';
import 'package:mapiah/src/elements/xvi/xvi_file.dart';
import 'package:mapiah/src/elements/xvi/xvi_station.dart';
import 'package:mapiah/src/selectable/mp_selectable.dart';

class MPStationHoverTooltipWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;

  const MPStationHoverTooltipWidget({
    super.key,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final Offset screenPosition = th2FileEditController.mousePosition;

        th2FileEditController.redrawTriggerAllElements;
        th2FileEditController.redrawTriggerImages;
        th2FileEditController.redrawTriggerNonSelectedElements;

        if (!th2FileEditController.screenBoundingBox.contains(
          screenPosition,
        )) {
          return const SizedBox.shrink();
        }

        final List<MPStationHoverRecord> stations =
            _getStationsUnderCursor(screenPosition);

        if (stations.isEmpty) {
          return const SizedBox.shrink();
        }

        final Offset tooltipPosition = _getTooltipPosition(screenPosition);
        final ColorScheme colorScheme = Theme.of(context).colorScheme;

        return Positioned(
          left: tooltipPosition.dx,
          top: tooltipPosition.dy,
          child: IgnorePointer(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: mpStationHoverTooltipMaxWidth,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.inverseSurface.withValues(
                    alpha: mpStationHoverTooltipOpacity,
                  ),
                  borderRadius: BorderRadius.circular(
                    mpStationHoverTooltipBorderRadius,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    mpStationHoverTooltipPadding,
                  ),
                  child: _buildTooltipContent(
                    colorScheme: colorScheme,
                    stations: stations,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTooltipContent({
    required ColorScheme colorScheme,
    required List<MPStationHoverRecord> stations,
  }) {
    final TextStyle textStyle = TextStyle(
      color: colorScheme.onInverseSurface,
      fontSize: mpStationHoverTooltipFontSize,
      height: mpStationHoverTooltipTextHeight,
    );
    final TextStyle titleTextStyle = textStyle.copyWith(
      fontWeight: FontWeight.bold,
    );
    final List<Widget> children = <Widget>[
      Padding(
        padding: const EdgeInsets.only(
          bottom: mpStationHoverTooltipTitleBottomPadding,
        ),
        child: Text(
          mpLocator.appLocalizations.mapiahStationHoverTooltipTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: titleTextStyle,
        ),
      ),
    ];

    children.addAll(
      stations.map(
        (MPStationHoverRecord station) => Text(
          '${station.source}: ${station.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textStyle,
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  List<MPStationHoverRecord> _getStationsUnderCursor(Offset screenPosition) {
    final Offset canvasPosition = th2FileEditController.offsetScreenToCanvas(
      screenPosition,
    );
    final List<MPStationHoverRecord> stations = <MPStationHoverRecord>[];

    stations.addAll(_getTherionStationsUnderCursor(canvasPosition));
    stations.addAll(_getXVIStationsUnderCursor(canvasPosition));

    return stations;
  }

  List<MPStationHoverRecord> _getTherionStationsUnderCursor(
    Offset canvasPosition,
  ) {
    final Iterable<MPSelectable> selectableElements = th2FileEditController
        .selectionController
        .getMPSelectableElements()
        .values;
    final List<MPStationHoverRecord> stations = <MPStationHoverRecord>[];

    for (final MPSelectable selectableElement in selectableElements) {
      if ((selectableElement is! MPSelectablePoint) ||
          !selectableElement.contains(canvasPosition)) {
        continue;
      }

      final THPoint point = selectableElement.element as THPoint;

      if (point.pointType != THPointType.station) {
        continue;
      }

      final String? stationName = MPCommandOptionAux.getName(point);

      if ((stationName == null) || stationName.isEmpty) {
        continue;
      }

      stations.add(
        MPStationHoverRecord(source: mpStationSourceTherion, name: stationName),
      );
    }

    return stations;
  }

  List<MPStationHoverRecord> _getXVIStationsUnderCursor(Offset canvasPosition) {
    if (!th2FileEditController.showImages) {
      return <MPStationHoverRecord>[];
    }

    final Iterable<MPRuntimeImageInsertConfigMixin> images =
        th2FileEditController.th2File.getImages();
    final List<MPStationHoverRecord> stations = <MPStationHoverRecord>[];

    for (final MPRuntimeImageInsertConfigMixin image in images) {
      final MPRuntimeImageInsertConfigMixin renderedImage =
          th2FileEditController.stateController
              .getImageOperationRenderedImageForImage(image.mpID) ??
          image;

      if (!renderedImage.isVisible) {
        continue;
      }

      final MPRuntimeXVIImageInsertConfigMixin? xviImage =
          renderedImage.asXVIImage;

      if (xviImage == null) {
        continue;
      }

      stations.addAll(
        _getXVIImageStationsUnderCursor(
          xviImage: xviImage,
          canvasPosition: canvasPosition,
        ),
      );
    }

    return stations;
  }

  List<MPStationHoverRecord> _getXVIImageStationsUnderCursor({
    required MPRuntimeXVIImageInsertConfigMixin xviImage,
    required Offset canvasPosition,
  }) {
    final XVIFile? xviFile = xviImage.getXVIFile(th2FileEditController);

    if (xviFile == null) {
      return <MPStationHoverRecord>[];
    }

    final Offset imageGridOffset = Offset(
      xviImage.xviRootedXX,
      xviImage.xviRootedYY,
    );
    final Offset imageOffset =
        imageGridOffset - Offset(xviFile.grid.gx.value, xviFile.grid.gy.value);
    final double toleranceSquared =
        th2FileEditController.selectionToleranceSquaredOnCanvas;
    final List<MPStationHoverRecord> stations = <MPStationHoverRecord>[];

    for (final XVIStation station in xviFile.stations) {
      final Offset stationPosition =
          xviImage.transformWorldPointFromBaseWorldPoint(
            station.position.coordinates + imageOffset,
          );
      final double distanceSquared =
          (stationPosition - canvasPosition).distanceSquared;

      if (distanceSquared > toleranceSquared) {
        continue;
      }

      if (station.name.isEmpty) {
        continue;
      }

      stations.add(
        MPStationHoverRecord(source: mpStationSourceXVI, name: station.name),
      );
    }

    return stations;
  }

  Offset _getTooltipPosition(Offset screenPosition) {
    final double preferredLeft =
        screenPosition.dx + mpStationHoverTooltipCursorDistance;
    final double preferredTop =
        screenPosition.dy + mpStationHoverTooltipCursorDistance;
    final double maxLeft =
        th2FileEditController.screenSize.width -
        mpStationHoverTooltipMaxWidth -
        mpStationHoverTooltipScreenMargin;
    final double maxTop =
        th2FileEditController.screenSize.height -
        mpStationHoverTooltipEstimatedMaxHeight -
        mpStationHoverTooltipScreenMargin;

    final double left = _clampTooltipCoordinate(
      preferredValue: preferredLeft,
      maxValue: maxLeft,
    );
    final double top = _clampTooltipCoordinate(
      preferredValue: preferredTop,
      maxValue: maxTop,
    );

    return Offset(left, top);
  }

  double _clampTooltipCoordinate({
    required double preferredValue,
    required double maxValue,
  }) {
    if (maxValue < mpStationHoverTooltipScreenMargin) {
      return mpStationHoverTooltipScreenMargin;
    }

    final num clampedValue = preferredValue.clamp(
      mpStationHoverTooltipScreenMargin,
      maxValue,
    );

    return clampedValue.toDouble();
  }
}

class MPStationHoverRecord {
  final String source;
  final String name;

  const MPStationHoverRecord({required this.source, required this.name});
}
