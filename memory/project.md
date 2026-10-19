# Project knowledge after cloud extraction

## Purpose and evidence horizon

This is a retrospective, maintainable knowledge baseline for the committed main state at cloud extraction on 2026-05-20. The associated project parent identifies the inspected snapshot. This GAW checkpoint is created during the present reconstruction, not at the time of that project change, and does not describe today's deployed machines.

The owner explains during this reconstruction that the NixOS-WSL environment came first, followed by native NixOS on ThinkBook. Sharing user-level configuration between them was an important goal. This is an owner-supplied recollection, distinguished from contemporaneous execution evidence.

The repository already has substantial earlier history. The initial baseline summarized the supported state reached by the selected date rather than claiming that the project or its design began then. Between May 12 and May 18, the two later main commits only update the lock file; implementation content is unchanged.

## Working model and maintenance responsibilities

The flake explicitly builds two x86_64-linux systems: `nixos` imports the ThinkBook host and `nixos-wsl` imports NixOS-WSL and the WSL host. Each calls `inputs.nixpkgs.lib.nixosSystem` directly. A local `globalConfGenerate` supplies common overlays, unfree-package policy, basic tools, and Nix garbage-collection settings. System-specific module lists decide the actual composition.

Home Manager is integrated into each NixOS system. Both directly configure `home-manager.users.lingyu`, reuse the personal module under `modules/users/lingyu`, and import selected functional HM modules. External HM integrations are passed through `sharedModules`; ordinary imports receive `inputs` explicitly through `extraSpecialArgs`. Sharing therefore already crosses host boundaries, while hardware, WSL integration, and graphics remain host-dependent.

Functional code is partly separated into `os/` and `hm/` implementations. There is no repository-wide features/hosts/users selection protocol, UID registry, integration registry, flake-parts configuration layer, or root public `lib/` yet. The secret module has its own local helper; that is not the later general construction library. These are historical boundaries, not a claim that the earlier arrangement was already considered defective.

For maintenance at this point:

- Change machine-specific hardware and platform behavior in the corresponding host module. Do not make WSL inherit native laptop graphics or boot requirements merely to share a user environment.
- Keep final host composition visible in `flake.nix`. Adding an HM module file alone does not deliver it to either user: inspect each system's user imports and external `sharedModules` as appropriate.
- Personal editor, mail, Git, shell, terminal, and related settings still live under the user module. Cloud functionality now has its own HM module. Some reusable capabilities, including agent tooling, fonts, office tools, Niri, and secret integration, already have separate module paths. Do not infer a universal reuse contract from their directory names.
- When changing a shared capability, inspect both its OS requirements and HM configuration. The desktop receives Niri and desktop-oriented HM modules; the WSL composition intentionally differs. A successful change to one configuration does not establish compatibility with the other.

The implementation entry points are the selected snapshot's `flake.nix`, `modules/hosts/thinkbook/default.nix`, `modules/hosts/wsl/default.nix`, and `modules/users/lingyu/default.nix`. Use historical paths when examining this state; later profile schemas and library names do not apply here.

## Functional capabilities and open boundaries

The desktop composition includes Niri/Noctalia-related integrations, office and media functionality, fonts, and native host support. The WSL composition supplies the WSL platform with a shared personal environment rather than the desktop's complete OS module list. SOPS integrations are present on both OS and HM sides. These are inspected wiring facts, not a statement that each application, graphical session, secret operation, or host deployment was exercised.

Cloud functionality has moved unchanged from `modules/users/lingyu/cloud.nix` to `modules/cloud/hm/default.nix`. Both system compositions explicitly import the new path, and the personal module no longer does. This separates reusable capability ownership from one user without yet introducing a general Feature protocol. File extraction is not automatic registration: adding or changing recipients still requires explicit flake composition. This is a source-level responsibility change, not a demonstrated new cloud runtime capability. The later greetd session and UID routing are not present yet.

## Verification and next maintenance questions

The present reconstruction inspected the committed flake, module layout, and relevant main history. The cloud file move and both updated recipient imports were checked directly. There is no root `tests/` registration in this snapshot. No historical build success is inferred from a commit message, an existing module, or the absence of failures. No Nix evaluation, check, build, deployment, decryption, or application runtime test was executed in this reconstruction.

The current baseline supports continued investigation of where shared functionality should be owned, what is deliberately host-specific, and how a change is actually delivered to the two systems. Before making a stronger behavioral claim, obtain evidence for the affected historical snapshot; do not reuse a later session's successful check.

For the actual present-day establishment task, source decisions and the next action, see [reconstruction.md](reconstruction.md). Later recollections and research do not turn the May 18 implementation into a later architecture.
