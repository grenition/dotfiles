# Neovim configuration maintenance

Keep this configuration small, predictable, and portable. Apply these rules to
every change in this directory, including one-line fixes.

- Preserve the module boundaries: editor behavior belongs in `lua/config/`, and
  plugin declarations/integration belong in `lua/plugins/`.
- Prefer Neovim's built-in APIs and existing dependencies. Add a plugin only
  when it removes substantially more maintained code than it introduces.
- Use documented public APIs. If an internal plugin API is unavoidable, isolate
  it behind one small module, explain why, and verify it against the locked
  plugin revision.
- Keep plugin dependencies acyclic. Configure each plugin once and lazy-load it
  unless startup behavior genuinely requires eager loading.
- Do not add polling, timers, subprocesses, filesystem watchers, or global state
  without checking lifecycle and cost. Close every libuv handle on exit and
  avoid overlapping mechanisms for the same job.
- Never assume Homebrew paths or macOS commands. Gate platform-specific behavior
  with `vim.fn.has()` and `vim.fn.executable()`, and retain a working Linux
  fallback. Optional tools must degrade gracefully when absent.
- Keep runtime data, logs, caches, and downloaded artifacts under Neovim's
  `stdpath("state")`, `stdpath("cache")`, or `stdpath("data")`; do not leak them
  into the repository. The two tracked `*_selection.lua` preference files are
  deliberate exceptions.
- Preserve user-visible behavior unless the task explicitly changes it. Avoid
  duplicate mappings and autocmds, and keep callbacks buffer-local when their
  behavior is buffer-specific.
- Run `./scripts/check.sh` after every change. Also exercise the affected feature
  interactively when headless startup cannot cover it.
- Update `README.md` when requirements, mappings, supported languages, external
  tools, or platform behavior change.
