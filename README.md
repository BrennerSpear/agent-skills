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

- `example-greeting` - A simple example skill
