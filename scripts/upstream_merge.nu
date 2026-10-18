#!/usr/bin/env nu

# Mechanical steps for the upstream merge runbook (`upstream_merge.md`).
#
# Fetches upstream and lists pending changes. After a completed review,
# records `master@upstream` as a second parent while keeping this tree,
# then moves `master` and pushes. Does not choose or port changes.

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

def parent-ids [] {
  jj-out log -r 'parents(@)' --no-graph -T 'commit_id ++ "\n"' | lines | compact
}

def upstream-is-ancestor [rev: string] {
  let span = (jj-out log -r $"master@upstream::($rev)" --no-graph -T 'commit_id' | str trim)
  not ($span | is-empty)
}

# `@` is the bad merge. Put the working copy back on `port` and drop the merge.
def undo-merge [port: string] {
  let bad = (jj-out log -r @ --no-graph -T 'change_id' | str trim)
  ^jj edit $port
  ^jj abandon $bad
}

# Second parent = `master@upstream`, tree = `port`. No-op if already an ancestor.
def record-upstream-parent [port: string] {
  if (upstream-is-ancestor '@') {
    return
  }
  let parents = (parent-ids)
  if ($parents | length) != 1 {
    error make { msg: 'Working copy must have one parent before recording upstream' }
  }
  let first = ($parents | first)

  print 'Recording master@upstream as a second parent; keeping our tree'
  ^jj new $first 'master@upstream'
  let restored = (^jj restore --from $port | complete)
  if $restored.exit_code != 0 {
    undo-merge $port
    let err = ($restored.stderr | str trim)
    error make { msg: (if ($err | is-empty) { 'jj restore failed' } else { $err }) }
  }

  let conflict = (jj-out log -r @ --no-graph -T 'conflict' | str trim) == 'true'
  let drifted = (jj-out diff --from $port --to @ --name-only | lines | compact | is-empty) == false
  let after = (parent-ids)
  let parents_ok = if ($after | length) == 2 {
    ($after | first) == $first and ($after | get 1) == (rev-id 'master@upstream')
  } else {
    false
  }
  if $conflict or $drifted or not $parents_ok {
    undo-merge $port
    error make { msg: 'Merge did not keep our tree and parent order; restored the previous change' }
  }
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

# Print the pending upstream diff since the last review.
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

# Fetch `upstream` and print pending changes. Requires an empty `@` on `master`.
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
  print 'Port accepted changes into this tree. Do not cherry-pick or content-merge.'
  print 'Then record them in the Log and run: nu scripts/upstream_merge.nu finish'
}

# Reprint pending changes. Does not fetch or change the repo.
def "main status" [] {
  print-pending
}

# Record `master@upstream` as a second parent, move `master`, and push.
#
# The Log pointer must equal `master@upstream`. `@` must change
# `upstream_merge.md`, unless it is empty and upstream is not yet an ancestor
# (ancestry only; no new Log entry). Tree stays ours. Flags: --no-push, -m.
def "main finish" [
  --no-push # Move `master` locally but do not push `origin`
  --message (-m): string = '' # Commit description; default is generated from the Log pointer
] {
  ensure-on-master

  let pointer = (latest-pointer)
  let head = (rev-id 'master@upstream')
  if $pointer != $head {
    error make {
      msg: 'Log pointer does not match master@upstream'
      help: $"Log has ($pointer); upstream HEAD is ($head). Advance Upstream through only when the review is complete."
    }
  }

  let ancestry_only = (wc-is-empty)
  if $ancestry_only {
    if (upstream-is-ancestor '@') {
      error make { msg: 'Working copy is empty and master@upstream is already an ancestor' }
    }
  } else {
    let changed = (jj-out diff --from '@-' --to '@' --name-only | lines | compact)
    if not ($LOG_REL in $changed) {
      error make {
        msg: $"($LOG_REL) is not part of the working-copy change"
        help: 'Prepend a Log entry with decisions before finishing.'
      }
    }
  }

  let short = (jj-out log -r $pointer --no-graph -T 'commit_id.short()' | str trim)
  let current = (jj-out log -r '@' --no-graph -T 'description' | str trim)
  let description = if ($message | is-not-empty) {
    $message
  } else if ($current | is-not-empty) {
    $current
  } else if $ancestry_only {
    $"Record upstream ancestry through ($short)"
  } else {
    $"Port selected upstream kickstart.nvim changes through ($short)"
  }

  let port = (rev-id '@')
  record-upstream-parent $port
  print $"Describing @ as: ($description)"
  ^jj describe -m $description
  print $"Moving master -> ($short)"
  ^jj bookmark move master --to '@'
  if $port != (rev-id '@') {
    ^jj abandon $port
  }

  print 'Starting a new empty working copy on master'
  ^jj new
  if $no_push {
    print 'Skipping push (--no-push)'
    return
  }
  print 'Pushing origin/master'
  ^jj git push --remote origin --bookmark master
}

# Fetch upstream, list pending changes, and after review record upstream as a
# second parent while keeping this tree. Does not choose or port changes.
# Decision log: `upstream_merge.md`.
def main [] {
  main prepare
}
