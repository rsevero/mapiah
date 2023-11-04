# Command-like options

Understanding line options described at the Therion Book.

## Line options

These affect the whole line but they can appear both inside line data (among line segments) or at the main line command:

- anchors <on/off> - rope
- border* <on/off> - slope
- clip* <on/off> - all - same as point
- close* <on/**off**/auto> - all
- context <point/line/area> <symbol-type> - all - same as point
- head* <begin/end/both/none> - arrow
- height <value> - pit, wall:pit
- id* <ext_keyword> - all - same as point
- outline* <in/out/none> - all
- place* <bottom/default/top> - all - same as point
- rebelays <on/off> - rope
- reverse* <on/**off**> - all
- scale* - all
- text <string> - label
- visibility* <on/off> - all - same as point

## Line point options

They affect individual line points. Some affect only the next point, others affect all subsequent points.

### Only next point

Affects only the line point defined immediately before (above) the option itself:

- adjust <horizontal/vertical> - all
- altitude <value> - wall
- direction <begin/end/both/**none**/point> - section - if set to 'point', it applies to the last point. For other settings, affects the whole line
- gradient <**none**/center/point> - contour - if set to 'point', it applies to the last point. For other settings, affects the whole line
- l-size <number> - slope
- mark <keyword> - all
- orientation/orient <number> - slope
- size <number> - synonym of l-size
- smooth <on/off/auto> - all -

### All subsequent points

Affects all line points below it:

- subtype <keyword> - u, wall, border, survey, water-flow
