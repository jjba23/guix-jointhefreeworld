# Vision

`guix-jointhefreeworld` is a signed GNU Guix channel: a package collection Guix can pull alongside its own, carrying the latest releases of the software written around jointhefreeworld — the Guile libraries, the command-line programs, the Emacs packages, a GTK4 dock and desktop shell, and the site builder that publishes the web site. It is not a fork of Guix and not an operating system, and that modesty is the design: every definition is an ordinary `package` form, and the channel's whole claim is that one pull gives you the newest versions of a coherent stack, together, with the dependencies and launchers they were tested with. This document is about turning that claim from a promise kept by hand into a property the channel can demonstrate.

## Where the channel is today

Twenty-eight packages in five modules. `packages/guile.scm` has eight libraries — Kracht, Scriba, Veritas, Bewaking, Hygguile, orgwebalchemy, the OpenAPI generator and Olive CSS. `packages/applications.scm` has ten command-line programs, from maak to sift, ggg, iter-vitae, lenkesamler, consceal, skapa, araneola, mutastructura and cask-and-cons. `packages/emacs.scm` has five Emacs packages, `packages/misc.scm` has heks-bash, lambdock, whelk and heks-toon, and `packages/site.scm` has the jointhefreeworld site builder. `packages.scm` re-exports the lot, `manifest.scm` lists every package so `guix build -m manifest.scm` builds the collection in one go, and `channels.scm` is a worked example of subscribing to the channel.

The trust chain is the most careful part of the repository, and it is worth stating plainly because it is what a channel is judged on. `.guix-authorizations` lists exactly one OpenPGP key, with a name beside it. `.guix-channel` declares the module directory, the primary URL and the `keyring` branch. The introduction — commit `b0ac3f05…`, signed by `83BC 6E1C 8726 B8C2 97F8 D16E 24F4 6738 CE11 4AF6` — is what a user pins in their own `channels.scm`, and it is the one commit Guix cannot verify against its parent, so it is verified directly against that fingerprint. `maak authenticate` runs `guix git authenticate` from the introduction to HEAD; `maak show-introduction` prints the stanza to paste. `maak publish` pushes `trunk` and then pushes the `keyring` branch with `--no-verify`, because the keyring is the root of trust and is not a descendant of the introduction — the pre-push hook installed by `guix git authenticate` would otherwise refuse to push it.

Each origin pins content rather than a name. `commit` is `(string-append "v" version)`, so a version bump moves the tag without a second edit, and the `sha256` is the recursive hash of the checkout, so a tag that moves upstream fails the build instead of silently changing what a user installs. Projects without a release tag are pinned to a commit and carry a version that says so. `HACKING.org` documents the whole procedure: clone the tag shallowly, `guix hash -x -r` it, `rev-parse` the commit, raise the version, replace the hash, build, lint, commit.

The task list is small and honest about what needs the network. `maak build` builds every package; `maak fmt` runs `sift format --write` over the sources; `maak check` lints offline, builds everything and authenticates the history; `maak lint` adds the network checks — the updater and the CVE checker; `maak outdated` runs `guix refresh -t generic-git -m manifest.scm`, one tag fetch per package and none of the GitHub API's rate limiting, and is deliberately not part of `maak check`. `maak shell` enters an environment with the whole collection.

Three stands are written down rather than implied, and each is a decision worth keeping. The channel holds no secrets: no `env.scm`, no session keys, no tokens, no database files. The Artanis web services in the same account — byggsteg, lucidplan, pingwing, wikimusic, torikomi — are *not* packaged, because they need a writable tree, a database and a deployment's own secrets, so they are run from their own checkouts. And the things that are neither programs nor libraries — heks-emacs, heks-linux, wolk-jjba, private-notes, static-assets, a repository with no public URL — are named in the README with the reason each one is absent.

What the channel does not do is visible in the same document. There is no substitute server, so every user builds every package locally. There is no build farm, so nothing is known about `aarch64` or any other architecture until someone reports it. The README's package catalogue is a hand-kept copy of the modules, and it has already drifted: `misc.scm` carries lambdock 1.3.0 against 1.2.7 in the table, and `emacs.scm` carries welkomscherm 1.5.3 against 1.5.2. Neither is a bug — both are the ordinary cost of a catalogue maintained by hand next to a source of truth that moves.

## The vision

1. **The channel is current because a task makes it current.** A single `maak bump` finds the packages whose project has a new tag, computes the recursive hash of each new checkout, edits the version and the hash, builds and lints what changed, and leaves a signed commit for review. "Latest releases, not leftovers" becomes a property of a job rather than a habit of the maintainer.

   What has to be true first: the hash computation moves out of `HACKING.org` and into the Maak file, and the tag-to-commit mapping is stated once for the packages that have no tag.

2. **The catalogue is generated from the definitions.** Versions, entry points, one-line descriptions and licences are in the modules already; the README table, a machine-readable catalogue and the published site are three renderings of the same data, and none of them can drift from the code.

   What has to be true first: the entry points are learned from the build rather than guessed — the one thing a package definition does not say is what lands in `bin/`.

3. **The collection is proven to build together, on more than one architecture.** The README's strongest sentence is that the pieces you install are the pieces that were tested together. Today that is a build on one machine; the vision is a job that builds the manifest on `x86_64-linux` and `aarch64-linux`, and a substitute server that lets the second architecture download what the first compiled.

   What has to be true first: a signing key for substitutes that lives in CI rather than in a person's keyring, and a runner that can build for the other architecture.

4. **The channel's state is answerable in one command.** Which packages are behind their upstream tag, which lint findings are new since the last release, which architectures have no substitute, and what changed between two commits a user might have pulled. The information exists; nobody can ask for it.

   What has to be true first: `maak lint` gains a baseline, so a finding is either new or known, and the reports are written to a file rather than to a terminal.

5. **Upstreaming is a path, not a sentence.** A package that lands in Guix stays here for the release cadence, which the FAQ already says. The next step is mechanical: the same definition rendered in the shape `gnu/packages` expects, so proposing an upstream patch is a task rather than a rewrite.

   What has to be true first: the definitions stay ordinary enough that the rendering is a formatting question, and the channel keeps the discipline of using nothing Guix does not already provide.

## Features that are in scope and not built yet

The design anticipates these; each is a seam rather than a wish.

- **`maak bump`.** Everything it needs is in `HACKING.org` as prose. The hard part is the hash: one shallow clone per changed package, `guix hash -x -r` on each, and a rule for a project whose tag and commit disagree.
- **A generated catalogue.** The hard part is the entry points. A package definition says how a program is built, not what it installs, so the list has to come from a built output or be declared beside the package.
- **A substitute server.** The hard part is key management: a channel whose whole virtue is a verifiable history should not acquire an unsigned binary path, so substitutes need their own key, their own CI variable and their own paragraph in the README.
- **Cross-architecture builds.** `guix build --system=aarch64-linux` on an `x86_64` machine needs emulation or hardware, and the Emacs and Guile packages are architecture-independent while `lambdock` and `heks-toon` are C and GTK4. The hard part is a matrix that says which packages are expected to build where.
- **A lint baseline.** `maak lint` runs the network checks and prints what it finds; a stored baseline turns a wall of warnings into "one new finding in one package", which is the difference between a report and a gate.
- **A changelog across pulls.** Guix users see `guix describe` and a git log. The hard part is a summary that names the packages and versions that moved between two channel commits, which is derivable from the modules and useful to a person deciding whether to pull.
- **Packaging the Artanis services.** Deliberately absent and correctly so. The hard part is real and unsolved: a writable working tree, a database, and deployment secrets, none of which a package can carry.
- **A `maak test`.** `guix build` runs each project's own tests when its build system does; a channel-level task that builds every package with tests explicit, and reports the ones that skip them, would make the claim about "the pieces that were tested together" precise.
- **A signing check for every commit, not only a range.** `maak authenticate` walks from the introduction to HEAD. A pre-push hook that refuses an unsigned commit *before* it becomes history would catch the one mistake that cannot be fixed afterwards, and the repository already has the key and the tooling for it.
- **A description lint.** Every package has a `synopsis` and a `description` in the Guix style: a synopsis under 80 characters that starts with a capital and does not end with a full stop, and a description that says something a synopsis cannot. `guix lint` checks the shape; nothing checks whether the sentence is true, and the Emacs packages are where a reader notices.
- **The `channels.scm` stanza, generated.** `maak show-introduction` prints the introduction; users still hand-assemble the `channel` form around it. Printing the whole stanza, with the URL and branch the repository actually uses, removes the step where a reader copies the wrong commit.

## New features that would be worth having

- **A machine-readable catalogue at a stable URL.** `catalogue.json` — name, version, upstream URL, licence, entry points, module — generated by `maak` and published with the site. The channel already packages the site builder, which makes this a small joke and a good idea at once: the collection's own builder publishes the collection's own index.
- **`maak since <commit>`.** The packages and versions that changed since a commit, in the words of the catalogue: what a user gets if they pull. It is the missing half of `guix describe`.
- **A per-package development shell.** `maak shell maak` entering an environment with that package's inputs, so a contributor can hack on a program without building it first. The inputs are in the definition; the hard part is a `guix shell` invocation that starts from a package rather than a manifest.
- **A CVE digest.** `maak lint` already runs the CVE checker with the network. A task that prints only the vulnerabilities, grouped by package and severity, is what makes the check useful between releases rather than during one.
- **A `guix home` service for the Emacs packages.** The channel installs `emacs-modusregel` and expects the user to `require` it. A service that generates the `require` and the `setopt` forms from what is installed would be the smallest possible bridge between a Guix channel and a configuration, without packaging the configuration itself.
- **A `--dry-run` for every task that touches the network.** `outdated` is read-only and `bump` will not be; saying what would change before changing it is the habit the rest of this collection already has.
- **A reproducibility check across two builds.** Build a package twice from the same definition and compare the store paths; a channel that talks about reproducibility should be able to say it verified one.
- **`maak publish --dry-run`.** The most consequential task in the repository pushes two branches, one of them with `--no-verify`. Printing what would be pushed, and to which remote, before it is pushed is the cheapest possible guard on the operation that cannot be undone.
- **A `guix` version floor in the README.** The channel is developed against Guix 1.5 and says "a recent Guix is enough". A minimum version checked by `maak check` — the point below which `guix git authenticate` or a build-system change would break — is one sentence that would save a bug report.
- **A licence summary, generated.** Every definition names the project's licence. A table of package to licence, generated the way the catalogue would be, answers the first question a distributor asks, and the data is already there.
- **A `HACKING` recipe per kind of change.** Updating a hash, adding an Emacs package, adding a program, and changing a package's build system are four different procedures sharing one page. Four short recipes, one per kind, would be shorter than the page they replace and would be the shape a contributor actually needs.

## Contributions that would move the needle

Ranked roughly by value per hour.

1. **`maak bump`, as a task that edits one package and stops.** The procedure is already written down; encoding it is a day's work, and it removes the only step in this repository that is a manual sequence with a hash in the middle.
2. **`maak show-channels`.** Three lines of formatting over values that already exist as constants, and the first thing a new user needs. It is also the change that would stop the README's copy of the stanza drifting from the code.
3. **The generated catalogue, starting with the table the README already has.** Two entries have already drifted, so the value is demonstrated rather than argued; the entry-point question can be answered by a hand-written list in the definition at first.
4. **A lint baseline file, and a `maak check` that respects it.** Small, and it turns the most useful network check the channel runs into something a contributor can run before a patch.
5. **`maak since`.** A derivation over the modules and a git range, useful to every user of the channel, and a good first contribution because it touches nothing that is built.
6. **The cross-architecture matrix.** Even without emulation, a job that builds the architecture-independent packages anywhere and the C packages on their own platforms would replace "report what breaks" with a table.
7. **A substitute server and its key.** The largest item here, and the one that changes what using the channel costs a user on a slow machine.
8. **`maak test`.** The precision it adds to the README's central claim is worth more than its size suggests.
9. **The pre-push signature hook.** Ten lines of shell that prevent the one class of mistake the channel's entire trust story depends on, and the natural companion to the `--no-verify` that `publish` already explains.

## Compared to related projects

| Project | What it is | Where this channel differs |
|---|---|---|
| GNU Guix's own `gnu/packages` | The official channel: thousands of packages, the same authentication rules, substitutes and a build farm behind it | The upstream that this channel defers to. It carries some of these projects at whatever revision it last imported; this one follows each project's release tag, at the cost of breadth and of having no build farm |
| nonguix | A community channel adding what Guix cannot ship — a non-free kernel, firmware, and many programs that need them | Solves a different problem: nonguix exists to cross a licensing line, this channel exists to be current. nonguix also has substitutes and CI, which is the part worth copying |
| small-guix | A small, carefully documented community channel with signed history and its own conventions | The closest in spirit. The difference is scope: small-guix collects a person's packages, this channel packages a whole stack — libraries, programs, Emacs packages, GTK4 applications and a site builder — and keeps them versioned together |
| guix-gaming-channels | A channel of games and gaming tools, with its own substitutes | A themed collection with community maintainers; this one is one stack maintained by one person, which is why the definitions stay ordinary and the authentication story stays short enough to read |
| Nix flakes and overlays (`flake.lock`) | Pinned dependency graphs with a lockfile, overlays to add packages and an ecosystem of inputs | A flake locks its inputs, and a channel does not: it follows whatever Guix the user pulled. That is a real difference — a channel is a package collection, not a build graph — and the reason `guix time-machine` is the answer to a question Nix answers with a lockfile |
| Homebrew taps | Extra formulae for Homebrew, distributed by git, with bottles for the common platforms | Taps have bottles, which is the substitute question again, and they have no cryptographic history: a tap is whatever its branch says. This channel's authentication is the part a tap cannot offer |
| AUR | User-submitted build scripts for Arch, with votes and comments that surface breakage | The AUR has community signal this channel will never have; what it does not have is a verified history or a package set built together |
| `guix import` and the Guix updaters | The tooling that turns an upstream release into a package definition, and the harness `maak outdated` drives | A tool, not a collection. The channel wraps it with a policy — generic tags, no API tokens, no rate limit — and the gap that remains is the hash, which no updater can compute without checking out the source |

Three things the others do that this channel could add: nonguix's substitutes and CI, the AUR's habit of recording what broke and where, and Nix's discipline about pinning — which for a channel means being explicit that the pinned thing is the *source*, not the build graph, and saying so in one sentence a reader can find. The AUR's lesson is cheaper than it looks: a `maak since` and a changelog per pull are the local equivalent of a comment thread that tells you a package moved.

Where this channel is ahead and should stay ahead: authentication as a default rather than an option, with the keyring branch, the authorizations file and the introduction all explained in the README in the order a user meets them; the catalogue split by what a package *is*, so a reader can find the Emacs package without knowing its name; a "what is not packaged, and why" section, which almost no channel writes and every user wants; the refusal to hold secrets or deployment state; and the packaging of a coherent stack rather than one project's addenda, which is what makes "the pieces you install are the pieces that were tested together" a meaningful sentence.

Two details are worth naming because they are easy to lose. The `commit` field is derived from the version, so a bump cannot forget it — a small convention that removes a whole class of mistake, and one that should survive every refactor of the definitions. And the introduction is written down twice, in `channels.scm` and in `maak.scm`, exactly as a constant, which is what lets `show-introduction` print the truth rather than a remembered string.

What this channel should not become is a second Guix. The temptation, as a channel grows, is to add a macro that makes definitions shorter, a layering scheme that makes modules independent, and a build system of its own. Every one of those would be an improvement in a different repository and a loss here: the value of an ordinary `package` form is that a reader who knows Guix already knows how to read it, and that a patch can move upstream without translation.

## In the long run

- **The release cadence as the reason to exist.** Guix upstream will keep importing these projects at whatever revision it last imported. The bet is that a channel whose only product is *currency* stays useful even as the official collection grows, because the gap between a tag and an import is structural.
- **Upstreaming without losing the mirror.** Every package here should be a candidate for `gnu/packages`, and a package that lands there can still stay here. The bet is that the two roles stop competing: the channel is where a release is tested together, and Guix is where it becomes permanent.
- **Substitutes or a smaller claim.** Either the channel grows a build farm and a substitute key, or it says plainly that it is a source-only channel for people who build. Both are honest; the bet is that the first happens, because the second is what stops a curious user at the first `guix pull`.
- **The collection as a proof obligation.** Twenty-eight packages that must build together is a testable statement about an ecosystem. The bet is that it becomes an automated one — a matrix, a manifest and a report — and that the report is the channel's best argument.
- **The site builder as the channel's voice.** The channel packages the program that publishes the web site where these projects are described. The bet is that the catalogue it publishes is generated from the same definitions a user installs from, so the page and the packages cannot disagree.
- **A channel that a stranger can use on the first try.** The README is long because the subject is genuinely fiddly: an introduction, a stanza, a signing key, a manifest, a signed history. The bet is that the whole of it collapses into one command that prints the stanza, one that checks it, and one that says what changed — and that the long version survives as the explanation rather than the instructions.

## A closing note

The distinguishing thing about this repository is how much of it is an argument rather than a definition: why the channel is not a fork, why it is not official, why the Artanis services are run from their own checkouts, why no secret lives here, why a package that lands in Guix stays anyway. Those paragraphs are the reason the forty lines of any one package definition can be trusted, and they are the part a contributor should read first.

The second thing is how little of it moves. Twenty-eight packages, one signing key, five modules, and a task list of eight verbs. A channel like this stays trustworthy by staying boring: same shape as Guix, same authentication, same definitions, a hash that changes when a release does and nothing else. Everything above is an attempt to keep it boring while making it keep up.

*This document describes intent, not commitments: it names directions the maintainer finds worth taking, and nothing here is a promise that a given feature will exist, in the order listed, or at all.*
