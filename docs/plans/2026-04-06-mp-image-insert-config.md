<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# MPImageInsertConfig — Implementation Plan

## Goal

Introduce a new Mapiah-side image insert configuration model inspired by `THXTherionImageInsertConfig`, but capable of representing:

- XVI images
- Raster images already supported by `THXTherionImageInsertConfig`
- SVG images in a later phase

The initial implementation should cover only XVI and raster images. SVG should be designed for now, but deferred in code.

## Decision

Use a small inheritance hierarchy, not one monolithic class.

Recommended shape:

- `abstract class MPImageInsertConfig`
- `class MPXVIImageInsertConfig extends MPImageInsertConfig`
- `class MPRasterImageInsertConfig extends MPImageInsertConfig`
- Later: `class MPSVGImageInsertConfig extends MPImageInsertConfig`

## Why This Is Better Than One Big Class

All image formats share a common transform payload:

- `isVisible`
- top-left offset
- `xScale`
- `yScale`
- rotation-center offset
- rotation angle

But the format-specific behavior is already meaningfully different:

- XVI has `isGridVisible`
- XVI rendering is vector/grid/station/shot based
- Raster rendering depends on decoded bitmap dimensions
- SVG will likely need its own loader, bounds logic, and possibly intrinsic-size handling

Putting all of that into one class would likely recreate the current `THXTherionImageInsertConfig` pattern, but with more branching and more nullable or format-only fields over time.

A base class plus descendants keeps:

- shared transform/state in one place
- format-specific loading/rendering/bounds in descendants
- SVG addition later much safer
- tests more focused

## Compatibility Goal For `.th2`

Do not use `##XTHERION##` for `MPImageInsertConfig`.

`MPImageInsertConfig` should use its own `##MAPIAH##` command line, fully independent from `THXTherionImageInsertConfig`.

For each image there should be exactly one persisted representation:

- either `THXTherionImageInsertConfig`
- or `MPImageInsertConfig`

Never both for the same image.

## Recommended Persistence Strategy

### `THXTherionImageInsertConfig` remains the insertion default

When an image is inserted, it should initially be written as a normal XTherion image insert:

```text
##XTHERION## xth_me_image_insert {xx vsb igamma} {yy xviRoot} "filename" iidx {imgx xData}
```

This keeps the initial insertion flow maximally compatible with existing tools and with the current code path.

### `MPImageInsertConfig` is the advanced transformed representation

When an image needs `MPImageInsertConfig`-only behavior, Mapiah should replace the XTherion entry with a self-sufficient `##MAPIAH##` line.

Recommended example shape:

```text
##MAPIAH## image_insert_v1 {format=xvi; filename=...; isVisible=true; xx=...; yy=...; xScale=...; yScale=...; rotationCenterDx=...; rotationCenterDy=...; rotationDeg=...; xviRoot=...}
```

The exact encoding format can be refined during implementation, but the line should satisfy these constraints:

- ignored safely by XTherion and other apps as an unknown `##MAPIAH##` line
- fully self-sufficient
- versioned from day one
- independent from runtime `mpID`
- able to represent all persisted image state without requiring an accompanying `THXTherionImageInsertConfig`

## Replacement Rule

`MPImageInsertConfig` does not decorate or augment a `THXTherionImageInsertConfig`.

It substitutes it.

Recommended rule set:

- if a persisted image entry is `##XTHERION## xth_me_image_insert`, load it as `THXTherionImageInsertConfig`
- if a persisted image entry is `##MAPIAH## image_insert_v1`, load it as `MPImageInsertConfig`
- never expect both entries for the same image
- when writing back, preserve whichever representation the runtime object currently uses

## Encoding Recommendation

Prefer a compact structured key-value payload instead of JSON in the line body.

Recommended v1 fields:

- `format`
- `filename`
- `xx`
- `yy`
- `xScale`
- `yScale`
- `rotationCenterDx`
- `rotationCenterDy`
- `rotationDeg`
- `xviRoot`

Do not persist `isGridVisible` nor `isVisible`.

`MPImageInsertConfig` lines must be self-sufficient, so they should persist top-left offset directly.

`rotationCenterDx` and `rotationCenterDy` should be defined in the image's unrotated local coordinate system, measured from the unrotated top-left corner of the image.

## Proposed Domain Model

### Base class

`MPImageInsertConfig` should own the fields common to all image formats:

- `String filename`
- `bool isVisible`
- `THDoublePart xx`
- `THDoublePart yy`
- `THDoublePart xScale`
- `THDoublePart yScale`
- `THDoublePart rotationCenterDx`
- `THDoublePart rotationCenterDy`
- `THDoublePart rotationDeg`

Recommended base responsibilities:

- serialization of common fields to `##MAPIAH## image_insert_v1`
- helpers for transform matrix construction
- common equality, `copyWith`, `toMap`, `fromMap`
- common visibility invalidation and bounding-box clearing hooks

Recommended transform pipeline:

1. Start in unrotated image-local coordinates
2. Apply `xScale` and `yScale`
3. Compute the scaled pivot from `rotationCenterDx` and `rotationCenterDy`
4. Translate by `xx` and `yy`
5. Rotate around the resulting world-space pivot

This means the rotation center is stored in local image space, before rotation, and is scaled together with the image before the final rotation is applied.

### XVI descendant

`MPXVIImageInsertConfig` should add:

- `String xviRoot`
- cached `XVIFile?`
- XVI-specific root correction helpers
- XVI-specific bounding-box calculation

### Raster descendant

`MPRasterImageInsertConfig` should add:

- cached raster image future
- decoded raster image cache
- raster-specific bounding-box calculation using scaled and rotated dimensions

### SVG descendant

Design now, implement later:

- intrinsic-size loading strategy
- vector rendering path
- SVG-specific bounds implementation

No SVG code should block the initial rollout.

## Relationship To `THXTherionImageInsertConfig`

`THXTherionImageInsertConfig` remains part of the system.

Recommended runtime model:

1. Regular image insertion creates `THXTherionImageInsertConfig`
2. SVG insertion creates `MPImageInsertConfig`
3. Existing XTherion image inserts are converted to `MPImageInsertConfig` only when the user enters an `MPImageInsertConfig`-only editing state
4. The first 3 such states should be:
   - scale
   - move
   - rotate
5. The actual implementation of those 3 actions should be deferred to a later phase
6. That conversion replaces the original XTherion image entry instead of augmenting it

This keeps ordinary inserted images compatible by default while still enabling advanced transforms when the user actually needs them.

## Recommended File Map

### New model

- Create `lib/src/elements/mp_image_insert_config.dart`
- Optionally split descendants into:
  - `lib/src/elements/mp_image_insert_config_base.dart`
  - `lib/src/elements/mp_xvi_image_insert_config.dart`
  - `lib/src/elements/mp_raster_image_insert_config.dart`
  - Later: `lib/src/elements/mp_svg_image_insert_config.dart`

### Parser/writer

- Modify `lib/src/mp_file_read_write/th_file_parser.dart`
- Modify `lib/src/mp_file_read_write/th_file_writer.dart`
- Modify `lib/src/mp_file_read_write/th_grammar.dart` to recognize `##MAPIAH##` image insert lines

### Commands/controllers

- Modify `lib/src/commands/factories/mp_command_factory.dart`
- Modify add/remove/edit image insert commands
- Modify the relevant controllers that enumerate or mutate image inserts

### Rendering/UI

- Modify widgets and painters that currently expect `THXTherionImageInsertConfig`
- Likely includes `lib/src/widgets/mp_xvi_image_widget.dart`

### Tests

- Add parser/writer round-trip tests for image insert metadata
- Add model tests for transform defaults and serialization
- Add XVI-specific metadata tests
- Add raster-specific metadata tests
- Add state-machine tests for the new image-operation states

## Implementation Phases

## Phase 1: Data model and metadata codec

- [ ] Create `MPImageInsertConfig` base class and XVI/raster descendants
- [ ] Add common transform fields with defaults:
  - `xScale = 1.0`
  - `yScale = 1.0`
  - `rotationCenterDx = 0.0`
  - `rotationCenterDy = 0.0`
  - `rotationDeg = 0.0`
  - `isVisible = true`
- [ ] Do not add `isGridVisible`
- [ ] Create a codec for `##MAPIAH## image_insert_v1`
- [ ] Add unit tests for serialization/deserialization

## Phase 2: Parser integration

- [ ] Parse `##XTHERION## xth_me_image_insert ...` into `THXTherionImageInsertConfig`
- [ ] Parse `##MAPIAH## image_insert_v1 ...` into `MPImageInsertConfig`
- [ ] Ensure each entry is self-sufficient
- [ ] Add parser tests for:
  - XTherion image insert
  - Mapiah XVI image insert
  - Mapiah raster image insert
  - malformed Mapiah image insert
  - mixed files containing both styles for different images

## Phase 3: Writer integration

- [ ] Write `THXTherionImageInsertConfig` objects as standard XTherion image insert lines
- [ ] Write `MPImageInsertConfig` objects as `##MAPIAH## image_insert_v1` lines
- [ ] Ensure only one persisted entry exists per image
- [ ] `##MAPIAH##`entries should beserialized in the same block as `##XTHERION##`entries so they keep their internal order.
- [ ] Add writer round-trip tests proving that:
  - XTherion image inserts stay XTherion when untouched
  - converted images are saved only as `##MAPIAH##` entries
  - transform data survives save/load
  - mixed files remain readable

## Phase 4: Runtime model preparation

- [ ] Move raster loading and XVI loading logic to descendants
- [ ] Keep the transform-capable runtime model ready for later scale, move, and rotate implementation
- [ ] Keep `isVisible` invalidation behavior
- [ ] Add focused tests for transform-field defaults and runtime preparation

## Phase 5: Command and controller migration

- [ ] Update command factory methods to construct the new image insert classes
- [ ] Update add/remove/edit commands
- [ ] Update selection and visibility toggles
- [ ] Add conversion from `THXTherionImageInsertConfig` to `MPImageInsertConfig` when the user first enters scale, move, or rotate state for that image
- [ ] Ensure the conversion preserves filename, visibility, position, and XVI root semantics
- [ ] Keep undo/redo stable

## Phase 6: State machine preparation

- [ ] Keep existing UI working for XVI and raster
- [ ] Create 3 new image-operation states:
  - `scale`
  - `move`
  - `rotate`
- [ ] Wire the state machine so these states can own future MP-only image operations
- [ ] Do not implement the actual scale, move, or rotate behavior yet
- [ ] Do not block XVI/raster rollout on SVG editing UI

## Phase 7: Later UI and action rollout

- [ ] Implement the actual scale action
- [ ] Implement the actual move action
- [ ] Implement the actual rotate action
- [ ] Expose the new transform properties through the MP-only actions
- [ ] Insert SVG images directly as `MPImageInsertConfig`

## XVI Root

`xviRoot` means the station used as the anchor point for positioning an `.xvi` background image.

An `.xvi` file is a vector background with grid, shots, stations, and LRUD, used for digitizing in the map editor.

### Intended behavior

On save, Mapiah should compute a root description using the anchor station, usually:

- station name
- x offset relative to the XVI grid origin
- y offset relative to the XVI grid origin

Mapiah should not rely only on raw canvas position for persisted XVI registration.

On reload, Mapiah should:

- find that station inside the current `.xvi`
- reconstruct the saved anchor relationship
- shift the background so the station lands back in the saved place

This is especially important when the `.xvi` file is regenerated and its absolute coordinates change, but the station still exists.

Practical meaning:

- `xviRoot` preserves registration of an `.xvi` sketch by tying it to a known survey station
- it should be trusted more than absolute file coordinates when both are available

### Implementation direction

- Persist `xviRoot` as a self-sufficient component of `MPXVIImageInsertConfig`
- Represent it as a root description, not only as a bare station name
- Recommended v1 minimum payload:
  - `rootStationName`
  - `rootOffsetDx`
  - `rootOffsetDy`
- On conversion from `THXTherionImageInsertConfig`, compute this root description from the current loaded XVI and current placement
- On reload, if the named station is found, rebuild placement from the root description
- If the station is missing, fall back gracefully to the persisted absolute placement

## Open Design Choices

### 1. Where should `format` come from?

Choosen answer:

- derive it from the runtime class, not only from filename extension
- still validate extension where useful

This avoids baking behavior into string matching once SVG arrives.

### 2. Should Mapiah metadata include `isVisible`?

Choosen answer:

- yes

Reason:

- `MPImageInsertConfig` lines are self-sufficient
- they should not depend on `THXTherionImageInsertConfig`

### 3. Should metadata include top-left offset?

Choosen answer:

- yes

Reason:

- `MPImageInsertConfig` lines are self-sufficient
- placement must survive without an accompanying XTherion line

### 4. Should metadata be JSON?

Choosen answer:

- avoid JSON in v1 unless escaping proves too painful

Reason:

- a compact key-value payload will be easier to inspect in saved `.th2` files

### 5. Should `isGridVisible` be persisted?

Choosen answer:

- no

Reason:

- you explicitly do not want to persist it
- it is editor-only state and should not define file compatibility
1. Do not implement the actual scale, rotation, and move actions for `MPImageInsertConfig` yet. In this phase, only create the necessary states, methods, and tests, with no UI for those operations yet.
2. For XVI images with XVIRoot, the rotation center will necessarily be the XVI root station position.


## Risks

- Bounding-box math will become more complex once rotation is active
- XVI root handling and rotation may interact in non-obvious ways
- Converting from XTherion entries to Mapiah entries must be undo-safe
- Deferring the actual scale, move, and rotate behavior means the new states must be introduced without regressing current selection flows
- Existing code assumes `THXTherionImageInsertConfig` in several places, so migration should be incremental
- `##MAPIAH##` grammar support will require parser updates beyond the current generic XTherion path

## Risk Mitigation

- Keep phase 1 and 2 narrowly focused on persistence and model shape
- Keep conversion to `MPImageInsertConfig` lazy and action-driven
- Keep the new image-operation states structurally present, but defer their concrete editing behavior to a later phase
- Preserve unknown `##MAPIAH##` lines instead of dropping them
- Delay SVG implementation until XVI and raster paths are stable
- Add round-trip tests before broad refactors

## Test Plan

- Parser test: XTherion image insert loads as `THXTherionImageInsertConfig`
- Parser test: `##MAPIAH## image_insert_v1` XVI entry loads as `MPXVIImageInsertConfig`
- Parser test: `##MAPIAH## image_insert_v1` raster entry loads as `MPRasterImageInsertConfig`
- Writer test: untouched XTherion image stays XTherion
- Writer test: an image already represented as `MPImageInsertConfig` is written back as `##MAPIAH## image_insert_v1`
- Model test: descendant `copyWith`, equality, and `toMap` behave correctly
- State machine test: entering scale creates or activates the dedicated scale state
- State machine test: entering move creates or activates the dedicated move state
- State machine test: entering rotate creates or activates the dedicated rotate state
- Conversion test: entering scale, move, or rotate state converts the XTherion image entry into a Mapiah image entry
- XVI root test: reloaded file reanchors using saved root station and root offsets when the station still exists

## Final Recommendation

Build `MPImageInsertConfig` as an abstract base class with descendants for XVI, raster, and later SVG.

Persist `MPImageInsertConfig` as a self-sufficient `##MAPIAH## image_insert_v1 ...` line, not as an addition to `THXTherionImageInsertConfig`.

Keep XTherion image inserts as the default insertion format for non-SVG images, and convert them lazily into `MPImageInsertConfig` only when the user performs an MP-only transform action such as scale or rotate.

For XVI, persist a root description centered on a named station plus offsets relative to the XVI grid origin, so reloading can reanchor the sketch even after the `.xvi` file is regenerated.
