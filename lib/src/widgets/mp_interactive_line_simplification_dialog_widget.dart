// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_dialog_bottom_widget.dart';

enum MPInteractiveLineSimplificationDialogResult { close, cancel }

class MPInteractiveLineSimplificationDialogWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;

  const MPInteractiveLineSimplificationDialogWidget({
    required this.th2FileEditController,
    super.key,
  });

  @override
  State<MPInteractiveLineSimplificationDialogWidget> createState() =>
      _MPInteractiveLineSimplificationDialogWidgetState();
}

class _MPInteractiveLineSimplificationDialogWidgetState
    extends State<MPInteractiveLineSimplificationDialogWidget> {
  static const double _dialogWidth = 720.0;

  late final TH2FileEditElementEditController _elementEditController;
  late final AppLocalizations _appLocalizations;

  late MPLineSimplificationMethod _lineSimplificationMethod;
  late int _intensity;

  // Drag state
  late Offset _dialogPosition;
  bool _dialogPositioned = false;
  bool _isDragging = false;
  Offset? _dragStartGlobal;
  Offset? _dragStartPosition;
  Size _screenSize = Size.zero;
  double _maxDialogHeight = 0;

  @override
  void initState() {
    super.initState();
    _elementEditController = widget.th2FileEditController.elementEditController;
    _appLocalizations = mpLocator.appLocalizations;
    _lineSimplificationMethod = _elementEditController.lineSimplificationMethod;
    _intensity = _elementEditController.interactiveLineSimplificationIntensity;
  }

  Widget _buildSegmentCountsTable(ThemeData theme) {
    final counts = _elementEditController
        .getInteractiveLineSimplificationCounts();

    if (counts == null) {
      return const SizedBox.shrink();
    }

    final TextStyle? headerStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final TextStyle? bodyStyle = theme.textTheme.bodyMedium;

    TableRow buildRow(String label, int before, int after) {
      return TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(label, style: bodyStyle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              before.toString(),
              style: bodyStyle,
              textAlign: TextAlign.right,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              after.toString(),
              style: bodyStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _appLocalizations.th2FileEditPageInteractiveSimplifyLinesStatusLabel,
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(),
            1: FixedColumnWidth(64),
            2: FixedColumnWidth(64),
          },
          children: [
            TableRow(
              children: [
                const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _appLocalizations
                        .th2FileEditPageInteractiveSimplifyLinesStatusBeforeLabel,
                    style: headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _appLocalizations
                        .th2FileEditPageInteractiveSimplifyLinesStatusAfterLabel,
                    style: headerStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            buildRow(
              _appLocalizations
                  .th2FileEditPageInteractiveSimplifyLinesStatusTotalLabel,
              counts.beforeTotal,
              counts.afterTotal,
            ),
            buildRow(
              _appLocalizations
                  .th2FileEditPageInteractiveSimplifyLinesStatusBezierLabel,
              counts.beforeBezier,
              counts.afterBezier,
            ),
            buildRow(
              _appLocalizations
                  .th2FileEditPageInteractiveSimplifyLinesStatusStraightLabel,
              counts.beforeStraight,
              counts.afterStraight,
            ),
          ],
        ),
      ],
    );
  }

  void _updatePreview() {
    _elementEditController.previewInteractiveLineSimplification(
      lineSimplificationMethod: _lineSimplificationMethod,
      intensity: _intensity,
    );
  }

  void _setLineSimplificationMethod(MPLineSimplificationMethod? method) {
    if ((method == null) || (_lineSimplificationMethod == method)) {
      return;
    }

    setState(() {
      _lineSimplificationMethod = method;
    });

    _updatePreview();
  }

  void _setIntensity(double value) {
    final int roundedValue = value.round();

    if (_intensity == roundedValue) {
      return;
    }

    setState(() {
      _intensity = roundedValue;
    });

    _updatePreview();
  }

  void _onTitlePointerDown(PointerDownEvent event) {
    if ((event.kind != PointerDeviceKind.mouse) ||
        (event.buttons != kSecondaryMouseButton)) {
      return;
    }

    setState(() {
      _isDragging = true;
      _dragStartGlobal = event.position;
      _dragStartPosition = _dialogPosition;
    });
  }

  void _onTitlePointerMove(PointerMoveEvent event) {
    if (!_isDragging) {
      return;
    }

    final Offset? dragStartGlobal = _dragStartGlobal;
    final Offset? dragStartPosition = _dragStartPosition;

    if ((dragStartGlobal == null) || (dragStartPosition == null)) {
      return;
    }

    final Offset delta = event.position - dragStartGlobal;
    Offset newPosition = dragStartPosition + delta;

    newPosition = Offset(
      newPosition.dx.clamp(0.0, _screenSize.width - _dialogWidth),
      newPosition.dy.clamp(0.0, _screenSize.height - _maxDialogHeight),
    );

    setState(() {
      _dialogPosition = newPosition;
    });
  }

  void _stopDrag() {
    if (!_isDragging) {
      return;
    }

    setState(() {
      _isDragging = false;
      _dragStartGlobal = null;
      _dragStartPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    _screenSize = MediaQuery.sizeOf(context);
    _maxDialogHeight =
        _screenSize.height -
        (mpOverlayWindowOutsidePadding * 2) -
        (mpOverlayWindowPadding * 2);

    if (!_dialogPositioned) {
      _dialogPosition = Offset(
        (_screenSize.width - _dialogWidth) / 2,
        (_screenSize.height - _maxDialogHeight) / 2,
      );
      _dialogPositioned = true;
    }

    final double screenTolerance =
        mpLineSimplifyEpsilonOnScreen * _intensity.toDouble();
    final double canvasTolerance =
        _elementEditController.getLineSimplifyEpsilonOnCanvasIncrease() *
        _intensity;

    final Widget dialogContent = Material(
      elevation: 6,
      color: theme.colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _dialogWidth,
          maxHeight: _maxDialogHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.move,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: _onTitlePointerDown,
                onPointerMove: _onTitlePointerMove,
                onPointerUp: (_) => _stopDrag(),
                onPointerCancel: (_) => _stopDrag(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Text(
                    _appLocalizations
                        .th2FileEditPageInteractiveSimplifyLinesTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Text(
                _appLocalizations
                    .th2FileEditPageInteractiveSimplifyLinesDescription,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: mpButtonSpace),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _appLocalizations
                          .th2FileEditPageInteractiveSimplifyLinesMethodLabel,
                      style: theme.textTheme.titleSmall,
                    ),
                    RadioGroup<MPLineSimplificationMethod>(
                      groupValue: _lineSimplificationMethod,
                      onChanged: _setLineSimplificationMethod,
                      child: Column(
                        children: [
                          RadioListTile<MPLineSimplificationMethod>(
                            value: MPLineSimplificationMethod.keepOriginalTypes,
                            title: Text(
                              _appLocalizations
                                  .th2FileEditPageInteractiveSimplifyLinesKeepOriginal,
                            ),
                          ),
                          RadioListTile<MPLineSimplificationMethod>(
                            value: MPLineSimplificationMethod.forceBezier,
                            title: Text(
                              _appLocalizations
                                  .th2FileEditPageInteractiveSimplifyLinesForceBezier,
                            ),
                          ),
                          RadioListTile<MPLineSimplificationMethod>(
                            value: MPLineSimplificationMethod.forceStraight,
                            title: Text(
                              _appLocalizations
                                  .th2FileEditPageInteractiveSimplifyLinesForceStraight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: mpButtonSpace),
                    Text(
                      '${_appLocalizations.th2FileEditPageInteractiveSimplifyLinesIntensityLabel}: $_intensity',
                      style: theme.textTheme.titleSmall,
                    ),
                    Slider(
                      value: _intensity.toDouble(),
                      min: mpInteractiveLineSimplificationInitialIntensity
                          .toDouble(),
                      max: mpInteractiveLineSimplificationMaxIntensity
                          .toDouble(),
                      divisions:
                          mpInteractiveLineSimplificationMaxIntensity -
                          mpInteractiveLineSimplificationInitialIntensity,
                      label: _intensity.toString(),
                      onChanged: _setIntensity,
                    ),
                    Text(
                      '${_appLocalizations.th2FileEditPageInteractiveSimplifyLinesScreenToleranceLabel}: ${screenTolerance.toStringAsFixed(1)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_appLocalizations.th2FileEditPageInteractiveSimplifyLinesCanvasToleranceLabel}: ${canvasTolerance.toStringAsFixed(3)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: mpButtonSpace),
                    _buildSegmentCountsTable(theme),
                  ],
                ),
              ),
            ),
            MPDialogBottomWidget(
              child: Wrap(
                spacing: mpButtonSpace,
                runSpacing: mpButtonSpace,
                alignment: WrapAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _lineSimplificationMethod =
                            MPLineSimplificationMethod.keepOriginalTypes;
                        _intensity =
                            mpInteractiveLineSimplificationInitialIntensity;
                      });
                      _updatePreview();
                    },
                    child: Text(_appLocalizations.mpButtonReset),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop(MPInteractiveLineSimplificationDialogResult.close);
                    },
                    child: Text(_appLocalizations.buttonClose),
                  ),
                  TextButton(
                    onPressed: () {
                      _elementEditController
                          .commitInteractiveLineSimplification();
                    },
                    child: Text(_appLocalizations.mpButtonSave),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop(MPInteractiveLineSimplificationDialogResult.cancel);
                    },
                    child: Text(_appLocalizations.mpButtonCancel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: _screenSize.width,
        height: _screenSize.height,
        child: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(
                context,
              ).pop(MPInteractiveLineSimplificationDialogResult.close),
              child: const SizedBox.expand(),
            ),
            Positioned(
              left: _dialogPosition.dx,
              top: _dialogPosition.dy,
              child: dialogContent,
            ),
          ],
        ),
      ),
    );
  }
}
