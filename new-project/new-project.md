# New Project

Create a new T3 app with Brenner's preferred defaults.

## Usage

Run `/new-project` or `/new-project <project-name>` to scaffold a new project.

## Stack Defaults

Always use these options when creating a T3 app:

- **TypeScript**
- **Tailwind CSS**
- **App Router** (not Pages)
- **tRPC** - default choice unless the API needs external consumers
- **NextAuth** - when authentication is needed
- **Prisma** - when a database is needed
- **Biome** - linting/formatting, no semicolons
- **Git** - always initialize

## Database Choice

- **SQLite + Turso** - for smaller apps (Vercel marketplace, easy hosting)
- **Postgres + Supabase** - for larger apps or when Supabase features are needed

## Process

1. Check `~/specs/` for existing project specs that match the request
2. Ask clarifying questions if needed (database choice, auth requirements, etc.)
3. Create the app using `create_t3_app <app_name> [public|private]` (defined in `.zshrc`)
4. Run post-creation setup (below)
5. Create initial spec files if they don't exist

## Post-Creation Setup

After creating a T3 app:

1. **Biome config** - Update `biome.jsonc` to disable semicolons:
   ```json
   "javascript": {
     "formatter": {
       "semicolons": "asNeeded"
     }
   }
   ```

2. **tRPC cleanup** - If using tRPC, remove the hello world router:
   - Delete `src/server/api/routers/post.ts`
   - Remove its reference in `src/server/api/root.ts`

3. **Create spec folder** - Set up documentation structure:
   ```bash
   mkdir -p spec
   ```

4. **Initial commit** - Commit the scaffolded app before making changes

## Deployment

Default deployment target is **Vercel**.
