// Conditional import for context menu suppression
// Only the correct implementation is imported for the current platform.

export 'mp_context_menu_suppression_stub.dart'
    if (dart.library.html) 'mp_context_menu_suppression_web.dart';
