# Feature wiring evaluation

Captured 2026-11-25T10:30:30Z UTC from the isolated scratch experiment directory. The source anchor is project revision `e2115b6156df93629a0112a0cfbce42124c8f0f9`, with its root lock selecting Nixpkgs revision `0bb8272318b4ca41bf0edc6224df3e3e3046b70d`. The evaluation used Nix 2.35.6. The project source and Nixpkgs were resolved offline through the rev-pinned local root flake. These are historical experimental evidence and implementation candidates.

## Scope and selection

- `files/experiments.nix` preserves the final executed expression byte for byte. It remains independently useful because the expressions were deliberately outside the project tree and no formal tests cover these candidate interfaces.
- `files/observations.json` preserves the exit codes, JSON results, and principal error diagnostics of the 77 independent final invocations. It is a normalized derivative of the local observations. Temporary directory and pinned Nixpkgs store path strings in diagnostics were replaced by placeholders; the diagnostic text and cases are otherwise preserved. Transient fixture mistakes, earlier iterations, raw command logs, caches and project/Nixpkgs source copies are omitted.
- E imports the real pinned `lib/flakeParts.nix` and runs its real option declarations, name lookup and constructors against a minimal `nixosSystem`/HM projection. The prospective types and the Account/User schema extension are local experimental definitions. F imports the actual SOPS input type and secret expansion helper and gives them mock options, a fixture path, and fabricated names. The other native scopes are minimal simulations. No real secret input, ciphertext contents, deployment path inspection or secret-access command was used.

## Replay

Resolve both source paths from the committed root flake. Run from a clone at the supplied URL or adjust the local URL to the location of a clone containing the same commit. The flake lock fixes Nixpkgs transitively. The pinned revision returned by the first command should match the revision above.

```sh
nix eval --impure --offline --no-write-lock-file --json --expr '
  let p = builtins.getFlake "git+file:///home/lingyu/nixos?rev=e2115b6156df93629a0112a0cfbce42124c8f0f9";
  in { source = toString p.outPath; nixpkgs = toString p.inputs.nixpkgs.outPath; rev = p.inputs.nixpkgs.rev; }'
```

From this archive directory, set `project_src` and `locked_nixpkgs` to the returned absolute paths. Choose a key from `observations.json`. Replay each case separately to force the selected projection and get the actual diagnostic for negative cases.

```sh
case_name=E_accounts
nix eval --offline --no-write-lock-file --json --file ./files/experiments.nix \
  --apply "f: f { project = ${project_src}; nixpkgs = ${locked_nixpkgs}; caseName = \"${case_name}\"; }"
```

## Outcome by question

| Group | Observed result and boundary |
| --- | --- |
| A · type | The direct single-definition merge preserves plain functions, callable attrsets and signatures, converts ordinary sets to constant functions, and rejects integers, strings, lists and paths. The original `coercedTo attrs` treats a callable attrset as a plain set, returning that callable as data with an empty outer signature. `functionTo attrs` consumes returned definition properties itself: false `mkIf` returned `{}`, and `mkMerge` returned already merged fields. |
| B · arguments | The wrapper propagated `config`, `lib`, `options`, special-argument `osConfig`, and `_module.args.customArg` through a merged deferred module. The native projection was 42; the FP projection was safe without the argument values. Ellipsis alone did not expose `customArg`; explicitly naming it with a Nix default still produced a missing-attribute diagnostic when the module system supplied an unresolved argument thunk. |
| C · properties | Nested provider conditions, returned whole `mkIf` and `mkMerge`, and properties nested within ordinary sets remained native. False native conditions left throwing payloads alone. Native `mkDefault`, `mkForce`, `mkBefore`, and `mkAfter` gave the projected override and ordering values. A property directly on the FP definition is processed in FP: false `mkIf` leaves the option undefined, and a multi-branch `mkMerge` conflicts with single definition. Wrapper output stayed under the Feature namespace. Undeclared `imports` and `options` resulted in ordinary unknown native options. |
| D · sparse and read-only | Empty User features, multiple Feature names and the same Feature on independent Users all evaluated. Duplicate definitions, a forced competing definition and a false conditional alongside a real definition were rejected on a read-only option. In contrast, the type's single-definition merge without read-only let `mkForce` win. Read-only counts pre-filter definitions. |
| E · FP wiring | Three native projections showed ordinary deferred-module merging, an enabled selection without profile data, and two Accounts reusing one profile with separate UIDs and SOPS/provider state. A known unselected module with a throwing body was neither called nor imported. Account contributions came from `config.profile.features`, so no read of the final Account `features` fixed point was needed. The existing target schema rejected an unknown Feature for a referenced profile, and an unreferenced profile with an unknown Feature was left unevaluated. |
| F · optional inputs | At the locked revision, missing values of declared nullable options without a default resolve to `null` and the actual no-default SOPS input list resolves to `[]`. A strict string or bool with no value throws. Attribute `or` did not intercept the strict error and did not replace a nullable result. `isDefined` was false for missing and inactive definitions, true for explicit null and a declared default. Read-only default-plus-definition failed. Shared-key-only and explicitly empty SOPS produced zero entries; complete input produced a mock declaration through the real helper; nonempty data required both format and file. Disabled SOPS and a false Agent provider guard did not force throwing inputs. Providers were independent, path-only data did not activate a provider, non-SOPS credentials worked, and enabled providers with absent/null credentials failed. |
| G · OS dependency | An owned read-only derived value was consumed in OS and via HM `osConfig`, stayed lazy when disabled, and rejected a competing definition. The SOPS HM enable `apply` allowed a disabled HM scope with absent or throwing OS data. Enabled HM with OS enabled resolved the path; enabled HM with OS disabled or absent produced the intended dependency error. |

Fifty-one cases serialized successfully and 26 produced the intended negative diagnostics. No full NixOS or Home Manager evaluation, flake check, build, deployment or live access was performed.

## Minimal patch guidance

Use the following type and wrapper. Pass just `featureModule` explicitly to the FP library from the root library composition. Reuse the common Registry entry schema for Host and User; extend only the User entry with the sparse option. The constructor can remain unchanged.

```nix
featureModule = lib.types.mkOptionType {
  name = "featureModule";
  description = "Feature-local configuration module function.";
  check = value: lib.isFunction value || builtins.isAttrs value;
  merge = loc: defs:
    let value = lib.options.mergeOneOption loc defs;
    in if lib.isFunction value then value else _: value;
};

mkFeatureModule = name: module:
  lib.setFunctionArgs
    (args: { config.features.${name} = module args; })
    (lib.functionArgs module);
```

```nix
# Extra fields of the User Registry submodule
options.features = lib.mkOption {
  type = lib.types.attrsOf (lib.types.submodule {
    options.module = lib.mkOption {
      type = featureModule;
      readOnly = true;
    };
  });
  default = { };
};

# Account FP submodule, alongside its existing options
config.features = lib.mapAttrs
  (name: entry: { module = mkFeatureModule name entry.module; })
  config.profile.features;
```

Keep optional SOPS fields typed and without explicit defaults. At this lock their native empty values can be consumed directly. Require both file and format only for nonempty input. Guard Agent provider enable with `options.<provider>.enable.isDefined && cfg.<provider>.enable`; require a non-null credential on the enabled path and use the typed nullable path there. Keep the User's guard as one nested `mkIf` at `pi.providers`, returned by its function. Give each read-only field a single definition. A disabled condition is not a supported way to add another definition beside the actual producer.

In the SOPS HM module use optional OS context, for example `osConfig = args.osConfig or { };` from `{ config, lib, ... }@args:`. The enable `apply` checks `!enabled || (osConfig.features.sops.enable or false)` with the existing native assertion style. In the HM-enabled branch consume `osConfig.features.sops.ageKeys.hm.path`. Keep the path and OS secret name as single-producer read-only options.

## Static HM-to-OS review

- Shell requires the exported OS Shell package interfaces and native `programs.zsh.enable` state. Rename both package declarations, the OS consumer, and HM existence checks and reads. A same-name OS enable assertion would overstate the dependency.
- Niri HM requires a system `programs.niri.package`. OS Feature and Noctalia enable states compute the HM Noctalia default. Noctalia OS's real NetworkManager, Bluetooth, power profile and UPower requirements still matter when changing the default. HM Noctalia also reads actual font and fingerprint-service information.
- Font HM consumes native `fonts.fontconfig.defaultFonts`, independently of which module supplied it. File-manager HM uses OS File-manager and FileChooser as default inputs and separately uses HM Niri as its Wayfile default. Its actual file chooser terminal-execution requirement remains native.
- SOPS HM currently defaults its age key from the OS secret via the internal name. The adopted change substitutes the published path and a genuine OS SOPS dependency. The isolated evidence covers only the modeled contract. Check actual production merging, registration, SOPS/Agenix path projection and valid system/account selections after the patch.

Keep explicit System and Account settings during the defaults work. The experiment does not validate all production changes in the backlog.
