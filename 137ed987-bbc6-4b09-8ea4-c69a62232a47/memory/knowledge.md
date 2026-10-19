# Framebuffer Kmscon

This independent source history reconstructs one existing archived discovery line. It is historical evidence, not Formal current-memory authority. The input is previously distilled memory, not a complete original transcript. Raw rollouts, logs, archives, old Git trees and old GAW parents are not retained. Relative source-state order is supported, but no global ordering against other discovery lines is inferred. Checkpoints are created now without backdating. Exact original project provenance is unestablished; no project parent is guessed. Historical test reports below are not rerun by this task.

## Recoverable knowledge

The inspected ThinkBook design uses a host-gated oneshot that sets fb0 geometry only when its device is xedrmfb, plus a udev add path for late device appearance. Its intended geometry is 3072x1920 with 32-bit depth before display-manager startup. This is framebuffer geometry, not kmscon's independently managed KMS/font layout.

Systemd Before/After order jobs in a common transaction; Wants/Requires pull dependencies in. Conflicts can stop another unit but does not restore it later. A completed oneshot usually has no resident process to kill, and stopping it does not undo the geometry. Earlier DRM card-change triggers could compete for modes without constituting a simple unit-name conflict.

Dependencies and ExecStartPre/StopPost examples were discussed, but concurrent kmscon VTs still complicate ownership. The source ends with an unanswered Conflicts proposal rather than an authorized adopted patch. It contains read-only source/history and documentation assessment, with no fbset, kmscon or systemd mutation/runtime validation. Original exact working-tree provenance is incomplete.

## Continuation

Compare these conclusions with the relevant project snapshot before Formal adoption. Preserve unresolved questions, distinguish proposals from adopted behavior and do not extend a historical successful check to later changes.
