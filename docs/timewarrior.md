# Timewarrior

[Timewarrior](https://timewarrior.net) is a command-line time tracker. These
dotfiles wrap it across four surfaces so you can start, stop and see tracking
without breaking flow.

## Install

Not captured in a Brewfile, so install once per machine:

```sh
brew install timewarrior
```

The integrations degrade gracefully — the prompt and tmux indicators simply
show nothing if `timew` isn't installed.

## Syncing between machines

Timewarrior reads `TIMEWARRIORDB` to locate its **entire** database — both the
interval data and `timewarrior.cfg` — in one folder. Point that at a Google
Drive folder so all machines share one database.

The path contains your Drive account, so keep it in `~/.zshenv.local` (personal,
sourced by `zshenv`) rather than this public repo:

```sh
# ~/.zshenv.local — NOT committed to the public dotfiles repo
_gdrive="$HOME/Library/CloudStorage/GoogleDrive-you@example.com/My Drive"
[ -d "$_gdrive" ] && export TIMEWARRIORDB="$_gdrive/timewarrior"
```

Because it's exported from `zshenv`, the prompt indicator, the tmux script and
terminal-launched Neovim all inherit it. The guard means a machine without
Drive falls back to timew's default local location.

### Setting up a new machine

1. `brew install timewarrior`
2. Install Google Drive for Desktop and sign in.
3. Add the export above to `~/.zshenv.local`.
4. Wait for the `timewarrior/` folder to sync down, then open a new shell.

That's it — the guarded export finds the synced folder; no re-init needed.

### Keep it healthy

- **Make the folder "Available offline"** in Drive for Desktop so timew reads
  real local files (not streamed placeholders) — this also keeps the
  every-prompt and 15s-tmux reads fast.
- **Track on one machine at a time** and let Drive settle before switching.
  Concurrent writes can produce "conflicted copy" files that timew silently
  ignores — the one real risk of syncing a live database over any file-sync
  service.

> Migrating existing data? Copy your old DB into the Drive folder before the
> first run: `cp -a ~/.local/share/timewarrior/. "$TIMEWARRIORDB"/`.

## Core concepts

Timewarrior tracks **intervals**, each labelled with one or more **tags**. One
interval is "active" at a time.

```sh
timew start Acme "Rocket Skates"  # begin tracking, tagged "Acme" and "Rocket Skates"
timew stop                        # stop the active interval
timew continue                    # resume the most recent interval
timew summary :day                # report today's tracked time
timew cancel                      # discard the active interval (no record kept)
```

Ranges like `:day`, `:week`, `:month` and `:lastweek` work with `summary`.

### Tags vs annotations

An interval carries two kinds of metadata, and they serve different jobs:

|           | Tags                                           | Annotation                              |
| --------- | ---------------------------------------------- | --------------------------------------- |
| How many  | Many per interval                              | One free-text string per interval       |
| Purpose   | Categorize — the axis you filter and report on | A note describing _this_ interval       |
| On repeat | Each `tag` adds to the set                     | Re-annotating **replaces** the previous |
| Filtering | `timew summary Acme` filters by tag            | Not a filter dimension                  |

Use **tags** for your reusable vocabulary — the things you'll want summed up in
reports (project, client, activity type). Keep them short and consistent:

```sh
tws Acme "Rocket Skates"   # start, tagged
tw tag @1 bugfix           # add another tag to an interval
tw untag @1 bugfix         # remove one
```

Use the **annotation** for the one-off detail of what you actually did — the
sentence you'd want when reviewing later, not a category:

```sh
tw annotate @1 "rocket boosters kept detaching mid-run"
tw day :annotations    # reports collapse annotation text unless you ask
```

Rule of thumb: if you'll ever want to sum or filter by it, make it a tag; if
it's a description of this specific session, make it the annotation.

### Tagging conventions

Tags do the real work — they're the axes you report and bill on — so keep them
consistent. Annotations are optional; reach for one only when an interval needs
context the tags don't capture.

- **Customer and project as separate tags.** Because tags are a set, tagging
  both gives you every aggregation axis for free: sum by customer across all
  their projects, or by a single project.

  ```sh
  tws Acme "Rocket Skates"   # per-customer AND per-project reporting
  ```

- **Ticket ids are tags too, not annotations.** You'll usually want to sum time
  against a ticket, and only tags are filterable.

  ```sh
  tws Acme "Rocket Skates" ACME-123
  tw week ACME-123             # total time on that ticket
  ```

- **Quote multi-word tags** — unquoted, they split into separate tags
  (`Rocket Skates` → `Rocket` + `Skates`). Or adopt no-space names (`RocketSkates`)
  to sidestep it.

- **Tags are case-sensitive** (`acme` ≠ `Acme`). Pick a casing and
  stick to it; run `tw tags` to review what you've used and catch drift.

- **Annotations are for the exceptional** — a note on what specifically got
  done, or why an interval is unusual. Skip them for routine tracking.

  ```sh
  tw annotate @1 "anvil arrived flat-packed; some assembly required"
  ```

## Shell

`tw` is a function (`zsh/functions/tw`) that mirrors the `g` git helper:

| Command     | Runs                 | Notes                            |
| ----------- | -------------------- | -------------------------------- |
| `tw`        | `timew summary :day` | bare invocation = today's report |
| `tw <args>` | `timew <args>`       | proxies anything through         |

Aliases (`aliases`) cover the common verbs:

| Alias | Runs                  |
| ----- | --------------------- |
| `tws` | `timew start`         |
| `twx` | `timew stop`          |
| `twc` | `timew continue`      |
| `tww` | `timew summary :week` |

```sh
tws Acme "Rocket Skates"   # start
tw                         # check today so far
twx                        # stop
```

## Prompt

When a timer is running, the zsh prompt appends a stopwatch and the first tag,
next to the git branch:

```
~/projects/acme main ⏱ Acme %
```

Defined by `timew_prompt_info` in `zsh/configs/prompt.zsh`. It's a single
`timew` call per prompt render and no-ops when idle.

## tmux

The tmux `status-right` (`tmux.conf`) shows the active interval, refreshed
every 15 seconds via `bin/timew-tmux`:

```
⏱ Acme Rocket Skates 0:42:17
```

The line is blank when nothing is tracked. Reload after editing config with:

```sh
tmux source-file ~/.tmux.conf
```

## Neovim

Custom module `config/nvim/lua/richvim/core/timewarrior.lua`. Commands run
asynchronously (`vim.system`) and report via notifications.

### Commands

| Command                 | Action                                             |
| ----------------------- | -------------------------------------------------- |
| `:TimewStart [tags]`    | Start tracking. No tags → defaults to project name |
| `:TimewStop`            | Stop the active interval                           |
| `:TimewContinue`        | Resume the most recent interval                    |
| `:TimewStatus`          | Show the active interval                           |
| `:TimewSummary [range]` | Report (default `:day`)                            |

`:TimewStart` with no arguments tags the interval with the **project name** —
the git root basename, falling back to the working directory basename.

### Keymaps

All under the `<leader>w` ("warrior") namespace:

| Keys         | Action                      |
| ------------ | --------------------------- |
| `<leader>ws` | Start (tagged with project) |
| `<leader>wS` | Start, prompting for tags   |
| `<leader>wx` | Stop                        |
| `<leader>wc` | Continue                    |
| `<leader>ww` | Status                      |
| `<leader>wd` | Day summary                 |

## Retrospective & corrections

Forgot to start a timer, or need to fix one after the fact? Timewarrior edits
the record directly. All of these flow through the `tw` wrapper.

### Record a completed past block

`track` logs an interval that has already finished, given a start and end:

```sh
tw track 9am - 10:30am Acme "Rocket Skates"         # today, 9:00–10:30
tw track 2026-07-20T09:00 - 2026-07-20T11:00 Acme   # a specific day
```

### Find interval ids

Corrections target an interval by `@id`. List them first — ids are
**positional and renumber** as intervals are added, so always re-check before
editing:

```sh
tw week :ids                # or: timew summary :day :ids
```

### Fix a forgotten stop or wrong times

```sh
tw modify end @1 17:00      # you left @1 running — cap its end time
tw modify start @3 9:15     # @3 started earlier/later than recorded
tw move @2 8:00             # shift @2 to begin at 08:00
```

### Handle overlaps

A retro entry that would overlap an existing interval is refused unless you add
the `:adjust` hint, which trims the neighbouring intervals to make room:

```sh
tw track 9am - 10am Acme :adjust
```

### Undo a fumble

`undo` reverts the last change (one command at a time):

```sh
tw undo
```

> `track` for completed blocks is shell-only by design. The Neovim
> `:TimewStart` accepts a past _start_ time (`:TimewStart 9am Acme`), but
> retrospective edits are fiddlier than a keymap warrants — reach for the shell.

## Typical flow

```
# terminal, entering a project
tws                     # or <leader>ws in Neovim — tags with project name
                        # prompt + tmux now show ⏱
# ... work ...
twx                     # stop when switching context
tw                      # review the day
```
