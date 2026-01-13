# Merge Upstream

Intelligently merge upstream changes (e.g., from Gary) into your current branch, squashing them into a single well-organized commit while resolving conflicts in your favor.

## Usage

Run `/merge-upstream` or `/merge-upstream <upstream-branch>` to merge changes from upstream into your current branch.

If no upstream branch is specified, defaults to `origin/main`.

## Process

This skill uses `merge-upstream.sh` for all deterministic operations and focuses on intelligent analysis and decision-making.

### 1. Execute Initial Setup

```bash
# The script will handle:
# - Validation (git repo, clean working directory, not on main/master)
# - Creating backup branch
# - Fetching upstream
# - Finding merge base
# - Exporting commit list to /tmp/merge-upstream-commits.txt

# Get skill directory
SKILL_DIR="$HOME/repos/claude-code-skills/merge-upstream"
UPSTREAM="${1:-origin/main}"

# First, run script to export commit data (will fail waiting for commit message, that's expected)
"$SKILL_DIR/merge-upstream.sh" "$UPSTREAM" || true
```

### 2. Analyze Commits and Generate Message

Read the exported commit list from `/tmp/merge-upstream-commits.txt` and analyze:

- **Identify reverts**: Look for commits with "Revert" in message
- **Find canceling pairs**: Commits that undo each other (e.g., "Add X" followed by "Remove X")
- **Categorize changes**: Group into features, fixes, refactors, chores, etc.
- **Extract key changes**: Dependencies, breaking changes, bug fixes

Generate an intelligent commit message that:
- Has a clear, concise title (50 chars or less)
- Summarizes meaningful changes in bullet points
- Omits reverted/canceled commits
- Groups related changes
- Uses conventional commit format

Example format:
```
feat: merge upstream changes from Gary

- Add new terminal status tracking system
- Improve error handling in session manager
- Refactor configuration parsing
- Update dependencies (react@18.3.0, vite@5.1.0)
- Fix race condition in cleanup handler

Technical notes:
- Removed experimental feature X (was unstable)
- Breaking: Changed SessionConfig interface
```

Write this message to `/tmp/merge-upstream-msg.txt`.

### 3. Execute Merge

```bash
# Now run the script with the commit message
if "$SKILL_DIR/merge-upstream.sh" "$UPSTREAM" "/tmp/merge-upstream-msg.txt"; then
  echo "✓ Merge completed successfully!"
  exit 0
elif [ $? -eq 2 ]; then
  echo "⚠ Conflicts detected - analyzing..."
  # Continue to conflict resolution
else
  echo "✗ Merge failed"
  exit 1
fi
```

### 4. Intelligent Conflict Resolution

When conflicts occur (script exits with code 2), conflict details are exported to `/tmp/merge-upstream-conflicts/`:

- `file-list.txt` - List of conflicted files
- `<filename>.ours` - Your version
- `<filename>.theirs` - Upstream version

For each conflicted file:

1. **Read both versions**
2. **Analyze the differences**:
   - If changes are in different sections → merge both
   - If changes overlap → prefer ours (current branch) unless theirs is clearly better

3. **"Clearly better" means**:
   - Fixes a bug that ours doesn't
   - Adds error handling or type safety
   - Uses more recent API or best practices
   - Includes tests or documentation
   - Removes security vulnerability

4. **Apply resolution**:

```bash
# For files where we want ours:
git checkout --ours <file>
git add <file>

# For files where we want theirs:
git checkout --theirs <file>
git add <file>

# For complex merges, read both versions and create merged version:
# Read ours: /tmp/merge-upstream-conflicts/<file>.ours
# Read theirs: /tmp/merge-upstream-conflicts/<file>.theirs
# Write merged version to <file>
git add <file>
```

5. **Ask user for confirmation on ambiguous cases**

### 5. Complete Merge

After resolving all conflicts:

```bash
# Complete the merge
git commit --no-edit

# Run quality checks and cleanup
"$SKILL_DIR/merge-upstream.sh" "$UPSTREAM" "/tmp/merge-upstream-msg.txt" "post-merge"
```

The script will:
- Run typecheck (if configured)
- Run linting (if configured)
- Run tests (if configured)
- Delete temporary and backup branches
- Show merge summary

### 6. Cleanup Temp Files

```bash
rm -f /tmp/merge-upstream-msg.txt
rm -f /tmp/merge-upstream-commits.txt
rm -rf /tmp/merge-upstream-conflicts
```

## Conflict Resolution Guidelines

Default preference order:
1. **Ours (current branch)** - the default choice
2. **Theirs (upstream)** - only if clearly better
3. **Manual merge** - when both have valuable changes
4. **Ask user** - when uncertain

## Script Exit Codes

- `0` - Success (no conflicts or merge completed)
- `1` - Error (validation failed, merge failed)
- `2` - Conflicts detected (need resolution)

## Safety Features

The script automatically:
- Validates clean working directory
- Prevents merging into main/master
- Creates backup branch before starting
- Exports all data needed for intelligent analysis
- Provides clear recovery steps

## Recovery

If something goes wrong:

```bash
# Abort the merge
git merge --abort

# Restore from backup
git checkout backup-<branch>-<timestamp>

# Delete backup when confirmed working
git branch -D backup-<branch>-<timestamp>
```

## Example Session

```bash
# User runs the skill
/merge-upstream origin/main

# Skill executes:
# 1. Runs script to export commits
# 2. Analyzes 15 commits, finds 2 reverts, groups into 8 meaningful changes
# 3. Generates commit message
# 4. Runs script to merge
# 5. Detects 3 conflicts
# 6. Analyzes conflicts:
#    - src/config.ts: Both added different options → merge both
#    - src/server.ts: Ours has old API, theirs has new API → use theirs
#    - README.md: Different wording → prefer ours
# 7. Resolves conflicts
# 8. Completes merge
# 9. Runs tests (pass)
# 10. Shows summary
```

## Files

- `merge-upstream.sh` - Deterministic bash script
- `merge-upstream.md` - This skill file
