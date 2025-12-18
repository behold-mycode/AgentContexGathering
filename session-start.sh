#!/bin/bash

# Context Intelligence System - Session Start Hook
# Minimal output - tells agent WHERE context is, not WHAT it contains

# Find repo root by walking up to find .claude directory
find_repo_root() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.claude" ]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    echo "$PWD"
}

REPO_ROOT=$(find_repo_root)
CONTEXT_DIR="$REPO_ROOT/.claude/context"
ACTIVE_FILE="$CONTEXT_DIR/.active"

main() {
    if [ -f "$ACTIVE_FILE" ]; then
        local active_context=$(cat "$ACTIVE_FILE")
        local context_path="$CONTEXT_DIR/$active_context"

        if [ -d "$context_path" ]; then
            echo "═══════════════════════════════════════════════════════"
            echo "  ACTIVE CONTEXT: $active_context"
            echo "═══════════════════════════════════════════════════════"
            echo ""
            echo "Context files to read BEFORE writing code:"
            [ -f "$context_path/types.md" ] && echo "  → $context_path/types.md"
            [ -f "$context_path/patterns.md" ] && echo "  → $context_path/patterns.md"
            [ -f "$context_path/overview.md" ] && echo "  → $context_path/overview.md"
            echo ""
            echo "REMINDER: Output the Context Acknowledgment Block before coding."
            echo "See .claude/rules/context-awareness.md for requirements."
            echo "═══════════════════════════════════════════════════════"
        else
            echo "No active context. Run /context to gather context for your task."
        fi
    else
        echo "No active context. Run /context to gather context for your task."
    fi
}

main
