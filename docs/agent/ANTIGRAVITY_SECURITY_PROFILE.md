# Antigravity Security Profile

## Required manual project settings

Enable Strict Mode, terminal sandboxing, and workspace isolation. Keep sandbox network access disabled by default. Remove wildcard project grants for commands, MCP, unsandboxed execution, reads, and writes. Keep browser interaction and MCP mutation methods approval-gated.

Strict Mode forces review for terminal, browser JavaScript, and artifact execution; it also disables non-workspace file access and enables sandboxing with network denied. Verify effective settings in the Antigravity UI after reopening the project.

## Repository protections

`.geminiignore` and `.gitignore` exclude local credential and agent-backup paths. They supplement, but do not replace, UI permission boundaries. Never place secrets in reports, rules, workflows, skills, or generated documentation.
