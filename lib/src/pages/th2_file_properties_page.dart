// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda

import 'package:flutter/material.dart';
import 'package:mapiah/main.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/controllers/th2_file_properties_controller.dart';
import 'package:mapiah/src/generated/i18n/app_localizations.dart';

class TH2FilePropertiesPage extends StatefulWidget {
  final TH2FileEditController th2FileEditController;

  const TH2FilePropertiesPage({required this.th2FileEditController, super.key});

  @override
  State<TH2FilePropertiesPage> createState() => _TH2FilePropertiesPageState();
}

class _TH2FilePropertiesPageState extends State<TH2FilePropertiesPage> {
  late final TH2FilePropertiesController _propertiesController;
  late String _selectedEncoding;

  @override
  void initState() {
    super.initState();
    _propertiesController = widget.th2FileEditController.propertiesController;
    _selectedEncoding = _propertiesController.encoding;
  }

  void _save() {
    _propertiesController.setEncoding(_selectedEncoding);
    Navigator.of(context).pop();
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = mpLocator.appLocalizations;
    final List<String> availableEncodings = mpLocator.mpGeneralController
        .getAvailableEncodings();

    if (!availableEncodings.contains(_selectedEncoding)) {
      availableEncodings.add(_selectedEncoding);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.th2FilePropertiesPageTitle),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.th2FilePropertiesPageEncodingLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              initialValue: _selectedEncoding,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                helperText:
                    appLocalizations.th2FilePropertiesPageEncodingDescription,
                helperMaxLines: 5,
              ),
              items: availableEncodings
                  .map(
                    (String enc) =>
                        DropdownMenuItem<String>(value: enc, child: Text(enc)),
                  )
                  .toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedEncoding = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _save,
                  child: Text(appLocalizations.mpButtonSaveAndClose),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _cancel,
                  child: Text(appLocalizations.th2FilePropertiesPageClose),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
