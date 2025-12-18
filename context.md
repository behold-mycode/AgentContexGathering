# Context Intelligence Command

You are executing the `/context` command. This command manages context gathering for AI coding sessions.

## Command Variants

Parse the command arguments to determine which variant to execute:

- `/context` (no args) - Initial context gathering
- `/context expand` - Expand current context
- `/context update` - Update current context for changed files
- `/context narrow <topic>` - Focus on subset of current context
- `/context switch <topic>` - Switch to a different saved context
- `/context list` - List all saved contexts

---

## Initial Context Gathering (`/context` with no args)

Ask the user for context information using this structured format:

```
What context should I gather?

Please provide:
1. **Topic/Feature** - What area of the codebase?
   (e.g., "field mapping validation", "user profile settings", "authentication flow")

2. **Task Type** - What kind of work?
   - bug fix - Fixing a specific issue
   - new feature - Adding new functionality
   - refactoring - Restructuring existing code
   - understanding - Learning how something works

3. **Depth Level** - How much context to gather?
   - shallow - Entry file + direct imports only (bug fixes, quick lookups)
   - medium - 2 levels deep + related services (typical development)
   - deep - Full dependency tree (refactoring, migrations)

Example: "option mapping selector, new feature, medium"
```

After receiving the user's response, follow the **Structure-First Resolution** process below.

---

## Structure-First Resolution Process

When gathering context, follow these phases IN ORDER:

### PHASE 1: Understand Codebase Organization

Analyze the folder structure to identify:
- **Business Logic Folders** - Pages, features, domain-specific code
- **Code Logic Folders** - Services, reusable components, shared utilities, types

Use `ls` or `tree` commands to map the structure. Document what you find.

### PHASE 2: Locate Relevant Folder(s)

Based on the user's topic:
- Is this a page/feature? → Look in business logic folders
- Is this a shared component? → Look in components/
- Is this a service? → Look in services/

Identify the most relevant folder(s) for the topic.

### PHASE 3: Learn Patterns from Sibling Files

Within the identified folder, examine sibling files to learn:
- How components are structured in this area
- Naming conventions used
- What services/types are commonly imported
- Local patterns and idioms

These sibling files serve as **reference examples** for the target files.

### PHASE 4: Cross-Reference with Spec Files

Read existing specification files:
- `CLAUDE.md` - Project-wide conventions
- `.claude/rules/*.md` - Hard rules and constraints

Ensure gathered patterns align with documented rules. **Hard rules take precedence** over observed patterns.

### PHASE 5: Deep Dive into Target Files

Based on the depth level:
- **Shallow**: Target file + direct imports only
- **Medium**: + services + types + sibling components
- **Deep**: + full dependency tree + cross-cutting concerns

Extract:
- Interfaces and types
- Service dependencies
- Component relationships
- Data flow

---

## Generate Context Files

After analysis, create files in `.claude/context/{topic-slug}/`:

### overview.md
```markdown
# {Topic Name} Context

## Summary
Brief description of what this feature/area does.

## Codebase Location
- Feature folder: `path/to/folder/`
- Related services: `services/...`
- Shared components used: `components/...`

## Entry Points
- `path/to/MainComponent.tsx` - Description

## Key Components
| File | Type | Purpose |
|------|------|---------|
| ... | ... | ... |

## Data Flow
1. Step 1
2. Step 2
...

## Dependencies (Services)
- `ServiceName.instance()` - What it provides

## Sibling Files (Reference Examples)
These files in the same folder follow the same patterns:
- `SiblingFile.tsx` - Example of...

## Applicable Rules (from spec files)
- Rule 1 from CLAUDE.md or rules/*.md
- Rule 2...

## Gathering Info
- Generated: {ISO-8601 timestamp}
- Depth: {shallow|medium|deep}
- Task Type: {bug fix|new feature|refactoring|understanding}
- Files Analyzed: {count}
```

### types.md
```markdown
# Types for {Topic Name}

## Core Interfaces

```typescript
// Copy actual interface definitions from the codebase
interface Example {
  ...
}
```

## Enums and Constants

```typescript
enum ExampleEnum {
  ...
}
```

## Type Patterns
- Pattern 1: How types are used in this area
- Pattern 2: ...

## Usage Notes
- Important usage notes for these types
```

### file-graph.json
```json
{
  "version": "1.0",
  "topic": "{topic-slug}",
  "generatedAt": "{ISO-8601}",
  "depth": "{shallow|medium|deep}",
  "taskType": "{task-type}",
  "entryPoints": ["path/to/entry.tsx"],
  "nodes": {
    "path/to/file.tsx": {
      "type": "component|service|types|hook",
      "imports": ["path/to/dep.ts"],
      "exports": ["ExportName"],
      "dependencies": ["ServiceName"]
    }
  }
}
```

### patterns.md
```markdown
# Patterns in {Topic Name}

## From Sibling Files
(Patterns observed in files alongside target)
- Pattern 1
- Pattern 2

## From Spec Files
(Hard rules from CLAUDE.md and rules/*.md - these take precedence)
- Rule 1
- Rule 2

## Conflicts/Notes
(Any cases where observed patterns differ from spec)
```

---

## Activate Context

After generating files:
1. Write the topic slug to `.claude/context/.active`
2. Create/update `.claude/rules/active-context.md` with a summary:

```markdown
# Active Context: {Topic Name}

This context was gathered for: {task type}

## Quick Reference
- Entry: `path/to/entry.tsx`
- Key files: {count} files at {depth} depth

## Key Types
{List main interfaces/types}

## Key Patterns
{List critical patterns to follow}

## Rules to Remember
{List applicable rules from spec files}

See `.claude/context/{topic-slug}/` for full context.
```

---

## Expand Command (`/context expand`)

If current context exists, ask:

```
Current context: "{topic-name}" ({depth} depth)

How would you like to expand?
- **deeper** - Add another level of imports
- **related <topic>** - Add related area (e.g., "validation", "services")
- **files <pattern>** - Add specific files matching pattern
```

Then update the context files accordingly.

---

## Update Command (`/context update`)

Check for files that changed since last gather:
1. Read `generatedAt` from file-graph.json
2. Check modification times of entry point files
3. If any are newer, re-analyze those files
4. Update types.md and file-graph.json

Report what was updated.

---

## Narrow Command (`/context narrow <topic>`)

Filter current context to focus on a subset:
1. Save current context state (for later restore)
2. Filter files related to the specified topic
3. Update active-context.md to reflect narrowed focus

---

## Switch Command (`/context switch <topic>`)

Switch to a different saved context:
1. Check if `.claude/context/{topic}/` exists
2. If yes, activate it
3. If no, offer to gather new context for that topic

---

## List Command (`/context list`)

List all saved contexts:
1. Read directories in `.claude/context/`
2. For each, show: name, depth, task type, file count, age
3. Mark which one is active

---

## Important Notes

- Always use the Structure-First Resolution process (5 phases)
- Sibling files are valuable reference examples - use them
- Cross-reference with CLAUDE.md and rules/*.md
- Hard rules in spec files take precedence over observed patterns
- Generate all context files before activating
