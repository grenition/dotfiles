-- Filesystem-only detection of the project's Python interpreter for pyright:
-- .venv/venv in the project root first, then Poetry's cached virtualenvs. No
-- subprocesses are spawned; a missing environment degrades to pyright's
-- default (system) interpreter.
local M = {}

local function project_root()
  return vim.fs.root(0, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt" })
end

local function python_bin(path)
  local stat = vim.uv.fs_stat(path)
  if stat and stat.type == "file" and vim.fn.executable(path) == 1 then
    return path
  end
  return nil
end

local function venv_in(root, name)
  return python_bin(vim.fs.joinpath(root, name, "bin", "python"))
end

local function project_name(root)
  local file = io.open(vim.fs.joinpath(root, "pyproject.toml"), "r")
  if not file then
    return vim.fs.basename(root)
  end

  local name
  for line in file:lines() do
    name = string.match(line, '^name%s*=%s*"([^"]+)"')
    if name then
      break
    end
  end
  file:close()
  return name or vim.fs.basename(root)
end

-- Poetry stores virtualenvs in a per-platform cache as <name>-<hash>-<py>.
-- When several match (e.g. recreated venvs), prefer the newest pyvenv.cfg.
local function poetry_venv(root)
  local home = vim.fn.expand("~")
  local mac = vim.fs.joinpath(home, "Library", "Caches", "pypoetry", "virtualenvs")
  local linux = vim.fs.joinpath(home, ".cache", "pypoetry", "virtualenvs")
  local caches = vim.fn.has("mac") == 1 and { mac, linux } or { linux, mac }

  local prefix = "^" .. vim.pesc(project_name(root)) .. "-"
  local best, best_mtime = nil, -1
  for _, cache in ipairs(caches) do
    if vim.uv.fs_stat(cache) then
      for name, type in vim.fs.dir(cache) do
        if type == "directory" and string.match(name, prefix) then
          local base = vim.fs.joinpath(cache, name)
          local python = python_bin(vim.fs.joinpath(base, "bin", "python"))
          local cfg = python and vim.uv.fs_stat(vim.fs.joinpath(base, "pyvenv.cfg"))
          local mtime = cfg and cfg.mtime.sec or 0
          if python and mtime > best_mtime then
            best, best_mtime = python, mtime
          end
        end
      end
    end
  end
  return best
end

local function interpreter_for(root)
  return venv_in(root, ".venv") or venv_in(root, "venv") or poetry_venv(root)
end

-- Short virtualenv label for the statusline. ".venv"/"venv" directories
-- show as-is; Poetry cache directories (<project>-<hash>-py3.11) drop the
-- hash and Python suffix; no environment means "system".
function M.name()
  local root = project_root()
  local interpreter = root and interpreter_for(root) or nil
  if not interpreter then
    return "system"
  end

  local name = vim.fs.basename(vim.fs.dirname(vim.fs.dirname(interpreter)))
  if name ~= ".venv" and name ~= "venv" then
    -- Poetry cache dirs are <project>-<hash>-py3.14; drop the hash and the
    -- Python suffix, keeping plain <project>-py3.14 and other names intact.
    name = string.match(name, "^(.+)%-[A-Za-z0-9_]+%-py%d+%.%d+$") or string.match(name, "^(.+)%-py%d+%.%d+$") or name
  end
  if name == "" then
    return "system"
  end
  return name
end

function M.interpreter()
  local root = project_root()
  return root and interpreter_for(root) or nil
end

function M.settings()
  local root = project_root()
  if not root then
    return nil
  end

  local interpreter = interpreter_for(root)
  if not interpreter then
    return nil
  end

  local src = vim.fs.joinpath(root, "src")
  return {
    python = {
      pythonPath = interpreter,
      analysis = {
        extraPaths = vim.uv.fs_stat(src) and { src } or {},
      },
    },
  }
end

return M
