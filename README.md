# setup

## Claude Code plugins

```bash
./claude-plugins.sh
```

Installs ponytail, superpowers, claude-mem, caveman, and the Context7 MCP server.
Restart Claude Code afterwards so the hooks load.

Equivalent slash commands, if you'd rather run them inside a session:

```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail

/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace

/plugin marketplace add thedotmack/claude-mem
/plugin install claude-mem@thedotmack

/plugin marketplace add JuliusBrussee/caveman
/plugin install caveman@caveman
```

Context7 has no `/plugin` equivalent — it's an MCP server, added via the script
or `claude mcp add --transport http context7 https://mcp.context7.com/mcp`.

**Enable 2-3 at a time.** Each plugin adds to the context-window baseline, and
ponytail + caveman together push hard toward terseness in a way that fights
superpowers' spec/TDD output. `claude plugin disable <name>` toggles them off.
