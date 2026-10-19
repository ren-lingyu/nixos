# Flake Parts Module Refactor

This independent source history reconstructs one existing archived discovery line. It is historical evidence, not Formal current-memory authority. The input is previously distilled memory, not a complete original transcript. Raw rollouts, logs, archives, old Git trees and old GAW parents are not retained. Relative source-state order is supported, but no global ordering against other discovery lines is inferred. Checkpoints are created now without backdating. Exact original project provenance is unestablished; no project parent is guessed. Historical test reports below are not rerun by this task.

## Recoverable knowledge

The later flake-parts layer describes system configuration and selects implementations before calling nixosSystem. That outer selection is not a same-level NixOS config/import recursion. Configuration is separate from static metadata; the adapter treats functionTo/submodule according to declared types instead of guessing and calling arbitrary function values. OS config.modules becomes a read-only adapted view, and HM reads it through osConfig.

Declaration aggregation initially selected its own share declaration file and overflowed during import collection, rather than recursing in the adapter. ReadOnly wrapper defaults also conflicted with real values. Removing intermediate wrapper options lets Niri/X11 contribute session packages directly, with Niri priority and nonempty mainProgram validation; registering a session does not enable greeter. A negative UID fixture needed an unregistered UID because recursiveUpdate with an empty attrset did not clear inherited users. The source reports two successful checks for those respective dirty stages, not for every later migration. The retained source is itself a recovery summary, not the full original tool trace.

Responsibilities are regrouped under llib.types, modules, hosts, features.sops, packages and flakeParts. Collection construction uses mkNixosConfigurations, internally mapping mkNixosSystem. Keep flakeParts.types rather than introducing an extra configurations namespace. The now-unused groupImportsByUid implementation/export/tests are removed; its former role is preserved historically rather than presented as a current API. No comprehensive export reduction or new check is established after this cleanup.

## Continuation

Compare these conclusions with the relevant project snapshot before Formal adoption. Preserve unresolved questions, distinguish proposals from adopted behavior and do not extend a historical successful check to later changes.
