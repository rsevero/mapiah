// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';
import 'package:mapiah/src/controllers/th2_file_edit_controller.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'This file has structural or parsing errors and cannot be edited or saved in Mapiah.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          for (final TH2FileProblem problem in controller.problems)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Line ${problem.lineNumber}: ${problem.detail}\n${problem.sourceLine.trimRight()}',
              ),
            ),
          if (onReload != null)
            ElevatedButton(onPressed: onReload, child: const Text('Reload')),
        ],
      ),
    );
  }
}
