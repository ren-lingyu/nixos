# Icewm Fallback

This independent source history reconstructs one existing archived discovery line. It is historical evidence, not Formal current-memory authority. The input is previously distilled memory, not a complete original transcript. Raw rollouts, logs, archives, old Git trees and old GAW parents are not retained. Relative source-state order is supported, but no global ordering against other discovery lines is inferred. Checkpoints are created now without backdating. Exact original project provenance is unestablished; no project parent is guessed. Historical test reports below are not rerun by this task.

## Recoverable knowledge

Niri remains the main desktop. X11 is a general compatibility fallback, accessible from the greeter or from another TTY after Niri login, rather than a single-application special case. The adopted split gives the OS responsibility for Xorg/startx/IceWM and the session entry, and HM responsibility for the user's launcher through native options. An earlier suggestion to omit HM to avoid interface changes was superseded by the user's requirement.

Clear inherited DISPLAY, WAYLAND_DISPLAY, SWAYSOCK and NIRI_SOCKET. Do not hardcode input-method startup or couple this independent session to the shared user graphical target. Cross-VT clipboard sharing and automatic host-monitor layout are outside this first phase; provide tools without inventing a new monitor interface.

The implementation declares an HM side, keeps the `X11-Session` entry and starts `icewm-session` through `dbus-run-session`. It removes XFCE, enables IceWM/startx on the OS side and adds minimal rofi launcher configuration plus xdg-utils/xrandr without automatic layout policy.

The user reported a successful rebuild test, TTY2 login and broadly usable meeting software. A browser could still open in an existing Niri instance; the source ended without a confirmed diagnosis or fix. Neither a reboot nor a different rebuild action is established as its solution. These runtime statements are historical reports, not fresh verification.

## Continuation

Compare these conclusions with the relevant project snapshot before Formal adoption. Preserve unresolved questions, distinguish proposals from adopted behavior and do not extend a historical successful check to later changes.
