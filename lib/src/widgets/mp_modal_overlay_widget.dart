import 'package:flutter/material.dart';
import 'package:mapiah/src/constants/mp_constants.dart';

typedef MPModalChildBuilder = Widget Function(VoidCallback onPressedClose);

class MPModalOverlayWidget {
  static OverlayEntry show({
    required BuildContext context,
    bool dismissOnBarrierTap = true,
    VoidCallback? onDismissed,
    required MPModalChildBuilder childBuilder,
  }) {
    late OverlayEntry entry;

    void remove() {
      entry.remove();
      onDismissed?.call();
    }

    entry = OverlayEntry(
      opaque: false,
      maintainState: true,
      builder: (ctx) {
        final Size screenSize = MediaQuery.of(ctx).size;
        final double maxDialogHeight =
            screenSize.height - mpOverlayWindowOutsidePadding * 2;

        return Stack(
          children: [
            // Barrier
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: dismissOnBarrierTap ? remove : null,
                child: Semantics(
                  label: 'Modal barrier',
                  container: true,
                  child: AbsorbPointer(
                    absorbing: true,
                    child: const ColoredBox(color: Colors.black54),
                  ),
                ),
              ),
            ),
            // Dialog
            Padding(
              padding: const EdgeInsets.all(mpOverlayWindowOutsidePadding),
              child: Center(
                child: Material(
                  elevation: 12,
                  color: Theme.of(ctx).colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    mpOverlayWindowCornerRadius,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 280),
                    child: IntrinsicWidth(
                      child: IntrinsicHeight(
                        child: FocusScope(
                          autofocus: true,
                          child: Padding(
                            padding: const EdgeInsets.all(
                              mpOverlayWindowPadding,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    maxDialogHeight -
                                    (mpOverlayWindowPadding * 2),
                              ),
                              child: SingleChildScrollView(
                                child: childBuilder(remove),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(entry);

    return entry;
  }
}
