# Backlog

Pending work and adopted target constraints. Current progress and verification belong in [current.md](current.md). Completed work should leave this list once any durable conclusions have been incorporated into current knowledge; Git history preserves its evolution.

## Independent follow-ups

- Verification follow-up: native intermediary registration and nine-file source re-encryption are committed. All four SSH backups now have X25519 and piv-p256 stanzas, but successful YubiKey-only decryption of these backups and Nix evaluation/build have not been established. Validate evaluated declarations and each SSH backup manually or with explicit authorization. Host rekey skips intermediaries and cannot validate these backups. Do not deploy real identities or rotate actual keys.
- Deferred: decide ownership and an FP interface for master identity policy and the secret-management lifecycle. Agenix and Agenix-rekey are currently composed by Base. Keep management policy explicit, avoid duplicate secret-path inventories, and avoid making backup management depend on a deployed Host. A virtual management node remains a candidate if management must cover Hosts without System configurations. Locked-source compatibility findings are in current memory.
- Deferred: assess recovery/deployment workflows and retention of ignored legacy SOPS backups when explicitly requested. Login password hashes and actual SSH/WireGuard key rotation remain outside the present task.

- Deferred: reduce MateBook's actual secret grants separately from the allocation migration. Verify the selected delivery set and account for secrets accessible through older generations, deployment artifacts and runtime copies before treating the machine as lower trust.

## Deferred SSH trust policy

- Establish a managed SSH login authentication path that can be maintained long term, without reliance on unmanaged user keys or temporary trust relationships. The authentication mechanism is undecided.
- Defer a separate known-hosts file or additional server trust isolation. The present benefit does not justify the extra complexity. Revisit it in a future system-wide review of SSH trust.

These are deferred design questions. The unified target implementation is complete.
