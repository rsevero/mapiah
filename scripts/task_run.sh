#!/usr/bin/env bash
# Runs, tests or analyzes a task's worktree version of Mapiah, so the user
# can try an agent's work before it is merged. See AGENTS.md, "Parallel Work".
#
# Usage:
#   task_run.sh                                  Lists the task worktrees.
#   task_run.sh <branch> [run|test|analyze] [flutter args...]
#
# The action defaults to run, which starts the desktop app for the current
# platform. Extra arguments go to flutter, e.g.
# `task_run.sh fix_46_xtherion_image_format test test/t3917_th2_file_tabs_page_run_therion_buttons_test.dart`.
set -euo pipefail

MAIN_CHECKOUT="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
WORKTREES_DIR="$(dirname "${MAIN_CHECKOUT}")/mapiah-worktrees"

if [[ $# -eq 0 ]]; then
  git -C "${MAIN_CHECKOUT}" worktree list | grep -F "${WORKTREES_DIR}/" || echo "No task worktrees."
  exit 0
fi

BRANCH="$1"
ACTION="${2:-run}"
shift $(($# < 2 ? $# : 2))

WORKTREE="${WORKTREES_DIR}/${BRANCH}"

if [[ ! -d "${WORKTREE}" ]]; then
  echo "Worktree '${WORKTREE}' not found. Task worktrees:" >&2
  git -C "${MAIN_CHECKOUT}" worktree list | grep -F "${WORKTREES_DIR}/" >&2 || echo "None." >&2
  exit 1
fi

cd "${WORKTREE}"

echo "== ${BRANCH} at $(git log -1 --format='%h %s') =="
if [[ -n "$(git status --porcelain)" ]]; then
  echo "(with uncommitted changes)"
fi

if [[ ! -d .dart_tool ]]; then
  flutter pub get
fi

case "${ACTION}" in
  run)
    case "$(uname -s)" in
      Darwin) DEVICE=macos ;;
      *) DEVICE=linux ;;
    esac
    flutter run -d "${DEVICE}" "$@"
    ;;
  test)
    flutter test "$@"
    ;;
  analyze)
    flutter analyze "$@"
    ;;
  *)
    echo "Unknown action '${ACTION}'. Use run, test or analyze." >&2
    exit 1
    ;;
esac
