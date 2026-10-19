# Project knowledge at the first module-protocol integration

## Scope and motivation

This reconstructed state describes the initial explicit modular architecture as integrated into main by the development-line merge in early June. The associated project parent is the exact historical tree inspected now. This GAW commit is made at reconstruction time and is not a contemporaneous build record. The main first-parent merge, rather than date-sorting its development commits, determines this stage's position.

WSL and native ThinkBook continue to share user-level configuration while preserving platform differences. The owner now explains that treating an entire Home Manager configuration as the sharing unit was too coarse. The supplied research dossier recovers early discussion positions: cross-layer Features need coherent OS/HM activation; the final flake selects enabled components; host, user and feature modules should be peers; checking dependencies must not silently enable peers. These are attributed historical paraphrases, not complete original messages. Static source corroborates incremental adoption, not perfect realization of every principle.

## Composition and responsibilities

`flake.nix` still calls `inputs.nixpkgs.lib.nixosSystem` separately for `nixos` and `nixos-wsl`. It replaces `globalConfGenerate` with exported `nixosModules.base`, `features`, `hosts` and `users` wrappers and explicit per-system selections. `modules.base.enable` gates common policy; `allowUnfreePredicateList` controls the permitted unfree package names. External Home Manager, Niri, Noctalia, SOPS, WSL and Flatpak wiring remains in wrappers. This phase does not yet use flake-parts or a general construction library.

Implementations are grouped under `modules/features/`, `modules/hosts/` and `modules/users/`, with matching `modules.features`, `modules.hosts` and `modules.users` option responsibilities. Feature modules use enable flags and conditional configuration. A directory move and an option-namespace change are separate implementation steps, both integrated by this main merge. Host entry points were briefly changed to `configuration.nix`; `default.nix` then became the directory entry aggregating that file and submodules. Use the actual snapshot's paths rather than treating an intermediate name as permanent.

The wrappers remain explicit. `features.share` groups several feature imports; Niri and secret wrappers add external provider integrations. The flake selects each host and activates its intended capabilities. This is not automatic discovery of all features or a blanket guarantee that importing any wrapper has no effects. A separate modularizer flake was explored and deferred in favor of handwritten options and narrow pure helpers; this was not a permanent ban on later abstractions.

## User and cross-layer interfaces

The initial `modules.users` interface is one record with `enable`, `name`, `uid` and `home`. The exported `users.lingyu` wrapper fills it, while generated NixOS and HM user entries use the UID string. `modules/users/default.nix` still imports the specific `./lingyu` profile. This is UID-referenced integration, not the later `attrsOf submodule` multi-user registry or per-feature `allowUidList` router.

Feature enable options make cross-layer participation more explicit. Niri has greeter, monitor geometry, Noctalia and Waybar options. Secret integration has distinct OS/HM controls at this stage. Do not rename these to later interfaces or claim that later general user routing is already implemented.

For maintenance, read the exported wrappers and final system choices in `flake.nix`, then the selected feature's own options and OS/HM imports. Keep the capability's shared contract out of a personal profile where practical, and hardware/platform details in the host. Central selection, dependency availability and side-effect gating are distinct questions; check each rather than inferring behavior from directory names.

## Capabilities and unresolved work

The ThinkBook has the Niri/Noctalia desktop, optional Waybar, greetd/Sway/gtkgreet login, and desktop-oriented office/media features. WSL selects its platform and shared cloud, shell, font, secret and other user capabilities without native laptop graphics requirements. Cloud has already been extracted from the personal profile. The greeter's temporary Sway session launches the Niri session wrapper; it does not replace Niri as the user compositor.

General multi-user composition and recipient routing remain future work at this horizon. Later discussion reports a duplicate base import/declaration problem and disappeared Niri service/portal components. The supplied dossier does not establish their final diagnosis, exact fix or successful evaluation. Do not present an assistant's stable-key proposal as an adopted and verified resolution.

## Evidence and continuation

This task directly inspected the integrated flake and user interface, the development commits' relationship to main, and earlier cloud/greeter changes. No Nix evaluation, build, deployment, decryption or runtime login test was performed. A code-level invariant or assertion is not evidence that every system evaluated successfully. The next independently useful state is the general UID registry and feature-to-HM import routing, checked against its own committed tree.

See [reconstruction.md](reconstruction.md) for the present establishment task, source coverage and retention limits.
