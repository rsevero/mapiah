#!/usr/bin/env bash
# Starts a task: creates its branch and worktree from the current main and
# runs flutter pub get in it. See AGENTS.md, "Parallel Work".
set -euo pipefail

BRANCH="${1:?Usage: task_start.sh <type>_<issue>_<slug> | <type>_<slug>}"

if [[ ! "${BRANCH}" =~ ^(feat|fix|docs|refactor|test)_[a-z0-9_]+$ ]]; then
  echo "Invalid branch name '${BRANCH}'. Expected <type>_<issue>_<slug> or <type>_<slug>, type one of feat, fix, docs, refactor, test." >&2
  exit 1
fi

MAIN_CHECKOUT="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
WORKTREE="$(dirname "${MAIN_CHECKOUT}")/mapiah-worktrees/${BRANCH}"

if [[ -n "$(git -C "${MAIN_CHECKOUT}" branch --list "${BRANCH}")" ]]; then
  echo "Branch '${BRANCH}' already exists." >&2
  exit 1
fi

git -C "${MAIN_CHECKOUT}" worktree add -b "${BRANCH}" "${WORKTREE}" main

(cd "${WORKTREE}" && flutter pub get)

echo "Worktree ready: ${WORKTREE}"
