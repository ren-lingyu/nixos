---
name: git-maintenance
description: Maintain Git repositories by generating Conventional Commits messages from staged changes, auditing repository-facing documentation, updating README files conservatively, and avoiding Git state-changing commands.
license: MIT
metadata:
    domain: git
    workflow: repository-maintenance
---

# Git Maintenance Skill

Use this skill for conservative Git repository maintenance tasks.

This skill is repository-generic. It must not assume that the current repository is the user's NixOS configuration repository.

## Supported workflows

This skill supports these workflows:

* `commit`: generate a commit message from staged changes.
* `readme`: inspect or update README files conservatively.
* `audit`: audit repository-facing documentation without modifying files.
* `changelog`: draft a changelog-like summary.
* `help`: explain available workflows.

In v0, the `commit` workflow is the primary workflow. The `readme`, `audit`, and `changelog` workflows are defined only as conservative placeholders for future expansion.

## General principles

* Prefer repository evidence over assumptions.
* Keep generated text objective, restrained, and specific.
* Do not invent project features, commands, dependencies, modules, scripts, options, hosts, or goals.
* Do not infer the user's motivation unless it is explicitly provided or directly supported by repository evidence.
* Preserve existing repository style unless the user explicitly asks for restructuring.
* Prefer minimal, reversible operations.
* Do not run Git commands that change repository state.
* Do not create commits, push changes, rewrite history, stage files, unstage files, or modify branches.
* For commit messages, use staged changes as the source of truth.
* If unstaged changes exist, mention them in the response but do not include them in the generated commit message.

## Safety boundaries

### Allowed inspection commands

Only request or run read-only commands needed for the selected workflow.

Examples of read-only Git commands:

* `git rev-parse --show-toplevel`
* `git status --porcelain`
* `git diff --cached`
* `git diff --cached --stat`
* `git diff --cached --name-status`
* `git diff --name-only`
* `git log -n 20 --pretty=format:%s`
* `git branch --show-current`

When using `git diff`, do not use flags that write files, such as `--output`.

### Forbidden Git commands

Do not run commands that change repository state, working tree state, index state, branch state, tags, remotes, or history.

Forbidden examples include:

* `git add`
* `git commit`
* `git push`
* `git pull`
* `git fetch`
* `git reset`
* `git clean`
* `git rebase`
* `git checkout`
* `git switch`
* `git restore`
* `git stash`
* `git merge`
* `git tag`
* `git cherry-pick`
* `git revert`

If the user explicitly asks for one of these operations, explain that this skill is limited to conservative maintenance and provide a read-only plan instead.

### File modification boundaries

For v0:

* The `commit` workflow may write the final commit message to `tmp/commit.md`.
* The `readme` workflow should propose README edits by default.
* The `readme` workflow may modify README only when the user explicitly requests a write operation.
* The `audit` workflow must not modify files.
* Do not modify source code, lock files, manifests, tests, generated files, or project configuration as part of this skill.

If writing `tmp/commit.md` or README requires approval, request approval rather than bypassing the permission system.

## Repository evidence collection

Before generating or editing repository-facing text, inspect only the evidence needed for the selected workflow.

Useful evidence may include:

* Git staged changes.
* Recent commit subjects.
* Existing README.
* Project manifests.
* Entry-point files.
* CI files.
* Scripts.
* Directory structure.

When the repository type is unclear, infer it from files rather than names alone.

### Repository type hints

Use these hints only when matching files are present.

Nix or NixOS repository:

* `flake.nix`
* `flake.lock`
* `default.nix`
* `shell.nix`

Node repository:

* `package.json`
* `pnpm-lock.yaml`
* `yarn.lock`
* `package-lock.json`

Python repository:

* `pyproject.toml`
* `setup.py`
* `requirements.txt`

Rust repository:

* `Cargo.toml`
* `Cargo.lock`

Go repository:

* `go.mod`
* `go.sum`

Documentation or notes repository:

* Markdown, Org, TeX, or documentation files are the main content rather than repository-descriptive documentation.

Do not treat every `.md` change as `docs`. In notes repositories, Markdown files may be the primary content. Program instruction files and prompt files, often also Markdown files, are not automatically documentation changes.

## Commit workflow

Use this workflow when the user asks to generate, review, or prepare a commit message.

### Required steps

1. Confirm that the current directory is inside a Git worktree when needed.
2. Inspect staged changes using `git diff --cached`.
3. Inspect staged change names and stats using `git diff --cached --name-status` and `git diff --cached --stat` when useful.
4. Inspect `git status --porcelain` to detect unstaged changes.
5. If staged changes are empty, output exactly `No staged changes to commit.` and do not generate a commit message.
6. If unstaged changes exist, mention them in the response but do not include them in the commit message.
7. Inspect recent commit subjects with `git log -n 20 --pretty=format:%s` when available.
8. Use recent commit subjects only as repository context. Do not copy an inconsistent or unstructured historical style if it conflicts with this skill.
9. Generate one commit message for the staged changes.
10. Write the final commit message to `tmp/commit.md`.
11. Provide a split assessment in the response.
12. Do not write split assessment text into `tmp/commit.md`.

### Commit message format

Use this structure:

```git
<type>(<scope>): <subject>

<body>

<footer>
```

The body and footer are optional when not needed, but prefer a body when the change has more than one meaningful effect.

### Header

The header must follow these rules:

* Use Conventional Commits style.
* Use the form `<type>(<scope>): <subject>` when a useful scope exists.
* Use the form `<type>: <subject>` when no useful scope exists.
* Do not use `*` as scope unless the repository already uses it consistently.
* Keep `scope` lowercase.
* Use short hyphenated scopes when needed, such as `editor`, `niri`, `opencode`, `readme`, `ci`, `flake`.
* Write `subject` in English.
* Write `subject` as an imperative present-tense phrase.
* Do not capitalize the first word of `subject` unless it is a proper noun.
* Do not end `subject` with a period.
* Keep the header concise.

Allowed types:

* `feat`: add user-visible or project-visible functionality.
* `fix`: fix incorrect behavior, broken configuration, broken documentation claims, or build/runtime failures.
* `docs`: update repository-descriptive documentation.
* `style`: change formatting, whitespace, colors, fonts, or presentation without behavior changes.
* `refactor`: restructure existing code or configuration without changing intended behavior.
* `test`: add or update tests.
* `chore`: perform maintenance that does not fit other types.
* `build`: change build systems, packaging, dependency wiring, lock files, or generated build metadata.
* `ci`: change CI or automation workflows.
* `perf`: improve performance without changing external behavior.
* `revert`: revert a previous change.

For repositories that already use a smaller type set, prefer the repository's compatible subset unless it conflicts with the staged change.

### Type selection guidance

Use these defaults unless repository evidence suggests a better choice:

* README-only changes: `docs`.
* Changelog-only changes: `docs`.
* CI workflow changes: `ci`.
* Build system, packaging, or dependency metadata changes: `build`.
* Lock-file-only changes: `build` or `chore`; prefer `build` for program projects and `chore` for configuration repositories.
* `flake.lock`-only changes: usually `chore` in personal configuration repositories, otherwise `build`.
* Prompt files, command files, agent files, and skill files: do not automatically use `docs`; choose `feat`, `fix`, `refactor`, or `chore` according to behavior.
* Notes repositories: do not use `docs` merely because the changed files are Markdown, Org, or TeX; choose the type according to the role of the content.
* Mixed changes: choose the primary behavior. If no primary behavior is clear, use `refactor` or `chore` conservatively and report split assessment separately.

### Body

The body should usually be written in Chinese by default.

Use these body rules:

* Use unordered bullet points.
* Start each bullet with `-`.
* End each bullet with an English period.
* Do not insert blank lines between bullet points.
* Describe what changed, not the user's unstated intention.
* Keep wording objective and restrained.
* Mention file paths, commands, Nix attributes, variables, options, function names, and other code-like elements in backticks.
* Avoid vague language such as "improve things" or "optimize config" unless the diff directly supports that wording.
* Do not mention unstaged changes.
* Do not mention split assessment.

Example body:

```git
- 在 `programs.opencode` 中新增 `git-maintenance` skill 配置.
- 调整 commit message 生成规则以仅使用 staged diff.
```

### Footer

Use footer only when needed.

Breaking changes:

* Use `BREAKING CHANGE:` followed by a clear description and migration guidance.
* Add `BREAKING CHANGE:` only when the user explicitly says the change is breaking, or the staged diff clearly changes a public API, CLI, configuration interface, file format, or documented behavior in an incompatible way.
* If a breaking change is only possible but not certain, do not put it in the footer. Mention it in the response as a potential breaking change instead.

Issue closing:

* Use `Closes #123`.
* For multiple issues, use `Closes #123, #456`.
* If both `BREAKING CHANGE:` and `Closes` are present, separate them with one blank line.

### Output file

The final commit message must be written to:

```text
tmp/commit.md
```

The file should contain only the commit message.

Do not include:

* Explanation.
* Markdown fences.
* Split assessment.
* Warnings about unstaged changes.
* Alternative messages.
* Candidate messages for split commits.

If file writing is not allowed, present the exact commit message and say that writing `tmp/commit.md` requires approval.

### Response after generating commit message

After writing or presenting the commit message, respond with:

* The output path, if written.
* A note if unstaged changes exist.
* A split assessment.

Do not duplicate the full commit message in the response unless writing failed or the user explicitly asks to see it.

## Split assessment

Always provide split assessment for the `commit` workflow when staged changes exist.

Use this structure:

```text
Split assessment: recommended | optional | not necessary.
Difficulty: low | medium | high.
Reason: ...
```

Assess these factors:

* Whether multiple change types are mixed.
* Whether touched files belong to independent areas.
* Whether one change depends on another.
* Whether tests or validation are coupled.
* Whether a future revert might need to revert only part of the change.
* Whether review burden is high.
* Whether staged changes can be separated by file or hunk.
* Whether low-risk formatting is mixed with high-risk logic changes.

Use `recommended` when the staged changes contain clearly independent logical changes.

Use `optional` when changes touch multiple areas but serve one coherent goal.

Use `not necessary` when the staged changes are strongly coupled and form one logical change.

Do not perform the split.

Do not generate multiple candidate commit messages unless the user explicitly asks.

## README workflow

Use this workflow when the user asks to update or maintain README.

In v0, default to inspection and proposal.

Rules:

* Read the existing README first.
* Follow the README's existing language unless the user specifies another language.
* Inspect repository evidence before changing claims.
* Prefer minimal patches.
* Do not rewrite the whole README unless the user explicitly requests a restructure.
* Do not add commands unless they are present in repository files or directly inferable from manifests or scripts.
* Do not invent project features, supported platforms, modules, hosts, options, dependencies, or usage examples.
* If content cannot be verified, ask the user to confirm it.
* If the user asks to mark uncertain content inside README, prefer an HTML comment over visible TODO text.
* Do not modify files other than README or explicitly named repository-descriptive documentation.

If asked to write README changes, apply only the requested README or descriptive-document changes.

## Documentation audit workflow

Use this workflow when the user asks to check whether documentation matches repository content.

This workflow is read-only.

Check for:

* Paths mentioned in README that no longer exist.
* Commands mentioned in README that cannot be verified.
* Features described in documentation that cannot be found in repository evidence.
* Repository entry points not documented at all.
* Documentation language that appears inconsistent with the actual project.
* Documentation sections that appear stale.

Output:

* Findings.
* Evidence.
* Recommended edits.
* Open questions for the user.

Do not modify files.

## Changelog workflow

Use this workflow only when the user asks for changelog-like output.

In v0:

* Draft summaries only.
* Do not introduce release automation.
* Do not modify `CHANGELOG.md` unless the user explicitly asks.
* Do not treat raw `git log` as a user-facing changelog.
* Group meaningful changes by type when possible.

## Help workflow

When asked for help or when no workflow is specified, explain the supported workflows briefly.

Example supported requests:

* `commit`: generate a commit message from staged changes.
* `readme`: inspect or update README conservatively.
* `audit`: audit repository-facing documentation.
* `changelog`: draft a changelog-like summary.

If the user's intent is ambiguous, ask one concise clarification question.

## Failure handling

If required information is unavailable:

* Say what could not be inspected.
* Do not guess.
* Provide the safest useful partial result.
* Ask one concise clarification question only when it is necessary to proceed safely.

If staged diff is too large:

* Summarize by file groups.
* Avoid overfitting to minor line-level details.
* Still generate a commit message if the primary logical change is clear.
* If the primary change is not clear, state that split assessment is recommended and explain why.
