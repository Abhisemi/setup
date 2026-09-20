#!/usr/bin/env bash
# Installs the Claude Code plugin stack. Commands verified 2026-09-20.
set -euo pipefail

add() { claude plugin marketplace add "$1"; }
install() { claude plugin install "$1"; }

# ponytail        - YAGNI / stdlib-first minimalism, injected into subagents too
# superpowers     - plan -> spec -> TDD -> execute methodology (/brainstorm, /write-plan)
# claude-mem      - persistent memory across sessions
# caveman         - terse output mode, ~65% fewer output tokens
add DietrichGebert/ponytail
add obra/superpowers-marketplace
add thedotmack/claude-mem          # marketplace registers as "thedotmack"
add JuliusBrussee/caveman

install ponytail@ponytail
install superpowers@superpowers-marketplace
install claude-mem@thedotmack
install caveman@caveman

# context7 is an MCP server, not a plugin -- `plugin install context7` fails.
# Drop --scope user for project-local instead.
claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp

claude plugin list
