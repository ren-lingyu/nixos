# Backlog

Pending work and adopted target constraints. Current progress and verification belong in [current.md](current.md). Completed work should leave this list once any durable conclusions have been incorporated into current knowledge; Git history preserves its evolution.

## Independent follow-ups

- Verification follow-up: native intermediary registration and nine-file source re-encryption are committed. All four SSH backups now have X25519 and piv-p256 stanzas, but successful YubiKey-only decryption of these backups and Nix evaluation/build have not been established. Validate evaluated declarations and each SSH backup manually or with explicit authorization. Host rekey skips intermediaries and cannot validate these backups. Do not deploy real identities or rotate actual keys.
- Deferred: decide ownership and an FP interface for master identity policy and the secret-management lifecycle. Agenix and Agenix-rekey are currently composed by Base. Keep management policy explicit, avoid duplicate secret-path inventories, and avoid making backup management depend on a deployed Host. A virtual management node remains a candidate if management must cover Hosts without System configurations. Locked-source compatibility findings are in current memory.
- Deferred: assess recovery/deployment workflows and retention of ignored legacy SOPS backups when explicitly requested. Login password hashes and actual SSH/WireGuard key rotation remain outside the present task.

## Subflake boundary exploration

The owner is considering whether a single root flake, a separately locked subflake loaded through `builtins.getFlake`, or localized package/group subflakes would reduce dependency wiring and improve version ownership. The current child has its own declared inputs and root supplies the committed lock graph. Root consumes overlays rather than a pre-instantiated package set; assess what each overlay captures and which other outputs matter before drawing a compatibility conclusion. Preserve intentionally pinned upstream build APIs when considering `follows`; fewer lock nodes alone are insufficient reason to override them. External reference material alone does not warrant a separate flake. These alternatives remain open.
