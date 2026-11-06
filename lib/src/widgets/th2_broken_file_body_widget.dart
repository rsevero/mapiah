// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/auxiliary/th2_file_problem_text_aux.dart';
import 'package:mapiah/src/constants/mp_constants.dart';
import 'package:mapiah/src/controllers/mp_general_controller.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/types/th2_edit_mode.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';
import 'package:material_ui/material_ui.dart';

/// The body shown instead of the canvas for a broken `.th2` file: a
/// localized explanation, the file path, every problem with its localized
/// category, source line and parser diagnostic, an _Edit as text_ button and
/// a Reload button.
///
/// It holds the canvas focus node, so tab activation and `F2` work here.
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

    return _TH2BrokenFileBodyFocusWidget(
      controller: controller,
      child: SingleChildScrollView(
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
          Wrap(
            spacing: mpTH2BrokenFileBodyButtonSpacing,
            runSpacing: mpTH2BrokenFileBodyButtonSpacing,
            children: <Widget>[
              _buildEditAsTextButton(appLocalizations),
              if (onReload != null)
                ElevatedButton(
                  onPressed: onReload,
                  child: Text(appLocalizations.th2ElementTreeReload),
                ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  /// _Edit as text_: disabled, with a progress indicator, while the entry
  /// (or any other gated operation) runs.
  Widget _buildEditAsTextButton(AppLocalizations appLocalizations) {
    return Tooltip(
      message: appLocalizations.th2BrokenFileEditAsTextTooltip,
      child: Observer(
        builder: (BuildContext context) {
          final bool isBusy = controller.isOperationBusy;

          return ElevatedButton.icon(
            key: const ValueKey('TH2BrokenFileBodyEditAsTextButton'),
            onPressed: isBusy ? null : controller.requestEnterTextMode,
            icon: isBusy
                ? const SizedBox.square(
                    dimension: mpTH2BrokenFileBodyEditAsTextProgressSize,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.edit_note),
            label: Text(appLocalizations.th2BrokenFileEditAsText),
          );
        },
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
            style: const TextStyle(
              fontFamily: mpMonospaceFontFamily,
              fontFamilyFallback: mpMonospaceFontFamilyFallback,
            ),
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

/// Attaches the canvas focus node to the broken-file body, and focuses it
/// when the body mounts in the active tab: a broken tab's load usually
/// completes after the tab activation's focus request.
class _TH2BrokenFileBodyFocusWidget extends StatefulWidget {
  final TH2FileEditController controller;
  final Widget child;

  const _TH2BrokenFileBodyFocusWidget({
    required this.controller,
    required this.child,
  });

  @override
  State<_TH2BrokenFileBodyFocusWidget> createState() =>
      _TH2BrokenFileBodyFocusWidgetState();
}

class _TH2BrokenFileBodyFocusWidgetState
    extends State<_TH2BrokenFileBodyFocusWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      final TH2FileEditController controller = widget.controller;

      if (!mounted ||
          controller.isDisposed ||
          (controller.editMode != TH2EditMode.canvas) ||
          !controller.isBroken ||
          !_isActiveTab(controller)) {
        return;
      }

      controller.th2FileFocusNode.requestFocus();
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  /// Whether [controller]'s file is the active tab's.
  bool _isActiveTab(TH2FileEditController controller) {
    final MPGeneralController generalController = mpLocator.mpGeneralController;
    final List<String> openFileOrder = generalController.openFileOrder;
    final int activeTabIndex = generalController.activeTabIndex;

    return (activeTabIndex >= 0) &&
        (activeTabIndex < openFileOrder.length) &&
        (openFileOrder[activeTabIndex] == controller.filename);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.controller.th2FileFocusNode,
      child: widget.child,
    );
  }
}
