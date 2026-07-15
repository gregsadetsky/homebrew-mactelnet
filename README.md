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

- **No changes to the program source.** The formula builds a pristine upstream
  *release* tarball — whichever tag it currently pins (v0.6.3 at the time of
  writing; the daily autobump advances the pin to each new upstream release, see
  below). It never patches the C source.
- One build-time tweak: the line `chown root .../mactelnetd.users` is removed from
  `config/Makefile.am` before compiling, because a non-root Homebrew install cannot
  chown to root (the file still gets `chmod 600`). This only affects the optional
  `mactelnetd` config file, not the binaries.

## Maintainer notes (release flow)

- `tests.yml` runs `brew test-bot` on every PR: it builds the formula on each
  matrix platform, runs the formula's `test do` block on that same platform, and
  uploads the resulting bottles as CI artifacts.
- Publishing can only promote a **green** PR (pr-pull pulls that PR's tested bottle
  artifacts, uploads them, and commits the `bottle do` block). Two ways it runs:
  automatically for autobump's `bump-*` PRs (see next section), or manually via the
  **brew pr-pull** workflow (`publish.yml`) with a PR number — used for
  human-authored PRs.
- Invariant either way: failing tests ⇒ no bottles ⇒ no release, and no bottle is
  ever published for a platform it wasn't built *and* tested on.

- **Releases are fully automatic.** `autobump.yml` runs daily: it livechecks
  upstream and, on a new release tag, opens a version-bump PR (updated url +
  sha256) using the `BUMP_TOKEN` PAT secret. CI builds/tests bottles on that PR;
  when it goes green, `autopublish.yml` (triggered by the CI completion, guarded
  to `bump-*` branches from this repo only) runs pr-pull automatically: merge,
  upload bottles, stamp the formula. Human-authored PRs are untouched — release
  those with the manual pr-pull dispatch. The whole chain was rehearsed end-to-end
  (0.6.2→0.6.3) with zero manual steps.
- `BUMP_TOKEN` is a fine-grained PAT (contents + pull-requests write on this repo),
  stored via `gh secret set BUMP_TOKEN`. It exists because PRs and dispatches made
  with the default workflow token don't trigger other workflows (GitHub
  anti-recursion), and replacing existing release assets needs owner scope.

Workflows are the stock output of `brew tap-new` (Homebrew's official template),
except: the template's `tests.yml` shipped an invalid job-level `options:` key
(GitHub rejects the workflow), fixed here by nesting it in the `container:` mapping.
