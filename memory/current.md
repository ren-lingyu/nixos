# Current project memory

## Purpose and entry points

Maintain composable, declarative NixOS and Home Manager configurations with separate responsibilities for final system composition, feature implementations, static metadata, and internal interfaces. Historical consolidation and cleanup are complete. No new implementation task has been taken on.

Start here to resume maintenance. See [architecture.md](architecture.md) for interfaces, invariants, and design rationale, and [consolidation.md](consolidation.md) for historical sources and recovery instructions.

The committed baseline for the existing static review is `48c7f0fc403d525ce982d11e613008042cf1e456`. Project HEAD still matches that baseline at this normalization. An unstaged `flake.lock` change is outside this memory's implementation baseline and remains untouched. Future implementation claims must check the relevant baseline.

Formal GAW uses `_agents`. No Auxiliary branches remain active; Formal ancestry retains historical sources. This normalization changes only the three current memory documents, without repeating consolidation, retirement, or repository-wide validation.

## Confirmed implementation scope

`flake.nix` composes four `x86_64-linux` configurations. Their presence does not establish that the corresponding machines have been deployed from this revision.

| System output | Host profile | User profile | Main configuration scope |
| --- | --- | --- | --- |
| `nixos` | `thinkbook` | `lingyu` | Niri/Noctalia, IceWM fallback, desktop applications, Flatpak, VM, WBO |
| `nixos-matebook` | `matebook` | `lingyu` | Niri/Noctalia, editors, and desktop tools |
| `nixos-server` | `aliyun` | `lingyu-minimal` | Shell, SOPS, and the Caddy workload |
| `nixos-wsl` | `wsl` | `lingyu` | NixOS-WSL, editors, and terminal tools |

Project entry points are `flake.nix`, `lib/`, `modules/`, and `pkgs/`, relative to the ordinary project root. The flake also exposes `legacyPackages`, overlays, NixOS/Home Manager modules, `deploy` and `secret` devShells, a treefmt formatter, and checks. Detailed source references are in architecture.md.

## Active constraints

- Final configuration selects profiles, binds UIDs, and injects external dependencies. Modules check dependencies rather than enabling other profiles.
- OS/HM implementation discovery and declaration registration are distinct from activation. Keep configuration, static metadata, `moduleInternals`, and per-user `moduleInterfaces` separate.
- Distinguish committed implementation, historical rationale, reported success, and current execution evidence. Internal option declarations are not access controls.
- Follow host authorization rules for project writes, Nix commands, deployment, and external changes. Previous results and drafts do not authorize or prove new results.

## Validation status

The existing review checked committed composition, README, libraries, and key consumers, including FileChooser, agent providers, Codex/Pi/rage-armored packages, and Noctalia settings. These are static findings. No Nix evaluation, check, build, deployment, or application runtime validation was performed for that review or this normalization. Historical success reports cover their original workspaces, not this baseline.

`tests/default.nix` registers six checks: `lib-types`, `exist-module-assertions`, `host-functions`, `module-composition`, `configuration-adapter`, and `sops-functions`. They cover types and implementation-presence assertions, unique host/monitor constraints, negative UID/feature combinations, configuration adaptation, and SOPS inputs. Treefmt supplies a separate formatting check. README lists `nix flake check` as the validation entry point; execution requires applicable host authorization.

## Open issues and next actions

- Current runtime evidence is missing for FileChooser and applications across sessions, actual Clash geodata loading, Noctalia settings overrides and multiple monitors, fbset/kmscon mode restoration, and rage-armored behavior. These are historical validation limits, not a claim that every reported problem is a reproducible current bug. Investigate the relevant case when maintenance requires it.
- README's `functionTo` example uses `emacs31-pgtk`, while desktop configurations in `flake.nix` use `emacs-pgtk`. Synchronize the example during the next relevant editor or documentation change; README was not modified here.
- No current conclusion has been established about related Issues/PRs or deployment status. Check them when a concrete implementation request arrives. Completed consolidation and cleanup belong in consolidation.md and Formal first-parent history, not an active work queue.
