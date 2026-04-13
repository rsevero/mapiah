<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Raster Line Tracing in Mapiah — Design Plan

## Goal

Add raster line tracing to Mapiah in a way that:

- works well for different raster image styles,
- keeps the UI responsive,
- fits the existing add-line flow,
- and does not hard-code a single tracing algorithm.

This plan deliberately does **not** assume the current tracing heuristic is the final design.

## Core Decision

Make tracing **pluggable**.

Tracing should be implemented as a strategy layer behind the existing line-trace controller, so Mapiah can support different algorithms over time without rewriting the UI or the line-creation flow.

## Undo/Redo Decision

Use **option 2**:

- append traced nodes through the existing interactive line-creation flow,
- do not introduce a separate batching command for tracing output.

This keeps tracing behavior consistent with manual line drawing and reduces the number of special cases in undo/redo handling.

## Proposed Architecture

### 1. Keep `TH2FileEditLineTraceController` as the session controller

The controller should own:

- trace start / stop / toggle behavior,
- availability checks,
- active trace session state,
- UI-facing notifiers,
- and the bridge into line creation.

It should not contain the tracing algorithm itself.

### 2. Introduce tracing strategies

Add a small interface for trace algorithms, for example:

- `LineTraceStrategy`
- `TraceInput`
- `TraceStepResult`
- `TraceSession`

The controller selects a strategy, then delegates each trace step to it.

### 3. Add shared raster preprocessing

Create a reusable preprocessing layer for:

- image decoding,
- pixel sampling,
- threshold maps,
- edge maps,
- skeleton graphs,
- and cost maps.

This layer should be shared by all strategies.

## Recommended Strategy Set

### Strategy A: Local color-guided tracing

This is the closest to the current user-visible behavior.

Use it as the default strategy when:

- the image is a colored raster,
- the image is moderately clean,
- or the user wants an interactive “continue tracing” workflow.

Strengths:

- easy to understand,
- fast to prototype,
- works well as a fallback strategy.

### Strategy B: Cost-map pathfinding

Build a per-pixel cost map and use a path search algorithm such as A* or Dijkstra.

Use it when:

- the image has gaps or noise,
- a local heuristic becomes unstable,
- or the line should follow a broader route through the image.

Strengths:

- more globally stable than local sampling,
- less sensitive to small artifacts.

### Strategy C: Skeleton-based tracing

Threshold the image, thin it to a skeleton, then trace the resulting graph.

Use it when:

- the raster is mostly monochrome,
- the line width is thick or uneven,
- or the user wants a clean centerline from a scan.

Strengths:

- produces editable centerline geometry,
- good for line art and scanned sketches.

### Strategy D: Hybrid manual + snap tracing

Let the user place nodes manually while Mapiah snaps each new point to a nearby inferred raster path.

Use it when:

- the image is difficult,
- automatic tracing is uncertain,
- or the user prefers stronger control.

Strengths:

- predictable,
- low surprise,
- good fallback mode.

## Strategy Selection

Tracing strategy selection should be runtime-pluggable.

The resolver can choose based on:

- image format,
- image contrast,
- estimated line thickness,
- user preference,
- and previous trace failures.

Recommended behavior:

- prefer local color-guided tracing for colored or sketch-like images,
- prefer skeleton tracing for clean monochrome scans,
- fall back to cost-map pathfinding when local stepping fails,
- keep hybrid snapping available as a user-controlled mode.

## Data Flow

1. User enters add-line mode.
2. Mapiah checks whether tracing is available.
3. User starts tracing from a valid seed line.
4. The controller builds a trace session.
5. The resolver picks the best strategy.
6. The strategy preprocesses the image if needed.
7. The strategy returns the next point.
8. The controller appends that point through the existing interactive line-creation flow.
9. The canvas follows the trace.
10. Tracing stops on failure, user cancel, or auto-close near the start point.

## Interaction With Existing Mapiah Flow

### Add-line state

The add-line state should keep its current responsibility:

- enable tracing on entry,
- stop tracing on exit,
- and keep the trace UI consistent with line creation.

### Line creation

Tracing should reuse:

- `TH2FileEditAreaLineCreationController`,
- the current node insertion behavior,
- and the existing line-finalization flow.

This keeps tracing aligned with manual drawing.

### Undo/redo

Because traced points are appended through the interactive line-creation flow:

- undo remains consistent with normal node insertion,
- no new batch-commit command is needed,
- and trace-generated nodes behave like user-created nodes.

## Suggested File Map

### New files

- `lib/src/controllers/th2_file_edit_line_trace_strategy.dart`
- `lib/src/controllers/th2_file_edit_line_trace_session.dart`
- `lib/src/controllers/th2_file_edit_line_trace_context.dart`
- `lib/src/controllers/th2_file_edit_line_trace_strategy_registry.dart`
- `lib/src/controllers/th2_file_edit_trace_image_preprocessor.dart`

### Modify existing files

- `lib/src/controllers/th2_file_edit_line_trace_controller.dart`
- `lib/src/state_machine/mp_th2_file_edit_state_machine/mp_th2_file_edit_state_add_line.dart`
- `lib/src/widgets/th2_file_edit_state_context_fabs/add_element_panel.dart`
- `lib/src/controllers/th2_file_edit_area_line_creation_controller.dart`

### Likely future test files

- `test/` coverage for strategy selection
- `test/` coverage for trace start/stop behavior
- `test/` coverage for fallback behavior
- `test/` coverage for raster preprocessing

## Implementation Phases

### Phase 1: Extract the strategy boundary

- Keep the current behavior as the first `LineTraceStrategy` implementation.
- Move algorithm details behind the new interface.
- Preserve the existing UI and keybinding flow.

### Phase 2: Add shared preprocessing

- Add decoded-image caching.
- Add reusable pixel sampling.
- Move expensive work out of the per-step path.

### Phase 3: Add a second strategy

- Implement cost-map pathfinding or skeleton tracing.
- Add strategy selection rules.
- Keep the original strategy as fallback.

### Phase 4: Tighten failure handling

- Add bounded retry rules.
- Switch to safer strategies when the current one fails repeatedly.
- Keep manual drawing available at all times.

### Phase 5: Improve trace output consistency

- Ensure trace nodes flow through the same interactive creation path as manual nodes.
- Keep undo/redo behavior predictable.

## Notes And Constraints

- Keep UI work on the main thread.
- Push heavy preprocessing off the UI thread when practical.
- Keep each strategy independently testable.
- Favor explicit, bounded search steps over unbounded heuristics.
- Preserve the current add-line user experience while improving the algorithm behind it.

