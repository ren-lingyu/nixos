# Backlog

Pending work and adopted target constraints. Current progress and verification belong in [current.md](current.md). Completed work should leave this list once any durable conclusions have been incorporated into current knowledge; Git history preserves its evolution.

## Deferred WireGuard firewall

The owner adopted these constraints for design and acceptance. The current Aliyun policy and decision to defer a local change are recorded in [current.md](current.md#wireguard-ssh-targets-and-aliyun-reachability).

- Aliyun defaults to denying locally initiated connections over managed WireGuard networks. Policy belongs to the Host and is independent of the Hub topology role and whether Caddy is enabled. Allow the return traffic required by permitted inbound connections.
- Workloads may declare required access and their own security constraints. Apply Caddy's restrictions across every managed WireGuard interface. Caddy may initiate access only to the designated upstream through the designated interface. Adding a managed interface grants Caddy no additional initiation privileges.
- Decide Workload principal identification and isolation mechanisms case by case. The scope is managed WireGuard access control. General Internet/LAN egress control and a complete Workload network sandbox are outside this scope.
- Keep WireGuard forwarding isolation distinct from locally generated OUTPUT policy. Preserve Workload portability.

Earlier local rule interfaces, separate nftables tables and conntrack drafts were exploratory. The completed composition refactor retained the existing Caddy OUTPUT policy. Evaluate a separate design when authorized. No post-refactor private SSH or ICMP test is established.

## Independent follow-ups

- Verification follow-up: native intermediary registration and nine-file source re-encryption are committed. All four SSH backups now have X25519 and piv-p256 stanzas, but successful YubiKey-only decryption of these backups and Nix evaluation/build have not been established. Validate evaluated declarations and each SSH backup manually or with explicit authorization. Host rekey skips intermediaries and cannot validate these backups. Do not deploy real identities or rotate actual keys.
- Deferred: decide ownership and an FP interface for master identity policy and the secret-management lifecycle. Agenix and Agenix-rekey are currently composed by Base. Keep management policy explicit, avoid duplicate secret-path inventories, and avoid making backup management depend on a deployed Host. A virtual management node remains a candidate if management must cover Hosts without System configurations. Locked-source compatibility findings are in current memory.
- Deferred: assess recovery/deployment workflows and retention of ignored legacy SOPS backups when explicitly requested. Login password hashes and actual SSH/WireGuard key rotation remain outside the present task.

## Closeout verification

- The interface closeout is committed. Its separate Nix verification remains unconfirmed. See [current.md](current.md#committed-explicit-fp-composition-and-closeout) for the evidence boundary.
