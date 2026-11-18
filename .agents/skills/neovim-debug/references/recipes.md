# Neovim probe recipes

Stay in the working directory containing `.nvim_socket`. Set `PROBE` to the absolute path to the skill’s `scripts/probe.lua`.

```sh
probe() { nvim --clean --headless -l "$PROBE" "$@"; }
probe state
```

Apply a shell-tool deadline to every invocation. If GNU `timeout` is available, put `timeout 5s` before `nvim` inside the helper. The examples inspect the current context unless given an explicit ID. For a follow-up on a live session, pass the observed ID as an argument, convert it with `tonumber`, and verify it is still valid with `nvim_buf_is_valid` or `nvim_win_is_valid`.

## Options: what value is in effect, and who last set it?

```sh
probe stdin shiftwidth <<'LUA'
local name = ...
local api = vim.api
local info = api.nvim_get_option_info2(name, {})
local script
if info.last_set_sid > 0 then
  local entry = vim.fn.getscriptinfo({ sid = info.last_set_sid })[1]
  script = entry and entry.name
end
return {
  option = name,
  buf = api.nvim_get_current_buf(),
  win = api.nvim_get_current_win(),
  effective = api.nvim_get_option_value(name, {}),
  global = api.nvim_get_option_value(name, { scope = "global" }),
  local_value = info.scope ~= "global"
    and api.nvim_get_option_value(name, { scope = "local" }) or nil,
  scope = info.scope,
  global_local = info.global_local,
  last_set_sid = info.last_set_sid,
  last_set_line = info.last_set_linenr,
  last_set_channel = info.last_set_chan,
  script = script,
}
LUA
```

For boolean options, preserve a false local value explicitly: compute `local_value` in an `if` block before constructing the result table rather than using an `and`/`or` expression. An inherited local value can also be an option-specific sentinel; don't equate it with the effective value. For human-readable provenance, use a literal listing command:

```sh
probe lua 'return vim.api.nvim_exec2("verbose set shiftwidth?", {output=true}).output'
```

An absent source location is not proof the option was never set. Do not use the `filetype` argument to `nvim_get_option_value` for passive inspection: it can execute `FileType` autocmds.

## Autocmds: what is registered for this event?

```sh
probe stdin BufEnter <<'LUA'
local event = ...
local all = vim.api.nvim_get_autocmds({ event = event })
local rows = {}
for i = 1, math.min(#all, 40) do
  local a = all[i]
  local callback, source = a.callback
  if type(callback) == "function" then
    local s = debug.getinfo(callback, "S")
    if s and s.source:sub(1, 1) == "@" then
      source = { path = s.source:sub(2), line = s.linedefined }
    end
  end
  rows[i] = {
    id = a.id, group = a.group_name, pattern = a.pattern,
    buf = a.buf or a.buffer, once = a.once,
    callback_type = type(callback), callback_source = source,
  }
end
return { event = event, total = #all, entries = rows }
LUA
```

Filter further by `group` if the result is capped. A registered handler is not proof it fired or matched a particular buffer. For definition-site provenance try `:verbose autocmd BufEnter` through `nvim_exec2`; it can expose command bodies. Lua definition-site provenance can be missing if verbosity wasn't enabled when the handler was defined. A callback’s source is where the function was defined, not necessarily where it was registered.

## Keymaps: what is the exact mapping in the current buffer?

Replace `<Space>x` with the actual key sequence and `n` with the relevant mode.

```sh
probe stdin '<Space>x' n <<'LUA'
local lhs, mode = ...
local m = vim.fn.maparg(lhs, mode, 0, 1)
return {
  buf = vim.api.nvim_get_current_buf(),
  found = next(m) ~= nil,
  lhs = m.lhs, desc = m.desc, buffer_local = m.buffer,
  sid = m.sid, line = m.lnum, expr = m.expr, nowait = m.nowait,
  lua_callback = type(m.callback) == "function",
}
LUA
```

`maparg()` checks an exact mapping, preferring a buffer-local definition. If this doesn't explain the behavior, compare `nvim_buf_get_keymap(buf, mode)` with `nvim_get_keymap(mode)` for longer mappings that share the same prefix. `:verbose nmap <Space>x` can show provenance and the RHS; use it only if needed. Never execute an expression mapping as a probe.

## LSP: is a client active, and is it attached here?

```sh
probe stdin <<'LUA'
local buf = vim.api.nvim_get_current_buf()
local lsp = rawget(package.loaded, "vim.lsp")
local clients = {}
if not lsp then return { buf = buf, lsp_loaded = false, clients = clients } end

local attached = {}
for _, c in ipairs(lsp.get_clients({ bufnr = buf })) do
  attached[c.id] = true
end
local all = lsp.get_clients()
for i = 1, math.min(#all, 40) do
  local c = all[i]
  clients[i] = {
    id = c.id, name = c.name, initialized = c.initialized,
    attached_here = attached[c.id] == true,
    root_dir = type(c.root_dir) == "string" and c.root_dir or nil,
  }
end
return { buf = buf, lsp_loaded = true, active = #all, clients = clients }
LUA
```

An active client elsewhere is not an attachment to this buffer. Compare the filetype from `state`, the client root, and recent startup messages before concluding why attachment failed. Don't serialize whole client objects: they contain methods and internal state.

## UI and highlights: global definition or window override?

```sh
probe stdin Normal <<'LUA'
local group = ...
local api = vim.api
local win = api.nvim_get_current_win()
local win_ns = api.nvim_get_hl_ns({ winid = win })
local active_ns = api.nvim_get_hl_ns({})
local ns = win_ns >= 0 and win_ns or active_ns
return {
  win = win,
  winhighlight = api.nvim_get_option_value("winhighlight", { win = win }),
  win_ns = win_ns, active_ns = active_ns,
  global = api.nvim_get_hl(0, { name = group, link = true, create = false }),
  namespace_definition = ns > 0
    and api.nvim_get_hl(ns, { name = group, link = true, create = false })
    or nil,
}
LUA
```

Keep `create = false`: a lookup should not create a missing highlight group. Use `link = false` to inspect attributes instead of the link. `state` lists attached UIs and their capabilities; neither probe tells you what was rendered in a particular screen cell.

## Extmarks: is a decoration present without reading its text?

Omit the namespace argument to sample all namespaces, or pass an exact name to narrow the query. The probe returns only IDs and coordinates.

```sh
probe stdin <<'LUA'
local name = ...
local api = vim.api
local buf = api.nvim_get_current_buf()
local ns = -1
if name then
  ns = api.nvim_get_namespaces()[name]
  if not ns then return { namespace = name, found = false } end
end
local limit = 40
local marks = api.nvim_buf_get_extmarks(buf, ns, 0, -1, { limit = limit })
return { buf = buf, ns = ns, cap_reached = #marks == limit, marks = marks }
LUA
```

To narrow by location, replace `0, -1` with an inclusive range of `{row, byte_col}` pairs, both zero-based. A cap hit means there may be more marks. An empty result does not rule out ephemeral decorations created during redraw. Avoid `details = true` by default: details can contain virtual text.

## Runtime and plugin loading: discoverable or already loaded?

```sh
probe stdin example.plugin lua/example/plugin.lua <<'LUA'
local module, path = ...
local value = rawget(package.loaded, module)
return {
  module = module,
  loaded = not not value,
  loaded_type = type(value),
  runtime_matches = vim.api.nvim_get_runtime_file(path, false),
}
LUA
```

Try `lua/example/plugin/init.lua` as a separate candidate if appropriate. A runtime-path match does not prove a module was loaded; `package.loaded` only answers for that exact module key. If inspecting internals, use `rawget` on a known table and return selected scalar fields. Do not call getters or `require` the module just to check its state.

## Messages and disposable reproduction

`probe messages` retrieves the latest 20 retained messages. This is message history, not a complete startup or LSP trace. Capture it soon after the symptom and redact paths or secrets before sharing.

For a clean-versus-configured comparison, use the same Neovim binary and repeat the same trigger in separate private working directories. Start a clean baseline with `--clean --listen ./.nvim_socket` from its directory, and run probes from the corresponding directory. For a configured reproduction, omit `--clean`; use `-u /absolute/path/to/minimal.lua` when narrowing the config. Use `-i NONE` if shared ShaDa isn't part of the problem. For startup provenance use `-V1"$DIR/startup.log"`; for performance use `--startuptime "$DIR/timing.log"`. Those change observation conditions and may write sensitive paths. Keep the reproduction interactive if the issue depends on a TUI or GUI.

If `.nvim_socket` is missing, report that to the user and stop. For other `socket` errors, check the file type and permissions in the current directory. If it fails at `connect`, the path can be stale even when it is a socket; don't delete it from the probe. An `rpc` failure can mean target-side Lua/API error or disconnection. An output-size failure calls for a smaller query, not a larger dump.

## Smoke test

Set `PROBE` as above and run with GNU `timeout` available. On macOS with GNU coreutils, substitute `gtimeout`. This launches and cleans up only its own disposable target.

```sh
(
	set -eu
	dir=$(mktemp -d /tmp/nvim-probe.XXXXXXXX)
	cd "$dir"
	pid=
	trap 'if [ -n "$pid" ]; then kill "$pid" 2>/dev/null || :; wait "$pid" 2>/dev/null || :; fi; rm -f "$dir/.nvim_socket" "$dir/target.log"; rmdir "$dir"' EXIT

	run() { timeout 5s nvim --clean --headless -l "$PROBE" "$@"; }
	rc=0
	missing=$(run state 2>&1) || rc=$?
	[ "$rc" -eq 1 ]
	[[ "$missing" == *'.nvim_socket does not exist in the current working directory'* ]]

	nvim --clean --headless --listen ./.nvim_socket </dev/null >target.log 2>&1 &
	pid=$!

	i=0
	while [ ! -S .nvim_socket ]; do
		i=$((i + 1))
		if [ "$i" -ge 100 ]; then
			cat target.log >&2
			exit 1
		fi
		sleep 0.05
	done

	run state
	[ "$(run lua 'return vim.fn.getpid()')" = "$pid" ]
	[ "$(run stdin 'a b' <<<'return ...')" = '"a b"' ]
	[ "$(run lua 'return false')" = false ]
	[ "$(run lua 'return nil')" = null ]
	rc=0
	run lua 'error("expected smoke-test error")' || rc=$?
	[ "$rc" -eq 1 ]
	printf '%s\n' 'Smoke test passed'
)
```

The smoke test uses a Bash here-string; run it in Bash.

## Upstream reference

- [Neovim startup flags and Lua script mode](https://neovim.io/doc/user/starting/)
- [Neovim API and MessagePack-RPC](https://neovim.io/doc/user/api/)
- [Neovim channels and RPC trust](https://neovim.io/doc/user/channel/)
- [Neovim LSP client API](https://neovim.io/doc/user/lsp/)
