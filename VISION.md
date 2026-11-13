# Vision

Lenkesamler treats a bookmarks file as a program you own: one Guile Scheme file,
written by hand, rendered into whatever document the tool of the day can read.
The claim in the README is that bookmarks should last fifty years, which is a
claim about formats and about the willingness to keep writing converters long
after the current browser is gone. This document is about what that claim costs,
what is already paid for, and which gaps would break it first.

## Where Lenkesamler is today

At v0.0.10 the program is roughly 1900 lines of Guile across eleven modules, and
it does one thing in both directions: it reads a bookmarks file and writes a
document.

- **One input.** `--file` reads this project's own DSL; `--import` reads a
  browser's Netscape export or this project's JSON output. A run reads exactly
  one of the two files, and the mode defaults to `scheme` when importing, because
  a migration wants back the file a person edits.
- **Eight renderers.** `cli`, `csv`, `json`, `markdown`, `netscape` (also
  `browser`, `web`), `org`, `scheme` and `xbel`, one module each under
  `src/lenkesamler/renderer/`, from the 52-line Markdown module to the 95-line
  CSV one.
- **Two importers.** Netscape, parsed with a hand-written reader that keeps
  folders, names, addresses, dates and Firefox's tags; and JSON, which is what
  makes an exported document able to come home again.
- **A link checker.** `--check` probes every address once (walking folders,
  de-duplicating repeats), prefers `HEAD`, falls back to `GET` on 405 and 501,
  sorts answers into `ok`, `moved`, `broken`, `error` and `skipped`, and exits
  non-zero when anything is broken or unreachable.
- **A DSL of two forms.** `(dir "Name" …)` and `(url "host/path" #:name … #:added … #:tags …)`,
  loaded from a module `(lenkesamler bookmarks)` that defines a
  `lenkesamler-bookmarks` list; folders are values and the file is ordinary
  Scheme, so `map`, `format` and `load` work inside it.
- **A test suite with one spec per module**, including a spec that runs the
  program over a real bookmarks file and reads both the file `--destination`
  writes and the standard output it prints; Maak runs it, and Byggsteg runs
  `maak test` then `maak deploy` on every push to `trunk`.
- **Four installation routes** pinned to the same tag: the jointhefreeworld Guix
  channel, a Nix flake, a two-stage container image, and Debian/openSUSE/Arch
  recipes that are built rather than published.

The load-bearing decisions are these, and every one of them constrains what can
be added later:

1. **The bookmarks file is executable.** That is what gives it loops, computed
   names and `load`, and it is also why importing a file from the internet and
   rendering it is equivalent to running it; every feature that reads a file
   inherits that.
2. **No database, no service, no state.** One file in, one document out, and a
   run's chatter goes to the error port so that `… --mode json | jq` works. This
   forbids anything that needs memory between runs.
3. **The renderers are pure functions of a normalised bookmark list.** That is
   why an eighth format is an afternoon's work, and why a renderer can only
   express facts that list carries — XBEL has no place for tags and says so.
4. **Dates are dates.** `#:added` is `YYYY-MM-DD`, converted to epoch only where
   a format demands it; a link without a day writes `false` in JSON rather than
   an invented date.

## The vision

1. **Round-tripping is a tested invariant, not a hope.** For every format that
   can carry a fact the model holds, the suite proves `render → import → compare`
   over the fixtures, and the formats that cannot carry a fact declare what they
   drop in a machine-readable way rather than in prose.
2. **The checker records what it learned.** A checked link's final address,
   status and the day it was seen are written back as data, so a file can say
   "this moved in 2026 and here is where to" — which needs a decision about where
   a fact about a link lives, given that the file is code a person edits.
3. **Imports merge.** Migrating from a browser into an existing file adds,
   updates and reports rather than replacing wholesale, with written rules for
   the awkward cases: one address under two folders, one address with two names.
4. **The format surface is wide enough that leaving is never lossy.** The
   README's TODO list — a valid pretty HTML export, SQLite, Nyxt, OS shortcut
   trees — is either done or explicitly declined, and short enough to be believed.
5. **A bookmarks file can be validated before it breaks something.** A mode that
   answers "will this file import cleanly, is every date real, is every folder
   name representable in the format I am about to write?" turns a class of silent
   losses into a report.

## Features that are in scope and not built yet

The code and the README already anticipate these; each names its hard part.

- **Pretty HTML exporter.** The Netscape file is semi-valid 1990s HTML and stays
  that way for compatibility, so a second, valid, styled document is wanted. Hard
  part: telling the two apart, since both are `.html` — the same problem
  `--import` already solves for JSON by reading content rather than names.
- **SQLite import and export** (`places.sqlite` and friends). Hard part: Firefox's
  schema is versioned and normalised across `moz_places` and `moz_bookmarks`, so
  an exporter must choose between `INSERT`s a browser would accept and a
  standalone document that merely looks like one.
- **Nyxt.** The README calls it "converting Scheme to Common Lisp", which it is
  not: the DSL must become forms Nyxt evaluates at startup, and the two Lisps
  differ exactly where the DSL is interesting — keywords, modules, folder lists.
- **OS shortcut trees** (`.desktop`, `.url`, `.webloc`). This is the first mode
  that writes many files rather than one document, so the destination stops being
  a filename and becomes a directory with a naming scheme. Hard part: three
  platforms, three escaping rules, and one folder name that must be legal on all
  three.
- **Machine-readable check reports.** The checker already computes per-link
  status, redirect targets and counts; `--check` writes prose. Hard part: giving
  the report a schema without turning the mode into a second output format with
  its own versioning problem.
- **Settings in the file.** `(lenkesamler prelude)` exports `get-setting`, which
  anticipates per-file configuration, but nothing in the model carries it. Hard
  part: a setting is not a bookmark, so it needs a home that survives every
  renderer's assumption of "a list of dirs and urls".

## New features that would be worth having

- **`--diff`.** Compare two bookmarks files, or a file with a browser export, and
  print what would be added, removed or renamed. It is the missing half of
  merging, and cheap: the model is a tree of records and both sides are parsed.
- **`--doctor`.** Duplicate addresses, empty folders, dates that cannot be parsed,
  folder names a chosen format will mangle, tags it will drop: validation as a
  mode, in the spirit of the checker — a report, and a non-zero exit when
  something is actually wrong.
- **`--sort`.** Output ordering is document order today, which is a fact about
  the file rather than about the bookmarks; sorting by name, date or
  folder-then-name is small and every consumer of `--mode cli` will notice it.
- **More importers.** XBEL and CSV are written but not read, which is the one
  asymmetry in an otherwise symmetric program; a Netscape-ish reader for Safari's
  and Chromium's exports is the same parser with different attribute names.
- **A tag vocabulary.** Tags are bare symbols, so `dev`, `Dev` and `development`
  are three tags; a pass that *reports* near-duplicates — rather than one that
  silently normalises them — fits a tool that prefers reports to surprises.
- **An archive mode.** Speculative and not yet in scope: a single-file snapshot
  of a page stored next to the bookmark, so a link that rots still has a copy. It
  changes the project from an index into a store, a much bigger promise than
  "next 50 years" currently makes.

## Contributions that would move the needle

1. **Read XBEL and CSV.** The renderers exist, the record type exists, and the
   importer interface is 61 lines. This closes the round trip for two of the eight
   formats in a day's work, and it is the single change that most improves the
   "leaving is never lossy" claim.
2. **A round-trip spec harness.** One spec that loops the fixtures through every
   renderer able to carry tags, dates and folders, imports the result and compares
   the trees, with an explicit per-format list of expected losses. It turns a
   scattered set of specs into a property of the whole program.
3. **`--doctor`.** Small, self-contained, no design risk, and it protects users
   from the failure this project cares about most: a lossy document discovered too
   late. It also gives the checker's `skipped` and `error` vocabulary a second home.
4. **A machine-readable check report.** The checker already returns structured
   checks; serialising them is mostly a schema decision, and it unlocks cron jobs
   and dashboards without a new program.
5. **The pretty HTML renderer.** Visible, useful, and the only TODO item a
   non-technical user would notice; the hard part is the disambiguation, not the
   markup.
6. **SQLite.** The largest of the README items: a schema to understand, a binary
   format to write or a database to emit SQL for, and tests that cannot assert
   against a browser's own behaviour. Worth doing, but not first.

## Compared to related projects

| Project | What it is | Where Lenkesamler differs |
|---------|------------|---------------------------|
| buku | a command-line bookmark manager storing everything in a SQLite database, with search, tags and a local web UI | buku owns the store; here the store is a Scheme file a person edits, and the program is a translator, not a manager |
| shiori | a Go bookmark manager with offline archiving and a web interface over an SQLite database | shiori is an application with a server and a database; Lenkesamler is a single command with no state between runs |
| wallabag | a self-hosted read-later and bookmark server with accounts, an API and a web UI | wallabag replaces the browser's library with its own service; Lenkesamler keeps the library in the filesystem and never asks for an account |
| Pocket and Raindrop.io | hosted bookmark services with sync, search and mobile clients | their value is the sync; the failure mode is the shutdown, which is the scenario this project is written against |
| lychee, muffet and linkchecker | link checkers that crawl a document or a site and report dead links | a checker here is one mode of a program that already knows the folder tree, and the report carries the taxonomy the bookmarks do |
| XBEL and its Python tooling | an XML bookmark exchange format with a DTD and a handful of readers and writers | Lenkesamler writes XBEL and must admit it drops tags; the exchange format is a target, never the source of truth |
| browser bookmark managers | the built-in library in Firefox, Chromium, Safari and Edge, synced to a vendor account | they are the thing being outlived; Lenkesamler reads and writes their export format precisely because it intends to still be here when they are not |

What the others do that this could still add: buku's and shiori's query model —
"show me everything tagged `dev` added this year" is a question this tool cannot
ask of its own file without rendering it into something else first. Where
Lenkesamler is ahead and should stay ahead: the source of truth is a text file in
a format a person can read, keep and version; every output is derived and
therefore disposable; dead-link checking is part of the same tool rather than a
separate crawl; and no feature requires a service, an account or a database.

## In the long run

The fifty-year claim rests on two bets that are worth stating plainly.

- **Formats rot, and the answer is importers, not archives.** Browsers will drop
  Netscape import long before they stop having bookmarks. The durable asset is a
  set of readers broad enough that whatever comes next can be pulled in — which
  is why "more importers" outranks "more exporters" in the long run, even though
  exporters are what people notice.
- **The DSL must stay small enough to reimplement.** A file format that only this
  program can read is a lock-in of its own. Two forms, four keywords and a module
  name is small enough that a reader could be rewritten in any Lisp in an
  afternoon, and that is the actual guarantee behind the "next 50 years" slogan —
  worth protecting against every future feature that would grow the dialect.

## Getting there from here

Close the round trip first (XBEL, CSV, then Safari and Chromium readers), pin it
with a round-trip spec, then add `--doctor` so a lossy file is caught before it is
written. Merging and diffing come after the readers, because a merge rule is only
worth writing once both sides of it can be read; the pretty HTML, SQLite and Nyxt
items all come after the invariant that makes the program trustworthy.

*This document describes intent, not commitments: nothing here is scheduled, and
the exit codes, formats and checks that exist today are the contract.*
