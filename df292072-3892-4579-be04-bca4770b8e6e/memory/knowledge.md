# Flake Parts Introduction

This independent source history reconstructs one existing archived discovery line. It is historical evidence, not Formal current-memory authority. The input is previously distilled memory, not a complete original transcript. Raw rollouts, logs, archives, old Git trees and old GAW parents are not retained. Relative source-state order is supported, but no global ordering against other discovery lines is inferred. Checkpoints are created now without backdating. Exact original project provenance is unestablished; no project parent is guessed. Historical test reports below are not rerun by this task.

## Recoverable knowledge

Outputs now use `mkFlake` with `systems`. Keep NixOS configurations in top-level `flake` rather than transposing them per system. The convenience nixos-anywhere executable belongs under apps; use the per-system `inputs'` projection and explicit executable lookup rather than hand-assembled paths.

The source reports a check failure involving nested standard `nixosModules` handling and `features.share`. Flattened names and a registry hidden in a local let were rejected. The owner selected the custom public `self.modules.features/hosts/users` hierarchy; it is not a standard flake-parts output or the ecosystem's `flakeModules` interface. The diagnosis is historical and was not rerun here. No successful final check after this rename is preserved, and the app description belongs to a separate source. A partially staged working tree means the complete final source state has no proven exact project parent.

## Continuation

Compare these conclusions with the relevant project snapshot before Formal adoption. Preserve unresolved questions, distinguish proposals from adopted behavior and do not extend a historical successful check to later changes.
