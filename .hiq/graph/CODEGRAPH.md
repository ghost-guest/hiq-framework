# CodeGraph (Cleboost/codegraph-rs via HiQ)

Engine: https://github.com/Cleboost/codegraph-rs  
Pinned: see `plugins/hiq/vendor/codegraph-rs.version`  
Binary: `~/.hiq/bin/codegraph` (installed by `$hiq-install` / `install-codegraph.sh`)

```bash
export PATH="$HOME/.hiq/bin:$PATH"
# or:
bash "$HOME/.hiq/scripts/codegraph.sh" <cmd>

codegraph init
codegraph status
codegraph index
codegraph sync
codegraph query <name>
codegraph files
codegraph context "implement X"
codegraph serve --mcp
```

Do not use a random `codegraph` on PATH if it is an old wrapper; prefer `~/.hiq/bin/codegraph`.
