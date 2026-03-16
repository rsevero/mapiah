<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->

# Pre-Commit Hook Documentation

## Overview

The pre-commit hook (`auxiliary/git-hooks/pre-commit`) automatically processes Dart and Markdown files before commits. It ensures consistency in file formatting and licensing headers across the repository.

## Installation

### Automatic Installation

The hook is already configured in the repository. Git should automatically detect and use it.

### Manual Installation (if needed)

```bash
# Navigate to the repository root
cd /devel/mapiah

# Copy the hook to Git's hooks directory
cp auxiliary/git-hooks/pre-commit .git/hooks/pre-commit

# Make it executable
chmod +x .git/hooks/pre-commit
```

### Verify Installation

```bash
# Check if the hook is installed
ls -l .git/hooks/pre-commit

# Should show: -rwxr--r-- ... pre-commit
```

## What It Does

The pre-commit hook automatically performs the following steps **in order**:

### 1. Add SPDX License Headers to Dart Files

**What**: Adds SPDX identifier and copyright headers to any Dart files (`.dart`) being committed

**Format**:
```dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
```

**Special Handling**: For executable scripts with a shebang (`#!/...`), the shebang remains on line 1, and the headers are added after it.

**Skips**: Files that already have an SPDX identifier

### 2. Add SPDX License Headers to Markdown Files

**What**: Adds SPDX identifier and copyright headers to any Markdown files (`.md`) being committed

**Format**:
```html
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
```

**Skips**: Files that already have an SPDX identifier

### 3. Format Dart Code

**What**: Runs `dart format` on all modified Dart files

**Effect**:
- Applies consistent indentation, spacing, and line wrapping
- Fixes common formatting issues
- Ensures compliance with Dart style guide

### 4. Re-stage Modified Files

**What**: Automatically stages all modified files after formatting

**Effect**: Headers and formatting changes are included in your commit without manual re-staging

## Usage

Simply commit as normal:

```bash
git add file.dart
git commit -m "Fix: something"
```

The hook runs automatically. You'll see output like:

```
Added SPDX headers to: lib/src/new_file.dart
```

## Error Handling

The hook uses `set -e`, which means it **stops and fails** if any step errors:

- If adding headers fails, the commit stops
- If `dart format` fails, the commit stops
- **The commit is NOT created** until all steps succeed

### Common Issues

**Issue**: Commit fails with formatting errors
- **Solution**: Fix the formatting issues that `dart format` reports and try again

**Issue**: Permission denied on hook
- **Solution**: Make it executable: `chmod +x .git/hooks/pre-commit`

**Issue**: Hook not running
- **Solution**: Verify installation with `ls -l .git/hooks/pre-commit`

## Disabling the Hook (Not Recommended)

If you need to commit without the hook for testing purposes:

```bash
git commit --no-verify
```

**Note**: Using `--no-verify` skips all git hooks. Files without proper headers will be committed.

## Files Affected

The hook processes only:
- Staged Dart files (`.dart`)
- Staged Markdown files (`.md`)
- Files with status: Added (A), Copied (C), or Modified (M)

## Examples

### Example 1: New Dart File

**Before hook**:
```dart
import 'package:flutter/material.dart';

void main() {
  print('Hello');
}
```

**After hook** (automatically):
```dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'package:flutter/material.dart';

void main() {
  print('Hello');
}
```

### Example 2: Script with Shebang

**Before hook**:
```dart
#!/usr/bin/env dart
import 'dart:io';

void main() {
  print('Running script');
}
```

**After hook** (automatically):
```dart
#!/usr/bin/env dart
// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2023- Mapiah Ltda
import 'dart:io';

void main() {
  print('Running script');
}
```

### Example 3: Markdown File

**Before hook**:
```markdown
# My Documentation

This is a documentation file.
```

**After hook** (automatically):
```markdown
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# My Documentation

This is a documentation file.
```

## Notes

- The hook runs automatically before **every commit**
- Headers are only added to staged files (not to unstaged files)
- If a file already has an SPDX header, the hook skips it (no duplicates)
- The hook is very fast for most commits
- Output is logged to console so you can see what it's doing
