---
name: process-brain-dump
description: Process a brain dump text file and extract structured tasks as JSON. Use when user wants to process a voice transcript or unstructured notes into actionable tasks.
---
# Process Brain Dump

## Purpose

Transform unstructured brain dump text (voice transcriptions, conversation recordings, or stream-of-consciousness notes) into a structured JSON array of actionable tasks. Works for both simple personal to-do brain dumps AND rich multi-person conversations with embedded ideas, insights, and business discussions.

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
   Read <directory>/raw-dump-formatted.txt (one sentence per line).

   BE INCLUSIVE - this step removes only obvious noise, not substantive content.

   REMOVE ONLY these categories (be conservative):
   - Pure filler with no content: standalone "Yeah", "Okay", "Mm-hmm", "Uh...", "Hmm", "Right", "Sure"
   - Incomplete fragments under 5 words that don't convey meaning
   - Exact duplicate sentences (keep the first occurrence)
   - Pure pleasantries with no substance: "Nice to see you", "Take care", "Hey man"

   KEEP everything else, including:
   - Ideas, insights, observations, opinions (even if not explicitly actionable)
   - Business strategy, technical discussions, product ideas
   - Interesting takes, hot takes, contrarian views
   - Stories and anecdotes that contain lessons or insights
   - Questions that reveal curiosity or research interests
   - Comparisons between products, companies, or approaches
   - Explanations of how things work
   - Future intentions ("I want to...", "I should...", "We need to...")
   - Past experiences that inform future thinking
   - Recommendations, advice, or wisdom shared
   - Names of people, companies, products, tools worth remembering
   - Any sentence where you're unsure - ERR ON THE SIDE OF KEEPING IT

   The goal is to preserve the richness of the conversation while removing only true noise.
   Expect to keep 60-80% of sentences from a substantive conversation.

   Write kept sentences to <directory>/raw-dump-filtered.txt, one per line, preserving original order.
   Report back: sentences kept / total sentences (percentage kept).
   ```

3. **Group sentences into topics** — Spawn a sub-agent with this prompt:
   ```
   Read <directory>/raw-dump-filtered.txt (one sentence per line).

   Group ALL sentences into topics. Every single sentence must be assigned to a topic - no sentence should be left behind or omitted.

   CRITICAL REQUIREMENTS:
   - Every sentence must be placed into exactly one topic
   - Create topics based on semantic similarity and related themes
   - Topics should be descriptive and capture the main theme (e.g., "Utah Development Project", "Research Tasks", "Personal Errands", "Technical Specifications")
   - If a sentence doesn't clearly fit existing topics, create a new topic for it (e.g., "Miscellaneous" or a more specific topic based on the sentence content)
   - Preserve the original order of sentences within each topic when possible

   OUTPUT TWO FILES:

   1. <directory>/topics.txt - One topic per line, in the order they appear in the grouped file:
      Topic Name 1
      Topic Name 2
      Topic Name 3

   2. <directory>/raw-dump-grouped.txt - Grouped sentences with markdown headers:
      ## Topic Name 1
      Sentence 1 from this topic
      Sentence 2 from this topic
      Sentence 3 from this topic

      ## Topic Name 2
      Sentence 1 from this topic
      Sentence 2 from this topic

      ## Topic Name 3
      Sentence 1 from this topic

   Format rules for raw-dump-grouped.txt:
   - Each topic section starts with `## Topic Name` (exactly two # symbols)
   - One blank line after the header before sentences
   - One sentence per line
   - One blank line between topic sections
   - No trailing blank lines at the end of the file

   Report back:
   - Total number of topics created
   - Total number of sentences grouped
   - List of all topic names
   - Confirmation that every sentence was assigned to a topic
   ```

4. **Extract, classify, and write tasks** — The main agent performs this step directly:

   - Read `<directory>/topics.txt` to get the list of topics
   - For each topic, extract just that section from raw-dump-grouped.txt using sed
     (e.g., `sed -n '/^## Topic Name/,/^## /p' <file> | head -n -1`)
   - Extract actionable tasks from that section
   - Classify into exactly one task type (see Task Types above — mutually exclusive)
   - After processing all topics, generate the JSON following the Output Schema above
   - Write to `<directory>/tasks.json`
5. **Extract tweetable soundbites** — Spawn a sub-agent with this prompt:

   ```
   Extract tweetable soundbites from <directory>/raw-dump-grouped.txt, processing topic-by-topic.

   PROCESS BY TOPIC SECTION:
   1. Read <directory>/topics.txt to get the list of topics
   2. Initialize tweets array: []
   3. For each topic, use grep/sed to extract just that section from raw-dump-grouped.txt
      (e.g., sed -n '/^## Topic Name/,/^## /p' <file> | head -n -1)
   4. Scan the section for tweetable content, add to tweets array
   5. After all topics, write final JSON to <directory>/tweets.json

   TARGET AUDIENCE:
   - Tech-savvy people plugged into frontier technology
   - Developers, founders, and builders
   - People who appreciate spicy takes and unique perspectives

   WHAT MAKES A BANGER TWEET:
   - A unique or contrarian take that sparks engagement
   - An insight that makes people think "I never thought of it that way"
   - A pithy observation about technology, building, or strategy
   - Something quotable that stands on its own without context
   - Hot takes on companies, products, or industry trends

   WHAT TO SKIP:
   - Generic observations anyone could make
   - Personal to-do items or shopping lists
   - Technical details that need too much context
   - Anything that sounds like meeting notes

   OUTPUT FORMAT in tweets.json:
   {
     "tweets": [
       {
         "topic": "Brief description of the core idea",
         "categories": ["category1", "category2"],
         "tweet": "The actual tweet text, punchy and under 280 chars"
       }
     ]
   }

   CATEGORY OPTIONS (use 1-3 per tweet):
   - ai, automation, developer-tools, infrastructure, hardware
   - startups, big-tech, strategy, product, ux
   - hot-take, prediction, observation, advice

   Report back how many tweetable soundbites were extracted and list their topics.
   ```

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
