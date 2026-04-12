// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/gestures.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_text_to_user.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/mp_setting_type.dart';
import 'package:mapiah/src/elements/types/mp_pla_type_subtype.dart';

class TH2FileEditLastUsedPLAButtonsWidget extends StatelessWidget {
  final TH2FileEditController th2FileEditController;

  const TH2FileEditLastUsedPLAButtonsWidget({
    required this.th2FileEditController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (BuildContext context) {
        mpLocator.mpSettingsController.getTrigger(
          MPSettingID.TH2Edit_ShowLastUsedPLATypeButtons,
        );

        if (!_showLastUsedPLAButtons) {
          return const SizedBox.shrink();
        }

        final List<MPPLATypeSubtype> lastUsedAreaLineTypes =
            th2FileEditController.elementEditController.lastUsedAreaLineTypes
                .toList(growable: false);
        final List<MPPLATypeSubtype> lastUsedPointTypes = th2FileEditController
            .elementEditController
            .lastUsedPointTypes
            .toList(growable: false);

        if (lastUsedAreaLineTypes.isEmpty && lastUsedPointTypes.isEmpty) {
          return const SizedBox.shrink();
        }

        final ColorScheme colorScheme = Theme.of(context).colorScheme;

        return Material(
          color: colorScheme.surfaceContainerHigh,
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: mpButtonSpace),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _TH2FileEditLastUsedPLAButtonsHalfWidget(
                      plaTypes: lastUsedAreaLineTypes.reversed.toList(),
                      alignment: Alignment.centerRight,
                      th2FileEditController: th2FileEditController,
                    ),
                  ),
                  SizedBox(width: mpButtonSpace, height: 44),
                  SizedBox(
                    height: 44,
                    child: Center(
                      child: Container(
                        width: 1,
                        height: 28,
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: mpButtonSpace * 2, height: 44),
                  Expanded(
                    child: _TH2FileEditLastUsedPLAButtonsHalfWidget(
                      plaTypes: lastUsedPointTypes,
                      alignment: Alignment.centerLeft,
                      th2FileEditController: th2FileEditController,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool get _showLastUsedPLAButtons {
    return mpLocator.mpSettingsController.getBoolWithDefault(
      MPSettingID.TH2Edit_ShowLastUsedPLATypeButtons,
    );
  }
}

class _TH2FileEditLastUsedPLAButtonsHalfWidget extends StatefulWidget {
  final Alignment alignment;
  final List<MPPLATypeSubtype> plaTypes;
  final TH2FileEditController th2FileEditController;

  const _TH2FileEditLastUsedPLAButtonsHalfWidget({
    required this.alignment,
    required this.plaTypes,
    required this.th2FileEditController,
  });

  @override
  State<_TH2FileEditLastUsedPLAButtonsHalfWidget> createState() =>
      _TH2FileEditLastUsedPLAButtonsHalfWidgetState();
}

class _TH2FileEditLastUsedPLAButtonsHalfWidgetState
    extends State<_TH2FileEditLastUsedPLAButtonsHalfWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plaTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool shouldReverseScroll =
        (widget.alignment == Alignment.centerRight);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SizedBox(
          height: 44,
          child: Listener(
            onPointerSignal: _onPointerSignal,
            child: ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                dragDevices: <PointerDeviceKind>{
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.invertedStylus,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.unknown,
                },
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                reverse: shouldReverseScroll,
                clipBehavior: Clip.hardEdge,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Align(
                    alignment: widget.alignment,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final MPPLATypeSubtype plaType
                            in widget.plaTypes) ...[
                          _TH2FileEditLastUsedPLAButtonWidget(
                            plaTypeSubtype: plaType,
                            th2FileEditController: widget.th2FileEditController,
                          ),
                          const SizedBox(width: mpButtonSpace),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) {
      return;
    }

    if (!_scrollController.hasClients) {
      return;
    }

    final double delta = _pointerScrollDelta(event);

    if (delta == 0) {
      return;
    }

    final double targetOffset = (_scrollController.offset + delta).clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.jumpTo(targetOffset);
  }

  double _pointerScrollDelta(PointerScrollEvent event) {
    final double deltaX = event.scrollDelta.dx;
    final double deltaY = event.scrollDelta.dy;

    if (deltaX != 0) {
      return deltaX;
    }

    return deltaY;
  }
}

class _TH2FileEditLastUsedPLAButtonWidget extends StatelessWidget {
  final MPPLATypeSubtype plaTypeSubtype;
  final TH2FileEditController th2FileEditController;

  const _TH2FileEditLastUsedPLAButtonWidget({
    required this.plaTypeSubtype,
    required this.th2FileEditController,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String buttonIcon = _buttonIconPath(plaTypeSubtype.pla);
    final String label = MPTextToUser.getPLATypeSubtype(plaTypeSubtype);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.94),
        elevation: 1,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => th2FileEditController.elementEditController
              .activatePLATypeSubtypeForNewElement(plaTypeSubtype),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  buttonIcon,
                  width: 18,
                  height: 18,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buttonIconPath(MPPLAType plaType) {
    switch (plaType) {
      case MPPLAType.area:
        return 'assets/icons/add_element-addArea.png';
      case MPPLAType.line:
        return 'assets/icons/add_element-addLine.png';
      case MPPLAType.point:
        return 'assets/icons/add_element-addPoint.png';
    }
  }
}
