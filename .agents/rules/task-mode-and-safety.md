# Task Mode and Safety Boundaries

Classify the task before using tools or editing files.

- Explanation, planning, and diagnosis: explain or plan only; do not edit.
- Read-only audit: inspect and create only requested report artifacts; do not change source, configuration, tests, dependencies, or generated output.
- Implementation or refactoring: modify only the approved scope, validate it, and review the diff.
- Runtime QA and release validation: assess evidence; do not deploy.
- Deployment: operate only against the explicitly named environment with a rollback and post-deployment check.

Never reveal credentials or sensitive configuration. Do not access non-workspace files unless necessary and explicitly authorized. Do not install dependencies, mutate databases, run migrations, deploy, commit, push, reset, rebase, or rewrite history unless the task explicitly authorizes it. Treat every nested Git repository independently and preserve unrelated changes.

For a read-only task, record initial and final status for affected repositories and disclose any artifact created.
