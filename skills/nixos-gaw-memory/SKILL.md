---
name: nixos-gaw-memory
description: Navigate and interpret the NixOS project's Formal GAW Memory. Use when resuming repository work, reading current architectural knowledge, investigating historical design decisions or maintaining the memory organization.
---

# NixOS GAW Memory

Use the available `git-agent-workflow` skill and public GAW CLI. Run `git gaw status` in the project to discover the selected Formal branch and worktree; do not assume their names or locations. Recover its declared workspace from `.gaw/config` and use `git gaw check` to assess validity. Stop memory writes if lifecycle state is ambiguous or invalid. This skill does not grant lifecycle or project-write authorization.

## Read current knowledge first

Begin with [memory/project.md](../../memory/project.md) for architectural responsibilities, interfaces, conventions and outstanding investigations. Read [memory/reconstruction.md](../../memory/reconstruction.md) when interpreting historical claims, corrections, source limitations or reported verification.

These are Formal-worktree-root-relative data paths. The links resolve from this skill's declared `skills/nixos-gaw-memory/` layout; the memory files are workspace data, not resources bundled with the skill in isolation.

## Recover historical context when needed

1. Use the selected Formal ref reported by GAW with `git log --first-parent <formal-ref>` to find relevant architectural changes. Inspect those committed memory snapshots, rather than assuming current descriptions applied throughout history.
2. Inspect a relevant checkpoint's actual parents with `git show --no-patch --format=raw <checkpoint>`. The first parent follows Formal evolution; do not infer fixed roles for additional parent positions.
3. Inspect relevant parent trees with `git ls-tree -r --name-only <parent>` and read their committed configuration and declared memory using `git show <parent>:<path>`. Auxiliary paths are relative to the UUID root found in that snapshot. Follow the relevant source's first-parent history when its earlier knowledge states matter. Retained ancestry can supply this material even without a source branch.

Select relevant trees by their content and checkpoint context. UUIDs are structural locators, not permanent semantic identities. Additional parents provide historical context, not proof of adoption, approval or verification. Git reachability alone does not establish knowledge coverage. Do not maintain a source registry or checkpoint association table.

## Interpret and maintain

Distinguish current knowledge, reconstructed historical reports and actual project implementation. Use relevant committed implementation to resolve material factual uncertainty; distinguish static inspection from evaluation, build, deployment and runtime evidence. Uncommitted work is outside this memory's committed-project baseline. Historical investigations require present evidence before being called current defects.

Maintain this entry point when memory layout or interpretation conventions change, not after every memory edit. Keep substantive architecture in memory and exact historical relationships in Git. Follow the GAW workflow for content review, sensitive material, explicit staging and checkpoints.
