# File Manager Terminal Portal

This independent source history reconstructs one existing archived discovery line. It is historical evidence, not Formal current-memory authority. The input is previously distilled memory, not a complete original transcript. Raw rollouts, logs, archives, old Git trees and old GAW parents are not retained. Relative source-state order is supported, but no global ordering against other discovery lines is inferred. Checkpoints are created now without backdating. Exact original project provenance is unestablished; no project parent is guessed. Historical test reports below are not rerun by this task.

## Recoverable knowledge

The user wanted Yazi as the default directory handler and Wayfile separated from Niri. Yazi remains useful headlessly; Wayfile follows desktop availability without a new monitor protocol. Use the package's own desktop ID rather than duplicating its desktop entry. A `Terminal=true` entry still needs a working terminal provider. Directory MIME handling and the XDG FileChooser portal are distinct capabilities.

Terminal configuration moves from the personal user into an HM feature with Kitty/Alacritty and native `xdg.terminal-exec`. Niri launchers consume the native terminal interface with enable guards instead of depending directly on Kitty or adding a repository-only exclusive bridge. Another module may supply that interface. Desktop/WSL and minimal server selection differ.

The file chooser has its own enable flag controlling provider configuration and terminal prerequisites rather than being unconditionally tied to Niri. A separate terminal change was reviewed after the user temporarily stashed the file-manager work; these were independently recoverable editing states, not a single verified final deployment.

The actual capability test is HM's native `config.xdg.terminal-exec.enable`, not an indirect equivalence with the repository terminal feature or its recipient list. The chain is FileChooser portal to termfilechooser to xdg-terminal-exec to a terminal to Yazi; it applies only to applications actually using that portal.

With HM useUserPackages on WSL, OS `pathsToLink` must include applications and portal resources. The file-manager gained an OS implementation with conditional additions that preserve other modules' paths. Conflict markers left in the index after worktree resolution were later cleared by the owner. An invalid mix of top-level assertions and explicit config was fixed by moving assertions inside config. The source retains no successful check after the final fixes; later framebuffer commit drafting does not validate the portal.

## Continuation

Compare these conclusions with the relevant project snapshot before Formal adoption. Preserve unresolved questions, distinguish proposals from adopted behavior and do not extend a historical successful check to later changes.
