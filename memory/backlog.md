# Backlog

Pending work and adopted target constraints. Current progress and verification belong in [current.md](current.md). Completed work should leave this list once any durable conclusions have been incorporated into current knowledge; Git history preserves its evolution.

## Module system architecture refactor

The owner split implementation into two phases. Phase one moves Feature implementations and their reusable resources to `pkgs/modules/<name>/{os,hm}`, with native options and exports plus explicit root Registry bridges. This preserves the current FP schema, allocation and validation behavior. Phase two revisits system construction, Hosts, User profiles and Accounts, static FP data, deferred native contributions and project-wide validity. The separation allows the native Feature boundary to stabilize while those construction decisions remain open.

This is the next primary research effort. The uniform construction protocol obscures differences between categories and leaves some structural invariants to validation after construction. The FP/NixOS split also carries historical responsibilities forward. Some global static data and relationships are derived inside individual NixOS configurations, adding adaptation and deferred evaluation. The design principles are in [architecture.md](architecture.md#construction-semantics-and-layer-boundaries).

### Research sequence

1. **Audit the current architecture.** Examine each category's responsibilities, presence, cardinality and dependencies. Review the Registry, FP options, validators, assertions and configuration adapter. Identify validation arising from the common construction protocol, places where global models and local implementation are mixed, and which `functionTo` values genuinely require deferred evaluation.
2. **Design the domain objects and their construction semantics.** Start from domain requirements with the existing Registry schema open to revision. Study how system construction could guarantee one selected Host first. Examine Share, Features, Users and Workloads individually and determine their actual relationships.
3. **Define FP and NixOS responsibilities.** Study the global infrastructure model and per-system plans using WireGuard topology, SSH targets, Caddy/WBO deployment wiring and firewall policy. Determine where each input should be established and which values and implementation details require NixOS evaluation.
4. **Review shared mechanisms.** Use the domain semantics to decide which discovery, Registry, option construction, validator and configuration adapter mechanisms to retain, simplify, replace or remove. Treat uniform `enable`, the metadata/configuration merge and `config.modules` as existing choices open to review.
5. **Plan migration once the target architecture is agreed.** Prefer phases that can be verified and committed independently. State the functional and security behavior each phase must preserve. Include implementation and acceptance of the WireGuard firewall behavior under the new architecture.

These steps establish research order. Implementation milestones and development authorization are separate decisions.

### Deferred WireGuard firewall requirements

The owner adopted these constraints for design and acceptance. The current Aliyun policy and decision to defer a local change are recorded in [current.md](current.md#wireguard-ssh-targets-and-aliyun-reachability).

- Aliyun defaults to denying locally initiated connections over managed WireGuard networks. Policy belongs to the Host and is independent of the Hub topology role and whether Caddy is enabled. Allow the return traffic required by permitted inbound connections.
- Workloads may declare required access and their own security constraints. Apply Caddy's restrictions across every managed WireGuard interface. Caddy may initiate access only to the designated upstream through the designated interface. Adding a managed interface grants Caddy no additional initiation privileges.
- Decide Workload principal identification and isolation mechanisms case by case. The scope is managed WireGuard access control. General Internet/LAN egress control and a complete Workload network sandbox are outside this scope.
- Keep WireGuard forwarding isolation distinct from locally generated OUTPUT policy. Preserve Workload portability.

The explored local patch used `networking.wireguard.firewall.restrictOutput`, `networking.wireguard.firewall.extraOutputAllowRules`, `modules/hosts/wireguard-firewall.nix`, independent Host and Workload OUTPUT tables, `lib.types.lines` to aggregate nftables allowances, and specific conntrack state/direction matches. These remain exploratory implementation details. The future design must express the security requirements above and can choose its own mechanism.

### Open design decisions

- Host selection and Host-specific configuration API, and Share presence and enablement semantics.
- Feature and User composition, Workload instances and deployment relationships, and the need for any new top-level category.
- The long-term Registry structure, data interface between FP and NixOS, and the scope of `config.modules` and `functionTo`.
- The scope of validators and common assembly mechanisms, and how firewall authorizations compose.

## Independent follow-ups

- Verification follow-up: native intermediary registration and nine-file source re-encryption are committed. All four SSH backups now have X25519 and piv-p256 stanzas, but successful YubiKey-only decryption of these backups and Nix evaluation/build have not been established. Validate evaluated declarations and each SSH backup manually or with explicit authorization. Host rekey skips intermediaries and cannot validate these backups. Do not deploy real identities or rotate actual keys.
- Deferred: decide the independent responsibility and FP interface for master identity policy and secret-management lifecycle. Consider explicit builder fields versus a separate secretManagement = { manager; identities; } entry; a broader builder/environment rename is also undecided. Avoid hidden policy in specialArgs, assigning global meaning to the Registry share entry, duplicate secret-path catalogs, or coupling backup management to the existence of a deployed Host. Review a Registry-derived virtual management node if full coverage without system configurations is required. Locked-source compatibility findings are in current memory; no architecture refactor is authorized.
- Deferred: assess recovery/deployment workflows and retention of ignored legacy SOPS backups when explicitly requested. Login password hashes and actual SSH/WireGuard key rotation remain outside the present task.
