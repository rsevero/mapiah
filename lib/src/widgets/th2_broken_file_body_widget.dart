// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/services.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th2_file_problem_text_aux.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';
import 'package:material_ui/material_ui.dart';

/// The body shown instead of the canvas for a broken `.th2` file: a
/// localized explanation, the file path, every problem with its localized
/// category, source line and parser diagnostic, and a Reload button.
class TH2BrokenFileBodyWidget extends StatelessWidget {
  final TH2FileEditController controller;
  final VoidCallback? onReload;

  const TH2BrokenFileBodyWidget({
    required this.controller,
    this.onReload,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            appLocalizations.th2BrokenFileExplanation,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildPath(appLocalizations),
          const SizedBox(height: 16),
          for (final TH2FileProblem problem in controller.problems)
            _buildProblem(appLocalizations, problem),
          if (onReload != null)
            ElevatedButton(
              onPressed: onReload,
              child: Text(appLocalizations.th2ElementTreeReload),
            ),
        ],
      ),
    );
  }

  /// The selectable file path followed by its Copy path button.
  Widget _buildPath(AppLocalizations appLocalizations) {
    final String filename = controller.th2File.filename;
    final String copyPathLabel = appLocalizations.th2BrokenFileCopyPath;

    return Row(
      children: <Widget>[
        Flexible(child: SelectableText(filename)),
        const SizedBox(width: 8),
        Tooltip(
          message: copyPathLabel,
          child: TextButton.icon(
            key: const ValueKey('TH2BrokenFileBodyCopyPathButton'),
            onPressed: () => Clipboard.setData(ClipboardData(text: filename)),
            icon: const Icon(Icons.copy),
            label: Text(copyPathLabel),
          ),
        ),
      ],
    );
  }

  /// One problem: line number and localized category, the untrimmed source
  /// line and the parser diagnostic behind a Details disclosure.
  Widget _buildProblem(
    AppLocalizations appLocalizations,
    TH2FileProblem problem,
  ) {
    final String category = TH2FileProblemTextAux.userMessage(
      problem.kind,
      appLocalizations,
    );
    final String sourceLine = problem.sourceLine.trimRight();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            appLocalizations.th2ElementTreeProblemLine(
              problem.lineNumber,
              category,
            ),
          ),
          SelectableText(
            sourceLine,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          _TH2BrokenFileProblemDetailsWidget(
            label: appLocalizations.th2BrokenFileDetails,
            detail: problem.detail,
          ),
        ],
      ),
    );
  }
}

/// A collapsed-by-default disclosure that reveals one problem's parser
/// diagnostic.
class _TH2BrokenFileProblemDetailsWidget extends StatefulWidget {
  final String label;
  final String detail;

  const _TH2BrokenFileProblemDetailsWidget({
    required this.label,
    required this.detail,
  });

  @override
  State<_TH2BrokenFileProblemDetailsWidget> createState() =>
      _TH2BrokenFileProblemDetailsWidgetState();
}

class _TH2BrokenFileProblemDetailsWidgetState
    extends State<_TH2BrokenFileProblemDetailsWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextButton.icon(
          onPressed: () => setState(() => _expanded = !_expanded),
          icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
          label: Text(widget.label),
        ),
        if (_expanded) SelectableText(widget.detail),
      ],
    );
  }
}
