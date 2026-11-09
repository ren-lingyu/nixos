---
name: git-maintenance
description: Prepare and review evidence-based Conventional Commit messages from staged changes, assess commit readiness, and maintain repository-facing documentation against an explicit Git baseline. Use for staged diff review, tmp/commit.md maintenance, README synchronization, documentation audits, and CHANGELOG creation, historical backfill, updates, or audits; never use it to change Git state.
license: MIT
metadata:
  domain: git
  workflow: repository-maintenance
---

# Git Maintenance

Maintain repository-facing text from repository evidence while preserving Git state and the user's authorization boundaries.

This skill is repository-generic. Do not assume that the current repository is a NixOS configuration, even when examples mention Nix files.

## Select a workflow

- `commit`: inspect staged changes, decide whether they form a suitable commit, and prepare or review `tmp/commit.md`. Read [references/commit.md](references/commit.md) completely before acting.
- `readme`: inspect or update README and other explicitly named repository-descriptive files. Read [references/readme.md](references/readme.md) completely before acting.
- `audit`: compare README and repository-descriptive documentation with repository evidence without modifying files. Read [references/readme.md](references/readme.md) completely before acting. Use `changelog audit` for CHANGELOG review.
- `changelog`: create or backfill release history with `initialize`, maintain it with `update`, or review it read-only with `audit`. Read [references/changelog.md](references/changelog.md) completely before acting. For official standards and optional local snapshots, consult [references/standards.md](references/standards.md) when needed.
- `help`: briefly explain the workflows above.

When the intended workflow is ambiguous and the distinction changes what may be written, ask one concise question. Otherwise infer it from the requested output.

## Invariants

- Prefer repository evidence over assumptions and filenames over repository nicknames.
- Keep generated text objective, restrained, grammatical, and specific.
- Do not invent features, commands, dependencies, modules, scripts, options, hosts, goals, or motivations.
- A motivation explicitly supplied by the user is valid evidence, but distinguish it from effects visible in the diff.
- Preserve the repository's established language, terminology, scope style, and document conventions when they remain accurate.
- Do not treat Markdown, Org, prompt, command, agent, or skill files as `docs` merely because of their format. Classify their role and behavioral effect.
- Do not run Git commands that change repository, worktree, index, branch, tag, remote, stash, or history state.
- Do not create commits, stage or unstage files, rewrite history, fetch, pull, push, or update submodules.
- Do not modify source code, manifests, lock files, tests, generated files, or project configuration as part of this skill.

## Evidence and baselines

Establish the source of truth before drafting text:

- Commit messages use only the staged diff for change claims.
- README work uses the baseline requested by the user, such as `HEAD`, the staged tree, or the current worktree.
- If no README baseline is stated, inspect the worktree and its diff, then state which evidence was used when that distinction matters.
- Changelog work verifies released versions against their actual source trees. Unless the user specifies another target, incremental updates compare the latest confirmed release with `HEAD` and maintain the current development entry: an Org `TODO` version in the adopted Org profile, or the conventional `Unreleased` section. Tags and commit dates alone do not establish release facts.
- Unstaged changes may be inspected to detect overlap, but do not silently mix them into a staged commit message or a `HEAD`-based documentation baseline. Changelog work uses staged or worktree implementation changes only when explicitly selected.

Use only the evidence needed for the selected workflow. Relevant read-only commands include:

```sh
git rev-parse --is-inside-work-tree
git rev-parse --show-toplevel
git status --porcelain
git diff --cached
git diff --cached --name-status
git diff --cached --stat
git diff -- <path>
git log -n 20 --pretty=format:%s
git log -1 --format=%H -- <path>
git show <revision>:<path>
git ls-tree -r --name-only <revision>
```

Do not use output-writing flags such as `git diff --output`. Follow the active workspace policy for file size, sensitive content, bounded searches, timeouts, and reads outside the repository.

## File writes

The `commit` workflow may write only the final commit message to `tmp/commit.md`, after validating the repository's temporary-directory boundary as required by the active workspace policy. The file must contain only the commit message.

The `readme` workflow may modify only README or other explicitly named repository-descriptive files, and only when the user has explicitly requested that write. A direct request such as "update README" is sufficient authorization for that named file; it does not authorize staging, testing, formatting unrelated files, or changing Git state.

The `changelog initialize` and `changelog update` operations may write only the explicitly authorized root CHANGELOG and corresponding selected detailed version files. This includes `CHANGELOG.md`, `CHANGELOG.org`, or the project's equivalent, plus `CHANGELOGS/<version>.org` when the Org profile is adopted and those files are within the authorized scope. A request for a draft does not authorize file writes or changes to README, version numbers, or manifests.

In the Org profile, existing TODO keyword transitions and changes to existing version-level `CLOSED` records are human-only. Read the creation and historical-backfill exceptions in [references/changelog.md](references/changelog.md); content maintenance does not authorize release-state changes.

The top-level `audit` workflow and `changelog audit` operation are read-only.

## Failure handling

If required evidence is unavailable, say what could not be inspected and provide the safest useful partial result without guessing. Ask a question only when the missing answer is necessary to proceed safely.

If a diff is large, group it by logical area and identify uncertainty explicitly. Do not overfit the message or documentation to incidental line-level details.
