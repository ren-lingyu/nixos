# Flake Parts Module Refactor

This independent source history reconstructs one existing archived discovery line. It is historical evidence, not Formal current-memory authority. The input is previously distilled memory, not a complete original transcript. Raw rollouts, logs, archives, old Git trees and old GAW parents are not retained. Relative source-state order is supported, but no global ordering against other discovery lines is inferred. Checkpoints are created now without backdating. Exact original project provenance is unestablished; no project parent is guessed. Historical test reports below are not rerun by this task.

## Recoverable knowledge

The later flake-parts layer describes system configuration and selects implementations before calling nixosSystem. That outer selection is not a same-level NixOS config/import recursion. Configuration is separate from static metadata; the adapter treats functionTo/submodule according to declared types instead of guessing and calling arbitrary function values. OS config.modules becomes a read-only adapted view, and HM reads it through osConfig.

Declaration aggregation initially selected its own share declaration file and overflowed during import collection, rather than recursing in the adapter. ReadOnly wrapper defaults also conflicted with real values. Removing intermediate wrapper options lets Niri/X11 contribute session packages directly, with Niri priority and nonempty mainProgram validation; registering a session does not enable greeter. A negative UID fixture needed an unregistered UID because recursiveUpdate with an empty attrset did not clear inherited users. The source reports two successful checks for those respective dirty stages, not for every later migration. The retained source is itself a recovery summary, not the full original tool trace.

Responsibilities are regrouped under llib.types, modules, hosts, features.sops, packages and flakeParts. Collection construction uses mkNixosConfigurations, internally mapping mkNixosSystem. Keep flakeParts.types rather than introducing an extra configurations namespace. The now-unused groupImportsByUid implementation/export/tests are removed; its former role is preserved historically rather than presented as a current API. No comprehensive export reduction or new check is established after this cleanup.

Declaration registration becomes a private construction responsibility in lib/flakeParts.configurations.nix. Private generators return OS and HM declaration modules to the builder. OS declarations enter system modules and HM interfaces enter each user's sharedModules independently of share.enable. Share owns common behavior only. Proposed public builder.nixosModules/homeModules and inline flake aggregators were withdrawn.

User HM delivery binds the selected UID; Feature HM delivery follows allowUidList; other HM implementations and registry integrations use sharedModules. Declared interfaces do not imply enabled behavior. The existing internal/interface namespaces retain their value/type/merge semantics. This private-generation stage has targeted source/diff evidence, not a new Nix pass.

The final project discovery convention is _options.fp.nix for prefixed outer configuration/metadata schema, os/_options.os.nix for native OS declaration modules, and hm/_options.hm.nix for feature-name/HM-context interface fragments. The suffix selects interpretation environment, not a fixed namespace or common function signature. _metadata.nix remains static data. There is no compatibility fallback for old filenames.

The source records 18 byte-identical declaration-file renames with matching loader/README changes and static old-path checks. Existing tests had no old declaration-path references. These are repository loader conventions, not native automatic loading rules of the three module systems. The final renamed candidate was staged and reviewed, without a demonstrated final Nix check or a share-disabled declaration test. Earlier successful checks must not be extended to this state.

## Continuation

Compare these conclusions with the relevant project snapshot before Formal adoption. Preserve unresolved questions, distinguish proposals from adopted behavior and do not extend a historical successful check to later changes.
