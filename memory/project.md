# Shared capabilities become independent responsibilities

## Goal and composition

The project now composes desktop ThinkBook, WSL and an Aliyun server rather than only the original two environments. The flake remains the final assembly point, selecting public wrappers, external integrations and enabled features. Shared root configuration owns common Nix policy, basic tools and HM defaults. User-level sharing remains important, while native hardware, WSL platform behavior and server disk/bootstrap responsibilities remain host-specific.

The early Feature/User protocol is being used for actual maintenance. Cloud became `remote`; shell and editor implementations moved out of the personal profile into reusable features. The shell HM side was explicitly gated after extraction: moving a file alone does not make activation correct. Editor options select enabled editor implementations and defaults. Personal home settings moved to `modules/users/lingyu/home.nix`; generic XDG paths and directory-creation policy moved to the shared root rather than staying private to one user.

## Interfaces and delivery

Users are still keyed by numeric UID with separate enable, home and HM controls. A nullable HM profile source allows a minimal server user to exist without private profile imports while still participating in common HM configuration and selected features. This is not the later directory-keyed user-profile model. Shared Features and their HM recipient lists remain separate from personal profile contents.

Proxy implementation has been extracted from ThinkBook into `modules/features/proxy`, with explicit feature/backend options and implication assertions. The enabled host chooses policy; the feature owns service implementation. This state has the initial Clash/V2RayA choices, not every later backend. The Aliyun host uses disko/nixos-anywhere-related bootstrap wiring; its existence is static composition evidence, not proof of a fresh remote deployment.

## Maintenance implications and unresolved evidence

Look first at `modules/default.nix`, `modules/features/default.nix`, `modules/users/default.nix`, the feature's OS/HM files and the final flake choices. Route common capabilities through feature interfaces rather than copying personal settings to each host. Keep personal identity and data in user configuration, hardware/platform constraints in hosts, and reusable implementation in Features. This ownership direction is supported by the owner reference and actual migrations, rather than inferred merely from directory names.

The greeter remains the greetd/Sway/gtkgreet path to Niri. Host-owned generic monitor schemas, independently selectable greeter and native X11 fallback belong to subsequent states. The earlier duplicate base and Niri service/portal reports still lack a precise established resolution at this horizon. Some authored June migrations have later committer dates; no assertion is made that author date equals publication on main.

## Evidence and maintenance boundaries

This is a reconstructed historical knowledge state grounded in the associated project tree inspected during the present task. Its GAW commit is created now, not at the original event time. Main ancestry orders Formal stages; dates alone do not establish adoption. Discussion summaries establish attributed intent with limited completeness. Historical test reports are not new checks. This task has run no Nix evaluation, build, deployment, decryption or runtime test.

Read [reconstruction.md](reconstruction.md) for the current establishment work and [sources.md](sources.md) for source coverage and retained history. Do not interpret this in-progress historical horizon as the architecture deployed today.
