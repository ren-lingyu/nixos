# Project knowledge at generalized UID and Feature routing

## Horizon and adopted direction

This reconstructed state describes the June 6 implementation of general UID-keyed users, feature discovery and selected-user HM routing. The project parent identifies the tree reinspected now; this GAW commit is created during reconstruction. It does not prove when every machine adopted the design or that historical evaluations passed.

The owner wanted finer sharing than one monolithic Home Manager profile, including Features spanning NixOS and selected users' HM configuration. The research dossier recovers the direction toward central flake enablement, peer modules and UID allowlists without per-feature/per-user nested switches. Those discussion leads are paraphrases. The committed implementation determines the exact interfaces and defaults described below.

## Composition root and implementation availability

The final flake still constructs ThinkBook and WSL with `nixosSystem`, selects explicit public wrappers and sets feature values. `nixosModules.base` imports Home Manager and the common `./modules` entry. `modules/default.nix` imports the feature/user schemas and owns common GC, basic tools, unfree policy and baseline HM settings. The previous `modules.base.enable` gate is no longer in this shared root. Public wrappers still repeat the anonymous base wrapper and carry some provider integrations; do not portray dependency decoupling or stable module identity as already complete.

`modules/features/default.nix` discovers immediate feature directories and generates `enable`, `allowUidList` and `existModule.{os,hm}` options. At this point the availability markers are internal unique boolean options with `false` defaults, supplied by implementations. Filesystem directory discovery does not yet derive whether every OS/HM implementation exists. The later nullable marker design and construction-library registry are separate evolutions.

## UID registry, identity and routing

`modules/users/default.nix` exposes `modules.users` as `attrsOf (submodule ...)`, keyed by numeric UID strings. Each user has separate `enable`, `uid`, `username`, `home.enable`, `home.directory`, `home.manager.enable` and `home.manager.source`. UID defaults from the key and must agree with it. Enabled users require a nonempty unique username and normal-user UID; home/HM participation has implication and path checks. Profile source paths must remain under `modules/users` with an existing entry point. The module produces NixOS users and eligible HM users and binds their identity values.

Enabled HM-capable features contribute their `hm` implementation to the imports of each allowlisted UID. Listed users must exist, be enabled and have HM enabled. An empty allowlist is valid and produces no recipients. The actual default is `[1000]` when `existModule.hm` is true, otherwise `[]`. The discussion's wish to reach all eligible users is not this committed default. A general schema is not evidence of multiple deployed users or automatic distribution to every future user.

For maintenance, register the user and its personal profile independently from reusable Feature implementation. Inspect eligibility and the Feature allowlist whenever a module is missing from a user's HM imports. Changing the default list has delivery consequences. Keep the Feature's OS requirements and selected HM recipients explicit; importing a feature directory, enabling a feature and routing its HM part are different operations.

## Features, platforms and login

ThinkBook and WSL retain distinct platform wrappers and feature choices while sharing the user registry and selected capabilities. Niri still owns desktop options and the greetd/Sway/gtkgreet login boundary; temporary greeter composition is distinct from the user's Niri session. SOPS/secret integration and external provider modules remain configured through the corresponding wrappers. Reusable cloud functionality is separate from the personal profile; shell/editor extraction, additional hosts and broader shared-user policy follow in later main states.

The design moved beyond mere file categorization: common declarations, UID identity checks and feature recipient aggregation now encode responsibilities and interfaces. It still has implementation tensions. The recovered duplicate base declaration report motivates checking self-contained wrapper dependencies versus imported-once infrastructure. A shared file root is visible, but the evidence does not establish the exact successful repair of the reported error. The Niri service/portal regression lead likewise remains unresolved by the available material.

## Verification and next action

The present task directly inspected the flake, feature/user/root files and their parent-order relationship to the first integrated namespace state. It ran no Nix evaluation, build, deployment or runtime test. Assertions describe intended rejection conditions, not observed negative-test results. Author and committer timestamps diverge for some subsequent migrations; use main ancestry for their reconstruction order, not timestamp sorting.

Continue with actual feature/user responsibility migrations and host selection, then the later flake-parts, interface/library, metadata, identity, networking and configuration-construction stages. Each has its own evidence and validation boundary. See [reconstruction.md](reconstruction.md) for the present task and sources.
