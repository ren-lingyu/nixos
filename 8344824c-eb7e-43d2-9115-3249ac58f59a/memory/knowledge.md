# Wireguard Evolution

This independent source history reconstructs one existing archived discovery line. It is historical evidence, not Formal current-memory authority. The input is previously distilled memory, not a complete original transcript. Raw rollouts, logs, archives, old Git trees and old GAW parents are not retained. Relative source-state order is supported, but no global ordering against other discovery lines is inferred. Checkpoints are created now without backdating. Exact original project provenance is unestablished; no project parent is guessed. Historical test reports below are not rerun by this task.

## Recoverable knowledge

The initial purpose is private reachability between managed hosts with a cloud entry, not takeover of normal internet traffic. Keep service ports explicit, do not trust the whole WireGuard interface, and do not block boot because peers are offline. Upper-layer DNS/HTTP publication is separate. Initial hub/spoke labels describe this topology, not permanent universal server/client identities.

Stable membership claims identify host/node relationships and a unique claimant supplies derived fields. There is no demonstrated network handshake or deployed reachability in the source; some multi-node/interface conflict checks were deliberately deferred.

Host numbers replace a single global intranet IP so one host can join several networks without list-order-dependent address allocation. Intranet definitions centralize network numbers, nodes and claimant constraints. The schema's future flexibility exceeds current generation: single-valued derived fields still need a unique claimant. Min/max constraints and address/key/peer derivation must evolve together before multiple claimants are supported. Container orchestration appearing in later staging is not runtime proof.

The interconnect feature is ultimately removed. Hosts own stable WireGuard membership and a pure host-schema-specific builder derives current networking; it is not an unrestricted generic WireGuard framework. Endpoint hosts define networks and other participants become spokes. Roles are evaluated per network, so a host that is a hub elsewhere can still need endpoint/keepalive behavior as a spoke here.

Disabled/no-WireGuard selection returns an empty result without reading a private-key path. Hub filtering stays within WireGuard participants. The owner accepted the independent library builder as a useful commit boundary before separate host wiring. The final reviewed wiring had no unstaged changes and a clean diff check, without a demonstrated final project commit, Nix success or network deployment.

## Continuation

Compare these conclusions with the relevant project snapshot before Formal adoption. Preserve unresolved questions, distinguish proposals from adopted behavior and do not extend a historical successful check to later changes.
