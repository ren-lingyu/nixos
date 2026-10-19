# Flake-parts composition and a public module registry

## Composition and ownership

The root outputs now use `inputs.flake-parts.lib.mkFlake` with a systems list. NixOS configurations remain top-level flake outputs; each still calls `nixosSystem`. `perSystem` owns system-specific apps, not a transposed set of NixOS configurations. This changes flake construction while preserving final assembly responsibility at the root.

The public hierarchical module registry is now the custom `self.modules`, containing base/features/hosts/users. The independent source explains why a flat standard `nixosModules` naming scheme and a registry hidden in let were rejected. A reported nested-output schema failure motivated that discussion; the final rename is not backed by a retained successful source check. The custom-output warning was accepted at that time rather than changing Nix implementations solely for it. This is historical reasoning, not a current recommendation about alternative Nix implementations.

The convenience nixos-anywhere app uses the per-system `inputs'` projection and explicit executable lookup and now has a description. Editor has a separate public wrapper and configurable Emacs package selection, with the external distribution exposed through an overlay. Nixvim's independent dependency pin is preserved rather than forcing all dependencies to share a version.

Three configurations still compose desktop ThinkBook, WSL and Aliyun, common base policy, reusable features and UID-keyed users. Shared shell/editor/remote and XDG responsibilities remain separated from private profiles. The minimal server user has no private profile import but retains common HM participation. Provider imports still live partly in public wrappers: this is not the much later flake-parts configuration-builder architecture.

`modules/hosts` now provides an `attrsOf submodule` host namespace. Each profile has its own `enable`, `monitors` and package-group settings. Importing the host entry declares that host enabled; ordinary hardware and OS effects are guarded by its own enable state while imports remain at module top level. The global assertion currently permits zero or one enabled host. It is not yet the later exactly-one invariant.

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

## Evidence and maintenance boundaries

This is a reconstructed historical knowledge state grounded in the associated project tree inspected during the present task. Its GAW commit is created now, not at the original event time. Main ancestry orders Formal stages; dates alone do not establish adoption. Discussion summaries establish attributed intent with limited completeness. Historical test reports are not new checks. This task has run no Nix evaluation, build, deployment, decryption or runtime test.

Read [reconstruction.md](reconstruction.md) for the current establishment work and [sources.md](sources.md) for source coverage and retained history. Do not interpret this in-progress historical horizon as the architecture deployed today.
