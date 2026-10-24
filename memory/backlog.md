# Backlog

Pending work and adopted target constraints. Current progress and verification belong in [current.md](current.md). Completed work should leave this list once any durable conclusions have been incorporated into current knowledge; Git history preserves its evolution.

- Manage and re-encrypt the four Host SSH private-key backups so the configured YubiKey can unlock them while retaining the ordinary age master recipient. Consider upstream intermediary-secret registration, verify the locked interface before implementation, and validate each backup using only YubiKey. Host runtime key rotation and login password hashes are outside the current scope; see current memory for verification and authorization boundaries.
