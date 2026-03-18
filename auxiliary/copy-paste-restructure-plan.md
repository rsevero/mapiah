# Plan: Restructure Copy/Paste Architecture to Match Specifications

## Overview

Restructure the Copy/Paste system to follow the new rules where:
- Clipboard is a flat `List<MPCopyElementWithChildren>`
- Each entry carries a `positionAtParent` indicator (using existing constants from mp_constants.dart)
- Children are represented as a `List<MPCopyElementWithChildren>` embedded in the parent

This fixes the core issue: positioning information is now **at the element level**, not on the lists containing them.

---

## Current Architecture Issues

1. **MPCopyElementResult** has two separate lists (addAtEndMinusOneOfParent and addAtEndOfParent)
   - Position context is on the list, not on individual elements
   - This causes children's position information to be lost during materialization

2. **Materialization flattens the structure** in _buildPasteCommands
   - endMinusOneElements and endMinusOneChildren are separated
   - endOfParentElements and endOfParentChildren are separated
   - This breaks the parent-child relationship's positioning

3. **copySelectedElements()** creates complex logic to manage two lists
   - Special handling for border lines requires careful list manipulation

---

## New Architecture

### Data Structure Changes

#### 1. MPCopyElementWithChildren (restructured)

**File:** `lib/src/auxiliary/mp_copy_element_result.dart`

```dart
/// Represents one element in the copy clipboard with its position and children.
class MPCopyElementWithChildren {
  final MPCopyTemplate template;

  /// Position of this element relative to its parent:
  /// Uses existing constants from mp_constants.dart:
  /// - mpAddChildAtEndMinusOneOfParentChildrenList = 0 (main elements, before end marker)
  /// - mpAddChildAtEndOfParentChildrenList = 1 (after main elements)
  final int positionAtParent;

  /// This element's children, recursively structured.
  /// Can be empty if element has no children.
  final List<MPCopyElementWithChildren> childrenResult;

  MPCopyElementWithChildren({
    required this.template,
    required this.positionAtParent,
    required this.childrenResult,
  });

  Map<String, dynamic> toMap() => {
    'template': template.toMap(),
    'positionAtParent': positionAtParent,
    'childrenResult': childrenResult.map((c) => c.toMap()).toList(),
  };

  factory MPCopyElementWithChildren.fromMap(Map<String, dynamic> map) =>
    MPCopyElementWithChildren(
      template: MPCopyTemplate.fromMap(map['template']),
      positionAtParent: map['positionAtParent'] as int,
      childrenResult: (map['childrenResult'] as List)
        .cast<Map<String, dynamic>>()
        .map(MPCopyElementWithChildren.fromMap)
        .toList(),
    );
}
```

#### 2. Remove MPCopyElementResult

- Delete the entire `MPCopyElementResult` class
- Clipboard becomes `List<MPCopyElementWithChildren>`
- Top-level structure is now flat and simple

#### 3. Keep MPMaterialisedResult (mostly unchanged)

Used as output of materialization with live THElements instead of templates.

---

## Copy Phase Logic

The copy phase uses a single unified recursive method `_buildCopyResult()` that processes selected elements and their children, handling special cases for THArea (border lines) and THLine (deduplication).

**Key Rules:**

a) **Initialize in `copySelectedElements()`:**
   - Filter selection to only top elements (THScrap, THPoint, THLine, THArea)
   - Initialize tracking set for copied MPIDs (for deduplication)
   - Initialize result list as `List<MPCopyElementWithChildren>` (flat top level)

b) **For each selected top element:**
   - Call `_buildCopyResult(element, positionAtParent=mpAddChildAtEndMinusOneOfParentChildrenList, trackedMPIDs)`
   - This returns a `List<MPCopyElementWithChildren>` which may include pre-sibling entries (e.g., border lines)
   - Add all returned entries to clipboard list

c) **In `_buildCopyResult()` - unified recursive method:**

   **Input:** `(THElement element, int positionAtParent, Set<int> trackedMPIDs)`

   **Output:** `List<MPCopyElementWithChildren>` (may include pre-sibling entries)

   **Processing steps:**

   - **Handle THArea special case:**
     * Check all children for THAreaBorderTHID
     * For each THAreaBorderTHID found:
       - Extract the referenced border line's MPID from thID
       - If line MPID not in trackedMPIDs:
         * Call `_buildCopyResult(borderLine, positionAtParent=SAME_AS_AREA, trackedMPIDs)`
         * Add returned entries to result list (pre-siblings of area)

   - **Handle THLine special case:**
     * If element.mpID is in trackedMPIDs: return empty list (already copied, skip)
     * Otherwise: mark element.mpID as tracked in trackedMPIDs

   - **Create entry for this element:**
     * Build childrenResult by recursively processing all children:
       - For each child: call `_buildCopyResult(child, positionAtParent=mpAddChildAtEndOfParentChildrenList, trackedMPIDs)`
       - Collect all returned entries into childrenResult list
     * Create MPCopyElementWithChildren with:
       - template = MPCopyTemplate.fromElement(element)
       - positionAtParent = positionAtParent parameter
       - childrenResult = collected child entries
     * Add entry to result list

   - **Return:** result list (includes element + any pre-siblings)

d) **Deduplication:**
   - Track all copied element MPIDs in trackedMPIDs set
   - First occurrence is copied, subsequent duplicates are skipped
   - Order-independent: whichever appears first gets copied

**Output:** `List<MPCopyElementWithChildren>` stored in clipboard (top-level list)

---

## Materialization & Command Building Phase (Intermingled in Single Pass)

**Key Insight:** Materialization and command building are tightly coupled. To create an add command for a main element, we need the actual add element commands of its children to pass as posCommand. Therefore, these phases are done in one recursive pass, not sequentially.

**Key Rules:**

1. Accept `List<MPCopyElementWithChildren>` from clipboard

2. **Determine top-level parents** (first pass):
   - Scrap → parent = `th2File.mpID`
   - Non-scrap top element → parent = `activeScrapMPID`

3. **Single recursive pass:** Method `_materializeAndBuildCommands()` in `MPTHElementPasteAux`

   For each `MPCopyElementWithChildren entry`:

   - Step 1: Allocate new MPID via `mpLocator.mpGeneralController.nextMPIDForElements()`
   - Step 2: Create live element from template with: new MPID, parentMPID, empty originalLineInTH2File
   - Step 3: Check for THID conflicts and generate new THID if needed, cache in `_oldToNewTHIDMap`
   - Step 4: Create new options map if THID was regenerated
   - Step 5: **Recursively process all children:**
     * For each child in entry.childrenResult:
       * Call `_processMaterializeAndBuild()` with new MPID as parentMPID
       * Collect returned child commands
   - Step 6: **Create appropriate add command for this element:**
     * Switch on element type (Scrap, Line, Point, Area, etc.)
     * Pass child commands as posCommand
     * Use `positionAtParent` to determine command position
     * Use new options map if updated in step 4
   - Step 7: Return the add command

4. **Top-level aggregation:**
   - Collect all top-level add commands
   - Wrap in single `MPMultipleElementsCommand`
   - This is the final result, ready to execute

---

## Implementation Roadmap

### Phase 1: Restructure Data Classes

**File:** `lib/src/auxiliary/mp_copy_element_result.dart`

- [ ] Import position constants from mp_constants.dart: `mpAddChildAtEndMinusOneOfParentChildrenList`, `mpAddChildAtEndOfParentChildrenList`
- [ ] Restructure `MPCopyElementWithChildren` with `positionAtParent` field
- [ ] Update serialization methods (toMap/fromMap)
- [ ] Keep `MPMaterialisedResult` as-is
- [ ] Delete `MPCopyElementResult` class
- [ ] Run `flutter analyze` and fix any issues

**Affected imports throughout codebase:**
- [ ] Remove imports of `MPCopyElementResult`
- [ ] Update type signatures where `MPCopyElementResult` was used

### Phase 2: Refactor Copy Phase

**File:** `lib/src/controllers/th2_file_edit_element_edit_controller.dart`

Method `copySelectedElements()`:

- [ ] Filter selection to only top elements (THScrap, THPoint, THLine, THArea)
- [ ] Initialize `Set<int> trackedMPIDs = {}`
- [ ] Initialize `List<MPCopyElementWithChildren> result = []`
- [ ] For each selected top element:
  - [ ] Call `_buildCopyResult(element, mpAddChildAtEndMinusOneOfParentChildrenList, trackedMPIDs)`
  - [ ] Add all returned entries to result
- [ ] Store as `List<MPCopyElementWithChildren>` in clipboard via `mpLocator.mpGeneralController.setClipboard(result)`

Method `_buildCopyResult()` (new unified recursive method):

- [ ] Signature: `List<MPCopyElementWithChildren> _buildCopyResult(THElement element, int positionAtParent, Set<int> trackedMPIDs)`
- [ ] Initialize `List<MPCopyElementWithChildren> result = []`

**Processing:**

- [ ] **Handle THArea special case:**
  - [ ] If element is THArea:
    - [ ] For each childMPID in (element as THIsParentMixin).childrenMPIDs:
      - [ ] Get child via `_th2File.elementByMPID(childMPID)`
      - [ ] If child is THAreaBorderTHID:
        - [ ] Extract borderTHID from child.thID
        - [ ] Get borderLine via `_th2File.elementByTHID(borderTHID)`
        - [ ] If borderLine.mpID not in trackedMPIDs:
          - [ ] Call `_buildCopyResult(borderLine, positionAtParent=positionAtParent, trackedMPIDs)` (SAME position!)
          - [ ] Add all returned entries to result

- [ ] **Handle THLine special case:**
  - [ ] If element is THLine:
    - [ ] If element.mpID in trackedMPIDs: return empty list
    - [ ] Add element.mpID to trackedMPIDs

- [ ] **Create entry for this element:**
  - [ ] `List<MPCopyElementWithChildren> childrenList = []`
  - [ ] If element is THIsParentMixin:
    - [ ] For each childMPID in (element as THIsParentMixin).childrenMPIDs:
      - [ ] Get child via `_th2File.elementByMPID(childMPID)`
      - [ ] Call `_buildCopyResult(child, mpAddChildAtEndOfParentChildrenList, trackedMPIDs)`
      - [ ] Add all returned entries to childrenList
  - [ ] Create `MPCopyElementWithChildren` with:
    - [ ] template = `MPCopyTemplate.fromElement(element)`
    - [ ] positionAtParent = positionAtParent parameter
    - [ ] childrenResult = childrenList
  - [ ] Add entry to result

- [ ] **Return:** result

### Phase 3: Refactor Paste Phase (Materialization & Command Building)

**File:** `lib/src/controllers/th2_file_edit_element_edit_controller.dart`

Method `pasteElements()`:

- [ ] Get `List<MPCopyElementWithChildren>?` from clipboard
- [ ] If null or empty, return early
- [ ] Get activeScrapMPID from `_th2FileEditController.activeScrapID`
- [ ] Create `MPTHElementPasteAux(copyResult: clipboard, th2File: _th2File, activeScrapMPID: activeScrapMPID)`
- [ ] Call `materializeAndBuildCommands()` to get list of top-level add commands
- [ ] If empty, return early
- [ ] Wrap in single `MPMultipleElementsCommand`
- [ ] Execute via `_th2FileEditController.execute(command)`
- [ ] Select only top-level pasted elements (THScrap, THPoint, THLine, THArea)
- [ ] Trigger redraws

**Remove or simplify:**
- [ ] Delete `_buildPasteCommands()` method (logic moves to MPTHElementPasteAux)
- [ ] Delete `_buildElementAddCommand()` method (logic moves to MPTHElementPasteAux)
- [ ] Delete `_buildChildrenResult()` method as it's no longer used

**File:** `lib/src/auxiliary/mp_thelement_paste_aux.dart`

Constructor:

- [ ] Change `copyResult` parameter type from `MPCopyElementResult` to `List<MPCopyElementWithChildren>`
- [ ] Remove `materialise()` method (replaced by `materializeAndBuildCommands()`)

Method `materializeAndBuildCommands()`:

- [ ] Input: top-level `List<MPCopyElementWithChildren>`
- [ ] Initialize `Map<int, int> _oldToNewMPIDMap = {}`
- [ ] Initialize `Map<int, String> _oldToNewTHIDMap = {}`
- [ ] Initialize `List<MPCommand> topLevelCommands = []`
- [ ] For each top-level entry in copyResult:
  - [ ] Determine parent MPID:
    - [ ] If entry.template is THScrap: parentMPID = th2File.mpID
    - [ ] Otherwise: parentMPID = activeScrapMPID
  - [ ] Call `_processMaterializeAndBuild(entry, parentMPID)`
  - [ ] Add returned command to topLevelCommands
- [ ] Return topLevelCommands

Method `_processMaterializeAndBuild()`:

- [ ] Input: `(MPCopyElementWithChildren entry, int parentMPID)`
- [ ] Output: `MPCommand`

**Processing steps:**

- [ ] Step 1: Allocate new MPID
  - [ ] `int newMPID = mpLocator.mpGeneralController.nextMPIDForElements()`

- [ ] Step 2: Create live element from template
  - [ ] `THElement element = THElement.fromMap(entry.template.elementMap)`

- [ ] Step 3: Check THID and update options if needed
  - [ ] If element has THID (for THScrap check its THID property, for all other elements that are THHasOptionsMixin, check if it has a THIDCommandOption.):
    - [ ] Get original THID
    - [ ] Check if exists in th2File via `hasElementByTHID()`
    - [ ] If conflict: generate new THID via `getNewTHID(prefix: '$originalTHID-')`
    - [ ] Cache mapping: `_oldToNewTHIDMap[entry.template.originalMPID ?? 0] = newTHID`
    - [ ] Create new optionsMap with new THID
    - [ ] Update element with copyWith() using new optionsMap
Extra info:
1. Check if element is THHasOptionsMixin
1.1. If its not skip this part.
1.2. If it is, create a nullable optionsMap initialized as null (optionsMapForNewElement which should be used in the elements copyWith) and use mpCommandOptionAux.getTHID() on the element;
1.2.1. If thid is null, skip the rest of this part.
1.2.2. If THID is not null, check if it already exists on current TH2File.
1.2.2.1. If it does exist, 
1.2.2.1.1. Create a new one using the current one as prefix for the new one.
1.2.2.1.2. Create a new THIDCommandOption with the new THID and the current element as parentMPID;
1.2.2.1.3. Get current element optionsMap;
1.2.2.1.4. Substitute the old THIDCommandOption on the optionsMap by the new one and save this new optionsMap on optionsMapForNewElement;
1.2.2.2. Either way (if the current one exists or not on the curernt TH2File) register the current one and the one to be used (the current one or the new one) on a THID cache.
  
- [ ] Step 4: Update elements new copy (using copyWith()) with:
  - [ ] newMPID
  - [ ] parentMPID
  - [ ] empty originalLineInTH2File
  - [ ] empty childrenMPIDs (will be set by commands)
  - [ ] updated optionsMap if THID was regenerated 

- [ ] Step 5: Recursively process children and collect commands
  - [ ] `List<MPCommand> childCommands = []`
  - [ ] For each child in entry.childrenResult:
    - [ ] Call `_processMaterializeAndBuild(child, newMPID)` (use newMPID as parentMPID)
    - [ ] Add returned command to childCommands

- [ ] Step 6: Create appropriate add command
  - [ ] Handle THAreaBorderTHID special case:
    - [ ] If element is THAreaBorderTHID:
      - [ ] Look up new THID in `_oldToNewTHIDMap`
      - [ ] Update element.thID if found
  - [ ] Switch on element type:
    - [ ] **THScrap:** Use `MPAddScrapCommand` with childCommands as posCommand
    - [ ] **THLine:** Use `MPAddLineCommand.forCWJM()` with childCommands as posCommand
    - [ ] **THArea:** Use `MPAddAreaCommand.forCWJM()` with childCommands as posCommand
    - [ ] **THMultiLineComment:** Use `MPAddMultiLineCommentCommand.forCWJM()` with childCommands as posCommand
    - [ ] **THPoint:** Use `MPAddPointCommand.forCWJM()` (no posCommand)
    - [ ] **THLineSegment:** Use `MPAddLineSegmentCommand.forCWJM()` (no posCommand)
    - [ ] **Others:** Use `MPAddElementCommand.forCWJM()` (no posCommand)
  - [ ] All commands should use `elementPositionInParent: entry.positionAtParent`

- [ ] Step 7: Return the add command

### Phase 4: Update Global Clipboard Type

**File:** `lib/src/controllers/mp_general_controller.dart`

- [ ] Change clipboard field type from `MPCopyElementResult?` to `List<MPCopyElementWithChildren>?`
- [ ] Update `setClipboard()` method signature
- [ ] Update `getClipboard()` method signature
- [ ] Update any type checks or handling

### Phase 5: Existing Testing & Validation

- [ ] Run `flutter test test/3156-ui_duplicate_line_ctrl_d_test.dart` - verify segments are in correct position
- [ ] Run `flutter test test/3157-...`
- [ ] Run `flutter test test/3158-ui_duplicate_area_ctrl_d_test.dart` - verify area + border line duplicated correctly
- [ ] Run `flutter test test/3159-...`
- [ ] Run `flutter test` to ensure all tests pass

### Phase 6: New testing & Validation

- [ ] Create new test: Ctrl+C / Ctrl+V in same scrap
- [ ] Create new test: Ctrl+C in one scrap, Ctrl+V in different scrap
- [ ] Create new test: Ctrl+D still works identically
- [ ] Create new test: Undo paste removes all elements atomically
- [ ] Create new test: Cross-file paste (copy in file A, switch to file B tab, paste)
- [ ] Run `flutter test` to ensure all tests pass

### Phase 7: Code Cleanup

- [ ] Run `flutter analyze` and fix any issues
- [ ] Remove any unused imports
- [ ] Check for any remaining references to old MPCopyElementResult

---

## Key Design Points

1. **Position constants from mp_constants.dart:** Reuse existing `mpAddChildAtEndMinusOneOfParentChildrenList` and `mpAddChildAtEndOfParentChildrenList`

2. **All children at endOfParent during copy:** All children use `mpAddChildAtEndOfParentChildrenList` regardless of type

3. **Border line position matches area:** Border line gets SAME position as its parent area, whether top-level or nested

4. **Unified copy method:** Single `_buildCopyResult()` handles both top-level elements and children recursively, with special cases for THArea and THLine

5. **Intermingled materialization & command building:** Single recursive pass in `_processMaterializeAndBuild()`, no separate phases

6. **Position respected throughout:** Each element's positionAtParent is passed to command building

7. **Deduplication:** First occurrence wins, duplicates are skipped

---

## Benefits

1. **Simpler data model:** Position at element level, not list level
2. **Unified copy method:** Clearer logic flow, less code duplication
3. **Correct parent-child structure:** Preserved through recursion
4. **Fixes positioning bug:** Children go to correct positions during paste
5. **Intermingled phases:** Avoids information loss from flattening
6. **Cleaner code:** Less list manipulation, more straightforward recursion

---

## Dependencies & Breaking Changes

- **Data format change:** Clipboard format changes (but it's runtime-only, not persisted)
- **Type changes:** Selection of references to `MPCopyElementResult` need updating throughout
- **Method removals:** `_buildPasteCommands()` and `_buildElementAddCommand()` logic moves to `MPTHElementPasteAux`

---

## Status

Ready for implementation review and approval.
