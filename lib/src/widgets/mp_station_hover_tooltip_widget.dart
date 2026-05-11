// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_user_interaction_controller.dart';

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

        if (!th2FileEditController.screenBoundingBox.contains(screenPosition)) {
          return const SizedBox.shrink();
        }

        final List<MPStationPointNameCoordinateRecord> stations =
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
                  padding: const EdgeInsets.all(mpStationHoverTooltipPadding),
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
    required List<MPStationPointNameCoordinateRecord> stations,
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
        (MPStationPointNameCoordinateRecord station) => Text(
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

  List<MPStationPointNameCoordinateRecord> _getStationsUnderCursor(
    Offset screenPosition,
  ) {
    final Offset canvasPosition = th2FileEditController.offsetScreenToCanvas(
      screenPosition,
    );
    final double toleranceSquared =
        th2FileEditController.selectionToleranceSquaredOnCanvas;
    final List<MPStationPointNameCoordinateRecord> stationRecords =
        th2FileEditController.userInteractionController
            .getStationPointNameCoordinateCacheUnderScreenPosition(
              screenPosition,
            );
    final List<MPStationPointNameCoordinateRecord> stations =
        <MPStationPointNameCoordinateRecord>[];

    for (final MPStationPointNameCoordinateRecord station in stationRecords) {
      final double distanceSquared =
          (station.coordinates - canvasPosition).distanceSquared;

      if (distanceSquared > toleranceSquared) {
        continue;
      }

      stations.add(station);
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
