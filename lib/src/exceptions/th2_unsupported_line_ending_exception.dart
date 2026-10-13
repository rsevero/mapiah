// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:mapiah/src/exceptions/th_base_exception.dart';

/// Thrown when text that maps lines to elements would contain a lone `\r`,
/// which is not a line ending there.
class TH2UnsupportedLineEndingException extends THBaseException {
  /// The lone `\r`'s offset in the writer output, as it would be with the
  /// offending chunk appended, counting the separator that boundary insertion
  /// would put before it.
  final int offset;

  /// The MPID of the offending chunk's owner.
  final int mpID;

  TH2UnsupportedLineEndingException({required this.offset, required this.mpID})
    : super(
        "Unsupported lone carriage return at offset '$offset' in the text of the element with MPID '$mpID'.",
      );
}
