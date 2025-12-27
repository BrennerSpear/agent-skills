---
name: execute-brain-dump-tasks
description: Execute tasks from a processed brain dump tasks.json file. Use when user wants to act on extracted brain dump tasks - runs research, generates drafts, compiles order links, and manages todos.
---

# Execute Brain Dump Tasks

## Step 1: Load and Present (in main context)

1. Find tasks.json in ~/repos/brain-dumps/ (most recent or user-specified folder)
2. Present a summary table of tasks grouped by type (show only pending tasks, note any already completed)
3. Ask user which to execute (all, by type, or specific indices)

## Step 2: Spawn Parallel Sub-Agents

For each selected task type, spawn a sub-agent using `Task` tool with `subagent_type: "general-purpose"`. Run all sub-agents in parallel (single message with multiple Task calls).

**Important:** Pass the full path to tasks.json so sub-agents can update task status.

---

### Research Sub-Agent

```
Execute research tasks from a brain dump.

tasks.json path: [full-path-to-tasks.json]
Folder: [brain-dump-folder-path]
Tasks to run (indices): [array of task indices in tasks.json]

For each task at the given indices:
1. Skip if status is "completed"
2. Call mcp__parallel-task__createDeepResearch with the task's prompt
3. Append to research-tracking.json with task_id, title, started_at, status="pending", platform_url
4. Update the task in tasks.json: set status="completed", add completed_at timestamp

Return: "Fired X research tasks (skipped Y already done). Check back in 5-10 min with /check-research"
```

---

### Todos Sub-Agent

```
Compile todo items into a checklist.

tasks.json path: [full-path-to-tasks.json]
Folder: [brain-dump-folder-path]
Tasks to run (indices): [array of task indices in tasks.json]

For each task at the given indices:
1. Skip if status is "completed"
2. Add to todo-list.md with checkbox format: - [ ] **[Title]** - [Details]
3. Update the task in tasks.json: set status="completed", add completed_at timestamp

Return: "Added X items to todo-list.md (skipped Y already done)"
```

---

### Orders Sub-Agent

```
Find purchase links for order items and notify via SMS.

tasks.json path: [full-path-to-tasks.json]
Folder: [brain-dump-folder-path]
Tasks to run (indices): [array of task indices in tasks.json]

For each task at the given indices:
1. Skip if status is "completed"
2. Web search for 2-3 purchase links (official site for branded items, Amazon for generic)
3. Append to order-list.md with item title, details, and links
4. Send SMS notification via Twilio MCP with title and all links (double newline between each for readability): "New order item: [Title]\n\n[Link 1]\n\n[Link 2]\n\n[Link 3]"
5. Update the task in tasks.json: set status="completed", add completed_at timestamp

Return: "Found links for X items, saved to order-list.md, sent X SMS notifications (skipped Y already done)"
```

---

### Memos Sub-Agent

```
Generate memo drafts.

tasks.json path: [full-path-to-tasks.json]
Folder: [brain-dump-folder-path]
Tasks to run (indices): [array of task indices in tasks.json]

For each task at the given indices:
1. Skip if status is "completed"
2. Generate a structured memo (Summary, Background, Key Points, Recommendations, Open Questions)
3. Save to memos/[slugified-title].md
4. Update the task in tasks.json: set status="completed", add completed_at timestamp

Return: "Generated X memos in memos/ (skipped Y already done)"
```

---

### Specs Sub-Agent

```
Generate technical spec drafts.

tasks.json path: [full-path-to-tasks.json]
Folder: [brain-dump-folder-path]
Tasks to run (indices): [array of task indices in tasks.json]

For each task at the given indices:
1. Skip if status is "completed"
2. Do quick web research if needed
3. Generate a technical spec (Overview, Goals, Non-Goals, Requirements, Dependencies, Open Questions)
4. Save to specs/[slugified-title].md
5. Update the task in tasks.json: set status="completed", add completed_at timestamp

Return: "Generated X specs in specs/ (skipped Y already done)"
```

---

## Step 3: Collect Results

After all sub-agents complete, relay their brief summaries to the user.
