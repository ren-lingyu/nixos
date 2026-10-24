---
name: nixos-gaw-checkpoint-message
description: Choose the commit-message type and scope when preparing a GAW checkpoint for this project.
---

# GAW checkpoint message conventions

Choose from the checkpoint's actual changes.

## Type

- `chore`: record findings, decisions, verification, current state or pending work; make minor wording, formatting or link adjustments.
- `fix`: correct materially wrong knowledge or faulty workflow guidance.
- `refactor`: reorganize memory or guidance without changing its meaning.
- `feat`: add a reusable project-skill capability; newly recorded findings alone are not a feature.

## Scope

Use a category with optional subitems: `category[/subitem…]`. Categories include `memory`, `skill` and `archive`. There is no depth limit; prefer the shortest scope that accurately describes the maintenance area.

Examples: `memory`, `memory/current`, `memory/backlog/secrets`, `skill/nixos-gaw-checkpoint-message`.

Use a subitem for work focused on that area, or the category for coordinated changes across its subitems. Subitems must reflect a real maintenance area; do not invent divisions merely to make the scope more specific.

Put the concrete topic in the subject. Do not use `gaw` merely to name the workflow, or enumerate every changed path in the scope.
