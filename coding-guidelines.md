<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
<!-- Copyright (C) 2023- Mapiah Ltda -->
# Coding Guidelines

All code (app, scripts, tests) must follow these rules.

## General Guidelines (23 rules)

1. **Explicit types** — All variables must have explicit type definitions. Avoid `var` when type isn't obvious.

2. **Prefer `final`** — Declare variables as `final` whenever possible.

3. **Empty lines** — Put empty line between `final` declarations, and between `final`s and regular code.

4. **Break down complexity** — Avoid complex single-step calculations. Use intermediate variables with descriptive names.

5. **Parenthesize complex conditions** — Wrap multi-element comparisons in parentheses.

6. **No one-liner conditionals** — Always use curly braces `{}` around conditional blocks.

7. **Named parameters preferred** — Allow positional only for ≤2 parameters of different types.

8. **Run `flutter analyze`** — After generating or modifying code.

9. **Update CHANGELOG.md** — For every commit, add entry at end of appropriate section.

10. **Commit signature** — Include `Signed-off-by: Name <email>` (last line) and `Co-Authored-By: AI_MODEL <email>`.

11. **`git add -A` on commit** — Avoid forgetting files.

12. **Don't manually run `build_runner build`** — Watch instance is already running.

13. **Update TODO.md** — Check if any completed items should be marked done.

14. **Keep it linear** — No deep nesting. Code reads top to bottom. One level deep where possible.

15. **Bound every loop** — Explicit, enforced maximum iterations. Define ceiling and fallback behavior.

16. **One function, one job** — ≤60 lines, describable in one sentence without "and". Include docstring.

17. **State assumptions** — Use assertions for preconditions and postconditions.

18. **Never swallow errors** — Every error logged, raised, or explicitly returned.

19. **Narrow your state** — Scope locally, pass dependencies explicitly.

20. **Surface side effects** — I/O, mutations, network calls obvious at call site. Separate pure computation from effects.

21. **One layer of magic** — Prefer linear composition over deep indirection.

22. **Warnings are errors** — Zero compiler warnings. Run analysis on every change.

23. **Tests first** — Write tests before or alongside implementation. Cover edge cases and failure modes.

## App-Specific Rules

- **Localizations**: Use `mpLocator.appLocalizations`. Exception: `MapiahHome` uses `AppLocalizations.of(context)`.
- **No magic numbers**: Define constants in `lib/src/constants/mp_constants.dart`
- **No duplicated code**: Extract reusable logic
- **Separate UI from business logic**: Use MobX controllers
- **All user strings localized**: Via `AppLocalizations` — edit `.arb` files, run `flutter gen-l10n`
- **No all-caps in UI text**
- **Update help pages** (`assets/help/`) for new features (EN + PT, markdown)
- **Update keyboard shortcuts** (`assets/help/`), keep alphabetical order
- **Suggest tests** for new features (numeric prefix, descriptive name, `_test.dart`)
- **URLs**: Prefer `MPURLTextWidget`
- **Don't worry about formatting** — Automatic on commit

## Script-Specific Rules

- Avoid duplicated code
- No all-caps in user-facing text

## Test-Specific Rules

Follow all General Guidelines (no additional rules beyond those).