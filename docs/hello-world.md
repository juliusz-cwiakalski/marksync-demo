---
marksync:
  uuid: 019f5a2c-4a59-77aa-96ad-70f3719c2d1e
---

# Hello World from MarkSync

This page was published automatically by **MarkSync for Confluence** — a CLI tool that synchronizes Git-tracked Markdown
to Confluence Cloud.

## Why MarkSync?

- **Git as source of truth** — your docs live in Git, with full history and code review
- **Deterministic** — same input always produces the same Confluence output
- **Safe** — content-hash dedup, version-conflict detection, no silent overwrites
- **Auditable** — every page carries provenance (commit SHA, sync timestamp)

---

* [Hello World from MarkSync](#hello-world-from-marksync)
  * [Why MarkSync?](#why-marksync)
  * [Code Example](#code-example)
  * [Team Status](#team-status)
  * [Architecture Diagram (Mermaid)](#architecture-diagram-mermaid)
  * [mermaid kitchen sink](#mermaid-kitchen-sink)
    * [Class Diagram](#class-diagram)
    * [Gantt Diagram](#gantt-diagram)
    * [Mindmap Diagram](#mindmap-diagram)
    * [State Diagram](#state-diagram)
    * [Timeline Diagram](#timeline-diagram)
    * [Sequence Diagram](#sequence-diagram)
    * [Git Graph Diagram](#git-graph-diagram)
    * [Entity Relationship Diagram](#entity-relationship-diagram)
    * [User Journey Diagram](#user-journey-diagram)
    * [Pie Chart](#pie-chart)
    * [Quadrant Chart](#quadrant-chart)
    * [Requirement Diagram](#requirement-diagram)
  * [Update: Live Demo Section](#update-live-demo-section)
    * [Key Metrics](#key-metrics)
  * [🔄 Live Update](#-live-update)
  * [Update Test 13:24:30](#update-test-132430)
  * [Update Test 13:26:41](#update-test-132641)
  * [Update 16:42:33](#update-164233)
  * [Updated Section (22:16:26)](#updated-section-221626)
  * [Live Update Section](#live-update-section)
  * [Manual update 2026-07-14](#manual-update-2026-07-14)
  * [Testing tables](#testing-tables)

## Code Example

```typescript
function greet(name: string): string {
  return `Hello, ${name}!`;
}
```

## Team Status

| Member | Role      | Status   |
|--------|-----------|----------|
| Alice  | Tech Lead | Active   |
| Bob    | Engineer  | Active   |
| Carol  | Designer  | On leave |

## Architecture Diagram (Mermaid)

```mermaid
graph LR
    A[Git Repo] -->|marksync sync| B(MarkSync CLI)
    B -->|Storage XHTML| C[Confluence Cloud]
    B -->|content hash| D[(Yaml Lock File)]
```

## mermaid kitchen sink

### Class Diagram

```mermaid
classDiagram
    class SyncCommand {
        +String sourcePath
        +String spaceKey
        +run(): SyncResult
    }

    class MarkdownParser {
        +parse(input): Document
    }

    class ConfluenceRenderer {
        +render(doc): String
    }

    class SyncEngine {
        +sync(cmd): SyncResult
        -computeHash(content): String
    }

    class ConfluenceClient {
        +getPage(id): Page
        +updatePage(id, body): Page
    }

    class LockFileStore {
        +read(uuid): LockEntry
        +write(entry): void
    }

    SyncCommand --> SyncEngine : invokes
    SyncEngine --> MarkdownParser : uses
    SyncEngine --> ConfluenceRenderer : uses
    SyncEngine --> ConfluenceClient : calls
    SyncEngine --> LockFileStore : persists
```

### Gantt Diagram

```mermaid
gantt
    title MarkSync Release Plan
    dateFormat  YYYY-MM-DD
    axisFormat  %b %d

    section Foundation
    Requirements freeze        :done, req, 2026-07-01, 3d
    CLI command scaffold       :done, cli, after req, 4d
    Parser integration         :active, parser, after cli, 5d

    section Sync Engine
    Hash and dedup logic       :hash, after parser, 3d
    Conflict detection         :conflict, after hash, 3d
    Confluence API wiring      :api, after hash, 4d

    section Validation
    Integration tests          :test, after api, 4d
    Dry-run in staging         :staging, after test, 2d
    Production rollout         :milestone, rollout, after staging, 1d
```

### Mindmap Diagram

```mermaid
mindmap
  root((MarkSync))
    Inputs
      Markdown files
      Front matter
      CLI flags
    Core pipeline
      Parse
      Render
      Hash
      Compare lock
      Update page
    Safety
      Version conflict detection
      No silent overwrite
      Dry run mode
    Output
      Confluence pages
      Updated lock file
      Sync report
```

### State Diagram

```mermaid
stateDiagram-v2
    [*] --> Parsed
    Parsed --> Rendered : render XHTML
    Rendered --> Hashed : compute content hash

    Hashed --> Unchanged : hash matches lock
    Hashed --> Changed : hash differs

    Unchanged --> NoOp
    NoOp --> [*]

    Changed --> Conflict : remote version newer
    Changed --> Updating : remote version matches

    Conflict --> Aborted
    Aborted --> [*]

    Updating --> LockWritten : persist metadata
    LockWritten --> [*]
```

### Timeline Diagram

```mermaid
timeline
    title MarkSync Project Timeline
    2026 Q1 : Idea and prototype
            : Confluence API spike
    2026 Q2 : First public CLI
            : Content hash dedup
            : Lock file format
    2026 Q3 : Conflict detection
            : Dry-run mode
            : CI integration
    2026 Q4 : GA release
            : Team adoption
```

### Sequence Diagram

```mermaid
sequenceDiagram
    actor Dev as Developer
    participant CLI as MarkSync CLI
    participant Engine as Sync Engine
    participant API as Confluence API
    participant Lock as Lock File

    Dev->>CLI: marksync sync
    CLI->>Engine: run(command)
    Engine->>Engine: parse + render + hash
    Engine->>Lock: read stored hash
    Lock-->>Engine: previous hash

    alt hash unchanged
        Engine-->>CLI: NoOp (skipped)
    else hash changed
        Engine->>API: get current page version
        API-->>Engine: version + body
        Engine->>API: update page
        API-->>Engine: new version
        Engine->>Lock: write new hash + version
    end

    CLI-->>Dev: sync report
```

### Git Graph Diagram

```mermaid
gitGraph
    commit id: "init docs"
    commit id: "add hello-world"
    branch feature/mermaid
    checkout feature/mermaid
    commit id: "class + gantt"
    commit id: "mindmap"
    commit id: "state + timeline + sequence"
    checkout main
    merge feature/mermaid tag: "v1.0"
    commit id: "add git graph"
    branch hotfix/lockfile
    checkout hotfix/lockfile
    commit id: "fix lock hash"
    checkout main
    merge hotfix/lockfile tag: "v1.0.1"
```

### Entity Relationship Diagram

```mermaid
erDiagram
    PAGE ||--o{ SYNC_RUN : "has"
    PAGE ||--|| LOCK_ENTRY : "tracked by"
    SPACE ||--o{ PAGE : "contains"
    SYNC_RUN }o--|| USER : "triggered by"

    SPACE {
        string key PK
        string name
    }
    PAGE {
        string uuid PK
        string title
        string spaceKey FK
        int version
    }
    LOCK_ENTRY {
        string uuid PK
        string contentHash
        int syncedVersion
    }
    SYNC_RUN {
        string id PK
        datetime startedAt
        string result
    }
    USER {
        string id PK
        string email
    }
```

### User Journey Diagram

```mermaid
journey
    title Author a doc with MarkSync
    section Write
      Draft Markdown in editor: 5: Author
      Add front matter: 4: Author
    section Review
      Open pull request: 4: Author, Reviewer
      Approve changes: 5: Reviewer
    section Sync
      Run marksync sync: 5: CI
      Verify page in Confluence: 4: Author
```

### Pie Chart

```mermaid
pie showData
    title Sync outcomes (last 100 runs)
    "Updated" : 42
    "NoOp (unchanged)" : 51
    "Conflict" : 5
    "Failed" : 2
```

### Quadrant Chart

```mermaid
quadrantChart
    title Doc tooling landscape
    x-axis Low automation --> High automation
    y-axis Low control --> High control
    quadrant-1 Ideal
    quadrant-2 Manual but safe
    quadrant-3 Avoid
    quadrant-4 Risky automation
    MarkSync: [0.8, 0.85]
    Manual copy-paste: [0.15, 0.6]
    Wiki WYSIWYG: [0.3, 0.3]
    Ad-hoc scripts: [0.7, 0.25]
```

### Requirement Diagram

```mermaid
requirementDiagram
    requirement deterministic_sync {
        id: 1
        text: Same input yields same Confluence output.
        risk: high
        verifymethod: test
    }

    requirement no_silent_overwrite {
        id: 2
        text: Never overwrite newer remote versions.
        risk: high
        verifymethod: test
    }

    element sync_engine {
        type: component
    }

    element lock_store {
        type: component
    }

    sync_engine - satisfies -> deterministic_sync
    lock_store - satisfies -> no_silent_overwrite
```



---

*This page is part of the MarkSync demo.*

## Update: Live Demo Section

This section was added **after the initial publish** to demonstrate the update flow.

### Key Metrics

| Metric             | Value         |
|--------------------|---------------|
| Pages synced       | 2             |
| Sync latency       | < 2s          |
| Content hash       | sha256-based  |
| Conflict detection | version-aware |

> **Note:** MarkSync detects unchanged content and skips unnecessary updates (NoOp).

## 🔄 Live Update

**Last synced:** 2026-07-13 08:58:25 CEST

This section is automatically updated by `demo.sh` to demonstrate the
marksync update flow. Each run produces a new page version on Confluence.

## Update Test 13:24:30

This line was added to test the update flow.

## Update Test 13:26:41

Testing the update flow after GH-62 fix.

## Update 16:42:33

Testing update flow with GH-62+GH-66 fixes.

## Updated Section (22:16:26)

This content was added to demonstrate the update flow.

## Live Update Section

**Updated:** This content was added to demonstrate the update flow.
MarkSync detects content changes and updates the Confluence page version.

## Manual update 2026-07-14

Let's see what happens now? :)

And let's add some code block:

```java
static invert(String s) {
    return new StringBuilder(s).reverse().toString();
}
```

## Testing tables

| Idea                    | Description                                                           |
|-------------------------|-----------------------------------------------------------------------|
| MarkSync                | A CLI tool that synchronizes Git-tracked Markdown to Confluence Cloud |
| MarkSync for Confluence | A CLI tool that synchronizes Git-tracked Markdown to Confluence Cloud |
| A new row               | would that work after I did not commit the lock file?                 |
