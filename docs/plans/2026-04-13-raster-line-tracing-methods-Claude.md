<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Raster Line Tracing — Methods Survey

A survey of candidate algorithms for tracing lines from raster images in Mapiah, independent of the current implementation.

---

## Method 1: Greedy Arc Sampling (Current Approach)

Sample pixel colors along a circular arc centered ahead of the current direction. Select the centroid of the longest consecutive run of pixels matching the target color.

**Best for**: Clean, uniform-color lines on low-noise images.

**Weaknesses**:
- Drifts on noisy or low-contrast images
- Cannot recover from crossings or gaps
- Locally greedy: no global awareness of the line path

---

## Method 2: A\* Pathfinding on a Cost Map

Pre-process the image region into a per-pixel cost map (low cost where pixels match the target color or have high gradient magnitude). Run A\* between user-placed anchor points to find the globally optimal path.

**User interaction**: User places two or more waypoints; the algorithm finds the least-cost path between each consecutive pair.

**Pros**:
- Globally optimal within the cost map — avoids local traps
- Handles gaps, noise, and crossings naturally
- Natural fit for cave maps: user traces passage-by-passage with waypoints
- Reuses existing coordinate-transform and image-decoding infrastructure

**Cons**:
- Requires building a cost map (can be done lazily per region)
- Memory: cost map for a large image can be large
- Needs a good cost function (gradient magnitude, color distance, or a combination)

**Implementation sketch**:
1. User clicks a start anchor; Mapiah decodes the raster and builds a cost map (uint8 per pixel)
2. User clicks an end anchor → A\* finds the path → preview as polyline or Bézier spline
3. User confirms or repositions anchors

---

## Method 3: Intelligent Scissors (Livewire / Mortensen-Barrett)

A real-time variant of A\*. When the user moves the cursor, the shortest path from the last confirmed anchor to the cursor is recomputed and shown instantly as an overlay. The line visually "snaps" to high-contrast edges.

**User interaction**: Place an anchor, move the cursor near the line, watch the path snap to it, click to confirm.

**Pros**:
- Extremely fast to use in practice — skilled users can trace a complex passage in seconds
- No explicit algorithm parameter tuning required
- Standard in image editing tools (equivalent to Photoshop's Magnetic Lasso)
- Semantically correct for passage walls: snaps to edges, not just color matches

**Cons**:
- Requires Dijkstra pre-computation from the last anchor on every anchor placement
- More complex UI: cursor feedback, live path overlay, anchor management
- Needs a fast predecessor-map lookup for cursor-move updates

**Implementation sketch**:
1. On anchor placement: run Dijkstra from anchor outward, store best-path predecessor for every pixel within a bounded radius
2. On cursor move: look up path in predecessor map → render as canvas overlay
3. On click: commit path as THLine nodes

---

## Method 4: Skeletonization / Centerline Extraction

Threshold the image region to binary (ink vs. paper), then apply a morphological thinning algorithm (Zhang-Suen or Guo-Hall) to reduce every stroke to a 1-pixel-wide skeleton. Vectorize the skeleton into polylines, then let the user select which branch to keep.

**User interaction**: User draws a bounding box; Mapiah shows the skeleton overlay; user clicks to claim a branch.

**Pros**:
- Geometrically correct: produces the true centerline of thick or variable-width strokes
- Works on thick lines that confuse color-matching approaches
- Clean output can be simplified with Ramer-Douglas-Peucker into efficient Bézier curves

**Cons**:
- Requires a reliable threshold (challenging with uneven paper or scan quality)
- Produces the skeleton of the entire region — user must prune unwanted branches
- Skeleton can break at low-contrast or faint areas

**Implementation sketch**:
1. User draws a bounding box over a passage
2. Mapiah thresholds the region → binary image → thinning algorithm → skeleton graph
3. Skeleton rendered as overlay; user clicks a node to "claim" a connected branch
4. Claimed branch converted to a THLine with simplified nodes

---

## Method 5: Gradient / Edge Following

Instead of matching a target color, follow the edge boundary of a stroke. At each step, advance along the direction that keeps the local gradient magnitude high, turning to stay on the edge rather than crossing through the center.

**User interaction**: Same as the current flow; user picks a start point and direction.

**Pros**:
- Therion passage walls are edges, not centerlines — semantically more accurate
- More robust to variable ink density than center-color tracking
- Gradient computation (Sobel/Scharr) reusable across multiple strategies

**Cons**:
- Direction ambiguity at corners, T-junctions, and crossings
- Still greedy (locally guided), so can still drift
- Requires gradient pre-computation for the image region

---

## Method 6: ML-Based Probability Map + Vectorization

Run a pre-trained model (U-Net style or CRAFT-style line detector) over the image to produce a per-pixel probability map: "is this pixel part of a survey line?" Then apply any of the above vectorization strategies to the probability map instead of the raw image.

**User interaction**: One-time model setup; same tracing UI afterwards.

**Pros**:
- Can distinguish survey lines from text labels, grid lines, shading, and other map elements
- High precision on complex historical maps
- Separation of concerns: perception handled by ML, geometry handled by classical algorithms

**Cons**:
- Requires a trained model and training data
- Flutter has limited ML runtime support on Linux/macOS/Windows without native plugins
- Could run as a Dart isolate via ONNX Runtime or a bundled native library
- High implementation effort; most valuable for scanned historical maps

---

## Comparison

| Method                 | User Interaction     | Thick Lines | Noise Tolerance | Crossings | Effort      |
| ---------------------- | -------------------- | ----------- | --------------- | --------- | ----------- |
| Arc Sampling (current) | Fully automatic      | Poor        | Poor            | Poor      | —           |
| A\* Pathfinding        | Waypoints            | Good        | Good            | Good      | Medium      |
| Intelligent Scissors   | Magnetic cursor      | Good        | Good            | Moderate  | Medium-High |
| Skeletonization        | Region + branch pick | Excellent   | Moderate        | Moderate  | Medium      |
| Gradient Following     | Fully automatic      | Moderate    | Moderate        | Poor      | Low         |
| ML Probability Map     | One-time setup       | Excellent   | Excellent       | Excellent | Very High   |

---

## Recommendation for Mapiah

For a cave mapping tool where accuracy and user control matter:

- **Short term**: Gradient following (Method 5) is a low-effort improvement over arc sampling with no UI changes.
- **Medium term**: A\* pathfinding (Method 2) or Intelligent Scissors (Method 3) give the best usability-to-effort ratio. Both reuse existing coordinate-transform and image-decoding infrastructure.
- **Long term**: Skeletonization (Method 4) for clean monochrome scans; ML pre-processing (Method 6) for complex historical maps.

The pluggable strategy architecture described in `2026-04-13-raster-line-tracing-design.md` provides the right structure to adopt these methods incrementally.
