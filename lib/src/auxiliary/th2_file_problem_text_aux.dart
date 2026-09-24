// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/generated/i18n/app_localizations.dart';
import 'package:mapiah/src/mp_file_read_write/th2_file_problem.dart';

class TH2FileProblemTextAux {
  /// The localized, user-facing category of a broken `.th2` file problem.
  /// It is independent of the parser's `TH2FileProblem.detail`, which stays
  /// available as diagnostic evidence.
  static String userMessage(
    TH2FileProblemKind kind,
    AppLocalizations appLocalizations,
  ) {
    return switch (kind) {
      TH2FileProblemKind.plaOutsideScrap =>
        appLocalizations.th2FileProblemPlaOutsideScrap,
      TH2FileProblemKind.scrapInsideScrap =>
        appLocalizations.th2FileProblemScrapInsideScrap,
      TH2FileProblemKind.strayEndscrap =>
        appLocalizations.th2FileProblemStrayEndscrap,
      TH2FileProblemKind.missingEndline =>
        appLocalizations.th2FileProblemMissingEndline,
      TH2FileProblemKind.missingEndarea =>
        appLocalizations.th2FileProblemMissingEndarea,
      TH2FileProblemKind.missingEndscrap =>
        appLocalizations.th2FileProblemMissingEndscrap,
      TH2FileProblemKind.invalidBorderReference =>
        appLocalizations.th2FileProblemInvalidBorderReference,
      TH2FileProblemKind.parseError =>
        appLocalizations.th2FileProblemParseError,
    };
  }
}
