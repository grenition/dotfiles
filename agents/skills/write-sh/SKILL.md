---
name: write-sh
description: Write or edit small shell scripts, keeping their logic direct and scoped to the task.
---

- Give each script one responsibility; compose scripts for larger tasks.
- Prefer direct commands, simple loops, and positional arguments over abstractions.
- Use POSIX sh by default; use Bash when its features are needed. Match the shebang.
- Quote variable expansions. Resolve repository paths relative to the script.
- Keep repeated runs predictable and preserve unrelated user files.
- Add backups, migrations, options, and defensive checks only for concrete task requirements.
- Print actions and version changes during installation or updates.
- Check syntax; run scripts only within the user's authorized scope.
