# Commit Workflow

Use this workflow to judge staged changes, generate a commit message, or review an existing `tmp/commit.md` against the staged diff.

## Inspect the staged change

1. Confirm the worktree root.
2. Read `git diff --cached --name-status`, `git diff --cached --stat`, the complete staged diff, and `git status --porcelain`.
3. Read recent commit subjects, normally the latest 20. Inspect path-specific history when it materially helps choose `type` or `scope`.
4. If `tmp/commit.md` already exists and resolves inside the permitted repository `tmp/`, read it before replacing it. Preserve deliberate user wording or an explicitly supplied motivation when it remains accurate.
5. Read the minimum relevant source context needed to interpret the diff. Claims in the message must still describe staged changes, not unrelated context.

If no staged changes exist, output exactly:

```text
No staged changes to commit.
```

Do not derive a commit message from unstaged changes as a fallback. Mention unstaged changes in the response when present, but never include them in the staged commit message.

## Lock files and generated dependency state

When the staged diff includes a lock file, read the complete current lock file and the complete relevant source manifest that declares its root dependencies, subject to the active file-size policy. Common pairs include:

* `flake.lock` and the `inputs` declarations in `flake.nix`.
* `package-lock.json` or `yarn.lock` and `package.json`.
* `Cargo.lock` and the relevant `Cargo.toml` manifests.
* `go.sum` and `go.mod`.

Use the manifest and lock graph to distinguish direct or root dependency changes from transitive changes. Do not describe a transitive update as a newly added or directly updated root dependency. If the repository tracks generated metadata alongside its source, verify their relationship before judging coherence.

## Judge commit readiness

Before writing a message, decide whether the staged diff is suitable as one commit. Check:

* The staged files serve one coherent goal.
* Added, removed, renamed, and moved files have their corresponding references or imports staged when required.
* A partial stage has not separated a producer from a required consumer.
* Generated or lock-file changes agree with their source declarations.
* Documentation staged with implementation describes that same staged state.
* The diff does not contain unrelated formatting, cleanup, or configuration changes that would obscure review or complicate a future revert.

If the user says "if suitable" or otherwise conditions message generation on readiness, do not overwrite `tmp/commit.md` when the staged change is unsuitable. Report the concrete issue and a split or staging recommendation without changing Git state.

Lack of a build or test is not by itself proof that a commit is unsuitable. State unverified behavior or residual risk when relevant; do not run validation commands without authorization.

## Write one Conventional Commit message

Use this structure:

```git
<type>(<scope>): <subject>

<body>

<footer>
```

The body and footer are optional. Prefer a body when the staged change has multiple meaningful effects or the subject cannot state the important transformation precisely.

### Type

Choose the type from the staged change's primary semantic effect, then check it against recent repository usage:

* `feat`: add an externally meaningful capability, option, integration, or behavior.
* `fix`: correct behavior or a claim that is demonstrably wrong. Do not use `fix` merely because a value changed or the new state is preferable.
* `docs`: change repository-descriptive documentation, such as README, without changing executable instructions or primary content.
* `style`: change presentation or formatting without changing intended behavior.
* `refactor`: restructure implementation or configuration while preserving intended behavior.
* `test`: add or change tests.
* `chore`: perform intentional maintenance or configuration adjustment that fits no more specific semantic type.
* `build`: change the build system, packaging process, dependency wiring, or generated build metadata as the primary effect.
* `ci`: change CI or automation workflows.
* `perf`: improve performance without otherwise changing external behavior.
* `revert`: intentionally reverse an earlier commit as the primary purpose.

A touched lock file does not by itself require `build`. In configuration repositories, routine locked-input refreshes are commonly `chore`; reserve `build` for changes whose primary meaning is build, packaging, or dependency wiring. If a change partially undoes an earlier commit but retains a new coherent state, classify that resulting change rather than automatically using `revert`.

Prompt, command, agent, and skill files can change agent behavior. Choose `feat`, `fix`, `refactor`, or `chore` according to that behavior rather than their `.md` extension.

### Scope

Choose scope from the conceptual owner or driver of the change, not mechanically from every touched path.

* Prefer the repository's recent scope vocabulary and granularity.
* A slash-separated path-like scope such as `modules/features/niri` is valid when established by repository history.
* Use a shared library scope when a library API or function signature drives coordinated consumer changes.
* Use a feature or module scope when the change is primarily owned by that feature, even if supporting files elsewhere also change.
* Omit scope when no single scope is more informative than the subject.

Keep scope lowercase. Do not use `*` unless the repository consistently does so.

### Subject

Write an English imperative present-tense phrase. Do not capitalize its first word unless required by a proper noun, and do not end it with a period.

The subject is the primary information in the message. Name the main semantic action directly:

* Say what was added, removed, migrated, exposed, renamed, or replaced.
* If removal is the defining effect, make the removal visible in the subject rather than hiding it under `update` or `restructure`.
* Avoid broad verbs such as `improve`, `adjust`, `update`, or `rework` when a more exact verb is supported by the diff.
* Do not force implementation detail into the subject when the behavior-level action is clearer.

### Body

Write the body in Chinese by default, while retaining established English technical terms. Follow the repository's language when it clearly differs.

* Use `-` bullets with no blank lines between them.
* End each bullet with an English period.
* Wrap paths, options, attributes, functions, commands, and identifiers in backticks.
* Cover every meaningful staged effect, but group mechanically related edits instead of narrating each changed line.
* Prefer an explicit "从 ... 改为 ..." comparison when the old-to-new transformation is important to understanding the change.
* Do not list unchanged behavior merely to say it was preserved.
* Do not claim a feature section was updated if the diff only changes wording embedded in another section.
* Avoid causal language unless the cause is visible in repository evidence or explicitly supplied by the user.
* User-supplied motivation may be included when it explains the change accurately; phrase it as motivation, not as a diff-derived fact.
* Do not mention unstaged changes, review commentary, or split assessment.

### Footer

Use `BREAKING CHANGE:` only when the staged diff clearly introduces an incompatible public API, CLI, configuration interface, file format, or documented contract, or when the user explicitly confirms that impact. Internal restructuring and private function-signature changes are not breaking changes by themselves. When uncertain, report the possible incompatibility in the response instead of asserting it in the footer.

Use `Closes #123` only when the issue relationship is known. Separate `BREAKING CHANGE:` and `Closes` footers with one blank line.

## Write and report

Write only the final message to `tmp/commit.md`. Do not include fences, alternatives, explanations, warnings, or split assessment in that file.

After writing, report:

* Whether the staged diff is suitable as one commit.
* The output path.
* Whether unstaged changes exist.
* Any material validation gap.
* A split assessment.

Use this split format:

```text
Split assessment: recommended | optional | not necessary.
Difficulty: low | medium | high.
Reason: ...
```

Use `recommended` for clearly independent logical changes, `optional` for separable areas serving one coherent goal, and `not necessary` for one strongly coupled change. Consider review burden, future reverts, change types, ownership areas, validation coupling, and whether separation is possible by file or hunk. Do not perform the split or generate multiple candidate messages unless explicitly requested.
