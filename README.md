# MarkSync for Confluence — Demo Repository

This repository demonstrates **MarkSync for Confluence** — a CLI tool that
synchronizes Git-tracked Markdown to Atlassian Confluence Cloud
deterministically, safely, and with a clear audit trail.

## What this demo shows

1. **Publish** — `marksync sync` creates Confluence pages from Markdown files
2. **Update** — edit Markdown locally, re-sync, Confluence pages update (version bumped)
3. **No-op detection** — unchanged files are skipped (no unnecessary writes)
4. **New pages** — add a new `.md` file, sync, and a new page appears on Confluence
5. **Mermaid diagrams** — Mermaid code blocks are rendered to SVG images via Kroki API
6. **Lock file** — a committed `marksync.lock.yml` tracks page bindings

## Prerequisites

| Requirement | Version |
|-------------|---------|
| [Bun](https://bun.sh) | ≥ 1.2.23 |
| Git | any recent version |
| Confluence Cloud account | with API token |
| MarkSync source | cloned locally |

## Quick start

### 1. Clone both repositories

```bash
# MarkSync source (the CLI tool)
git clone https://github.com/juliusz-cwiakalski/marksync.git ~/marksync

# This demo repository
git clone https://github.com/juliusz-cwiakalski/marksync-demo.git ~/marksync-demo
```

### 2. Configure credentials

```bash
cd ~/marksync-demo
cp .env.example .env
```

Edit `.env` and fill in your Confluence credentials:

```bash
MARKSYNC_CONFLUENCE_BASE_URL=https://your-site.atlassian.net
MARKSYNC_USER_EMAIL=you@example.com
MARKSYNC_API_TOKEN=your-api-token-here
```

> **Create an API token:** https://id.atlassian.com/manage-profile/security/api-tokens
> → "Create API token" (classic, no scopes needed for MS-0002).

### 3. Configure the target space

Edit `marksync.yml` and set your Confluence space ID and parent page ID:

```yaml
targets:
  default:
    type: confluence
    spaceKey: "123456789"          # ← numeric Confluence space ID (not the key!)
    parentPageId: "987654321"      # ← page ID under which pages are created
```

> **Finding your space ID:** Open your Confluence space in a browser. The space
> ID is the numeric value in the URL or available via the API:
> `GET /wiki/api/v2/spaces?keys=YOUR_KEY`

### 4. Commit the demo corpus

The demo files are already committed, but if you make changes:

```bash
git add -A
git commit -m "update demo content"
```

> MarkSync reads from Git HEAD — files MUST be committed before syncing.

### 5. Run the demo

Set the path to your MarkSync source:

```bash
export MARKSYNC_SRC=~/marksync
```

**Dry-run (plan):**

```bash
bun "$MARKSYNC_SRC/src/cli/index.ts" plan
```

**Publish to Confluence:**

```bash
bun "$MARKSYNC_SRC/src/cli/index.ts" sync
```

**One-click demo (edit → commit → sync):**

```bash
./demo.sh
```

## How it works

```
┌──────────────┐     ┌─────────────────┐     ┌──────────────────┐
│  Markdown    │────▶│  marksync sync  │────▶│  Confluence Cloud│
│  (Git-tracked)│     │  (Bun CLI)      │     │  (pages created) │
└──────────────┘     └────────┬────────┘     └──────────────────┘
                              │
                     ┌────────▼────────┐
                     │ marksync.lock.yml│  ← committed, tracks bindings
                     └─────────────────┘
```

1. **Discover** — reads committed Markdown from Git HEAD
2. **Parse** — converts Markdown → HAST → Confluence Storage XHTML
3. **Classify** — compares local/remote content hashes to determine action
4. **Apply** — creates or updates pages, writes lock file

## Demo corpus

| File | Content |
|------|---------|
| `docs/hello-world.md` | Feature showcase: headings, code blocks, tables, Mermaid |
| `docs/team-guide.md` | Team practices: checklists, deployment flow, links |

Each file has a `marksync.uuid` in YAML front-matter — this is the stable
identity that binds a Markdown file to a Confluence page across syncs.

## The lock file (`marksync.lock.yml`) — CRITICAL

After the first sync, a `marksync.lock.yml` appears in the repo root. This is
the **committed shared base** — it tracks which Markdown UUID maps to which
Confluence page ID, along with content hashes and version numbers.

> **⚠️ ALWAYS commit the lock file after every sync.** Without the committed
> lock, marksync cannot detect existing pages and will try to create duplicates
> (which Confluence rejects with "title already exists"). The typical workflow
> is:
>
> ```bash
> bun $MARKSYNC_SRC/src/cli/index.ts sync   # publish changes
> git add marksync.lock.yml                  # stage the updated lock
> git commit -m "sync: update pages"         # commit it
> ```

## Troubleshooting

| Problem | Fix |
|---------|-----|
| 0 entries in plan | Ensure files are `git commit`-ted. Check `select` pattern uses directory prefix (e.g. `docs/`). |
| 400 error on create | `spaceKey` in config must be the **numeric space ID**, not the string key. |
| All pages blocked on re-sync | Known issue ([#62](https://github.com/juliusz-cwiakalski/marksync/issues/62)) — Confluence normalizes XHTML. Being fixed. |
| Front-matter visible on page | Known issue ([#63](https://github.com/juliusz-cwiakalski/marksync/issues/63)) — being fixed. |

## Links

- [MarkSync source](https://github.com/juliusz-cwiakalski/marksync)
- [MarkSync docs](https://github.com/juliusz-cwiakalski/marksync/tree/main/doc)
- [Report a bug](https://github.com/juliusz-cwiakalski/marksync/issues)
