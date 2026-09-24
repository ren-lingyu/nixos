# README and Documentation Workflows

Use this reference for README maintenance and repository-facing documentation audits.

## Establish the factual baseline

Determine which repository state the document must describe before evaluating claims:

* `HEAD`: use tracked paths and file contents from `HEAD`; unstaged and staged implementation changes are not factual evidence for the target state.
* Staged tree: use the index as the target state and keep unstaged changes separate.
* Worktree: use current tracked files, while distinguishing staged, unstaged, and untracked content when that affects a claim.

When the user says README must reflect committed content, treat `HEAD` as the source of truth. Inspect the current README worktree diff before editing so that unrelated user changes are preserved, but verify repository claims against `HEAD` rather than those newer files.

For a README that has fallen behind, locate its most recent commit and compare the repository changes since that revision with current `HEAD`. Use that comparison to identify likely stale sections, then verify the affected current files directly. Commit history narrows the audit; it does not replace inspection of the resulting repository state.

## Inspect systematically

Read the existing README first and follow its language, tone, heading hierarchy, link syntax, and terminology unless the user requests a restructure.

Inspect only relevant repository evidence, but cover each documented area rather than sampling a few paths. Useful checks include:

* Tracked top-level layout and meaningful entry points.
* Paths, filenames, links, commands, and options named in the README.
* Added, removed, renamed, or moved components since the README's last update.
* Manifests, module aggregators, and entry-point files that define composition.
* Each relevant `default.nix` or equivalent entry point when the requested documentation granularity reaches that unit.
* Root dependencies and their actual consumers when dependencies are documented.
* Lock graphs only when the README describes dependency relationships; distinguish root inputs from transitive inputs using the source manifest and complete lock file.

Prefer revision-aware Git inspection for a `HEAD` baseline, such as `git ls-tree`, `git show`, and revision ranges. Do not infer committed layout solely from the current filesystem when the worktree differs from `HEAD`.

## Decide what belongs in the README

Document stable repository structure, ownership boundaries, composition mechanisms, and externally useful configuration facts. Avoid turning every internal subdirectory into a heading when it is only an implementation detail of its parent module.

Use enough detail to make the stated structure complete at the chosen abstraction level:

* Include meaningful peer categories; do not describe three categories when a fourth tracked category exists.
* Describe aggregators according to every category they actually import.
* Remove stale components and add newly tracked peer components when they affect the documented model.
* Explain scripts or helper files under the directory or component they serve instead of creating an empty organizational heading solely for file type.
* Keep link prefixes and trailing slashes consistent with the document's established convention.
* Describe mechanisms directly. Prefer how modules or features are discovered, exposed, imported, and enabled over historical bundle terminology that no longer matches the implementation.

Do not add speculative goals, unsupported commands, exhaustive internal implementation detail, or facts that cannot be verified from the selected baseline. If an unverifiable claim is essential, ask the user; otherwise omit it.

## Patch conservatively

Default to inspection and a proposed edit. Modify README only when explicitly requested.

When authorized:

* Patch the current worktree file without overwriting unrelated user edits.
* Keep changes limited to README or other explicitly named repository-descriptive files.
* Preserve accurate existing wording and structure.
* Restructure only when requested or when the existing structure itself makes an accurate update impractical.
* Keep terminology grammatically natural and retain important English technical terms when that matches the document.

After editing, inspect the complete resulting README where practical, its worktree diff, and each changed factual claim against the selected baseline. Do not run link checkers, formatters, builds, or tests without authorization.

## Audit output

The audit workflow is read-only. Report findings in descending importance with:

* The inaccurate, missing, stale, or inconsistent statement.
* Concrete repository evidence and the baseline used.
* A focused recommended edit.
* An open question only when evidence cannot resolve the issue.

Check for broken relative paths, unverifiable commands, stale names, missing meaningful entry points, incomplete category lists, inaccurate dependency relationships, inconsistent terminology, and language or grammar that obscures the repository's actual design. If no issue is found, state what was inspected and any remaining coverage limit.
