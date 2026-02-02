---
name: ui-scaffold
description: Initialize shadcn/ui with Base UI primitives and the base-nova theme. Installs curated component sets.
---

# UI Scaffold

Set up shadcn/ui with Base UI primitives (not Radix) and Brenner's base-nova theme.

## When to Use

- Starting a new Next.js/React project that needs UI components
- Adding shadcn/ui to an existing project
- User says "set up UI", "add shadcn", "scaffold components", etc.

## Quick Reference

```bash
# Non-interactive initialization:
npx shadcn@latest init -d -y -f --base-color gray

# Then overwrite components.json with style: "base-nova"
# Then install dependencies:
bun add @base-ui/react @tabler/icons-react tw-animate-css class-variance-authority

# Then add components:
npx shadcn@latest add button card dialog -y
```

## Step 1: Check Project State

Look for existing shadcn setup:

```bash
# Check for components.json (shadcn config)
ls components.json 2>/dev/null

# Check for existing component directory
ls -la src/components/ui/ 2>/dev/null || ls -la components/ui/ 2>/dev/null
```

If `components.json` exists, skip to Step 3 (component installation).

## Step 2: Initialize shadcn (Non-Interactive)

### 2a. Run shadcn init with defaults

```bash
npx shadcn@latest init -d -y -f --base-color gray
```

Flags:
- `-d` = use defaults (skips all prompts)
- `-y` = auto-confirm
- `-f` = force overwrite existing config
- `--base-color gray` = use gray palette

### 2b. Write components.json with Base UI config

After init, **overwrite** `components.json` with Base UI style:

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "base-nova",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "",
    "css": "src/app/globals.css",
    "baseColor": "gray",
    "cssVariables": true,
    "prefix": ""
  },
  "iconLibrary": "tabler",
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  }
}
```

**Key:** `"style": "base-nova"` tells shadcn to use Base UI primitives with the nova style.

### 2c. Install Dependencies

```bash
bun add class-variance-authority tw-animate-css @base-ui/react @tabler/icons-react
```

### 2d. Install Registry Dependencies

```bash
npx shadcn@latest add utils -y
```

### 2e. Apply CSS Variables

Read `base-nova.json` and transform `cssVars` into CSS.

Update `src/app/globals.css` (or `app/globals.css`):

```css
@import "tailwindcss";
@import "tw-animate-css";

@custom-variant dark (&:is(.dark *));

@theme inline {
  /* From cssVars.light - these become the defaults */
  --color-background: oklch(1 0 0);
  --color-foreground: oklch(0.13 0.028 261.692);
  --color-card: oklch(1 0 0);
  --color-card-foreground: oklch(0.13 0.028 261.692);
  --color-popover: oklch(1 0 0);
  --color-popover-foreground: oklch(0.13 0.028 261.692);
  --color-primary: oklch(0.60 0.10 185);
  --color-primary-foreground: oklch(0.98 0.01 181);
  --color-secondary: oklch(0.967 0.001 286.375);
  --color-secondary-foreground: oklch(0.21 0.006 285.885);
  --color-muted: oklch(0.967 0.003 264.542);
  --color-muted-foreground: oklch(0.551 0.027 264.364);
  --color-accent: oklch(0.967 0.003 264.542);
  --color-accent-foreground: oklch(0.21 0.034 264.665);
  --color-destructive: oklch(0.577 0.245 27.325);
  --color-border: oklch(0.928 0.006 264.531);
  --color-input: oklch(0.928 0.006 264.531);
  --color-ring: oklch(0.707 0.022 261.325);
  --color-chart-1: oklch(0.85 0.13 181);
  --color-chart-2: oklch(0.78 0.13 182);
  --color-chart-3: oklch(0.70 0.12 183);
  --color-chart-4: oklch(0.60 0.10 185);
  --color-chart-5: oklch(0.51 0.09 186);
  --radius: 0.45rem;
  --color-sidebar: oklch(0.985 0.002 247.839);
  --color-sidebar-foreground: oklch(0.13 0.028 261.692);
  --color-sidebar-primary: oklch(0.60 0.10 185);
  --color-sidebar-primary-foreground: oklch(0.98 0.01 181);
  --color-sidebar-accent: oklch(0.967 0.003 264.542);
  --color-sidebar-accent-foreground: oklch(0.21 0.034 264.665);
  --color-sidebar-border: oklch(0.928 0.006 264.531);
  --color-sidebar-ring: oklch(0.707 0.022 261.325);
}

/* Dark mode overrides from cssVars.dark */
.dark {
  --color-background: oklch(0.13 0.028 261.692);
  --color-foreground: oklch(0.985 0.002 247.839);
  --color-card: oklch(0.21 0.034 264.665);
  --color-card-foreground: oklch(0.985 0.002 247.839);
  --color-popover: oklch(0.21 0.034 264.665);
  --color-popover-foreground: oklch(0.985 0.002 247.839);
  --color-primary: oklch(0.70 0.12 183);
  --color-primary-foreground: oklch(0.28 0.04 193);
  --color-secondary: oklch(0.274 0.006 286.033);
  --color-secondary-foreground: oklch(0.985 0 0);
  --color-muted: oklch(0.278 0.033 256.848);
  --color-muted-foreground: oklch(0.707 0.022 261.325);
  --color-accent: oklch(0.278 0.033 256.848);
  --color-accent-foreground: oklch(0.985 0.002 247.839);
  --color-destructive: oklch(0.704 0.191 22.216);
  --color-border: oklch(1 0 0 / 10%);
  --color-input: oklch(1 0 0 / 15%);
  --color-ring: oklch(0.551 0.027 264.364);
  --color-sidebar: oklch(0.21 0.034 264.665);
  --color-sidebar-foreground: oklch(0.985 0.002 247.839);
  --color-sidebar-primary: oklch(0.78 0.13 182);
  --color-sidebar-primary-foreground: oklch(0.28 0.04 193);
  --color-sidebar-accent: oklch(0.278 0.033 256.848);
  --color-sidebar-accent-foreground: oklch(0.985 0.002 247.839);
  --color-sidebar-border: oklch(1 0 0 / 10%);
  --color-sidebar-ring: oklch(0.551 0.027 264.364);
}

/* Base layer from css["@layer base"] */
@layer base {
  * {
    @apply border-border outline-ring/50;
  }
  body {
    @apply bg-background text-foreground;
  }
}
```

### 2e. Update components.json

Apply the config from the preset:

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "",
    "css": "src/app/globals.css",
    "baseColor": "gray",
    "cssVariables": true
  },
  "iconLibrary": "tabler",
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  }
}
```

## Step 3: Install Components

Ask the user which component set they want:

### Component Sets

**Minimal** (5 components) - Quick prototypes:
```bash
npx shadcn@latest add button card input dialog label -y
```

**Standard** (20 components) - Most apps:
```bash
npx shadcn@latest add button card input label form select checkbox switch textarea dialog sheet dropdown-menu tabs sonner skeleton avatar badge separator table tooltip popover -y
```

**Full** - Everything:
```bash
npx shadcn@latest add --all -y
```

### Using shadcn MCP (Preferred)

If the shadcn MCP server is available, use its tools instead of CLI:

1. Check MCP availability: Look for `shadcn` in available MCP servers
2. Use `install-component` tool for each component
3. Use `list-components` to show available options

The MCP is preferred because it:
- Has up-to-date component source code
- Provides proper TypeScript types
- Works with custom registries

## Step 4: Verify Setup

```bash
# Check components were installed
ls src/components/ui/ || ls components/ui/

# Run typecheck
bun typecheck || npm run typecheck
```

## Component Reference

### Most Used Components

| Component | Purpose |
|-----------|---------|
| `button` | Actions, form submission |
| `card` | Content containers |
| `input` | Text input fields |
| `label` | Form labels |
| `form` | Form validation (react-hook-form + zod) |
| `dialog` | Modal windows |
| `sheet` | Slide-out panels |
| `dropdown-menu` | Action menus |
| `select` | Dropdown selection |
| `tabs` | Tabbed content |
| `table` | Data display |
| `sonner` | Toast notifications |
| `skeleton` | Loading states |
| `tooltip` | Hover hints |

### Icons

Using Tabler icons (per base-nova config):

```tsx
import { IconUser, IconSettings } from "@tabler/icons-react"

<Button>
  <IconUser className="mr-2 h-4 w-4" />
  Profile
</Button>
```

## Base UI Patterns

Base UI uses **render props** instead of Radix's `asChild`:

```tsx
// Base UI pattern
<Dialog.Trigger render={(props) => <button {...props}>Open</button>} />

// NOT this (Radix pattern)
<Dialog.Trigger asChild><button>Open</button></Dialog.Trigger>
```

Floating components need `<Positioner>`:

```tsx
<Select.Positioner>
  <Select.Popup>
    {/* options */}
  </Select.Popup>
</Select.Positioner>
```

## Completion Checklist

- [ ] `components.json` exists with Base UI config
- [ ] Dependencies installed (@base-ui/react, @tabler/icons-react, etc.)
- [ ] CSS variables applied (base-nova theme)
- [ ] Requested components installed in `components/ui/`
- [ ] Typecheck passes

## Troubleshooting

**"Cannot find module '@base-ui/react'"**
```bash
bun add @base-ui/react
```

**Components using Radix instead of Base UI**
Re-run init and explicitly select Base UI, or reinstall components with `-o` flag:
```bash
npx shadcn@latest add button -o -y
```

**Theme not applying**
Check that CSS variables are in globals.css and the file is imported in layout.tsx.
