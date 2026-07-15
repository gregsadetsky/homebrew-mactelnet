# homebrew-mactelnet

A Homebrew tap for [MAC-Telnet](https://github.com/haakonnessjoen/MAC-Telnet) by
Håkon Nessjøen — tools for talking to MikroTik RouterOS devices over **Layer 2**
(raw ethernet / MAC address), no IP configuration required.

This tap exists purely to make the upstream project easy to install on macOS.
All credit for the software goes to the upstream authors; nothing here modifies
their code (see "What this tap changes" below).

## Install

```sh
brew trust gregsadetsky/mactelnet          # one-time, Homebrew ≥ 6 requires trusting third-party taps
brew install gregsadetsky/mactelnet/mactelnet
```

Or the two-step form:

```sh
brew tap gregsadetsky/mactelnet
brew install mactelnet
```

To build the latest upstream git HEAD instead of the pinned release:

```sh
brew install --HEAD gregsadetsky/mactelnet/mactelnet
```

## What you get

| Binary       | What it does |
|--------------|--------------|
| `mactelnet`  | Telnet-style console to a RouterOS device by MAC address or identity (`mactelnet -l` discovers devices) |
| `mndp`       | Listens for MikroTik Neighbor Discovery broadcasts (Ctrl-C to stop) |
| `macping`    | Ping a device by MAC address |
| `mactelnetd` | Daemon that lets this machine *accept* MAC-telnet sessions (config: `$(brew --prefix)/etc/mactelnetd.users`) |

Quick start on a LAN with MikroTik gear:

```sh
mactelnet -l -t 5           # discover: prints IP, MAC, identity, RouterOS version
mactelnet <identity-or-MAC> # connect; prompts for RouterOS login/password
```

## What this tap changes relative to upstream

- **No source changes.** The formula builds the pristine `v0.6.3` tag tarball.
- One build-time tweak: the line `chown root .../mactelnetd.users` is removed from
  `config/Makefile.am` before compiling, because a non-root Homebrew install cannot
  chown to root (the file still gets `chmod 600`). This only affects the optional
  `mactelnetd` config file, not the binaries.

## Maintainer notes (release flow)

- `tests.yml` runs `brew test-bot` on every PR: it builds the formula on each
  matrix platform, runs the formula's `test do` block on that same platform, and
  uploads the resulting bottles as CI artifacts.
- Publishing is manual and can only promote a green PR: run the **brew pr-pull**
  workflow (`publish.yml`) with the PR number. It pulls the tested bottle
  artifacts, uploads them, and commits the `bottle do` block to the formula.
- Therefore: failing tests ⇒ no bottles ⇒ no release, and no bottle is ever
  published for a platform it wasn't built *and* tested on.

- `autobump.yml` runs daily: it livechecks upstream for a new release tag and, if
  one exists, opens a version-bump PR automatically (updated url + sha256). CI then
  builds/tests bottles on that PR as usual; releasing is still the one manual
  pr-pull dispatch. **One-time setup for full automation:** create a fine-grained
  PAT with contents + pull-requests write on this repo and store it as the
  `BUMP_TOKEN` secret (`gh secret set BUMP_TOKEN -R gregsadetsky/homebrew-mactelnet`).
  Without it, bump PRs are still opened but GitHub won't auto-run test-bot on them
  (PRs created by the default workflow token don't trigger workflows) — push to the
  PR branch or close/reopen it to start CI.

Workflows are the stock output of `brew tap-new` (Homebrew's official template),
except: the template's `tests.yml` shipped an invalid job-level `options:` key
(GitHub rejects the workflow), fixed here by nesting it in the `container:` mapping.
