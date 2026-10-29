# Changelog Workflow

Maintain a history of changes users need to understand when upgrading. A CHANGELOG describes changes between versions; README describes current use; Git history records implementation work. Do not transfer design history wholesale into the CHANGELOG.

## Standards and precedence

Use Keep a Changelog 2.0.0 for changelog conventions and Semantic Versioning 2.0.0 for version semantics. See [standards.md](standards.md) for official URLs, optional local snapshots, and access fallbacks. The workflow below remains usable without those snapshots or network access.

Follow the project's explicit format, language, public-interface definition, and compatibility policy. External standards supply defaults, not permission to override those decisions or select the next version. Do not impose one minor/patch upgrade rule on all `0.x` projects, or weaken evidence requirements because a project has only one user. Explain material departures or conflicts rather than claiming full conformance when only borrowing principles.

## Select an operation

Infer the operation from the requested outcome when clear; clarify only when ambiguity affects scope or permission to write. State the target document, historical range or baseline, and whether the output is a draft, edit, or audit.

### initialize: first introduction or historical backfill

Use this operation when no CHANGELOG exists, or when the user explicitly requests filling older gaps in an existing one.

1. Discover existing changelog documents, including Markdown, Org, or a project-specific equivalent. Reuse the established history rather than creating a competing file. Respect the requested format; absent any project or user convention, use `CHANGELOG.md`.
2. Identify the relevant released versions and their corresponding source trees. Use local Git tags and repository history first; distinguish version identification from verification of formal publication.
3. Compare the final source trees of successive releases. Inspect the historical README, public interfaces, manifests, and other relevant documentation at both endpoints to understand the changes and their user-visible effects. Use commit history to investigate changes that cannot be understood from the endpoint comparison alone.
4. Consult existing release notes as supplementary evidence. Use them to identify potentially overlooked changes, clarify release context, and cross-check the reconstructed history. Verify substantive claims against the corresponding source trees and historical documentation rather than treating release notes as the primary source of changelog entries.
5. Follow the requested backfill range. If none is given, prioritize confirmed releases with sufficient evidence. For early versions that cannot be reliably reconstructed, record only verified limited information and explain the coverage gap. Without a verified predecessor, do not describe every feature of the first recovered tree as newly introduced.

Do not rewrite old tags, hosted releases, commits, or historical README files. Historical backfill does not implicitly request an additional update through `HEAD`.

### update: incremental maintenance or release preparation

- Honor a specified version, range, and target state. Otherwise draft `Unreleased` from the latest confirmed release to `HEAD`; do not choose the base solely by tag name or nearest reachable tag. If a release baseline cannot be established, report that limit rather than inventing one.
- Use the staged tree or worktree as implementation evidence only when explicitly selected. State the selected scope and keep other states separate. Inspect the current CHANGELOG diff to preserve edits even when implementation claims use `HEAD`.
- Include changes users need to know, not every commit. Do not mechanically translate Conventional Commit types into changelog categories.
- For incompatible changes, identify the affected public interface, the actual behavior change, and a supported migration direction. Mark `Breaking` within `Changed` or `Removed` entries when appropriate.
- Release preparation is still a draft until release facts are verified. Do not invent a release date or present an unreleased version as already published.
- If README contains obsolete migration notes, recommend moving suitable material into the CHANGELOG; do not edit README under this workflow.

### audit: read-only review

Review the existing document against the selected release history and implementation baseline. Check version order, tag/release mapping, date sources, categories, missing important features or fixes, breaking changes and migration guidance, duplicate entries, relative links, Markdown/Org syntax, and established style.

Report concrete findings in descending importance, with the relevant entry, evidence and baseline, and a focused suggested correction. If no issue is found, state the coverage and remaining limits. Do not edit the document; actual rewriting requires an authorized `update` operation. This operation is distinct from the top-level README/documentation `audit` route.

## Evidence and historical attribution

- Use local Git history and version-specific source trees as the primary evidence for reconstructing changes. Compare successive release baselines and inspect historical README files, public interfaces, manifests, tests, and other relevant documentation at both endpoints to understand the changes and their user-visible effects. Use commit history to investigate changes that cannot be understood from endpoint comparisons alone.
- Use release notes as supplementary evidence for reconstructing changes. Use them to identify potentially overlooked changes, clarify release context, and cross-check the reconstructed history. Verify substantive claims against the corresponding source trees and historical documentation rather than treating release notes as the authoritative inventory of changes.
- For publication status and dates, prefer verifiable published release notes, publication pages, and distribution records tied to the relevant source state. No particular hosting service, package manager, or framework is required.
- For adjacent releases, `git diff <old> <new>` compares their endpoint trees. `git diff <old>...<new>` compares a merge base with the new endpoint and can omit relevant differences in nonlinear history. Use the comparison that answers the release question, and inspect each endpoint's interfaces directly.
- Distinguish reconstruction of version changes from verification of publication. Tags identify candidate release baselines, but do not by themselves establish formal publication or release dates. A missing GitHub Release does not imply no release occurred. Preserve useful existing release-note links without assuming a host-specific URL pattern. Report unresolved publication status, dates, version mappings, and coverage; do not fetch or mutate repository state to fill gaps.
- Use verified release dates in `YYYY-MM-DD` form. If the date or a historical fact is unknown, omit that unverified claim and explain the uncertainty in the accompanying report; do not insert plausible dates or placeholders as publication facts.

## Format and content

- Organize releases newest first and keep `Unreleased` clearly distinct from published versions. Follow established version headings, links, language, and whether the project retains an `Unreleased` section. Default incremental drafts use `Unreleased`.
- Use the standard change types where applicable: `Security`, `Removed`, `Changed`, `Deprecated`, `Fixed`, and `Added`. Omit empty categories; follow existing translated headings and category order when their meaning is clear.
- Write concise entries about observable user impact. Keep enough interface and migration detail to make breaking changes actionable, linking to longer instructions when available.
- Preserve the document's native syntax. Markdown uses its heading levels, lists, and Markdown links; Org uses star headings, native lists, and `[[target][label]]` links. Do not paste Markdown heading or link examples into `CHANGELOG.org`.
- Preserve accurate existing history. Avoid broad formatting rewrites or unrelated editorial changes when inserting new entries or filling a requested gap.

## Authorization and delivery

Drafts and audits do not authorize writes. Only an explicit request to create or update the corresponding CHANGELOG permits editing that document. Before editing, inspect its worktree and staged differences and preserve existing user changes; clarify overlapping edits only when they cannot safely be reconciled.

Do not stage files, create commits, tags, branches, or releases, rewrite history, fetch, pull, push, or change version numbers, manifests, README, or other project files. Follow the active workspace policy for read-only inspection, remote access, and any validation tools; this workflow grants no additional execution permission.

Report the range and evidence used, the output produced or file changed, and any unresolved facts or coverage gaps. Provide the supported portion when evidence is incomplete, keeping uncertainty separate from asserted release facts.
