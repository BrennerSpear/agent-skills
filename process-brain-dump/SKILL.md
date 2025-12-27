---
name: process-brain-dump
description: Process a brain dump text file and extract structured tasks as JSON. Use when user wants to process a voice transcript or unstructured notes into actionable tasks.
---

# Process Brain Dump

## Purpose

Transform unstructured brain dump text (typically voice transcriptions) into a structured JSON array of actionable tasks.

## Task Types (Enum)

- `research` - Topics requiring investigation, web searches, or information gathering
- `todo_item` - Personal action items, errands, cancellations, administrative tasks
- `order_item` - Physical goods to purchase/order online
- `generate_memo_draft` - Ideas requiring a written memo or document draft
- `generate_spec_draft` - Technical or project specifications needing formal documentation

## Output Schema

```json
{
  "tasks": [
    {
      "type": "research | todo_item | order_item | generate_memo_draft | generate_spec_draft",
      "title": "Brief descriptive title (5-10 words)",
      "prompt": "Full context and details for the task, including any specific requirements mentioned",
      "tools": ["tool1", "tool2"]
    }
  ]
}
```

## Tool Suggestions by Task Type

- **research**: `WebSearch`, `WebFetch`, `parallel-search:web_search_preview`, `parallel-task:createDeepResearch`
- **todo_item**: `Bash`, `Read`, `Edit` (depends on the specific task)
- **order_item**: `WebSearch`, `WebFetch` (for finding where to order)
- **generate_memo_draft**: `Write`, `Read`
- **generate_spec_draft**: `Write`, `Read`, `WebSearch` (for research during drafting)

## Instructions

**Important**: Use sub-agents for processing steps to avoid clogging the main context with raw transcript content.

1. **Format the raw dump** — Spawn a sub-agent with this prompt:
   ```
   Run the formatting script on the brain dump file:
   npx ts-node /Users/brenner/repos/ClaudeCodeSkills/process-brain-dump/format-raw-dump.ts <path-to-raw-dump.txt>

   Report back the number of sentences extracted and confirm the output file path.
   ```

2. **Filter out noise** — Spawn a sub-agent with this prompt:
   ```
   Read <directory>/raw-dump-formatted.txt and filter out noise.

   REMOVE sentences that are:
   - Filler words and acknowledgments ("Yeah", "Okay", "Mm-hmm", "Uh...", "Hmm")
   - In-the-moment conversation being resolved ("There's two in there", "That's okay, so it's for you")
   - Reactions and observations with no future action ("You look too rich right now")
   - Questions being answered in real-time during the conversation
   - Past tense completions where action already happened ("I just started to make some")
   - Background chatter unrelated to the speaker's intentions

   KEEP sentences that:
   - Express intent for future action ("I need to...", "I should...", "We need to...")
   - Request research or information gathering ("Research topic...", "Look into...")
   - Mention items to order or purchase
   - Contain ideas worth documenting or exploring
   - Provide important context for an adjacent actionable sentence

   Write only the kept sentences to <directory>/raw-dump-filtered.txt, one per line, preserving original order.
   Report back how many sentences were kept out of the original count.
   ```

3. **Extract, classify, and write tasks** — The main agent performs this step directly:
   - Read `<directory>/raw-dump-filtered.txt` (now small enough for main context)
   - For each sentence or group of related sentences, determine if it's actionable
   - Classify into exactly one task type (see Task Types above — mutually exclusive)
   - Generate the JSON following the Output Schema above
   - Write to `<directory>/tasks.json`

## Example Extraction

**Input text:**
> "Oh yeah, I need to cancel my Netflix subscription. Also research topic - what are the best standing desks under $500? And I should order more coffee beans from that place I like."

**Output:**
```json
{
  "tasks": [
    {
      "type": "todo_item",
      "title": "Cancel Netflix subscription",
      "prompt": "Cancel the Netflix subscription",
      "tools": ["WebFetch"]
    },
    {
      "type": "research",
      "title": "Best standing desks under $500",
      "prompt": "Research the best standing desks available for under $500, comparing features, reviews, and value",
      "tools": ["WebSearch", "WebFetch"]
    },
    {
      "type": "order_item",
      "title": "Order coffee beans",
      "prompt": "Order more coffee beans from the preferred supplier",
      "tools": ["WebSearch"]
    }
  ]
}
```

## Processing Guidelines

- **Be comprehensive**: Extract ALL actionable items, even if they seem minor
- **Preserve context**: Include relevant surrounding context in the prompt field
- **Deduplicate**: If the same task is mentioned multiple times, combine into one entry
- **Infer intent**: Voice transcripts may have errors - interpret the likely intended meaning
- **Group related items**: If multiple related sub-tasks exist, you may group them or keep separate based on logical action boundaries
