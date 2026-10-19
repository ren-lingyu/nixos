# Module Composition

This independent source history reconstructs one existing archived discovery line. It is historical evidence, not Formal current-memory authority. The input is previously distilled memory, not a complete original transcript. Raw rollouts, logs, archives, old Git trees and old GAW parents are not retained. Relative source-state order is supported, but no global ordering against other discovery lines is inferred. Checkpoints are created now without backdating. Exact original project provenance is unestablished; no project parent is guessed. Historical test reports below are not rerun by this task.

## Recoverable knowledge

The final flake owns named external inputs, external OS/HM adaptation and final composition. Base is a shared dependency. Features, hosts and users are peer responsibilities; a proposal to move all feature policy into host wrappers was withdrawn. Highly customized functionality may still be a Feature, while expensive-to-modularize settings that always follow a user may remain personal. Split at stable communication boundaries rather than for directory aesthetics.

Availability markers distinguish unimported profiles from missing implementations: `existModule.os/hm` become nullable booleans, default null. Explicit booleans must agree with files; both sides are declared together or both unset, and enabling needs declarations. Earlier false defaults caused inappropriate checks when WSL did not import Niri. The editor wrapper gained the base dependency and remote correctly declared no OS implementation. Historical success reports cover their original stage, not all later refactors.

Features own per-user HM interface schemas under `hm/interface-options.nix`; each user's HM scope registers the schemas, while actual implementations are delivered only to eligible selected UIDs. `moduleInterfaces.features.<feature>` carries user-supplied data without embedding a single user identity or exposing implementation helper functions as input.

For SOPS, the user owns encrypted inventory and the feature consumes interface data. The system-to-HM age key file is a bootstrap bridge, not an ordinary user inventory item or a separate key per UID. A shared root-owned `sops-decrypt` group with mode 0440 and allowlist-derived members supplies access. The feature remains independently disableable so a secret tooling download/build failure need not block all base configuration.

Canonical decimal UID keys and unique allowlists are checked. Hosts register numeric UIDs rather than usernames or personal profiles; users own cross-module identity consistency. The former equality check is superseded by subset membership. A historical permission failure after rebuild involved a still-running user manager: NSS group membership did not update its process credentials. The owner reported recovery after boot; an inactive successful oneshot is not necessarily failure. No system operation was rerun here.

User configuration changes to discovered profile names rather than UID keys. The final flake binds a profile UID from the selected host's numeric registry; enablement is distinct from import and from final identity binding. Enabled users require non-null UIDs; disabled profiles may be prebound. Username/home defaults remain overridable. The old home.enable/manager.enable/source controls are removed; even a minimal profile without private HM configuration can receive common HM features.

The earlier equality constraint is superseded: enabled user UIDs need only be a subset of the host registry, which may reserve unused UIDs. Feature recipient defaults now derive from enabled users instead of hardcoding 1000. Shared interface discovery moves to the root and must read the actual module-kind directory. The reusable remote feature is removed because native HM rclone options suffice; personal remotes move into the user's configuration. Rclone remains enabled when secret support is disabled, while secret-backed remote credentials are conditional. Removing its explicit sops service requirement was an intentional owner decision.

Profile roots are NixOS coordination modules; OS imports are static and HM implementation delivery can be conditional. Availability describes private files, not whether the user can have HM at all. Keep collection schemas/assertions with each module kind.

The root public library is instantiated using the receiving module system's nixpkgs lib and passed as `llib` to OS module arguments and HM extraSpecialArgs. Secret helpers move into the feature-specific moduleFunctions namespace. Shared monitor types replace duplicated definitions without removing per-entry host uniqueness or whole-value Niri uniqueness. A check exposed anonymous repeated base wrappers defining `_module.args.llib` twice; the adopted fix retained function arguments and gave the wrapper stable `key`/`_file` identity. Simply turning it into an attribute set was not a sufficient general remedy. A separate shadowing failure had earlier been reverted by the owner.

Greeter session packages retain interface-presence probing, non-null values and package metadata validation; enabled greeter requires a nonempty provider list. The source reports a successful check at this library stage, without proving earlier failures or later edits successful.

ExistModule types/assertion generators centralize paired declarations, enable witnesses and file consistency while callers retain real paths and contextual diagnostics. Ordinary imported functions do not inherit module arguments automatically: extra-options and interface functions must explicitly receive `llib`.

`groupImportsByUid` accepts separate UID and import selectors, each taking item name and value. It traverses attributes, stringifies UIDs and prepends each contribution to the accumulated imports. Later traversed names therefore precede earlier names for a shared UID. Callers own feature filtering, enable/availability semantics and file layout. The nested folds remain; no opaque result-record callback or unrelated mkMerge abstraction is introduced. Static review at this step is not yet a new check result.

Tests are registered through per-system checks with category derivations. They cover monitor/availability types, UID import grouping and SOPS generation, plus actual module-composition assertions rejecting unbound users, unregistered UIDs and invalid feature recipients. The source reports earlier successful category and composition checks for that stage. Later type, shell and documentation refinements have only static diff evidence, so success must not be extended automatically.

Nonempty monitor names move into the shared type with a negative case. Shell package options and diagnostics are clarified. An attempted wholesale README replacement was withdrawn; the adopted documentation preserves directory sections and adds contracts before the structural overview. Remaining wrapper-path/diagnostic cleanup was optional work, not falsely declared complete.

## Continuation

Compare these conclusions with the relevant project snapshot before Formal adoption. Preserve unresolved questions, distinguish proposals from adopted behavior and do not extend a historical successful check to later changes.

## Reconstruction-time ordering correction

Direct inspection of the historical `lib/moduleFunctions.features.default.nix` and `tests/feature-import-grouping/default.nix` establishes prepend behavior: the shared UID fixture expects beta-hm before alpha-hm. The earlier summary's generic ordering language was insufficient. This is a newly confirmed static interpretation during reconstruction, not an additional original-session result or a newly run Nix test. Keep the exact sequence when refactoring the fold.
