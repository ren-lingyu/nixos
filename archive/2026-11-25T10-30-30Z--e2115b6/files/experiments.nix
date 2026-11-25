{ nixpkgs, project, caseName }:
let
  lib = import (nixpkgs + "/lib");
  inherit (lib) mkOption mkIf types;
  eval = modules: lib.evalModules { inherit modules; };
  readOnly = type: mkOption { inherit type; readOnly = true; };
  opt = type: default: mkOption { inherit type default; };
  functionType = types.mkOptionType {
    name = "localFeatureFunction";
    check = lib.isFunction;
    merge = lib.options.mergeOneOption;
  };
  coerced = types.coercedTo types.attrs (value: _: value) functionType;
  featureModule = types.mkOptionType {
    name = "featureModule";
    description = "Feature-local configuration module function.";
    check = x: lib.isFunction x || builtins.isAttrs x;
    merge = loc: defs:
      let value = lib.options.mergeOneOption loc defs;
      in if lib.isFunction value then value else _: value;
  };
  wrap = name: module:
    lib.setFunctionArgs (args: { config.features.${name} = module args; }) (lib.functionArgs module);
  fp = type: defs: (eval ([ { options.local = readOnly type; } ] ++ map (value: { local = value; }) defs));
  sig = value: { callable = lib.isFunction value; arguments = lib.functionArgs value;
    result = value { inherit lib; config = {}; customArg = 42; };
  };
  userFunction = { config, lib, customArg, ... }: { value = customArg; };
  callable = lib.setFunctionArgs (args: { value = args.customArg; }) { customArg = false; };
  simulation = mods: lib.evalModules { modules = mods; specialArgs.osConfig.origin = "OS"; };
  namespace = {
    options = {
      features.example = {
        value = opt types.int 0;
        first = opt types.int 0;
        second = opt types.int 0;
        items = opt (types.listOf types.str) [];
        programs.git.enable = opt types.bool false;
      };
      programs.git.enable = opt types.bool false;
      mockSops = {
        enable = opt types.bool false;
        secrets.test.path = mkOption { type = types.str; };
      };
      features.agent.pi.providers = opt (types.attrsOf (types.submodule {
        options = { enable = opt types.bool false; apiKeyFile = mkOption { type = types.str; }; };
      })) {};
    };
  };
  runNative = expr: extra: (simulation ([ namespace (wrap "example" (fp featureModule [expr]).config.local) ] ++ extra)).config;
  providerBody = { config, lib, ... }: {
    pi.providers = lib.mkIf config.mockSops.enable {
      test = { enable = true; apiKeyFile = config.mockSops.secrets.test.path; };
    };
  };
  provider = enabled: pathDefs: (eval ([
    namespace (wrap "agent" (fp featureModule [providerBody]).config.local) { mockSops.enable = enabled; }
  ] ++ pathDefs)).config.features.agent.pi.providers;
  sparse = types.attrsOf (types.submodule { options.module = readOnly featureModule; });
  registry = defs: eval ([ {
    options.users = opt (types.attrsOf (types.submodule { options.features = opt sparse {}; })) {};
  } ] ++ defs);
  sample = { module = { value = 42; }; };
  regValue = modules: (registry modules).config.users.alice.features.example.module {};
  ro = defaults: defs: eval ([ { options.value = readOnly (types.nullOr types.str) // defaults; } ] ++ map (value: { inherit value; }) defs);
  argsFunction = { config, lib, options, osConfig, customArg, ... }: {
    value = if lib.isInt customArg && lib.isOption options.features.example.value && osConfig.origin == "OS"
      then customArg + config.features.example.first else throw "wrong args";
  };
  argsFP = eval [
    { options.local = readOnly featureModule; options.native = mkOption { type = types.deferredModule; }; }
    { local = argsFunction; }
    ({ config, ... }: { native = wrap "example" config.local; })
    { native = { features.example.first = 2; }; }
  ];
  projectTypes = import (project + "/lib/types.nix") { inherit lib; };
  constructor = import (project + "/lib/flakeParts.nix") { inherit lib; };
  # The Account's existing selection schema supplies the legal names.
  accountWiring = { config, ... }: {
    config.features = lib.mapAttrs (name: entry: { module = wrap name entry.module; }) config.profile.features;
  };
  # Extend the real FP schema externally. Production can put the equivalent
  # Account contribution beside the existing Account options instead.
  wiringExtension = {
    options.nixosBuilderArgs.userRegistry = mkOption {
      type = types.attrsOf (types.submodule { options.features = opt sparse {}; });
    };
    options.nixosConfigurations = mkOption {
      type = types.attrsOf (types.submodule {
        options.users = mkOption {
          type = types.attrsOf (types.submodule accountWiring);
        };
      });
    };
  };
  mockSops = { options.features.sops.enable = lib.mkEnableOption "SOPS"; };
  mockAgent = { options.features.agent = {
    enable = lib.mkEnableOption "Agent";
    account = opt types.int 0;
    layers = opt (types.listOf types.str) [];
    pi.providers.test = {
      enable = opt types.bool false;
      apiKeyFile = opt (types.nullOr types.str) null;
    };
  }; };
  # The actual constructor still selects and binds. The fake nixosSystem
  # only projects the OS module output and evaluates each HM module separately.
  mockNixos = { modules, ... }:
    let os = eval (modules ++ [ {
      options.users.users = opt (types.attrsOf types.raw) {};
      options.home-manager.extraSpecialArgs = opt (types.attrsOf types.raw) {};
      options.home-manager.users = opt (types.attrsOf types.deferredModule) {};
    } ]);
    in lib.mapAttrs (_: module: (eval [
      { options.home = { uid = mkOption { type = types.int; }; username = mkOption { type = types.str; }; homeDirectory = mkOption { type = types.str; }; }; }
      module
    ]).config) os.config.home-manager.users;
  flow = unknown: unreferenced: let
    e = eval [
      ({ config, ... }: { options = constructor.mkOptions config; })
      wiringExtension
      ({ config, ... }: {
        nixosBuilderArgs = {
          nixosSystem = mockNixos;
          homeManager = {};
          hostTopology = {};
          hostRegistry.host.module = {};
          userRegistry.alice.features = {
            agent.module = { config, lib, ... }: {
              account = config.home.uid;
              layers = lib.mkBefore ["profile"];
              pi.providers = lib.mkIf (config.features.sops.enable or false) {
                test = { enable = true; apiKeyFile = "/mock/${toString config.home.uid}"; };
              };
            };
            unused.module = _: throw "unselected function was called";
          } // lib.optionalAttrs unknown { typo.module = {}; };
          userRegistry.other.module = {};
          userRegistry.dormant.features = lib.optionalAttrs unreferenced { typo.module = _: throw "unreferenced body"; };
          featureRegistry.hm = {
            sops = mockSops;
            agent = mockAgent;
            unused = { options.features.unused.enable = lib.mkEnableOption "unused"; config.features.unused.enable = throw "unselected implementation was imported"; };
          };
        };
        nixosBuilderArgs.hostRegistry.host.users = { "1000" = 1000; "1001" = 1001; "1002" = 1002; };
        nixosConfigurations.demo = {
          host = config.nixosBuilderArgs.hostRegistry.host;
          users = {
            "1000" = { username = "a"; profile = config.nixosBuilderArgs.userRegistry.alice;
              features.agent = { enable = true; module.features.agent.layers = ["account"]; };
              features.sops.enable = true;
            };
            "1001" = { username = "b"; profile = config.nixosBuilderArgs.userRegistry.alice; features.agent.enable = true; };
            "1002" = { username = "c"; profile = config.nixosBuilderArgs.userRegistry.other; features.agent.enable = true; };
          };
        };
      })
      { options.nixosBuilderArgs.hostRegistry = mkOption {
          type = types.attrsOf (types.submodule { options.users = opt (types.attrsOf types.int) {}; });
        };
      }
      { nixosConfigurations.demo.users."1000".features.agent.module.features.agent.layers = lib.mkAfter ["another-FP"]; }
    ];
    systems = constructor.mkNixosConfigurations { builderArgs = e.config.nixosBuilderArgs; configurations = e.config.nixosConfigurations; };
  in { accounts = lib.mapAttrs (_: c: { inherit (c.features) agent; hasUnused = c.features ? unused; }) systems.demo; profile = e.config.nixosConfigurations.demo.users."1000".profile.name; };
  # Candidate consumers use native option presence. All secret/key paths are mocks.
  sops = defs: (eval ([
    ({ config, ... }: let
      cfg = config.features.sops;
      inputs = cfg.secretsInput;
      format = cfg.defaultSopsFormat;
      file = cfg.defaultSopsFile;
      helper = import (project + "/modules/features/sops/hm/secrets.nix") {
        config = { home.uid = 1000; sops = { defaultSopsFormat = format; defaultSopsFile = file; }; };
      };
    in {
      options = {
        features.sops = {
          enable = lib.mkEnableOption "mock SOPS";
          defaultSopsFormat = readOnly (types.nullOr types.str);
          defaultSopsFile = readOnly (types.nullOr types.path);
          secretsInput = readOnly projectTypes.sopsSecretsInput;
        };
        result = opt types.raw {};
      };
      config.result = mkIf cfg.enable (
        assert lib.assertMsg (inputs == [] || (format != null && file != null)) "mock secrets require format and file";
        { keyPath = "/mock/shared"; declarations = lib.mapAttrs (_: declaration: {
            inherit (declaration) key path mode format;
            fileMatches = declaration.sopsFile == file;
          }) (helper.mkSopsSecrets inputs);
        }
      );
    })
  ] ++ defs)).config.result;
  mockInputs = [{ template = "user"; structure = { account = ["example"]; }; }];
  agent = defs: (eval ([
    ({ config, options, ... }: let
      providers = [ "test" "other" ];
      enabled = provider: options.features.agent.pi.providers.${provider}.enable.isDefined
        && config.features.agent.pi.providers.${provider}.enable;
      credential = provider:
        let path = config.features.agent.pi.providers.${provider}.apiKeyFile;
        in assert lib.assertMsg (path != null) "enabled provider requires a credential"; path;
    in {
      options = {
        features.agent.pi.providers = lib.genAttrs providers (_: {
          enable = readOnly types.bool;
          apiKeyFile = readOnly (types.nullOr types.nonEmptyStr);
        });
        result = opt types.raw {};
        mockSops.enable = opt types.bool false;
      };
      config.result = lib.genAttrs providers (provider: if enabled provider then credential provider else null);
    })
  ] ++ defs)).config.result;
  derive = enabled: extra: (eval ([
    ({ config, ... }: {
      options = { service.enable = lib.mkEnableOption "mock OS service";
        service.path = readOnly types.str;
        peer = opt (types.nullOr types.str) null;
      };
      config = {
        service.path = mkIf config.service.enable "/mock/shared";
        peer = mkIf config.service.enable config.service.path;
      };
    })
    { service.enable = enabled; }
  ] ++ extra)).config;
  hm = os: enabled: (lib.evalModules {
    specialArgs = os;
    modules = [
      (args: {
        options.enable = lib.mkEnableOption "mock HM SOPS" // {
          apply = value: assert lib.assertMsg
            (!value || (args.osConfig.features.sops.enable or false))
            "Home Manager SOPS requires system SOPS.";
            value;
        };
        options.path = opt (types.nullOr types.str) null;
        config.path = mkIf args.config.enable args.osConfig.features.sops.ageKeys.hm.path;
      })
      { enable = enabled; }
    ];
  }).config.path;
  aliases = {
    A_attrs = sig (fp featureModule [{value=42;}]).config.local;
    A_fun = sig (fp featureModule [userFunction]).config.local;
    A_callable = sig (fp featureModule [callable]).config.local;
    A_coercedCallable = let value = (fp coerced [callable]).config.local; result = value {}; in {
      arguments = lib.functionArgs value;
      returnedCallable = lib.isFunction result;
      resultArguments = lib.functionArgs result;
    };
    A_coercedAttrs = sig (fp coerced [{value=42;}]).config.local;
    A_coercedFun = sig (fp coerced [userFunction]).config.local;
    A_badInt = (fp featureModule [42]).config.local {};
    A_badString = (fp featureModule ["example"]).config.local {};
    A_badList = (fp featureModule [[]]).config.local {};
    A_badPath = (fp featureModule [./.]).config.local {};
    A_functionTo = (fp (types.functionTo types.attrs) [(_: lib.mkIf false {value=42;})]).config.local {};
    A_functionToMerge = (fp (types.functionTo types.attrs) [(_: lib.mkMerge [{first=1;} {second=2;}])]).config.local {};
    A_directProperty = (fp featureModule [(_: lib.mkIf false {value=42;})]).config.local {};
    B_native = (simulation [ namespace argsFP.config.native { _module.args.customArg = 40; } ]).config.features.example.value;
    B_signature = lib.functionArgs argsFP.config.local;
    B_ellipsis = (runNative (args: {value = if args ? customArg then 1 else 0;}) [{_module.args.customArg = 42;}]).features.example.value;
    B_default = (runNative ({ customArg ? 42, ... }: {value = customArg;}) []).features.example.value;
    C_providerOn = provider true [{ mockSops.secrets.test.path = "/mock/token"; }];
    C_providerOff = provider false [];
    C_providerOffThrow = provider false [{ mockSops.secrets.test.path = throw "path too early"; }];
    C_fpLazy = lib.isFunction (fp featureModule [({config,...}: throw "called too early")]).config.local;
    C_if = (runNative ({config,...}: mkIf config.mockSops.enable {value=42;}) [{mockSops.enable=true;}]).features.example.value;
    C_ifOff = (runNative ({config,...}: mkIf config.mockSops.enable {value=throw "unexpected";}) []).features.example.value;
    C_merge = (runNative (_: lib.mkMerge [{first=1;} {second=2;}]) []).features.example;
    C_attrProps = (runNative {value = mkIf true 42; items = lib.mkMerge [["a"] ["b"]];} []).features.example;
    C_attrTopIf = (fp featureModule [ (mkIf false {value=42;}) ]).options.local.isDefined;
    C_attrTopMerge = (fp featureModule [ (lib.mkMerge [{first=1;} {second=2;}]) ]).config.local {};
    C_default = (runNative (_: {value=lib.mkDefault 1;}) [{features.example.value=2;}]).features.example.value;
    C_force = (runNative (_: {value=lib.mkForce 1;}) [{features.example.value=2;}]).features.example.value;
    C_order = (runNative (_: {items=lib.mkMerge [(lib.mkBefore ["first"]) (lib.mkAfter ["last"])];}) [{features.example.items=["middle"];}]).features.example.items;
    C_namespace = let c = runNative (_: {programs.git.enable=true;}) []; in {global=c.programs.git.enable; local=c.features.example.programs.git.enable;};
    C_imports = (runNative (_: {imports=[(throw "loaded imports")];}) []).features.example.value;
    C_options = (runNative (_: {options.escape=mkOption {type=types.int;};}) []).features.example.value;
    D_empty = (registry [{users.alice={};}]).config.users.alice.features;
    D_multi = let r=(registry [{users={alice.features={example=sample;another.module={value=3;};};bob.features.example=sample;};}]).config.users; in [ (r.alice.features.example.module {}).value (r.alice.features.another.module {}).value (r.bob.features.example.module {}).value ];
    D_duplicate = regValue [{users.alice.features.example=sample;} {users.alice.features.example=sample;}];
    D_force = regValue [{users.alice.features.example=sample;} {users.alice.features.example.module=lib.mkForce {value=2;};}];
    D_false = regValue [{users.alice.features.example=sample;} {users.alice.features.example.module=mkIf false (throw "false payload");}];
    D_mergeOne = (eval [{options.local=mkOption {type=featureModule;};} {local={value=1;};} {local=lib.mkForce {value=2;};}]).config.local {};
    E_accounts = flow false false;
    E_unknown = flow true false;
    E_unknownUnreferenced = flow false true;
    F_missingStrict = (eval [{ options.value = readOnly types.str; }]).config.value;
    F_orStrict = (eval [{ options.value = readOnly types.str; }]).config.value or "fallback";
    F_missingFile = (eval [{ options.value = readOnly (types.nullOr types.path); }]).config.value;
    F_missingInputs = (eval [{ options.value = readOnly projectTypes.sopsSecretsInput; }]).config.value;
    F_missingEnable = (eval [{ options.value = readOnly types.bool; }]).config.value;
    F_missing = (ro {} []).config.value;
    F_or = (ro {} []).config.value or "fallback";
    F_presence = { missing=(ro {} []).options.value.isDefined; inactive=(ro {} [ (mkIf false (throw "false")) ]).options.value.isDefined; explicitNull=(ro {} [ null ]).options.value.isDefined; default=(ro {default=null;} []).options.value.isDefined; };
    F_defined = (ro {} ["given"]).config.value;
    F_defaultOnly = (ro {default=null;} []).config.value;
    F_defaultConflict = (ro {default=null;} ["given"]).config.value;
    F_sopsEmpty = sops [{features.sops.enable=true;}];
    F_sopsExplicitEmpty = sops [{features.sops.enable=true;features.sops.secretsInput=[];}];
    F_sopsFull = sops [{features.sops={enable=true;secretsInput=mockInputs;defaultSopsFormat="yaml";defaultSopsFile=./.;};}];
    F_sopsNoDefaults = sops [{features.sops={enable=true;secretsInput=mockInputs;};}];
    F_sopsNoFormat = sops [{features.sops={enable=true;secretsInput=mockInputs;defaultSopsFile=./.;};}];
    F_sopsNoFile = sops [{features.sops={enable=true;secretsInput=mockInputs;defaultSopsFormat="yaml";};}];
    F_sopsDisabled = sops [{features.sops.secretsInput=throw "forced when disabled";}];
    F_sopsDuplicate = sops [{features.sops={enable=true;secretsInput=[];};} {features.sops.secretsInput=[];}];
    F_agentEmpty = agent [];
    F_agentA = agent [{features.agent.pi.providers.test={enable=true;apiKeyFile="/mock/non-sops";};}];
    F_agentAB = agent [{features.agent.pi.providers.test={enable=true;apiKeyFile="/mock/non-sops";};} {features.agent.pi.providers.other.enable=false;}];
    F_agentGuard = agent [({config,...}:{features.agent.pi.providers=mkIf config.mockSops.enable {test={enable=true;apiKeyFile=throw "secret path";};};})];
    F_agentPathOnly = agent [{features.agent.pi.providers.test.apiKeyFile = "/mock/not-enabled";}];
    F_agentNullKey = agent [{features.agent.pi.providers.test={enable=true;apiKeyFile=null;};}];
    F_agentNoKey = agent [{features.agent.pi.providers.test.enable=true;}];
    F_agentDuplicate = agent [{features.agent.pi.providers.test.enable=true;} {features.agent.pi.providers.test.enable=false;}];
    G_peer = (derive true []).peer;
    G_off = (derive false []).peer;
    G_duplicate = (derive true [{service.path="/mock/override";}]).peer;
    G_hmOn = hm {osConfig.features.sops={enable=true;ageKeys.hm.path=(derive true []).service.path;};} true;
    G_hmOff = hm {osConfig=throw "unexpected OS evaluation";} false;
    G_hmNoOSOff = hm {} false;
    G_hmNoOSOn = hm {} true;
    G_hmOSOff = hm {osConfig.features.sops.enable=false;} true;
  };
in aliases.${caseName}
