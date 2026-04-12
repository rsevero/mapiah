// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';

class TH2FileEditBottomStatusBarWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;

  const TH2FileEditBottomStatusBarWidget({
    required this.th2FileEditController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BottomAppBar(
      height: 40,
      color: colorScheme.secondary,
      child: Observer(
        builder: (_) {
          final TextStyle statusBarTextStyle = TextStyle(
            color: colorScheme.onSecondary,
            fontStyle: FontStyle.italic,
          );
          final TextStyle statusBarInfoStyle = TextStyle(
            color: colorScheme.onSecondary,
          );
          final String currentScrapName =
              th2FileEditController.currentScrapName;
          final String statusBarMessage =
              th2FileEditController.statusBarMessage;
          final String canvasScaleAsPercentageText =
              th2FileEditController.canvasScaleAsPercentageText;
          final Offset? movingMousePosition =
              th2FileEditController.movingMousePosition;
          final String movingMousePositionText = _movingMousePositionText(
            movingMousePosition: movingMousePosition,
          );

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double maxScrapNameWidth = constraints.maxWidth / 5;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxScrapNameWidth),
                    child: Text(
                      currentScrapName,
                      style: statusBarInfoStyle,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: mpButtonMargin),
                  Expanded(
                    child: Text(
                      statusBarMessage,
                      style: statusBarTextStyle,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (movingMousePositionText.isNotEmpty) ...[
                    const SizedBox(width: mpButtonMargin),
                    Text(
                      movingMousePositionText,
                      style: statusBarInfoStyle,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(width: mpButtonMargin),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "🔍 $canvasScaleAsPercentageText",
                      style: statusBarInfoStyle,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _movingMousePositionText({required Offset? movingMousePosition}) {
    if (movingMousePosition == null) {
      return '';
    }

    return mpLocator.appLocalizations.mpTH2FileEditPageMousePosition(
      movingMousePosition.dx.toStringAsFixed(1),
      movingMousePosition.dy.toStringAsFixed(1),
    );
  }
}
