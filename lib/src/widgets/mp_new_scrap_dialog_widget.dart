import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class MPNewScrapDialogWidget extends StatefulWidget {
  final VoidCallback onPressedClose;
  final String? initialScrapTHID;
  final TH2FileEditController fileEditController;

  const MPNewScrapDialogWidget({
    super.key,
    required this.onPressedClose,
    required this.fileEditController,
    this.initialScrapTHID,
  });

  @override
  State<MPNewScrapDialogWidget> createState() => _MPNewScrapDialogWidgetState();
}

class _MPNewScrapDialogWidgetState extends State<MPNewScrapDialogWidget> {
  late final TextEditingController _idController;
  String? _error;
  bool get _isValid => (_error == null);
  final AppLocalizations _appLocations = mpLocator.appLocalizations;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.initialScrapTHID ?? '');
    _validate();
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _validate() {
    final String text = _idController.text.trim();
    final String? err;

    if (text.isEmpty) {
      err = _appLocations.mpIDMissingErrorMessage;
    } else if (!RegExp(r'^[a-zA-Z0-9_][a-zA-Z0-9_\-]*$').hasMatch(text)) {
      err = _appLocations.mpIDInvalidValueErrorMessage;
    } else if (widget.fileEditController.thFile.hasElementByTHID(text)) {
      err = _appLocations.mpIDNonUniqueValueErrorMessage;
    } else {
      err = null;
    }

    setState(() {
      _error = err;
    });
  }

  void _onCreatePressed() {
    if (!_isValid) {
      return;
    }

    final String newScrapID = _idController.text.trim();

    widget.fileEditController.elementEditController.createScrap(newScrapID);
    widget.onPressedClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Create New Scrap', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        TextField(
          controller: _idController,
          autofocus: true,
          onChanged: (_) => _validate(),
          onSubmitted: (_) {
            if (_isValid) _onCreatePressed();
          },
          decoration: InputDecoration(
            labelText: 'Scrap ID',
            errorText: _error,
            hintText: 'Enter scrap identifier',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: widget.onPressedClose,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _isValid ? _onCreatePressed : null,
              child: const Text('Create'),
            ),
          ],
        ),
      ],
    );
  }
}
