#!/usr/bin/env nu

# Mechanical workspace steps for the upstream kickstart.nvim merge runbook
# (`upstream_merge.md`).
#
# Parses the Log pointer, fetches, lists pending changes since the last
# merge, and after a completed review describes/moves/pushes. Does not
# choose or apply changes.

const LOG_REL = 'upstream_merge.md'
const POINTER_RE = 'Upstream through: `(?P<hash>[0-9a-f]{40})`'

def --wrapped jj-out [...args: string] {
  let result = (^jj --color never ...$args | complete)
  if $result.exit_code != 0 {
    let err = ($result.stderr | str trim)
    error make {
      msg: (if ($err | is-empty) { $"jj ($args | str join ' ') failed" } else { $err })
    }
  }
  $result.stdout
}

def repo-root [] {
  jj-out root | str trim
}

def log-path [] {
  (repo-root) | path join $LOG_REL
}

# First `Upstream through` full git id in the Log (newest entry).
def latest-pointer [] {
  let matches = (open --raw (log-path) | parse --regex $POINTER_RE)
  if ($matches | is-empty) {
    error make {
      msg: $"No full 'Upstream through' hash found in ($LOG_REL)"
      help: 'Each Log entry must contain: - Upstream through: `<40-char git id>`'
    }
  }
  $matches | first | get hash
}

def rev-id [rev: string] {
  jj-out log -r $rev --no-graph -T 'commit_id' | str trim
}

def rev-summary [rev: string] {
  jj-out log -r $rev --no-graph -T 'commit_id ++ "  " ++ description.first_line()' | str trim
}

def wc-is-empty [] {
  (jj-out log -r '@' --no-graph -T 'empty' | str trim) == 'true'
}

# Fail unless `master` is an ancestor of the working copy.
def ensure-on-master [] {
  let span = (jj-out log -r 'master::@' --no-graph -T 'commit_id ++ "\n"' | str trim)
  if ($span | is-empty) {
    error make {
      msg: 'Working copy is not on the master bookmark line'
      help: 'Switch to a change that has `master` as an ancestor.'
    }
  }
}

# Print the pending upstream changes since the last merge (diff, not commits).
def print-pending [] {
  let pointer = (latest-pointer)
  let head = (rev-id 'master@upstream')
  print $"Last reviewed:  (rev-summary $pointer)"
  print $"Upstream HEAD:  (rev-summary 'master@upstream')"

  if $pointer == $head {
    print 'No pending changes; already up to date with master@upstream'
    return
  }

  print ''
  print 'Pending changes since last merge:'
  print (jj-out diff --from $pointer --to 'master@upstream' --stat | str trim)
  print ''
  print (jj-out diff --from $pointer --to 'master@upstream' | str trim)
}

# Fetch `upstream` and print pending changes since the last merge.
#
# Requires an empty working copy whose ancestors include `master`. Refuses a
# dirty `@`. Does not apply diffs, update the Log, or push.
def "main prepare" [] {
  ensure-on-master
  if not (wc-is-empty) {
    let stat = (jj-out diff --stat | str trim)
    error make {
      msg: 'Working copy is not empty'
      help: $"Finish or abandon current work first.\n($stat)"
    }
  }

  print 'Fetching upstream...'
  ^jj git fetch --remote upstream
  print ''
  print-pending
  print ''
  print 'Translate accepted changes into this tree. Do not cherry-pick.'
  print 'When in doubt, ask. Record applied and skipped changes in the Log.'
  print 'When the merge is complete:'
  print '  nu scripts/upstream_merge.nu finish'
}

# Reprint pending changes since the last merge. Does not fetch or change the repo.
def "main status" [] {
  print-pending
}

# Describe `@`, move `master`, and push after a completed Log update.
#
# Requires `@` nonempty, `upstream_merge.md` in the change, and the latest
# **Upstream through** hash equal to `master@upstream`. Then describes `@`
# (unless already set, or `--message` is passed), moves `master` to `@`,
# starts a new empty working copy, and pushes `origin` (unless `--no-push`).
def "main finish" [
  --no-push # Move `master` locally but do not push `origin`
  --message (-m): string = '' # Working-copy description; default is generated from the Log pointer
] {
  ensure-on-master
  if (wc-is-empty) {
    error make {
      msg: 'Working copy is empty; expected a Log update and any ported changes'
    }
  }

  let changed = (
    jj-out diff --from '@-' --to '@' --name-only
    | lines
    | compact
  )
  if not ($LOG_REL in $changed) {
    error make {
      msg: $"($LOG_REL) is not part of the working-copy change"
      help: 'Prepend a Log entry with decisions before finishing.'
    }
  }

  let pointer = (latest-pointer)
  let head = (rev-id 'master@upstream')
  if $pointer != $head {
    error make {
      msg: 'Log pointer does not match master@upstream'
      help: $"Log has ($pointer); upstream HEAD is ($head). Advance Upstream through only when the merge is complete."
    }
  }

  let short = (jj-out log -r $pointer --no-graph -T 'commit_id.short()' | str trim)
  let description = (
    if ($message | is-not-empty) {
      $message
    } else {
      let current = (jj-out log -r '@' --no-graph -T 'description' | str trim)
      if ($current | is-not-empty) {
        $current
      } else {
        $"Port selected upstream kickstart.nvim changes through ($short)"
      }
    }
  )
  print $"Describing @ as: ($description)"
  ^jj describe -m $description

  print $"Moving master -> ($short)"
  ^jj bookmark move master --to '@'

  print 'Starting a new empty working copy on master'
  ^jj new

  if $no_push {
    print 'Skipping push (--no-push)'
    return
  }

  print 'Pushing origin/master'
  ^jj git push --remote origin --bookmark master
}

# Mechanical helper for the upstream kickstart.nvim merge in `upstream_merge.md`.
#
# Intent: parse the Log pointer, fetch, list pending changes since the last
# merge, and after a completed review describe / move `master` / push. Does
# not choose, port, or cherry-pick changes — that is a human/agent
# translation recorded in the Log. Commits are a cursor, not the unit of work.
#
# Commands:
#   prepare  Empty working copy on `master`, fetch `upstream`, print pending
#            changes since the last merge. Default if no subcommand.
#   status   Reprint those pending changes without fetching or changing the repo.
#   finish   Require a Log entry whose pointer equals `master@upstream`, then
#            describe `@`, move `master`, start a new empty change, push
#            `origin`. Flags: --no-push, -m/--message.
#
# Decision log and process: `upstream_merge.md`.
def main [] {
  main prepare
}
