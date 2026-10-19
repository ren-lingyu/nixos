# Host-owned WireGuard networking

## Purpose and composition

Maintain native ThinkBook, WSL and Aliyun configurations while sharing selected user capabilities without erasing platform differences. The owner explains that a whole HM profile was too coarse a sharing unit. The root flake owns external inputs, provider adaptation and final selection; hosts own hardware/resources, users own identity/private settings and Features own reusable implementation. Modules check dependencies rather than enabling peers. The flake-parts root exposes top-level NixOS configurations and per-system tools, with a custom hierarchical self.modules registry.

## Users and interfaces

User profiles are directory-named; final composition binds their UID from a host's numeric registry. Enabled identities must be unique, bound and registered; the host may reserve unused UIDs. A minimal profile can receive common HM Features without personal configuration. Feature allowUidList defaults to enabled assigned users when HM-capable, with duplicate/unknown references rejected. Per-user moduleInterfaces schemas are registered separately from selected implementation delivery. Nullable existModule booleans distinguish undeclared roots from explicit implementation facts, checked against files. OS imports are static; HM delivery is recipient-dependent.

## Host facts and graphics

Host metadata is now loaded independently of enablement. UID slots and monitor facts remain available for all hosts without activating their OS configuration. Data integrity applies even to disabled hosts. Monitor output names are nonempty/unique and at most one has the default role; dimensions and non-null scale/refresh are positive. The global host rule now requires exactly one enabled host; graphical consumers additionally require a default monitor. The available default monitor is selected safely after cardinality checks. This separates hardware facts from consumer requirements. SSH host identity separates material from runtime paths, with age recipients derived from SSH public identity rather than a second independent identity. At this phase the shared getter still returns an empty set for non-unique selection, relying on global assertions; its later lazy-evaluation failure is not yet repaired.

## Desktop and native capabilities

Niri is the main native desktop; greetd uses temporary Sway/gtkgreet before launching its session. An independent IceWM/startx fallback provides native X11 compatibility through an OS entry and HM launcher, without cross-VT clipboard/layout promises. The unresolved browser reuse report is historical. Terminal consumers use native HM xdg.terminal-exec; the file manager provides Yazi and desktop Wayfile, and FileChooser integration requires a real terminal provider and OS application/portal resources. Only portal-using applications follow that route. ThinkBook framebuffer initialization is a guarded oneshot plus late-device udev rule, distinct from kmscon's own KMS/font lifecycle. Proposed conflict/pre/post policies were not adopted fixes.

## Secrets and agent inputs

The secret feature is renamed sops across namespaces and helper/test references. Per-user SOPS inventory remains optional and supplies the bootstrap key bridge with restricted group access. Agent-first provider interfaces expose enablement and an API-key file path, without assuming its secret manager. The personal user guards SOPS-derived inputs; Agent drops a global SOPS dependency. A nullable model-interface proposal was withdrawn; enabled providers determine default model fields and an explicit enabled-provider list. No final runtime/model request is tested. OS age/agenix-rekey infrastructure is now independent of optional HM/application SOPS, motivated by keeping base secret deployment usable when SOPS tooling builds/downloads block. Host runtime SSH identity and its public key feed rekey setup; master identities are separate inputs. The initial age-recipient hostPubkey wiring has been corrected to SSH public key. Public/ciphertext review does not establish private-key custody or runtime decryptability. The owner requires text-only encrypted files in Git. Dedicated rage-armored is scoped to rekey tooling and adds armor to ordinary encryption without changing decrypt/already-armored calls. It preserves the underlying package, embeds Scheme body with builtins.readFile, adds the Guile shebang and substitutes an exact executable token. Binary age output was an encoding concern, not evidence of encryption failure. The final wrapper has static evidence, without a new build or runtime proof.

## Library and verification

The public llib is instantiated with the receiving nixpkgs lib and passed through OS/HM arguments, with explicit arguments for ordinary imported functions. Stable base key/_file identity resolves a documented library-era duplicate import problem, without proving the same fix for every older complaint. Types, availability assertions, SOPS helpers and UID grouping have registered tests and real module-composition negative cases. The old grouping helper prepends later contributions; its beta-before-alpha fixture was clarified during this reconstruction. Historical check reports are scoped to their exact old stages; the final portal and several later refinements lack fresh validation.

## Network ownership

Interconnect has been removed. Stable WireGuard membership and encrypted key references belong to hosts; the public host helper purely derives the selected host's networking from the registry. Endpoint hosts define numbered networks, and other participants become spokes. Role checks are per network, so being a hub elsewhere does not suppress needed spoke keepalive/endpoint settings. Addresses and interface names derive from stable host numbers, not directory order. No-WireGuard selection returns an empty result without reading a private-key path. Builder implementation and host wiring were independent useful source states; their source reviews do not prove a deployed handshake.

## Definition ownership

Internal options designate producer ownership, not access security. Direct internal unique values become readOnly base-typed values where exactly one raw definition is intended; overwritten defaults are removed. Nested element uniqueness is retained where meaningful. User UID remains a public final-composition input; produced host UID metadata remains internal. Provider defaults/fallbacks are consumer views rather than extra readOnly definitions. Nix expression formatting choices do not establish build equivalence.

## Reconstruction and evidence

This checkpoint reconstructs the directly inspected committed project horizon. It is created now without backdating, and its project parent is evidence of present static reinspection rather than original-session working-tree provenance. Main ancestry orders Formal evolution; independent Auxiliary histories explain selected discovery lines. See [sources.md](sources.md) for actual adoption/retention and [reconstruction.md](reconstruction.md) for progress and limits. No Nix evaluation, build, deployment, decryption or runtime test was performed in this task. Do not read an unfinished historical horizon as today's deployed architecture.
