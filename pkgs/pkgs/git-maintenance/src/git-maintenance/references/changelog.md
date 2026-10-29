# Changelog Workflow

Maintain a history of changes users need to understand when upgrading. A CHANGELOG describes changes between versions; README describes current use; Git history records implementation work. Do not transfer design history wholesale into the CHANGELOG.

## Standards and precedence

Use Keep a Changelog 2.0.0 for content conventions: notable changes, version entries, change types, reverse chronological order, breaking changes, and version navigation. Refer to Semantic Versioning 2.0.0 only where the project's version policy makes it applicable. See [standards.md](standards.md) for official URLs, optional local snapshots, and access fallbacks. The workflow below remains usable without those snapshots or network access.

Follow the project's explicit format, language, public-interface definition, and compatibility policy. External standards supply defaults, not permission to override those decisions or select the next version. Do not impose one minor/patch upgrade rule on all `0.x` projects, or weaken evidence requirements because a project has only one user. Explain material departures or conflicts rather than claiming full conformance when only borrowing principles.

The Org profile below adds native maintenance states, UTC time semantics, and a summary/detail organization on top of those content principles. These are workflow extensions, not Keep a Changelog requirements. Apply them only when the project explicitly adopts the profile; do not migrate an existing Markdown or other-format changelog or create `CHANGELOGS/` merely because this skill supports Org.

## Select an operation

Infer the operation from the requested outcome when clear; clarify only when ambiguity affects scope or permission to write. State the target document, historical range or baseline, and whether the output is a draft, edit, or audit.

### initialize: first introduction or historical backfill

Use this operation when no CHANGELOG exists, or when the user explicitly requests filling older gaps in an existing one.

1. Discover existing changelog documents, including Markdown, Org, or a project-specific equivalent. Reuse the established history rather than creating a competing file. Respect the requested format; absent any project or user convention, use `CHANGELOG.md`.
2. Identify the relevant released versions and their corresponding source trees. Use local Git tags and repository history first; distinguish version identification from verification of formal publication.
3. Compare the final source trees of successive releases. Inspect the historical README, public interfaces, manifests, tests, and other relevant documentation at both endpoints to understand the changes and their user-visible effects. Use commit history to investigate changes that cannot be understood from the endpoint comparison alone.
4. Consult existing release notes as supplementary evidence. Use them to identify potentially overlooked changes, clarify release context, and cross-check the reconstructed history. Verify substantive claims against the corresponding source trees and historical documentation rather than treating release notes as the primary source of changelog entries. Prefer retaining useful verified original wording; resolve redundancy, inaccuracies, and placement case by case within the target document's content boundaries.
5. Follow the requested backfill range. If none is given, prioritize confirmed releases with sufficient evidence. For early versions that cannot be reliably reconstructed, record only verified limited information and explain the coverage gap. Without a verified predecessor, do not describe every feature of the first recovered tree as newly introduced.

Do not rewrite old tags, hosted releases, commits, or historical README files. Historical backfill does not implicitly request an additional update through `HEAD`.

For an adopted Org profile, create or fill the authorized root summary and selected detailed files. Use the historical time and first-creation rules below for new historical entries; inspect existing states and times without changing them. Report missing detailed history rather than inventing it. Check ignore coverage after creating each file as described under authorization.

### update: incremental maintenance or release preparation

- Honor a specified version, range, and target state. Otherwise use the latest confirmed release to `HEAD` and maintain the current development entry. In the adopted Org profile this is a `TODO` version, optionally named `Unreleased` until a version is chosen; other formats keep their established convention. Do not require a permanent inbox or choose the base solely by tag name or nearest reachable tag. If a release baseline cannot be established, report that limit rather than inventing one.
- Use the staged tree or worktree as implementation evidence only when explicitly selected. State the selected scope and keep other states separate. Inspect the current CHANGELOG diff to preserve edits even when implementation claims use `HEAD`.
- Include changes users need to know, not every commit. Do not mechanically translate Conventional Commit types into changelog categories.
- For incompatible changes, identify the affected public interface, the actual behavior change, and a supported migration direction. Mark `Breaking` within `Changed` or `Removed` entries when appropriate.
- Release preparation is still a draft until release facts are verified. Do not invent a release date or present an unreleased version as already published.
- In the Org profile, authorized content edits may include a human-frozen `NEXT` version and its detailed file, or corrections to a `DONE` version's body. Respect the human-only state/time boundaries below. Report whether freeze or release prerequisites appear satisfied and what remains unresolved; do not convert states or infer publication permission from completed content.
- If README contains obsolete migration notes, recommend moving suitable material into the CHANGELOG; do not edit README under this workflow.

### audit: read-only review

Review the existing document against the selected release history and implementation baseline. Check version order, tag/release mapping, date sources, categories, missing important features or fixes, breaking changes and migration guidance, duplicate entries, relative links, Markdown/Org syntax, and established style.

For the adopted Org profile, also check root/detail consistency, detailed-file coverage, version states, `CUSTOM_ID`, filenames, UTC `CLOSED`, and tag/source relationships. Use the historical committer-time rule for backfilled records. Identify unresolved `NEXT` prerequisites, missing mandatory details for new-flow `DONE` versions, and canceled or unfinished work leaking into formal content. Do not equate any terminal state's `CLOSED` with publication. Report legacy coverage gaps separately from new-flow release prerequisites, and give explicit human checks where semantic consistency cannot be established mechanically.

Report concrete findings in descending importance, with the relevant entry, evidence and baseline, and a focused suggested correction. If no issue is found, state the coverage and remaining limits. Do not edit the document; actual rewriting requires an authorized `update` operation. This operation is distinct from the top-level README/documentation `audit` route.

## Evidence and historical attribution

Apply these evidence rules and the format rules below to `initialize`, `update`, and `audit`.

- Use local Git history and version-specific source trees as the primary evidence for reconstructing changes. Compare successive release baselines and inspect historical README files, public interfaces, manifests, tests, and other relevant documentation at both endpoints to understand the changes and their user-visible effects. Use commit history to investigate changes that cannot be understood from endpoint comparisons alone.
- Use release notes as supplementary evidence for reconstructing changes. Use them to identify potentially overlooked changes, clarify release context, and cross-check the reconstructed history. Verify substantive claims against the corresponding source trees and historical documentation rather than treating release notes as the authoritative inventory of changes.
- For publication status and dates, prefer verifiable published release notes, publication pages, and distribution records tied to the relevant source state. No particular hosting service, package manager, or framework is required.
- For adjacent releases, `git diff <old> <new>` compares their endpoint trees. `git diff <old>...<new>` compares a merge base with the new endpoint and can omit relevant differences in nonlinear history. Use the comparison that answers the release question, and inspect each endpoint's interfaces directly.
- Distinguish reconstruction of version changes from verification of publication. A tag alone does not prove formal publication. Tags identify candidate baselines, not independent proof of release dates. A missing GitHub Release does not imply no release occurred. Preserve useful verified release-note links without assuming a host-specific URL pattern or making available links a prerequisite for backfill. Report unresolved publication status, dates, version mappings, and coverage; do not fetch or mutate repository state to fill gaps.
- Outside the adopted Org profile, use verified release dates in the established project format (normally `YYYY-MM-DD`) and retain its explicit date policy and verifiable historical date information. Do not label an unknown-zone date UTC or use a commit/tag timestamp alone as proof of actual publication. Where a date or fact cannot be verified, omit unsupported claims from new entries and report the gap; do not invent dates or silently relabel existing ones.

### UTC CLOSED in the Org profile

For new releases, the human `NEXT -> DONE` finalization/release checkpoint records the project's formal release time as version-level UTC `CLOSED`. The release tag normally points to the commit containing `DONE`, `CLOSED`, and the completed detailed file. Do not require that time to equal the release commit's committer timestamp, manipulate `GIT_COMMITTER_DATE`, or replace it with a hosting platform's publication time. Project finalization and successful publication on each platform are distinct facts and must be checked separately.

For authorized backfill of an already existing, confirmed historical release tag, derive the new historical `CLOSED` from the tag's peeled commit committer Unix timestamp, converted to UTC. This is the profile's historical recording convention, not an independent claim about the actual platform publication time; explain that distinction when relevant. Do not substitute tagger time, platform `published_at`, or the current backfill time. If the tag/commit mapping is unavailable or unreliable, report the missing time rather than guessing.

Read-only evidence and, where GNU `date` is available, conversion examples:

```sh
git log -1 --format=%ct 'v0.7.0^{commit}'
release_ts=$(git log -1 --format=%ct 'v0.7.0^{commit}')
LC_TIME=C date -u -d "@$release_ts" '+[%Y-%m-%d %a %H:%M]'
```

Source timestamps have second precision; ordinary Org `CLOSED` retains minutes, so compare at minute precision. Check existing historical records against the evidence, but leave state or version-time corrections for a human. Unknown versions, interfaces, dates, and coverage remain explicit limitations, not invented facts.

## Format and content

- Organize released versions newest first and distinguish development entries from published history. Follow established version headings, dates, language, and navigation. Conventional formats may retain `Unreleased`; the Org profile expresses progress through native TODO keywords and does not require a permanent `Unreleased` headline.
- Cover every notable user-visible change at an appropriate level of detail, not just a selection of highlights. Curate for readers rather than mechanically mapping commits or accumulating internal maintenance tasks. Version entries need stable navigation and verified time information under the applicable format/profile.
- Preserve native link syntax: Markdown may keep inline or established reference-style links, and Org uses native file/internal/external links. The Org profile below uses plain version titles with stable internal IDs, not hosting URLs embedded in headlines. Never invent targets, use Markdown reference-style syntax in Org, or normalize valid historical links merely for uniformity.
- Use the standard change types where applicable: `Security`, `Removed`, `Changed`, `Deprecated`, `Fixed`, and `Added`. Omit empty categories; follow existing translated headings and category order when their meaning is clear.
- Write concise entries about observable user impact. Keep enough interface and migration detail to make breaking changes actionable, linking to longer instructions when available.
- Preserve the document's native syntax. Markdown uses its heading levels, lists, and Markdown links; Org uses star headings, native lists, and `[[target][label]]` links. Do not paste Markdown heading or link examples into `CHANGELOG.org`.
- Preserve accurate existing history. Avoid broad formatting rewrites or unrelated editorial changes when inserting new entries or filling a requested gap.

## Org profile: summary, details, and lifecycle

### Content ownership and version identity

- Root `CHANGELOG.org` remains a Keep a Changelog-style history: concise, categorized entries covering important changes, with Breaking and migration directions visible. It also provides development/candidate maintenance entry points. It is not merely a directory or task checklist; long explanations and procedures belong in details or dedicated documentation.
- Every version formally released under this profile must have a complete `CHANGELOGS/<version>.org` before release. That file is the sole authoritative manuscript for its Release Notes; a generator must never fall back to the root summary when details are missing. Root entries can be shorter but must agree with confirmed detailed facts.
- Detailed files contain the needed complete user-visible changes, impacts, breaking changes, migration guidance, limitations, and verified context. Their internal structure is flexible; they need not mirror every root headline or list. Creating or finishing a detailed file does not itself publish a version.
- Version identity comes from the project's version identifier and confirmed Git tag relationship, not a platform URL. For definite `NEXT` and `DONE` versions, `CUSTOM_ID` exactly matches the corresponding tag name and the detailed filename uses that version identifier, such as `v0.8.0`. Do not introduce a separate `GIT_TAG` property.
- Keep version headline titles free of hosting-platform URLs. Use body links such as `[[file:CHANGELOGS/v0.8.0.org][Detailed release notes]]`, `[[#v0.8.0]]`, or `[[file:CHANGELOG.org::#v0.8.0]]`. Verified useful external navigation may remain in the body. Do not use persistent line numbers as identity or infer that a declared target tag already exists.

### Native states and human authority

Use file-local `#+TODO: TODO NEXT WAIT | DONE CANCELED`, `#+STARTUP: logdone`, and `#+PROPERTY: TIMEZONE UTC`. Version level 1 normally follows:

| State | Meaning | Version records |
| --- | --- | --- |
| `TODO` | Development; scope and version may be provisional | `TODO Unreleased` or `TODO v0.9.0`; no forced early `CUSTOM_ID` |
| `NEXT` | Human-frozen version and scope; release material being completed | Definite version and matching `CUSTOM_ID`; detailed file in preparation |
| `DONE` | Formal finalization/release marking; complete, reviewed detailed notes | Version-level UTC `CLOSED`, matching identity, complete detailed file; verify tag and publication facts separately |

`Unreleased` is an optional name, not an additional stage or permanent inbox. An existing `TODO v0.9.0` can be frozen in place by a human. `WAIT` and `CANCELED` are useful for candidate items; if an entire version is paused or canceled, explain the exceptional version flow rather than treating it as a normal release.

All existing TODO keyword transitions, at both version and item levels, are human-only in phase one, as are changes to existing version-level `CLOSED`. The agent may suggest transitions, review prerequisites, and edit authorized ordinary content. It must not mark an existing entry `NEXT`, `DONE`, or another state, even when asked to prepare a release. Completed children, checked boxes, or finished details do not imply publication authorization.

First creation is distinct from conversion: an explicitly requested new development entry may start as `TODO`. Authorized historical backfill may create a new `DONE` entry and derived `CLOSED` for a confirmed historical release tag. If a version entry/state/time already exists, report discrepancies and leave state/time changes to a human. Checkboxes may be updated under explicit content authorization but cannot bypass these restrictions.

`logdone` can insert `CLOSED` for any terminal keyword, including `CANCELED`; its presence alone does not mean a version was released. Use a standard inactive Org planning timestamp just below the headline, outside the properties drawer. Do not put `%z` or `%Z` inside it or repeat a date in the version title. Under this profile version `CLOSED` is interpreted in UTC, but the file's `TIMEZONE` property does not make Org's native `C-c C-t` generate UTC. The human must check the resulting state and UTC time; phase one supplies no technical enforcement.

Level 2 normally uses the six change types. As the profile's default presentation order, consider `Security`, `Removed`, `Changed`, `Deprecated`, `Fixed`, `Added`; respect established translated categories and ordering. Lower levels may mix TODO headlines, plain headlines, lists, and `- [ ]` / `- [X]` checkboxes. Maintenance progress never replaces classification or user-visible facts. Do not let canceled candidates, blocked tasks, or incomplete checks become an unreviewed formal change inventory. Keep Breaking on the affected `Changed`/`Removed` entry rather than adding a default category.

Root structure illustration only; versions, times, and content are not facts to copy into another project:

```org
#+TITLE: Changelog
#+TODO: TODO NEXT WAIT | DONE CANCELED
#+STARTUP: logdone
#+PROPERTY: TIMEZONE UTC

* TODO v0.9.0

** Added
*** TODO Candidate feature
*** WAIT Upstream-dependent change

** Fixed
- [X] Verified correction
- [ ] Further regression check

* DONE v0.8.0
CLOSED: [2026-10-29 Thu 06:56]
:PROPERTIES:
:CUSTOM_ID: v0.8.0
:END:

See [[file:CHANGELOGS/v0.8.0.org][Detailed release notes]].

** Added
- Describe a notable user-visible addition.

** Changed
- *Breaking:* Describe the affected interface and migration direction.
```

An illustrative detailed file might contain `#+TITLE: v0.8.0 Release Notes` and sections such as Highlights, Changes, or Migration. None of those section names or a fixed headline depth is mandatory; organize the complete manuscript for that version while retaining the content principles above.

### Relationship to release notes and historical sources

For new-profile versions, independent publishing tools obtain the sole authoritative Release Notes manuscript from `CHANGELOGS/<version>.org` in the version's release tag, not a later `main` or worktree. Preserve version identity, recorded time, changes, Breaking information, and migration meaning. Root summaries are not an alternate publishing source; missing mandatory details mean a release prerequisite is unmet.

For older releases whose own tags lack detailed files, inspect confirmed successor release-tag snapshots and select the first containing that version's detailed file. Establish successor order from the project's confirmed release sequence and Git history relationships, not lexical tag order, tagger time, or an assumption that maintenance branches are linear. Report ambiguous order or missing files; never rewrite old tags to insert backfill.

If no successor tag yet contains the backfill, use an already reviewed mainline document only when explicitly allowed, identifying its source revision and reproducibility limits. When returning a manuscript, report its version and source Git revision. Backfilled historical content may later improve with evidence; no separate backfill branch or snapshot index is required. Preserve old platform notes as historical material and do not silently replace them.

Section selection, Org-to-Markdown conversion, excluding properties drawers and maintenance metadata from output, validation, and platform publication belong to a separate release workflow/tool or CI. Phase one implements none of them. Platform-specific operational additions must not introduce an independently maintained, conflicting change inventory. Corrections require an explicit process, not mutation of tagged historical files. Legacy release notes remain supplementary reconstruction material; source-of-truth direction for future publication does not require copying old notes mechanically.

## Authorization and delivery

Drafts and audits do not authorize writes. Only an explicit request to create or update the corresponding CHANGELOG permits editing the authorized root and selected detailed version files. For the adopted Org profile this can include `CHANGELOG.org` and corresponding `CHANGELOGS/<version>.org`; it never automatically includes unrelated files. Before editing, inspect staged/worktree differences for existing targets and preserve user changes; clarify overlapping edits only when they cannot safely be reconciled. Existing Org state/time records remain subject to the human-only boundary above, including during historical backfill.

After creating a root or detailed file, diagnose whether ignore rules prevent tracking it with read-only `git check-ignore -v --no-index -- <path>`. Report matched rules and a separate suggested fix; do not modify `.gitignore`, stage the file, or treat successful content creation as proof it will be committed.

For large histories, use bounded searches by version headings, `CUSTOM_ID`, and file paths before reading the relevant portions. Follow the active file-size policy instead of loading multiple MiB of history; line numbers are temporary navigation aids, not stable version identifiers.

Do not stage files, create commits, tags, branches, or releases, rewrite history, fetch, pull, push, or change version numbers, manifests, README, or other project files. Follow the active workspace policy for read-only inspection, remote access, and any validation tools; this workflow grants no additional execution permission.

Report the range and evidence used, the output produced or file changed, and any unresolved facts or coverage gaps. Provide the supported portion when evidence is incomplete, keeping uncertainty separate from asserted release facts.
