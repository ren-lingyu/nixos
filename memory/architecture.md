# Project architecture and constraints

## Baseline and evidence

This repository maintains declarative NixOS and Home Manager configurations. `flake.nix` uses flake-parts to define `nixosBuilder`, `moduleRegistry`, and `nixosConfigurations`, then calls `llib.flakeParts.mkNixosConfigurations`. The four configurations are `nixos`, `nixos-matebook`, `nixos-server`, and `nixos-wsl`, all for `x86_64-linux`.

Implementation statements below describe the committed baseline in [current.md](current.md). Historical rationale comes from the retained summaries indexed in [consolidation.md](consolidation.md); it does not independently establish present behavior. Project paths are relative to the ordinary project root, not the Formal GAW worktree.

`tests/default.nix` registers checks for types, implementation-presence assertions, host functions, module composition, the configuration adapter, and SOPS functions. Their existence does not establish successful execution against this baseline. Current validation limits are recorded in current.md.

## Implementation entry points

| Responsibility | Entry points |
| --- | --- |
| Discovery and schema composition | `lib/modules.nix`: `discoverModules`, `mkOptionModules`, `mkOptionTree` |
| Builder, registry, and configuration types | `lib/flakeParts.types.nix` |
| Configuration adaptation and system construction | `lib/flakeParts.configurations.nix`: `adaptType`, `adaptOptions`, `mkNixosSystem`, and private OS/HM declaration generators |
| Host/monitor, UID, and feature constraints | `modules/hosts/default.nix`, `modules/users/default.nix`, `modules/features/default.nix` |
| Host selection and network topology | `lib/hosts.nix`: `getUniqueEnabledHost`, `mkWireGuardNetworks`; `modules/hosts/wireguard.nix` connects host networking |
| OS/HM secret bridge and per-user SOPS inputs | `modules/features/sops/default.nix`, `modules/features/sops/os/default.nix`, `modules/features/sops/hm/default.nix`, `lib/features.sops.nix` |
| Agent provider declarations and consumers | `modules/features/agent/hm/_options.hm.nix`, `modules/features/agent/hm/default.nix` |
| Directory opening and FileChooser | `modules/features/file-manager/hm/default.nix` |
| Lock screen, audio, brightness, and key bindings | `modules/features/niri/hm/noctalia/default.nix`, `modules/features/niri/hm/settings/binds.nix` |
| Local wrappers | `pkgs/codex/package.nix`, `pkgs/pi-coding-agent/package.nix`, `pkgs/rage-armored/package.nix` |

## Composition and ownership

Profiles are organized as hosts, users, features, and workloads; share provides common OS/HM configuration. Final configuration controls `enable`, UID binding, and external dependency injection. Modules check dependencies; they do not enable one another to orchestrate them.

Discovery recognizes `os/default.nix` or `hm/default.nix` as an implementation. A module-root `default.nix` is optional, and nested business modules are disallowed. The outer flake-parts configuration selects modules before generating NixOS/HM `imports`. This is not same-layer configuration-dependent recursive import selection.

The public `llib` namespaces are `types`, `modules`, `hosts`, `features.sops`, `packages`, and `flakeParts`. Generic directory discovery is separate from system construction. The configuration-set constructor maps to the single-system constructor. `groupImportsByUid` has been removed. Package namespace merging explicitly rejects treating a derivation as a namespace.

### Declaration protocol and configuration adaptation

- `_options.fp.nix` contributes configuration/metadata schemas along module path prefixes; `_metadata.nix` holds static values.
- `os/_options.os.nix` is a native NixOS declaration module.
- `hm/_options.hm.nix` retains the declaration-fragment function interface taking a module name and HM context.

The suffix identifies the interpreting environment; it does not require identical return structures. Private declaration generators in the construction library add OS declarations to system modules and HM declarations to `sharedModules`, independently of `share.enable`. This independence has been checked structurally, but the share-disabled case lacks current behavioral validation.

The adapter follows option declarations for `functionTo` and submodules rather than guessing whether arbitrary function values should be called. Adapted configuration and metadata form the read-only `config.modules` view; HM reads it through `osConfig.modules`. `moduleInternals` holds OS internal state, and `moduleInterfaces` carries per-user HM data. Registering declarations does not enable the corresponding functionality.

`internal` expresses a declaration/producer boundary, not access control. The merge semantics of `unique` differ from `readOnly`'s definition-count restriction. They are not interchangeable, and a default can become a second definition. UID remains an input assigned by final composition even when other derived internal options use `readOnly`. A `cfg` alias abbreviates reads of a module's own options; it does not change definition paths, cross-module reads, or diagnostic paths.

### Rationale and superseded designs

Moving all policy into hosts or delegating all composition to individual modules was rejected because it changed ownership among peer modules. An early share declaration aggregator imported itself, causing recursion. Aggregation was first moved out of the discovered declaration file and later made private in the construction library. A default `null` and an implementation value conflicted for read-only session-wrapper options. Those intermediate options were removed; providers now contribute directly to `moduleInternals.features.greeter.sessionPackages`. These failure explanations come from historical summaries, not a new reproduction against the current baseline.

The old `self.modules` registry, early base-module identity deduplication, and former declaration filenames are evolution context, not current APIs to restore. The earlier registry accepted output-schema warnings; the current design uses flake-parts options. The old nixos-anywhere app wrapper is also historical; the deployment devShell now provides the tool. Tool warnings do not automatically justify migrating the Nix implementation, and old assessments do not establish current upstream compatibility.

## Hosts, users, identities, and networking

### Host selection and UID ownership

Exactly one host must be enabled. `getUniqueEnabledHost` throws a clear error otherwise. A global assertion uses `tryEval` to preserve the invariant even when no consumer calls the getter. The earlier empty-set fallback allowed field access to fail before the assertion; do not reintroduce it.

Host metadata is static and does not disappear when a consumer is disabled. The UID registry may reserve UIDs that are not enabled. Every enabled user's bound UID must belong to the selected host's registry; the two sets need not be equal. Feature `allowUidList` refers to enabled users, and each user profile's HM implementation goes to its bound UID. The current negative composition test uses unregistered UID `1001`. Clearing the registry with `mkForce` belonged to a different fixture stage; an empty set passed to `recursiveUpdate` does not clear existing entries.

### Secret-management responsibilities

OS-side agenix/rekey supplies the base secret infrastructure; SOPS remains optional and composable. This separates responsibilities rather than replacing SOPS wholesale. One historical motivation was to avoid application-secret tooling build/download problems blocking base identity deployment. Host SSH identity, derived recipients, and master identities have separate roles. Type declarations do not establish encryption or private-key security.

The current HM SOPS key bridge uses an OS age secret owned by root, accessible to approved users through the `sops-decrypt` group with mode `0440`. HM reads its path through `moduleInternals`. Nonempty `secretsInput` requires a defined format and file. NSS updates do not give existing processes new group credentials; a historical report that restarting resolved access is not current runtime validation.

The armored ciphertext wrapper is specific to rekey tooling; it does not replace global rage. The package embeds the Scheme wrapper with `builtins.readFile`, preserves the original phase, and substitutes the actual executable path. An earlier mistake inserted a file path where script source was required. That implementation was corrected, but the current wrapper build and runtime behavior remain unverified.

### WireGuard topology

Stable WireGuard membership belongs to hosts. The topology builder derives networks and topology from host numbers and endpoint metadata; the host module connects secret paths and firewall rules. The former `interconnect`, `claims`, `claimantCount`, and `mkNode` prototypes are retired. Membership does not prove exclusive runtime activity, and a schema admitting multiple claimants does not prove that all derived configuration supports them. No handshake or actual routing result is established in current memory.

## Desktop and application capabilities

### Monitors and session fallback

At the host level, real monitor names are unique and at most one monitor is the default. Headless hosts may have no monitors. Enabled GUI consumers separately require a unique default, and a default monitor needs a valid mode. Geometry and scale are inputs to Noctalia centering, not a general guarantee of runtime display state.

X11 is a general compatibility fallback, currently split into IceWM OS/HM implementations rather than owned by a single application. Old Wayland session variables are cleared. The fallback is not tightly coupled to a shared graphical target or an additional monitor protocol. Historical user reports of successful login and applications do not resolve every cross-VT, existing-instance, or clipboard case.

### Terminal, directory opener, and FileChooser

Native `xdg.terminal-exec` exposes terminal capability. Consumers check the actual HM capability rather than requiring one particular terminal feature as its only valid provider.

With Niri enabled, the directory opener uses Wayfile; otherwise it defaults to Yazi. The FileChooser Portal is a separate path: termfilechooser invokes a terminal and Yazi. Do not conflate the directory opener and Portal based on an earlier goal of making Yazi the default. OS configuration retains the application and Portal link paths. Only applications using that Portal follow this path; no universal GUI success is established.

### Noctalia and Niri

Regular Noctalia locking and swaylock recovery have separate roles. The default monitor's `login_box` uses mode/scale to derive the logical center. A withdrawn custom clock should not be restored as current design.

At the committed baseline, lock-screen settings are `show_weather=false` and `show_unlock_hint=true`; the earlier weather experiment was reverted. Noctalia uses `audio.enable_sounds=false` and `brightness.minimum_brightness=0.05`. Niri permits the audio and brightness bindings while locked. These are source settings, not evidence that runtime settings overrides or multiple-monitor behavior have been verified.

### Framebuffer and kmscon

ThinkBook's fbset service is `oneshot`. Ordering, activation dependencies, mutual exclusion with kmscon, and mode restoration are separate problems. Stopping a completed oneshot does not undo framebuffer geometry. No complete mode-restoration design was adopted in the historical discussion; suggested `Conflicts` or lifecycle hooks are not implemented fixes.

## Agent tooling, packages, and operational boundaries

### Codex, Emacs, and input wiring

The local Codex wrapper adds Python/PyYAML and bubblewrap to `PATH` in `pkgs/codex/package.nix`. Installing those tools does not prove the sandbox works in every environment; that needs runtime evidence. emarccs's `treefmt-nix` follows the root `treefmt-nix`. Desktop configuration uses `emacs-pgtk`; README's old `emacs31-pgtk` example is not implementation evidence.

### Provider interface

The agent provider interface consumes key-file paths without requiring SOPS to produce them. Consumers distinguish undefined `enable` from enabled state and do not add default definitions to read-only options. Model selection belongs to the consumer; the earlier nullable model interface was withdrawn. Configuration data does not establish credential security or permission enforcement.

### Pi wrapper

The Pi wrapper uses `overrideAttrs` to retain original outputs, metadata, and phases while setting the startup offline variable. Tool dependencies are managed through `extraPackages`. A corrected rebuild after an earlier missing-space wrapper-path error is a historical user report. Current source has output-path-prefix checks and command separation. `PI_OFFLINE=1` does not mean model API network requests are forbidden; current build evidence is governed by current.md.

### Skills and maintenance boundaries

Generic skills describe working methods; host permissions enforce execution boundaries. Earlier duplicate agent/command wrappers gave way to shared skills. Command availability, aliases, and proposed capability restrictions are not evidence of deployed security isolation. Historical Nix style decisions retain their original scope; do not turn them into repository-wide rules unsupported by current code.

The historical WSL vscode-server integration change removed it rather than merely extracting a module. Classify commits by semantic effect; do not rewrite ordinary project history to repair inconsistent old titles. A historical review does not establish a new source's project parent, and a draft is not an actual commit.

### Clash geodata

A package geodata override and the data actually loaded by an application are different. Successful evaluation of an initial version did not establish a build; a later successful rebuild did not prove the gfw problem was fixed. Cache-first loading was a historical hypothesis, while EOF downloading `geoip.metadb` was a separate observation. The current source retains the override, but reproduction of those failures is unknown. Do not describe them as confirmed current bugs or resolved current bugs.
