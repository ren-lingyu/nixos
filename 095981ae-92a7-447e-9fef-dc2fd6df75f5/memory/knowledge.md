# Monitor Host X11

This independent source history reconstructs one existing archived discovery line. It is historical evidence, not Formal current-memory authority. The input is previously distilled memory, not a complete original transcript. Raw rollouts, logs, archives, old Git trees and old GAW parents are not retained. Relative source-state order is supported, but no global ordering against other discovery lines is inferred. Checkpoints are created now without backdating. Exact original project provenance is unestablished; no project parent is guessed. Historical test reports below are not rerun by this task.

## Recoverable knowledge

The host owns monitor data and its invariants. Niri and greeter require one default monitor only when enabled. Logical attribute keys may differ from actual output names; duplicate actual names can silently overwrite generated outputs and must be rejected. Names are nonempty and unique, at most one monitor has the default role, dimensions are positive integers and non-null refresh/scale values are positive floats. Default selection checks cardinality before taking the first item, avoiding an empty-list failure that obscures the assertion.

Keep local types and assertion helpers near their consumers and retain complete option paths in diagnostics. A generated declaration is a source-level contract, not proof of a working display or login session.

Host profiles are now generated as fixed names from host directories with entry points rather than an open `attrsOf` namespace with `enable`, `monitors` and `packageGroups`. Importing a host root declares its own enablement. This stage permits zero or one enabled host globally; graphical consumers separately require exactly one host and default monitor. Do not back-project the later global exactly-one rule. Ordinary host OS/hardware effects are guarded by their own enable state; imports stay at module top level rather than under `config.mkIf`. Niri's internal unique monitor value is derived from the enabled host. Common fields and host-specific `extra-options.nix` are composed without dropping the defensive entry-point existence assertion.

The source also retains an earlier startx/XFCE fallback investigation: it sought a usable native X11 compatibility environment rather than extreme minimalism. A wrapper incorrectly left `$out` for runtime expansion; the fix used build-time absolute paths and the intended XFCE session/xinit packages. This is the initial fallback line, not a claim that XFCE remains the final implementation after the separate IceWM source. Overlay subdirectories gained discovery and explicit enable guards.

The source reports evaluations of desktop, server and WSL compositions and diff checks, without a fresh runtime login test. These are historical reports, not tests run in this task.

## Continuation

Compare these conclusions with the relevant project snapshot before Formal adoption. Preserve unresolved questions, distinguish proposals from adopted behavior and do not extend a historical successful check to later changes.
