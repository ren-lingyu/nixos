# Tested composition contracts and reusable aggregation

## Composition and ownership

The root outputs now use `inputs.flake-parts.lib.mkFlake` with a systems list. NixOS configurations remain top-level flake outputs; each still calls `nixosSystem`. `perSystem` owns system-specific apps, not a transposed set of NixOS configurations. This changes flake construction while preserving final assembly responsibility at the root.

The public hierarchical module registry is now the custom `self.modules`, containing base/features/hosts/users. The independent source explains why a flat standard `nixosModules` naming scheme and a registry hidden in let were rejected. A reported nested-output schema failure motivated that discussion; the final rename is not backed by a retained successful source check. The custom-output warning was accepted at that time rather than changing Nix implementations solely for it. This is historical reasoning, not a current recommendation about alternative Nix implementations.

The convenience nixos-anywhere app uses the per-system `inputs'` projection and explicit executable lookup and now has a description. Editor has a separate public wrapper and configurable Emacs package selection, with the external distribution exposed through an overlay. Nixvim's independent dependency pin is preserved rather than forcing all dependencies to share a version.

Three configurations still compose desktop ThinkBook, WSL and Aliyun, common base policy, reusable features and directory-named user profiles. Shared shell/editor and XDG responsibilities remain separated from private profiles. Remote data now uses native rclone configuration in the user; the minimal profile retains common HM participation. Provider imports still live partly in public wrappers: this is not the much later flake-parts configuration-builder architecture.

`modules/hosts` now generates its namespace from host directories with entry points. Each profile has its own `enable`, `monitors` and package-group settings. Importing the host entry declares that host enabled; ordinary hardware and OS effects are guarded by its own enable state while imports remain at module top level. The global assertion currently permits zero or one enabled host. It is not yet the later exactly-one invariant.

## Monitor and session interfaces

Hosts own monitor facts. A logical monitor attribute key may differ from its actual output name; actual names must be nonempty and unique to avoid overwriting generated output entries. A host has at most one default-role monitor. Dimensions are positive integers and non-null refresh/scale values are positive floats. Niri's internal monitor configuration is derived from the selected host rather than repeated as feature-local constants.

Graphical consumers add contextual requirements: enabled Niri and greeter require exactly one enabled host and exactly one default monitor. Thus headless compositions may have no default display without weakening graphical validation. Derivations check list cardinality before selecting its first member, so malformed metadata can reach meaningful assertions rather than failing on an empty list.

Greeter has become an independent Feature. It owns login service implementation and consumes session packages provided by desktop features; Niri owns its session wrapper and user compositor. The greetd service's temporary Sway/gtkgreet session is not the user's Niri session. The greeter registers the session providers, and a separate native X11 compatibility path is now available.

## X11 compatibility responsibility

The initial XFCE fallback has been replaced with IceWM. This is a general compatibility session alongside Niri, accessible at login or from another TTY, not a bespoke meeting-app environment. The OS owns Xorg/startx/IceWM and the `X11-Session` entry. HM owns minimal launcher configuration. The wrapper starts `icewm-session` under a new D-Bus session and clears inherited display/compositor variables. It does not attach itself to the main user graphical target or hardcode input-method startup.

The first phase provides xrandr/xdg tools without automatic host-monitor layout or cross-VT clipboard policy. The independent source reports a successful user rebuild test, TTY login and broadly working meeting software; the browser could still reuse a Niri instance, without a confirmed resolution. These are attributed historical observations, not tests executed now. Inspect `modules/features/x11-session/{default.nix,os/default.nix,hm/default.nix}` for the interface and implementation split.

## Maintenance and evidence

Inspect `modules/hosts/default.nix`, the selected host `default.nix`, and `modules/features/{niri,greeter}/default.nix`. Keep monitor data in hosts and graphical prerequisites in consumers. Do not weaken name/cardinality checks simply because a default display works on ThinkBook. Do not put imports under an enable-dependent `config` branch.

The independent monitor source preserves the motivation, earlier schema and namespace transition. Its reported rebuild/evaluation successes apply to historical working trees with incomplete exact provenance, not to every tree associated here. The source is used for rationale while the directly inspected main snapshot determines the committed interface. The earlier Niri service/portal investigation is not retrospectively declared resolved by this extraction.

## Platform scope correction

WSL no longer includes vscode-server integration. The inspected main change removes its flake input and wrapper import; the associated lock/platform result no longer needs that integration. NixOS-WSL remains the platform dependency. This is an intentional capability removal, not just an extraction that preserves all behavior.

The independent source preserves the owner's intent and historical read-only completion checks. It also corrected an earlier commit-title recommendation: classify the actual removal semantically rather than mechanically following earlier refactor titles. No history rewrite is performed by this reconstruction. The source's user-reported check and later clean-worktree inspection do not establish fresh verification of this project parent.

## Discovery versus activation

Host declarations are now generated from directories with `default.nix`; the prior open host-key submodule schema is replaced by fixed discovered names. Common enable/monitor/package/Flatpak fields combine with per-host `extra-options.nix`. The enabled-host entry-point check remains deliberately defensive. Feature discovery also requires an actual entry point.

This changes what names are available, not who activates them. Global host cardinality remains at most one, and graphical consumers retain stronger selection/display prerequisites. Import availability and enable effects must be checked separately. The monitor source's later state preserves the transition and an earlier XFCE wrapper lesson; that XFCE investigation does not supersede the already-adopted IceWM result.

Local `cfg` aliases abbreviate own-configuration reads; schema definition paths, cross-module references and diagnostic paths remain explicit. The alias source reports one host's unchanged active closure after a historical check/rebuild, not a universal or freshly repeated runtime equivalence result.

## Imported state is not missing implementation

Feature availability markers now use unique nullable booleans, default null. Null means the root has not declared availability; explicit true/false must match the OS/HM entry-point files. Both sides are declared together, and an enabled feature needs a declared root. HM delivery checks explicit true. This avoids treating a feature not imported by WSL as a malformed declared implementation.

The flake remains the external adapter and final composition owner. Base is shared infrastructure; hosts/users/features retain peer responsibilities. Moving all reusable policy into host wrappers was considered and withdrawn. The editor wrapper gained its base dependency; before removal, remote was corrected to declare no OS implementation. Personal settings need not be extracted merely to make directories look more uniform. That availability step still defaulted recipients to UID 1000; profile composition subsequently replaced the default with enabled assigned users.

The composition source preserves reported checks at specific old working stages. The inspected source contract establishes the committed declarations, without proving a new evaluation or resolving every original regression.

## Per-user data, shared schemas and secret bootstrap

Features can declare HM interface schemas under `hm/interface-options.nix`. Each user's HM scope registers `moduleInterfaces.features.<feature>`, while implementations are sent only to selected recipients. A user supplies data; the feature owns schema and implementation. Schema availability does not enable behavior for every user.

SOPS inputs move behind that interface. The system-to-HM age key file remains a bootstrap bridge, supplied with root ownership and a `sops-decrypt` group at mode 0440; selected users become group members. Encrypted inventory belongs with the user's input data. The secret feature remains disableable independently from base operation. A historical permission failure concerned stale process group credentials despite correct NSS membership; the owner reported recovery after boot. This is not a newly exercised runtime result.

Hosts now register canonical decimal UIDs independently of login names and profile contents. The initial registry step used bidirectional equality, subsequently corrected to subset membership as explained below. Feature recipient lists reject duplicate UIDs and invalid user references. Root inputs and wrapper adaptation remain explicit.

## Identity binding and corrected membership

Users are discovered by profile directory name, not keyed by UID. The final flake binds a profile's UID from a host registry; username and home-directory defaults can be overridden. Enabled users need a bound UID and unique identity; disabled profiles may be prebound. The earlier home/manager/source switches are replaced by this profile model. A minimal user without private HM files still participates in generated HM users and common Features.

The former bidirectional equality check is replaced by subset membership: enabled user UIDs must belong to the selected host's registry, which may reserve unused values. HM-capable Feature recipients default to the enabled assigned users instead of hardcoded 1000. Shared interface discovery is centralized across module kinds.

Hosts/users now also declare private OS/HM availability. Their roots are NixOS coordination modules: static OS imports cannot depend on config, while HM delivery can be conditional. A false private HM availability marker does not disable HM as a whole. Remote is removed as an extra feature layer because native rclone options suffice; personal remotes move into the user profile, with secret-backed entries conditional on secret support. The owner intentionally removed the explicit sops-service requirement rather than preserving it by habit.

## Public construction helpers without hidden ownership

The root `lib/` is exposed as a flake library, instantiated with the receiving module system's nixpkgs lib. Base passes `llib` through OS `_module.args` and HM `extraSpecialArgs`; ordinary imported option/interface functions still need explicit arguments. Secret generators and monitor option types move into public namespaces. Hosts retain per-monitor definition uniqueness and Niri retains whole-value uniqueness.

Repeated anonymous base wrappers caused duplicate library-argument definitions during the historical migration. The inspected flake gives base a stable `_file` and `key` while preserving its function arguments. This is a supported later resolution of that specific library-era identity failure, not proof that every early-June base complaint had the same exact fix. The source also records an earlier shadowing failure reverted by the owner.

Availability contracts and profile responsibilities remain separate from library mechanics. Keep schemas/assertions with the responsible module collection; OS imports are static, HM imports may be recipient-dependent. The source reports a successful historical check for this phase; no new evaluation is run now.

## Generic helpers, real assertions and documentation

Availability types/assertions are centralized without hiding real file paths and diagnostic context. `groupImportsByUid` takes two explicit name/value selectors for recipient UIDs and imports. It groups values with prepend semantics: later traversed item names precede earlier ones for a shared UID. The committed fixture expects beta-hm before alpha-hm. This ordering was clarified by static reinspection during reconstruction; callers still own filtering and paths. Module arguments do not automatically flow through ordinary function application, so option/interface import functions receive `llib` explicitly.

Per-system checks register type, availability, UID grouping and SOPS generator categories plus real module-composition negative cases. They exercise missing UID bindings, unregistered enabled users and invalid recipient references using actual assertions rather than copying the rules. The shared monitor type enforces nonempty names, with a negative test; package options and diagnostics are clarified. README preserves its directory overview and adds the ownership/assembly contracts rather than replacing all structure with a new document.

Historical sources report successful category/composition checks for specific intermediate trees. Subsequent type, shell and documentation changes had static review only, so this stage does not acquire a blanket fresh pass. Browser cross-session reuse, the older Niri service/portal lead and comprehensive original working-tree provenance remain limited evidence.

## Evidence and maintenance boundaries

This is a reconstructed historical knowledge state grounded in the associated project tree inspected during the present task. Its GAW commit is created now, not at the original event time. Main ancestry orders Formal stages; dates alone do not establish adoption. Discussion summaries establish attributed intent with limited completeness. Historical test reports are not new checks. This task has run no Nix evaluation, build, deployment, decryption or runtime test.

Read [reconstruction.md](reconstruction.md) for the current establishment work and [sources.md](sources.md) for source coverage and retained history. Do not interpret this in-progress historical horizon as the architecture deployed today.
