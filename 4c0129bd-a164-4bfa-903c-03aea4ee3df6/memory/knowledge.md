# Module Composition

This independent source history reconstructs one existing archived discovery line. It is historical evidence, not Formal current-memory authority. The input is previously distilled memory, not a complete original transcript. Raw rollouts, logs, archives, old Git trees and old GAW parents are not retained. Relative source-state order is supported, but no global ordering against other discovery lines is inferred. Checkpoints are created now without backdating. Exact original project provenance is unestablished; no project parent is guessed. Historical test reports below are not rerun by this task.

## Recoverable knowledge

The final flake owns named external inputs, external OS/HM adaptation and final composition. Base is a shared dependency. Features, hosts and users are peer responsibilities; a proposal to move all feature policy into host wrappers was withdrawn. Highly customized functionality may still be a Feature, while expensive-to-modularize settings that always follow a user may remain personal. Split at stable communication boundaries rather than for directory aesthetics.

Availability markers distinguish unimported profiles from missing implementations: `existModule.os/hm` become nullable booleans, default null. Explicit booleans must agree with files; both sides are declared together or both unset, and enabling needs declarations. Earlier false defaults caused inappropriate checks when WSL did not import Niri. The editor wrapper gained the base dependency and remote correctly declared no OS implementation. Historical success reports cover their original stage, not all later refactors.

Features own per-user HM interface schemas under `hm/interface-options.nix`; each user's HM scope registers the schemas, while actual implementations are delivered only to eligible selected UIDs. `moduleInterfaces.features.<feature>` carries user-supplied data without embedding a single user identity or exposing implementation helper functions as input.

For SOPS, the user owns encrypted inventory and the feature consumes interface data. The system-to-HM age key file is a bootstrap bridge, not an ordinary user inventory item or a separate key per UID. A shared root-owned `sops-decrypt` group with mode 0440 and allowlist-derived members supplies access. The feature remains independently disableable so a secret tooling download/build failure need not block all base configuration.

Canonical decimal UID keys and unique allowlists are checked. Hosts register numeric UIDs rather than usernames or personal profiles; users own cross-module identity consistency. The former bidirectional equality check has been replaced as described below. A historical permission failure after rebuild involved a still-running user manager: NSS group membership did not update its process credentials. The owner reported recovery after boot; an inactive successful oneshot is not necessarily failure. No system operation was rerun here.

User configuration changes to discovered profile names rather than UID keys. The final flake binds a profile UID from the selected host's numeric registry; enablement is distinct from import and from final identity binding. Enabled users require non-null UIDs; disabled profiles may be prebound. Username/home defaults remain overridable. The old home.enable/manager.enable/source controls are removed; even a minimal profile without private HM configuration can receive common HM features.

The earlier equality constraint is superseded: enabled user UIDs need only be a subset of the host registry, which may reserve unused UIDs. Feature recipient defaults now derive from enabled users instead of hardcoding 1000. Shared interface discovery moves to the root and must read the actual module-kind directory. The reusable remote feature is removed because native HM rclone options suffice; personal remotes move into the user's configuration. Rclone remains enabled when secret support is disabled, while secret-backed remote credentials are conditional. Removing its explicit sops service requirement was an intentional owner decision.

## Continuation

Compare these conclusions with the relevant project snapshot before Formal adoption. Preserve unresolved questions, distinguish proposals from adopted behavior and do not extend a historical successful check to later changes.
