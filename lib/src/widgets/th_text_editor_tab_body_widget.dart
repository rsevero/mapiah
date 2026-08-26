// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th_text_editor_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/widgets/th_text_editor_widget.dart';
import 'package:material_ui/material_ui.dart';

/// Async-load wrapper for [THTextEditorWidget], mirroring
/// `TH2FileEditBodyWidget`'s `FutureBuilder`-over-a-cached-future pattern.
///
/// The caller is expected to key this widget by [filePath] (as
/// `TH2FileTabsPage` already does for `.th2` tabs), so a new tab always gets
/// a fresh [State] rather than reaching [didUpdateWidget].
class THTextEditorTabBodyWidget extends StatefulWidget {
  final THTextEditorController controller;
  final String filePath;

  const THTextEditorTabBodyWidget({
    super.key,
    required this.controller,
    required this.filePath,
  });

  @override
  State<THTextEditorTabBodyWidget> createState() =>
      _THTextEditorTabBodyWidgetState();
}

class _THTextEditorTabBodyWidgetState extends State<THTextEditorTabBodyWidget> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = widget.controller.loadFile(widget.filePath);
  }

  @override
  void didUpdateWidget(THTextEditorTabBodyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.controller, widget.controller) ||
        (oldWidget.filePath != widget.filePath)) {
      setState(() {
        _loadFuture = widget.controller.loadFile(widget.filePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(appLocalizations.textEditorTabLoadFailedMessage),
          );
        }

        return THTextEditorWidget(controller: widget.controller);
      },
    );
  }
}
