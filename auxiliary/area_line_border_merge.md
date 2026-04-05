<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
Present a plan to implement closed lines merging.

The lines to be merged can come either from:

1. Areas with more than one THAreaBorderTHID;
2. More than one area selected.

Change the shortcut available on keyboard_shortcut help page from Ctrl+Shift+M to Ctrl+M.

Change the action name to "Merge areas".

The new FAB button for area border merging will be enabled when there are more than one THAreaBorderTHID selected (either because of situation 1 or 2 before).

All lines referenced by THAreaBorderTHIDs from selected areas (LTSA) will be processed during "Merge areas".

All LTSA will be treated as closed lines.

LTSAs can be formed either by straight line segments and Bézier curve line segments. The merging process should be able to handle both types of line segments, and also the combination of them in the same LTSA.

The single final area with all merged lines will have the same options as the first area on the selected elements list. If it already has a THID, use it.

All final merged lines will have the same options as the first line on the list of LTSAs. If it already has a THID, use it.

Steps:

1. Separate the LTSAs in groups of lines that intercept each other. Lines that do not intercept any other line will be treated as individual groups.
2. For each group of LTSAs, if there are more than one LTSA, merge them into a single line. The merging process will be as follows:
   1. For each LTSA: if end point != start point, create a straight line segment from end point to start point.
   2. Get all LTSAs and split them at all crossings. Even internal crossings should result in split, i.e., if a line segment crosses any line segment from the same line or from other selected lines, there should be a split. Even in case the same Bezier curve line segment crossed itself.
   3. Calculate the bounding box for the group of all line segments from all LTSAs.
   4. Look for the line segment with its bounding box corner closest to the bounding box top left corner of the group of all line segments. This line segment will be the starting point for merging. Define closer as the minimum sum of horizontal and vertical distances between the bounding boxes top left corners of the line segment and of the group of all line segments. In case of a tie, choose the first line segment considered in the list of nearer line segments.
   5. Create a bounding path starting from the line segment found in step 4, and following the line segments from all LTSAs in a way that the bounding path is always on the left of the line segments. The bounding path should be closed, i.e., it should end at the other end of the starting line segment. Record if there were any alternative paths available, i.e., if there were any point where the bounding path could be on the left or on the right of the line segments. No line segment should appear more than once on the final merged line. Even in reversed form, it should not appear more than once. If a line segment is shared by 2 line borders, it should be completely removed as its a inner line segment.
   6. Create another bounding path starting from the line segment found in step 4, and following the line segments from all LTSAs in a way that the bounding path is always on the right of the line segments. The bounding path should be closed, i.e., it should end at the other end of the starting line segment. Record if there were any alternative paths available, i.e., if there were any point where the bounding path could be on the left or on the right of the line segments. No line segment should appear more than once on the final merged line. Even in reversed form, it should not appear more than once. If a line segment is shared by 2 line borders, it should be completely removed as its a inner line segment.
   7. Check which of the two bounding paths leaves the least amount of line segments outside of it. This will be the choosen bounding path.
   8.  If there were line segments outside of the choosen bounding path, throw.
   9.  Drop the line segments from all LTSAs that are not part of the bounding path.
   10. Create a single line starting from the starting line segment and following the choosen bounding path. This will be the single line of the merged area.
3.  Create a single area with the single line created for each group of LTSAs. This will be the merged area.


At the end of the "Merge areas" action, there should be only one area with the minimum amount of THAreaBorderTHIDs and all line segments from all LTSAs should be merged into the fewest possible lines.

This single area should replace as selected element all other areas and area border lines previously selected.

Try not to use Offset.distance() whenever possible. Prefer Offset.distanceSquared() instead.

No line segment should appear more than once on the final merged line. Even in reversed form, it should not appear more than once. If a line segment is shared by 2 line borders, it should be completely removed as its a inner line segment.
