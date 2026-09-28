#!/usr/bin/env bash
# Finishes a task after its commit: rebases its branch on main, runs
# flutter analyze and flutter test again when the rebase brought in new
# commits, fast-forwards main and removes the worktree and branch.
# See AGENTS.md, "Parallel Work", "Finishing (ccm)".
#
# Stops on any rebase conflict, leaving the rebase in progress. Resolve it
# (see AGENTS.md), run `git rebase --continue` and run this script again.
set -euo pipefail

BRANCH="${1:?Usage: task_finish.sh <branch>}"

MAIN_CHECKOUT="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
WORKTREE="$(dirname "${MAIN_CHECKOUT}")/mapiah-worktrees/${BRANCH}"

if [[ ! -d "${WORKTREE}" ]]; then
  echo "Worktree '${WORKTREE}' not found." >&2
  exit 1
fi

if [[ -n "$(git -C "${WORKTREE}" status --porcelain)" ]]; then
  echo "Worktree '${WORKTREE}' has uncommitted changes or a rebase in progress:" >&2
  git -C "${WORKTREE}" status --short >&2
  exit 1
fi

MAIN_TIP="$(git -C "${MAIN_CHECKOUT}" rev-parse main)"
BASE="$(git -C "${WORKTREE}" merge-base HEAD main)"

# Marks that the rebase brought in new commits, so flutter analyze and
# flutter test still run when this script is run again after a rebase
# conflict or a failed check.
NEEDS_CHECKS="$(git -C "${WORKTREE}" rev-parse --path-format=absolute --git-dir)/task_finish_needs_checks"

if [[ "${BASE}" != "${MAIN_TIP}" ]]; then
  touch "${NEEDS_CHECKS}"
  echo "== Rebase ${BRANCH} on main =="
  if ! git -C "${WORKTREE}" rebase main; then
    echo "Rebase stopped on a conflict. Resolve it (see AGENTS.md), run 'git rebase --continue' in ${WORKTREE} and run this script again." >&2
    exit 1
  fi
fi

if [[ -e "${NEEDS_CHECKS}" ]]; then
  echo "== flutter analyze =="
  (cd "${WORKTREE}" && flutter analyze)

  echo "== flutter test =="
  (cd "${WORKTREE}" && flutter test)

  rm "${NEEDS_CHECKS}"
fi

echo "== Fast-forward main =="
if ! git -C "${MAIN_CHECKOUT}" merge --ff-only "${BRANCH}"; then
  echo "Fast-forward failed. If main moved, run this script again. If the main checkout has uncommitted changes in the way, ask the user." >&2
  exit 1
fi

echo "== Remove worktree and branch =="
git -C "${MAIN_CHECKOUT}" worktree remove "${WORKTREE}"
git -C "${MAIN_CHECKOUT}" branch -d "${BRANCH}"

echo "Done: ${BRANCH} merged into main."
