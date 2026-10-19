# Host namespaces and graphics contracts

## Composition and ownership

ThinkBook, WSL and Aliyun remain explicit flake compositions over common base policy, reusable features and UID-keyed users. Shared shell/editor/remote capabilities and generic XDG policy have separated from private profiles. Proxy has become a feature with selectable backends. Niri remains the primary native desktop; WSL and the server do not inherit laptop graphics merely because they share user capabilities.

`modules/hosts` now provides an `attrsOf submodule` host namespace. Each profile has its own `enable`, `monitors` and package-group settings. Importing the host entry declares that host enabled; ordinary hardware and OS effects are guarded by its own enable state while imports remain at module top level. The global assertion currently permits zero or one enabled host. It is not yet the later exactly-one invariant.

## Monitor and session interfaces

Hosts own monitor facts. A logical monitor attribute key may differ from its actual output name; actual names must be nonempty and unique to avoid overwriting generated output entries. A host has at most one default-role monitor. Dimensions are positive integers and non-null refresh/scale values are positive floats. Niri's internal monitor configuration is derived from the selected host rather than repeated as feature-local constants.

Graphical consumers add contextual requirements: enabled Niri and greeter require exactly one enabled host and exactly one default monitor. Thus headless compositions may have no default display without weakening graphical validation. Derivations check list cardinality before selecting its first member, so malformed metadata can reach meaningful assertions rather than failing on an empty list.

Greeter has become an independent Feature. It owns login service implementation and consumes session packages provided by desktop features; Niri owns its session wrapper and user compositor. The greetd service's temporary Sway/gtkgreet session is not the user's Niri session. Provider registration and later X11 session support continue after this horizon.

## Maintenance and evidence

Inspect `modules/hosts/default.nix`, the selected host `default.nix`, and `modules/features/{niri,greeter}/default.nix`. Keep monitor data in hosts and graphical prerequisites in consumers. Do not weaken name/cardinality checks simply because a default display works on ThinkBook. Do not put imports under an enable-dependent `config` branch.

The independent monitor source preserves the motivation, earlier schema and namespace transition. Its reported rebuild/evaluation successes apply to historical working trees with incomplete exact provenance, not to every tree associated here. The source is used for rationale while the directly inspected main snapshot determines the committed interface. The earlier Niri service/portal investigation is not retrospectively declared resolved by this extraction.

## Evidence and maintenance boundaries

This is a reconstructed historical knowledge state grounded in the associated project tree inspected during the present task. Its GAW commit is created now, not at the original event time. Main ancestry orders Formal stages; dates alone do not establish adoption. Discussion summaries establish attributed intent with limited completeness. Historical test reports are not new checks. This task has run no Nix evaluation, build, deployment, decryption or runtime test.

Read [reconstruction.md](reconstruction.md) for the current establishment work and [sources.md](sources.md) for source coverage and retained history. Do not interpret this in-progress historical horizon as the architecture deployed today.
