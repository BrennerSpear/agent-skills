# Claude Code Skills

Personal collection of Claude Code skills, synced across machines.

## Usage

Clone and symlink to your Claude skills directory:

```bash
git clone git@github.com:yourusername/ClaudeCodeSkills.git ~/repos/ClaudeCodeSkills
ln -sf ~/repos/ClaudeCodeSkills ~/.claude/skills
```

## Structure

Each skill lives in its own folder with a `SKILL.md` file:

```
skill-name/
├── SKILL.md          # Required - skill definition
└── (optional files)  # Supporting docs, scripts, etc.
```

## Skills

- `process-brain-dump` - Process voice transcripts/brain dumps into structured task JSON
- `execute-brain-dump-tasks` - Execute tasks from processed brain dump (research, memos, specs, todos, orders)
- `check-research` - Poll async research tasks and save completed results
- `create-mcp` - Create a new MCP server from API documentation
