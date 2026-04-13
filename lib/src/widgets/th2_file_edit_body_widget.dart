// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/mp_error_dialog.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/th2_file_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_action_buttons_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_bottom_status_bar_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_last_used_pla_buttons_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_state_action_buttons_widget.dart';
import 'package:mapiah/src/widgets/th2_file_edit_state_context_fabs_widget.dart';

class TH2FileEditBodyWidget extends StatefulWidget {
  final TH2FileEditController th2FileEditController;
  final Future<TH2FileEditControllerCreateResult> loadFuture;

  const TH2FileEditBodyWidget({
    required this.th2FileEditController,
    required this.loadFuture,
    super.key,
  });

  @override
  State<TH2FileEditBodyWidget> createState() => _TH2FileEditBodyWidgetState();
}

class _TH2FileEditBodyWidgetState extends State<TH2FileEditBodyWidget> {
  late final TH2FileEditController th2FileEditController;
  late AppLocalizations appLocalizations;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();

    th2FileEditController = widget.th2FileEditController;
    appLocalizations = mpLocator.appLocalizations;
  }

  @override
  Widget build(BuildContext context) {
    final String heroPrefix = th2FileEditController.th2FileMPID.toString();

    appLocalizations = mpLocator.appLocalizations;
    colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: FutureBuilder<TH2FileEditControllerCreateResult>(
            future: widget.loadFuture,
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<TH2FileEditControllerCreateResult> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text(
                        appLocalizations.th2FileEditPageLoadingFile(
                          th2FileEditController.currentScrapName,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final List<String> errorMessages = snapshot.data!.errors;

                    if (snapshot.data!.isSuccessful) {
                      if (mpDebugMousePosition) {
                        return MouseRegion(
                          onHover: (event) => th2FileEditController
                              .performSetMousePosition(event.localPosition),
                          child: Stack(
                            children: [
                              TH2FileWidget(
                                key: th2FileEditController
                                    .getTH2FileWidgetGlobalKey(),
                                th2FileEditController: th2FileEditController,
                              ),
                              TH2FileEditStateActionButtonsWidget(
                                heroPrefix: heroPrefix,
                                th2FileEditController: th2FileEditController,
                              ),
                              TH2FileEditActionButtonsWidget(
                                heroPrefix: heroPrefix,
                                th2FileEditController: th2FileEditController,
                              ),
                              TH2FileEditStateContextFABsWidget(
                                heroPrefix: heroPrefix,
                                th2FileEditController: th2FileEditController,
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Stack(
                          children: [
                            TH2FileWidget(
                              key: th2FileEditController
                                  .getTH2FileWidgetGlobalKey(),
                              th2FileEditController: th2FileEditController,
                            ),
                            TH2FileEditStateActionButtonsWidget(
                              heroPrefix: heroPrefix,
                              th2FileEditController: th2FileEditController,
                            ),
                            TH2FileEditActionButtonsWidget(
                              heroPrefix: heroPrefix,
                              th2FileEditController: th2FileEditController,
                            ),
                            TH2FileEditStateContextFABsWidget(
                              heroPrefix: heroPrefix,
                              th2FileEditController: th2FileEditController,
                            ),
                          ],
                        );
                      }
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return MPErrorDialog(
                              errorMessages: errorMessages,
                              filename: th2FileEditController.th2File.filename,
                            );
                          },
                        ).then((_) {
                          th2FileEditController.close();
                        });
                      });

                      return Container();
                    }
                  } else {
                    throw Exception(
                      'Unexpected snapshot state: ${snapshot.connectionState}',
                    );
                  }
                },
          ),
        ),
        TH2FileEditLastUsedPLAButtonsWidget(
          th2FileEditController: th2FileEditController,
        ),
        TH2FileEditBottomStatusBarWidget(
          th2FileEditController: th2FileEditController,
        ),
      ],
    );
  }
}
