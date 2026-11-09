# External Standards

Use this entry point when a workflow needs details from an external standard. Official URLs identify the authoritative documents; bundled files are pinned documentation snapshots. Paths below are relative to this file and do not require a particular installation method or Nix store path.

## Keep a Changelog 2.0.0

- Official document: [Keep a Changelog 2.0.0](https://keepachangelog.com/en/2.0.0/).
- Optional local snapshot: `standards/keep-a-changelog/2.0.0.md`.
- Bundled upstream license: `standards/keep-a-changelog/LICENSE`.
- Use for changelog purpose, notable-change selection, release organization, change types, unreleased entries, and historical curation.

## Semantic Versioning 2.0.0

- Official document: [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).
- Optional local snapshot: `standards/semver/2.0.0.md`.
- The original document includes its attribution and CC BY 3.0 license notice at the end.
- Use for version-number semantics in the context of the project's declared public interface and compatibility policy. It does not authorize choosing the next version or changing a manifest.

## Access and fallbacks

If the relevant local snapshot exists, prefer consulting the needed sections there. If it is absent, continue using the workflow's core contract; when a decision needs additional specification detail and network access is available and permitted, consult the public official URL. Do not require network access, download files automatically, or load both standards in full on every invocation.

If a needed detail cannot be checked, report the resulting limitation and provide only supported conclusions. Missing snapshots do not disable the skill: for changelog operations, [changelog.md](changelog.md) supplies the core contract. Follow the project's explicit conventions and explain material differences from the external guidance.
