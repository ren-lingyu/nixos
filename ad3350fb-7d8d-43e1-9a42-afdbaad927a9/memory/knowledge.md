# Metadata Claims

This independent source history reconstructs one existing archived discovery line. It is historical evidence, not Formal current-memory authority. The input is previously distilled memory, not a complete original transcript. Raw rollouts, logs, archives, old Git trees and old GAW parents are not retained. Relative source-state order is supported, but no global ordering against other discovery lines is inferred. Checkpoints are created now without backdating. Exact original project provenance is unestablished; no project parent is guessed. Historical test reports below are not rerun by this task.

## Recoverable knowledge

Host metadata describes static facts/capabilities, not a shared consumer's activation view. It is loaded for disabled hosts too, including UID slots and monitors, without enabling their OS behavior. Profile roots retain activation/availability witnesses. Data integrity applies even when disabled; headless hosts may have no monitor, while graphical consumers require a unique default.

Automatic metadata made an old unregistered-UID fixture accidentally valid. At this historical stage the owner chose explicitly forcing the host registry empty rather than relying on a different unused UID. This is a stage-specific fixture, later revised again when clearing an attrset no longer worked. Static diff review does not demonstrate a successful evaluation.

Claims express stable host membership, not runtime online exclusivity. Duplicate WireGuard identities/addresses can conflict; a secret manager does not solve coordination. Derive node-specific values only with one claimant, leaving an independent claimed flag and meaningful assertions rather than failing on an empty list first. Public IP is a generic nullable host fact, not a provider-specific interface.

The schema names networks/nodes and checks unknown claims and counts. Historical min/max zero means no limit in that direction, so the pair cannot express exactly zero claimants. Count all metadata claimants rather than the active closure's boolean. A flexible schema does not establish complete multiple-claim generation support.

The final helper becomes a curried three-argument mkNode function: network name, node name and derivation callback. Current-closure membership and global unique claimant metadata have distinct roles. Assertions are generated directly with contextual network/node messages. Multiple-claim derived attributes remain deferred. The last changes were on top of staged work and had only diff-format review, not a successful Nix check.

## Continuation

Compare these conclusions with the relevant project snapshot before Formal adoption. Preserve unresolved questions, distinguish proposals from adopted behavior and do not extend a historical successful check to later changes.
