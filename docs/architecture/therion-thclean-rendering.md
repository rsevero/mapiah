# Therion `thclean` rendering decision

Therion's `thclean` masks drawing that already exists under a symbol. Flutter's
`BlendMode.clear` was considered, but it only subtracts reliably from the
current `saveLayer`; after that layer is composited, it reveals the previously
painted canvas instead of masking it. `Canvas.clipPath` only limits later draw
operations and cannot erase existing pixels.

Mapiah will therefore implement `thclean` by filling the cleaning path with the
active map background color through `MPThClean.drawPath`. This matches
Therion's opaque hole-punching semantics and works on canvases with or without
an existing layer. Callers must pass the actual map background color rather
than assume white. A local `saveLayer` plus `BlendMode.clear` remains suitable
only when a future symbol needs to subtract from other paths in that same
isolated symbol layer.
