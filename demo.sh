#!/usr/bin/env bash
# demo.sh — One-click MarkSync demo: edit → commit → sync → verify
#
# Simulates the user flow: modify markdown → git commit → marksync sync →
# Confluence page updates.
#
# Usage:  ./demo.sh [page-name]
# Default: ./demo.sh hello-world
#
# Prerequisites:
#   - MARKSYNC_SRC env var pointing to the marksync source repo
#   - .env file with Confluence credentials
#   - marksync.yml configured with target space + parent page

set -euo pipefail

PAGE="${1:-hello-world}"
MARKSYNC_SRC="${MARKSYNC_SRC:-$(realpath ../marksync-for-confluence)}"
DEMO_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$DEMO_DIR"

# ─── Colors ───
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  MarkSync for Confluence — Live Demo${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
echo ""

# ─── Step 1: Show current state ───
echo -e "${YELLOW}▸ Step 1: Current lock state${NC}"
if [ -f marksync.lock.yml ]; then
    echo "  Lock file exists. Current bindings:"
    grep -E "sourcePath|pageId|pageVersion" marksync.lock.yml | head -12 | sed 's/^/  /'
else
    echo "  No lock file yet — first sync will create pages."
fi
echo ""

# ─── Step 2: Edit the markdown ───
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S %Z')
MARKDOWN_FILE="docs/${PAGE}.md"

if [ ! -f "$MARKDOWN_FILE" ]; then
    echo -e "${YELLOW}⚠ File not found: $MARKDOWN_FILE${NC}"
    echo "Available pages:"
    ls docs/*.md 2>/dev/null | sed 's/^/  /'
    exit 1
fi

echo -e "${YELLOW}▸ Step 2: Editing $MARKDOWN_FILE${NC}"
echo ""
echo "  Adding update timestamp: $TIMESTAMP"

# Append a visible update marker (replaces any existing one)
# Remove old update section, then add new
python3 -c "
import re
with open('$MARKDOWN_FILE', 'r') as f:
    content = f.read()
# Remove existing update section
content = re.sub(r'\n## 🔄 Live Update.*?(?=\n---\n|\Z)', '', content, flags=re.DOTALL)
# Add new update section before the final separator
update = f'''

## 🔄 Live Update

**Last synced:** $TIMESTAMP

This section is automatically updated by \`demo.sh\` to demonstrate the
marksync update flow. Each run produces a new page version on Confluence.
'''
# Insert before the last '---' separator if it exists
if content.rstrip().endswith('---'):
    content = content.rstrip()[:-3] + update + '\n---\n'
else:
    content = content.rstrip() + update + '\n'
with open('$MARKDOWN_FILE', 'w') as f:
    f.write(content)
"
echo "  ✅ Markdown updated"
echo ""

# ─── Step 3: Git commit ───
echo -e "${YELLOW}▸ Step 3: Git commit${NC}"
git add "$MARKDOWN_FILE"
git commit -m "demo: update $PAGE at $TIMESTAMP" --quiet
echo "  Commit: $(git log --oneline -1)"
echo ""

# ─── Step 4: Run marksync sync ───
echo -e "${YELLOW}▸ Step 4: marksync sync${NC}"
echo ""
OUTPUT=$(bun "$MARKSYNC_SRC/src/cli/index.ts" sync 2>&1) || true
echo "$OUTPUT" | grep -E '"outcome"|"writes"|"skips"|"blocks"' | head -10 | sed 's/^/  /'
echo ""

# Parse results
WRITES=$(echo "$OUTPUT" | grep -o '"writes":[0-9]*' | grep -o '[0-9]*' || echo "0")
BLOCKS=$(echo "$OUTPUT" | grep -o '"blocks":[0-9]*' | grep -o '[0-9]*' || echo "0")

# ─── Step 5: Verify ───
echo -e "${YELLOW}▸ Step 5: Results${NC}"
if [ "$WRITES" -gt 0 ]; then
    echo -e "  ${GREEN}✅ SUCCESS: $WRITES page(s) updated on Confluence${NC}"
elif [ "$BLOCKS" -gt 0 ]; then
    echo -e "  ${YELLOW}⚠ BLOCKED: $BLOCKS page(s) were blocked${NC}"
    echo "  (This may be due to known issue #62 — remote hash mismatch)"
    # Show full output for debugging
    echo ""
    echo "  Full output:"
    echo "$OUTPUT" | sed 's/^/    /'
else
    echo "  No changes needed — content already in sync (NoOp)."
fi
echo ""

# ─── Step 6: Show page links ───
echo -e "${YELLOW}▸ Step 6: Confluence pages${NC}"
if [ -f marksync.lock.yml ]; then
    BASE_URL=$(grep MARKSYNC_CONFLUENCE_BASE_URL .env 2>/dev/null | cut -d= -f2 || echo "")
    grep 'pageId' marksync.lock.yml | while read -r line; do
        PAGE_ID=$(echo "$line" | grep -o '"[0-9]*"' | tr -d '"' || echo "")
        TITLE=$(grep -B5 "$line" marksync.lock.yml | grep 'sourcePath' | head -1 | sed 's/.*\///' | sed 's/.md//' || echo "page")
        if [ -n "$PAGE_ID" ] && [ -n "$BASE_URL" ]; then
            echo "  📄 $BASE_URL/wiki/pages/viewpage.action?pageId=$PAGE_ID"
        fi
    done
fi
echo ""
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  Demo complete${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════${NC}"
