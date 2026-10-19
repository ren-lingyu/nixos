# Static host facts separated from activation

## Purpose and composition

Maintain native ThinkBook, WSL and Aliyun configurations while sharing selected user capabilities without erasing platform differences. The owner explains that a whole HM profile was too coarse a sharing unit. The root flake owns external inputs, provider adaptation and final selection; hosts own hardware/resources, users own identity/private settings and Features own reusable implementation. Modules check dependencies rather than enabling peers. The flake-parts root exposes top-level NixOS configurations and per-system tools, with a custom hierarchical self.modules registry.

## Users and interfaces

User profiles are directory-named; final composition binds their UID from a host's numeric registry. Enabled identities must be unique, bound and registered; the host may reserve unused UIDs. A minimal profile can receive common HM Features without personal configuration. Feature allowUidList defaults to enabled assigned users when HM-capable, with duplicate/unknown references rejected. Per-user moduleInterfaces schemas are registered separately from selected implementation delivery. Nullable existModule booleans distinguish undeclared roots from explicit implementation facts, checked against files. OS imports are static; HM delivery is recipient-dependent.

## Host facts and graphics

Host metadata is now loaded independently of enablement. UID slots and monitor facts remain available for all hosts without activating their OS configuration. Data integrity applies even to disabled hosts. Monitor output names are nonempty/unique and at most one has the default role; dimensions and non-null scale/refresh are positive. The global host rule is still at most one, while graphical consumers require exactly one selected host/default monitor. The available default monitor is selected safely after cardinality checks. This separates hardware facts from consumer requirements.

## Desktop and native capabilities

Niri is the main native desktop; greetd uses temporary Sway/gtkgreet before launching its session. An independent IceWM/startx fallback provides native X11 compatibility through an OS entry and HM launcher, without cross-VT clipboard/layout promises. The unresolved browser reuse report is historical. Terminal consumers use native HM xdg.terminal-exec; the file manager provides Yazi and desktop Wayfile, and FileChooser integration requires a real terminal provider and OS application/portal resources. Only portal-using applications follow that route. ThinkBook framebuffer initialization is a guarded oneshot plus late-device udev rule, distinct from kmscon's own KMS/font lifecycle. Proposed conflict/pre/post policies were not adopted fixes.

## Secrets and agent inputs

The optional secret Feature consumes user-owned encrypted inventory through per-user HM interfaces. Its system-to-HM age key is a bootstrap bridge with root ownership and group-based restricted access. Stale process credentials explained one historical permission failure despite correct NSS membership; no current deployment is tested. Agent tools and their secret inputs are still being separated in subsequent states.

## Library and verification

The public llib is instantiated with the receiving nixpkgs lib and passed through OS/HM arguments, with explicit arguments for ordinary imported functions. Stable base key/_file identity resolves a documented library-era duplicate import problem, without proving the same fix for every older complaint. Types, availability assertions, SOPS helpers and UID grouping have registered tests and real module-composition negative cases. The old grouping helper prepends later contributions; its beta-before-alpha fixture was clarified during this reconstruction. Historical check reports are scoped to their exact old stages; the final portal and several later refinements lack fresh validation.

## Reconstruction and evidence

This checkpoint reconstructs the directly inspected committed project horizon. It is created now without backdating, and its project parent is evidence of present static reinspection rather than original-session working-tree provenance. Main ancestry orders Formal evolution; independent Auxiliary histories explain selected discovery lines. See [sources.md](sources.md) for actual adoption/retention and [reconstruction.md](reconstruction.md) for progress and limits. No Nix evaluation, build, deployment, decryption or runtime test was performed in this task. Do not read an unfinished historical horizon as today's deployed architecture.
