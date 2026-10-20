# Architecture and design constraints

## Purpose and composition

The committed project defines nixos (ThinkBook), nixos-matebook, nixos-server (Aliyun) and nixos-wsl. Its goal is selectable shared user capabilities over distinct platform/hardware environments, with finer ownership than one monolithic HM profile. Root flake-parts options own final enablement, UID binding and external input/module/overlay adaptation. Hosts, users, features and workloads have peer responsibilities; explicitly enabled share supplies common OS/HM behavior. Modules check dependencies instead of silently enabling peers.

Module descriptors are discovered from OS/HM implementation entry points and reject nested modules. Optional root default.nix holds cross-implementation coordination. moduleRegistry separates static metadata and external integrations; nixosBuilder and llib.flakeParts.mkNixosConfigurations construct the output collection. The typed adapter resolves only declared functionTo/submodule values. Configuration/metadata fields must be disjoint. OS config.modules is the merged internal readOnly view; HM consumes osConfig.modules.

## Users and interfaces

Directory-named user profiles retain unique bound UID and host-subset constraints. Outer configuration chooses user identities and Feature allowUidList. The builder sends user HM implementation to the bound UID and Feature HM implementations/external homeModules to recipients; other kinds contribute through sharedModules. Per-user interfaces and OS internals remain declaration mechanisms distinct from implementation enablement. Parent disablement prevents implementation/external integration loading; a child switch does not independently activate its parent.

## Host facts and graphics

Static metadata facts are available independently of activation. Exactly one host must be enabled; a strict getter and a global tryEval-based assertion protect both eager field use and lazy non-use. Hosts own numeric UID registries, identity, boot/shared resources, WireGuard facts and monitor data. Enabled users need registry membership, while spare UID slots are valid. Monitor names are nonempty/unique, at most one is default, and enabled graphical consumers impose the stronger default-monitor requirement. Default monitors require a mode for coordinate derivation. SSH identity is under identity.keys; rootAccess is separate policy, not a synonym for knowing a host public key.

## Desktop and native capabilities

Niri remains the main native desktop and starts Noctalia v5 from HM settings. OS Noctalia configuration supplies recommended services without installing its own competing user launch path. Noctalia now owns normal/idle/pre-suspend locking; swaylock remains an allow-when-locked rescue path. One login_box is centered on the default monitor using mode/scale-derived logical dimensions, with weather false and unlock hint true. Custom clock/weather trials were withdrawn; earlier successful migration checks do not verify this final lockscreen stage. Other outputs remain locked; runtime settings may override declarative values.

Greetd's temporary Sway/gtkgreet and the independent IceWM/startx fallback retain separate session duties. Browser reuse across concurrent sessions remains a historical unresolved report. Native xdg.terminal-exec supplies terminal capability; Yazi/Wayfile handle directories and the independent FileChooser portal only affects clients using it. ThinkBook framebuffer initialization is a host-gated oneshot/udev path; kmscon ownership proposals remain unadopted.

## Secrets and agent inputs

OS age/agenix-rekey is shared infrastructure, separated from optional SOPS so its tooling builds/downloads need not block base secret deployment, using encrypted host material and separately configured master identities, including YubiKey support. The dedicated rage-armored wrapper satisfies text-only encrypted retention for rekey operations. Optional per-user SOPS remains an application/HM Feature; the shared age key bridge is exposed through age.secrets with group access and user-derived membership. Agent providers consume file paths independently of secret manager and enable only explicitly selected providers. The reconstruction did not decrypt material or verify private-key custody or deployed runtime access.

## Library and verification

Use lib/modules.nix for discovery/schema trees, lib/flakeParts.configurations.nix for adaptation, private declarations, HM delivery and constructors, lib/flakeParts.types.nix for registry/builder types, lib/hosts.nix for host/network derivation, lib/features.sops.nix for SOPS inputs and lib/packages.nix for package discovery. modules/_options.fp.nix and category/module FP declarations define outer configuration and metadata; OS/HM declarations use their environment-specific filenames. New builder UID aggregation replaces the retired prepend helper, so its old fixture is historical evidence rather than a current API invariant.

Tests and treefmt are registered in flake checks. The reconstruction statically inspected committed implementations, tests, history and documentation; it did not run those project checks. Original working-tree provenance, some early design conversations and runtime results remain incomplete. Final lockscreen/portal/renamed declaration/share-disabled behavior are not upgraded from old successful checks to fresh verification. Browser session reuse, geodata precedence and multi-VT console ownership are historical open investigations requiring present reproduction before treatment as current defects.

## Network ownership

Hosts own encrypted WireGuard material and stable numbers. lib/hosts.nix derives per-network endpoint/spoke configuration, interface maps and a shared topology view. Roles are per network, addresses are stable-number-derived and a host without WireGuard does not need a key path. Workloads consume explicit topology/interface/address/port relationships instead of coupling to the retired interconnect Feature. Configuration topology is not live peer health, and no current handshake/routing/HTTP result is established here.

## Definition ownership

Internal marks producer ownership rather than confidentiality. ReadOnly constrains raw definitions, while unique types constrain value merging; they are not interchangeable. Remove producer defaults that would conflict with the sole final definition, keep element-level uniqueness where needed and put fallback interpretation in consumers. User UID is an explicit final-composition input; host UID metadata is produced internally. Review the complete index: a check of a working tree cannot prove a different staged snapshot.

## Workload responsibilities

Workloads are the peer category for host-selected services. Caddy reverse-proxy and WBO whiteboard containers receive explicit addresses, ports, interfaces and permitted-source inputs. Their FP options use declared functionTo values for delayed access to resolved system networking; the adapter resolves those values before OS consumers use them. WBO's port resolves to null by default; 18000 is an example, so final composition must supply its intended value. Firewall policy stays explicit, and wiring does not establish deployed HTTP reachability. Earlier containers drafts and the retired interconnect namespace are historical designs rather than the current API.

## Virtualization and host resources

ThinkBook integrates a declarative libvirt Windows guest through NixVirt, with domain/network/storage XML templates, GPU SR-IOV, guest tooling and Samba sharing. Display experiments return to SPICE after GTK trials; virtualized Windows is a host-owned workload/resource rather than another NixOS host profile. Mount policy distinguishes Windows and shared filesystems, with the Windows partition mounted read-only at this horizon. Static configuration does not establish a successful guest boot, GPU assignment, filesystem safety under every external OS or runtime display result.

## Local packages and tools

pkgs/default.nix uses llib.packages for local legacyPackages, overlays and OS/HM module collection, with derivation/namespace collision checks. Package resources supply composable agent context and shared skills. Pi's offline startup wrapper preserves package layout; it does not prohibit model API networking. Codex's committed wrapper PATH includes bubblewrap plus Python/PyYAML support. Skill instructions do not replace execution authorization. Pi resource extensions and a historical proposed Git-action filter are different capabilities; the latter was not established as implemented by its source.

The committed flake makes emarccs treefmt-nix follow the root treefmt-nix and retains formatter/check wiring. This architectural description covers committed input declarations and lock state. The old Clash geodata/cache ambiguity remains an unconfirmed historical diagnostic, not a current verified failure or proven fix.

## Declaration registration

Private functions in `lib/flakeParts.configurations.nix` register OS internal declarations and each user's HM interfaces independently of `share.enable`. Share provides common behavior, while declaration availability does not activate an implementation. This keeps the aggregator outside discovered declarations, avoiding the earlier self-import failure.

The repository loader uses three environment-specific interfaces:

- `_options.fp.nix` along module path prefixes returns outer configuration/metadata schema branches.
- `os/_options.os.nix` is a native NixOS declaration module.
- `hm/_options.hm.nix` returns an HM interface fragment parameterized by module name and evaluation context.

`_metadata.fp.nix` stores static values under the committed metadata filename convention; `_metadata.nix` is retired without a compatibility fallback. Metadata files return ordinary attribute sets, not flake-parts modules. The committed `_validators.fp.nix` protocol is described below; production business constraints have not yet migrated to it. The suffix identifies interpretation environment, without imposing one namespace or function signature. This is a repository convention, with no old-name fallback, rather than native automatic loading. The declaration-file renames were byte-identical with paired loader/documentation changes; reconstruction did not establish a final evaluated check or share-disabled behavior test. Later worktree checks are recorded in [current.md](current.md); a dedicated share-disabled test remains unestablished.

## Derived module availability

Registry metadata in `lib/flakeParts.types.nix` now declares internal, read-only boolean `existModule.os` and `.hm` values derived from descriptor paths. The Registry metadata and NixOS `config.modules` access paths remain unchanged. Availability is independent of enablement. Discovery still requires at least one OS/HM implementation entry; a directory with neither does not become a false/false Registry module. Assembly, UID routing and Feature recipient policy are unchanged.

The diff removes manual availability fields, 20 otherwise empty metadata files, the old nullable type, consistency helper/exports and obsolete tests. The workloads category root, whose only duty was the removed assertions, is deleted; category assembly already tolerates that absence. Other host metadata and Host/User/Feature assertions remain. The common FP declaration retains its configuration/metadata return protocol. README now describes derived availability and the resulting layout.

The existing `tests/configuration-adapter/default.nix` check now evaluates the real Registry type for OS-only, HM-only and dual implementations, rejects conflicting and identical-value manual definitions, checks boolean availability and the builder bridge projection for every discovered module, and verifies default recipients and disabled-Feature delivery. The mock builder inspects the generated bridge without evaluating OS services; separate actual system evaluation supplies broader evidence. Remaining assertion-only fixtures explicitly simulate availability and do not prove Registry derivation.

See [current.md](current.md) for implementation status, the workspace used for checks and remaining verification boundaries. Historical recovery context is in [reconstruction.md](reconstruction.md).

## FP validator protocol

`lib/modules.nix` discovers `_validators.fp.nix` through descriptor prefixes, deduplicating and sorting root/category/module owners by depth and path. OS/HM implementation directories are excluded. Files are ordinary functions returning optional `metadata` and `configuration` predicates; static import scope is only lib, llib and owner path. Metadata receives the merged Registry. Configuration receives name, merged per-system configuration and evaluated Registry. Predicates return booleans, may assert/throw specific errors and do not transform input values. Unknown branches, invalid structures and non-boolean results fail.

`lib/flakeParts.validators.nix` supplies `llib.flakeParts.mkValidatorApplications`. The small top-level apply integrations in `flake.nix` reuse its Registry identity validator and per-system lazy mapper. It composes constraints with conjunction rather than overriding functions and supplies file/branch/system error context. Registry validation never reads systems; configuration validators must use their supplied unprocessed input, not recursively recover it from top-level FP config. Only relevant fields and predicate booleans are forced. Actual typed-default tests and unrelated-value traps are essential: neither deepSeq of whole inputs nor early invocation of functionTo values is permitted. Current production business assertions remain native and unmigrated; no placeholder validator files are installed. See [current.md](current.md) for test evidence and the working-lockfile validation boundary.
