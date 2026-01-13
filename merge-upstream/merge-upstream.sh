#!/bin/bash

# merge-upstream.sh
# Deterministic script for merging upstream changes with intelligent squashing
# Called by the /merge-upstream skill

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
UPSTREAM="${1:-origin/main}"
COMMIT_MSG_FILE="${2:-/tmp/merge-upstream-msg.txt}"
CONFLICT_STRATEGY="${3:-prefer-ours}"

# Helper functions
error() {
  echo -e "${RED}✗ $1${NC}" >&2
  exit 1
}

success() {
  echo -e "${GREEN}✓ $1${NC}"
}

warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

info() {
  echo "$1"
}

# Validate we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  error "Not in a git repository"
fi

# Validate working directory is clean
if [[ -n $(git status --porcelain) ]]; then
  error "Working directory is not clean. Commit or stash your changes first."
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
if [[ -z "$CURRENT_BRANCH" ]]; then
  error "Not on a branch (detached HEAD)"
fi

# Validate not on main/master
if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
  error "Cannot merge upstream into main/master branch. Create a feature branch first."
fi

info "Current branch: $CURRENT_BRANCH"
info "Upstream: $UPSTREAM"

# Create backup branch
BACKUP_BRANCH="backup-${CURRENT_BRANCH}-$(date +%Y%m%d-%H%M%S)"
git branch "$BACKUP_BRANCH"
success "Created backup branch: $BACKUP_BRANCH"

# Fetch latest changes
info "Fetching latest changes..."
git fetch origin

# Validate upstream exists
if ! git rev-parse "$UPSTREAM" > /dev/null 2>&1; then
  error "Upstream branch '$UPSTREAM' does not exist"
fi

# Find merge base
MERGE_BASE=$(git merge-base HEAD "$UPSTREAM")
info "Merge base: ${MERGE_BASE:0:8}"

# Count commits from upstream
UPSTREAM_COMMITS=$(git rev-list --count "$MERGE_BASE..$UPSTREAM")
if [[ "$UPSTREAM_COMMITS" -eq 0 ]]; then
  success "Already up to date with upstream"
  git branch -D "$BACKUP_BRANCH"
  exit 0
fi

info "Upstream has $UPSTREAM_COMMITS new commits"

# Export commit list for skill to analyze
COMMIT_LIST_FILE="/tmp/merge-upstream-commits.txt"
git log --format="%H%x00%s%x00%b%x00" "$MERGE_BASE..$UPSTREAM" > "$COMMIT_LIST_FILE"
info "Commit list exported to: $COMMIT_LIST_FILE"

# Check if commit message file exists (created by skill)
if [[ ! -f "$COMMIT_MSG_FILE" ]]; then
  error "Commit message file not found: $COMMIT_MSG_FILE"
fi

# Create temporary branch at upstream
TEMP_BRANCH="temp-merge-upstream-$$"
git branch "$TEMP_BRANCH" "$UPSTREAM"
git checkout "$TEMP_BRANCH"
success "Created temporary branch: $TEMP_BRANCH"

# Squash all commits into one
info "Squashing $UPSTREAM_COMMITS commits..."
git reset --soft "$MERGE_BASE"
git commit -F "$COMMIT_MSG_FILE"
success "Squashed commits with custom message"

# Return to original branch
git checkout "$CURRENT_BRANCH"

# Attempt merge
info "Attempting merge..."
if git merge "$TEMP_BRANCH" --no-ff --no-edit; then
  success "Merge completed successfully with no conflicts"
  CONFLICTS=0
else
  warning "Conflicts detected"
  CONFLICTS=1
fi

# Export conflict information if any
if [[ $CONFLICTS -eq 1 ]]; then
  CONFLICT_FILES=$(git diff --name-only --diff-filter=U)
  CONFLICT_COUNT=$(echo "$CONFLICT_FILES" | wc -l | tr -d ' ')
  warning "Found $CONFLICT_COUNT conflicted files:"
  echo "$CONFLICT_FILES" | while read -r file; do
    echo "  - $file"
  done

  # Export conflict details for skill to analyze
  CONFLICT_DIR="/tmp/merge-upstream-conflicts"
  rm -rf "$CONFLICT_DIR"
  mkdir -p "$CONFLICT_DIR"

  echo "$CONFLICT_FILES" | while read -r file; do
    # Save both versions
    git show :2:"$file" > "$CONFLICT_DIR/$(basename "$file").ours" 2>/dev/null || true
    git show :3:"$file" > "$CONFLICT_DIR/$(basename "$file").theirs" 2>/dev/null || true
    echo "$file" >> "$CONFLICT_DIR/file-list.txt"
  done

  info "Conflict details exported to: $CONFLICT_DIR"
  info "Skill will now analyze and resolve conflicts..."

  # Exit with special code to signal conflicts need resolution
  exit 2
fi

# Run quality checks
info "Running quality checks..."

# Type checking
if [[ -f "package.json" ]] && grep -q "typecheck" package.json; then
  if bun run typecheck > /dev/null 2>&1; then
    success "Type checking passed"
  else
    warning "Type checking failed - review required"
  fi
fi

# Linting
if [[ -f "package.json" ]] && grep -q "lint" package.json; then
  if bun run lint > /dev/null 2>&1; then
    success "Linting passed"
  else
    warning "Linting issues detected"
  fi
fi

# Tests
if [[ -f "package.json" ]] && grep -q "\"test\"" package.json; then
  if bun test > /dev/null 2>&1; then
    success "Tests passed"
  else
    warning "Tests failed - review changes"
  fi
fi

# Cleanup
git branch -D "$TEMP_BRANCH"
git branch -D "$BACKUP_BRANCH"
success "Cleanup complete"

# Show summary
info ""
info "═══════════════════════════════════════"
success "Merge completed successfully!"
info "═══════════════════════════════════════"
git log -1 --stat

exit 0
