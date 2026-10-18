# Historical consolidation and source recovery

## Retained scope and evidence limits

Historical knowledge comes from 18 reviewed independent sources retaining 52 knowledge states with recovery value. They describe goals, design motivations, alternatives, implementation conclusions, and validation limits. They do not contain original rollouts, archives, or complete tool logs. These are historical syntheses, not claims of byte-for-byte fidelity to original evidence. The module-refactor source in particular retains only summaries of the visible conversation. Current implementation facts follow the committed baseline in [current.md](current.md) and the actual implementation described in [architecture.md](architecture.md).

The sources were integrated into Formal memory by topic. Exact source checkpoints support the corresponding judgments, and complete source tips retain each source's first-parent evolution. All activity branches and worktrees have since been safely retired. All 70 source commits, including initialization commits, remain in Formal ancestry.

Original logs were not directly associated with Formal history because of review cost and persistence risks. The replacement sources were synthesized primarily from older memory histories without inheriting the old Auxiliary or ordinary project ancestry. Consolidation and retirement are completed activities. The acceptance records below support future audits, not a standing cleanup task. Detailed process history remains in Formal first-parent history.

## Source index

Paths are relative to the corresponding source Git tree root. Each `source.md` explains the evidence horizon; the sibling `current.md` and its first-parent history preserve selected knowledge evolution. The index locates retained knowledge without depending on deleted branch names, local mount paths, or checkpoint OIDs as persistent identifiers.

| Topic | UUID-relative recovery path | Knowledge states |
| --- | --- | ---: |
| monitor-host-x11 | `d1ecfe98-8d70-4ed0-8fe9-086bfb5721fc/memory/source.md` and sibling `current.md` | 3 |
| file-manager-terminal-portal | `7cc5b1b0-9ad0-47a3-8e9e-afeb342bd6e9/memory/source.md` and sibling `current.md` | 3 |
| metadata-claims | `bd1cbfba-87f8-40ff-8170-07cf548cca1e/memory/source.md` and sibling `current.md` | 3 |
| registry-nix-app | `3ae570e4-1a6f-4eb5-a587-fef91898260a/memory/source.md` and sibling `current.md` | 1 |
| framebuffer-kmscon | `4038629b-910a-4e71-a8da-fcb671781cfc/memory/source.md` and sibling `current.md` | 1 |
| module-composition | `ab0e5495-e6c7-449b-a798-4b7453eb9319/memory/source.md` and sibling `current.md` | 6 |
| pi-skills | `67b1954b-f1df-49fa-9d6d-90f7779239e2/memory/source.md` and sibling `current.md` | 3 |
| flake-parts-introduction | `556edc63-3a28-4090-9d6f-12d884625a5a/memory/source.md` and sibling `current.md` | 2 |
| identity-secrets-armor | `8536cd94-a761-42a6-9ebd-517e37d30423/memory/source.md` and sibling `current.md` | 5 |
| cfg-aliases | `cc157a3b-d374-4edf-b3f1-284a0f7a8fab/memory/source.md` and sibling `current.md` | 2 |
| agent-providers | `d39e1ab2-c94e-4ec6-b7b9-eb5d16a54dec/memory/source.md` and sibling `current.md` | 2 |
| readonly-host-packages | `01d8e08d-e649-4b6a-989b-01c1f8f3b71a/memory/source.md` and sibling `current.md` | 4 |
| flake-parts-module-refactor | `ddc19bb1-dbb6-463a-8201-f286531af917/memory/source.md` and sibling `current.md` | 4 |
| clash-geodata | `ee5ea724-542e-4a38-a6a0-d7aee9717cc0/memory/source.md` and sibling `current.md` | 2 |
| icewm-fallback | `2b6c7939-aeff-4f1a-adcb-2a578653020a/memory/source.md` and sibling `current.md` | 2 |
| wsl-removal-commit-semantics | `602000f2-8797-4731-acf7-02ac8d0ba8e1/memory/source.md` and sibling `current.md` | 3 |
| noctalia-lockscreen | `dacd12b8-abff-441e-a495-ccaa2e8d6c65/memory/source.md` and sibling `current.md` | 3 |
| wireguard-evolution | `8a007c91-445c-4409-9af8-c574fe2663a3/memory/source.md` and sibling `current.md` | 3 |

## Retirement of old histories and local garbage collection

After knowledge and source acceptance, the user separately authorized cleanup and explicitly approved deleting all unreachable commits and independent blobs/trees without backup. The 18 original histories and 18 abandoned trial histories accounted for 36 retired branches/worktrees.

Before removal, tips, worktrees, the complete index, untracked files, and in-progress operations were checked again. Worktrees were not forcibly removed to discard changes. Branches were explicitly abandoned through public `git gaw branch -D`, without manual ref changes.

After retention relationships were checked again, only unreachable reflog entries were expired; reachable reflog history was preserved. `git gc --prune=now` then ran with additional reflog expiration disabled. No recovery bundle was made.

The pre-cleanup unreachable set contained:

| Object type | Count |
| --- | ---: |
| Commits | 276 |
| Trees | 702 |
| Blobs | 681 |

The 276 commits comprised 187 designated retired commits and 89 other unreachable commits whose deletion the user also approved. Separately, 469 blobs and 22 trees outside those commits' closures in the original preflight received explicit deletion approval.

Post-cleanup checks individually tested the 187 old/trial commits, 17 original rollout blobs, and 936 objects from the original non-target preflight set. All were unreadable. The complete unreachable-object check was empty. The 36 designated refs/worktrees were absent. At that intermediate point, 18 clean Auxiliary histories and 20 total worktrees remained, and every clean tip was still reachable from Formal ancestry. Ordinary project branches were unchanged; there was no push or ordinary project history rewrite.

An existing commit-graph cache referenced four invalid entries. Rebuilding that derived cache with public `git commit-graph write --reachable --split=replace` restored successful default full object checks and post-GC checks. Objects shared with legitimate retained history remained present; their retention was not treated as cleanup failure.

### GC scope and limits

These results concern Git objects and the specified worktrees in the target local repository only. They do not guarantee deletion of external copies or physical storage remnants. Original Codex sessions and isolated review copies outside the repository were not removed. Temporary material in ignored directories was not automatically cleared. Those copies are not long-term recovery dependencies of Formal memory.

The recorded checks are historical results, not new checks performed during English normalization. This maintenance does not repeat GC, change retention, or attempt to reconstruct discarded original logs.

## Safe retirement of integrated clean sources

After the old-history GC described above, the user explicitly accepted the personal configuration context retained in the sources and authorized retiring all 18 clean Auxiliary activity branches.

Before retirement, complete source tips were confirmed to be in Formal ancestry. All associated worktrees, indexes, and untracked states were clean, with no operation in progress. Each worktree was removed, `git gaw aux check` was repeated, and the public `git gaw branch -d` safely deleted the branch. This stage did not use `-D`.

Acceptance results:

- Zero Auxiliary branches remained; only the ordinary project and Formal worktrees remained.
- All 70 commits from the 18 clean sources remained reachable from Formal, including 52 knowledge checkpoints and 18 initialization roots.
- UUID-relative source paths and Formal integration parents were preserved. Removing activity branches did not remove retained source history.
- Source recovery remained possible through the relevant integration checkpoint's parents and the source index, without deleted branch names or local worktree paths.
- This retirement stage performed no GC or push. Ordinary project refs were unchanged, and full `fsck` passed.

The sensitivity review covered the 80 commits then reachable from Formal and 93 file-content versions. It found no credential values or original logs. Some sources contain usernames and personal configuration context, which the user explicitly accepted. This does not categorically exclude every unidentified risk. The acceptance does not authorize retaining credential values.

## Recovering retained source knowledge

1. Locate the relevant topic's Formal integration record through first-parent path history:

   ```sh
   git log --first-parent refs/gaw/HEAD -- memory/architecture.md memory/consolidation.md
   ```

2. Inspect its parent list:

   ```sh
   git gaw show --no-patch --format=raw <integration>
   ```

3. Inspect candidate external-parent trees for the UUID and source paths in the index. Parent positions have no fixed business meaning; do not assume a particular parent number identifies a source.
4. Read the retained synthesis and, when useful, its evolution:

   ```sh
   git show <source-parent>:<uuid>/memory/current.md
   git show <source-parent>:<uuid>/memory/source.md
   git log --first-parent <source-parent>
   ```

Revisions discovered during this inspection are operational lookup references, not persistent semantic identifiers. Recovery does not require recreating an Auxiliary branch or worktree.

Reachability proves historical retention, not independent validation or adoption of every statement. Keep historical checks, user-reported execution, the committed static review, and current execution validation distinct. Superseded proposals are not current APIs. Summary consistency cannot fill evidence gaps from old workspaces, truncated output, or behavior that was not reproduced. Original material was not retained in the replacement sources, so this index cannot reconstruct complete original logs.

## Consolidation corrections and maintenance lessons

Architecture memory records the adopted corrections: Noctalia weather ended disabled rather than in the earlier trial-enabled state; internal interfaces and UID constraints are interpreted against the current implementation. The architectural rationale remains distinct from current verification evidence.

Review material before giving it a persistent source history, and inspect final content and newly introduced events before committing. Deleting a branch afterward is not a substitute for sensitivity review. User acceptance of personal configuration context is narrower than permission to retain credential values.
