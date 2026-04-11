// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_element_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/mp_dialog_bottom_widget.dart';

enum MPInteractiveLineSimplificationDialogResult { close, save, cancel }

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
  late final TH2FileEditElementEditController _elementEditController;
  late final AppLocalizations _appLocalizations;

  late MPLineSimplificationMethod _lineSimplificationMethod;
  late int _intensity;

  @override
  void initState() {
    super.initState();
    _elementEditController = widget.th2FileEditController.elementEditController;
    _appLocalizations = mpLocator.appLocalizations;
    _lineSimplificationMethod = _elementEditController.lineSimplificationMethod;
    _intensity = _elementEditController.interactiveLineSimplificationIntensity;
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final double maxDialogHeight =
        screenSize.height -
        (mpOverlayWindowOutsidePadding * 2) -
        (mpOverlayWindowPadding * 2);
    final double screenTolerance =
        mpLineSimplifyEpsilonOnScreen * _intensity.toDouble();
    final double canvasTolerance =
        _elementEditController.getLineSimplifyEpsilonOnCanvasIncrease() *
        _intensity;

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 720,
        height: maxDialogHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                _appLocalizations.th2FileEditPageInteractiveSimplifyLinesTitle,
                style: theme.textTheme.titleMedium,
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
            Expanded(
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
                      Navigator.of(
                        context,
                      ).pop(MPInteractiveLineSimplificationDialogResult.close);
                    },
                    child: Text(_appLocalizations.buttonClose),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop(MPInteractiveLineSimplificationDialogResult.save);
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
  }
}
