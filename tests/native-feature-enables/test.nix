{
  lib,
  runCommand,
  types,
  modules,
  featureRegistry,
  featureTestPackages,
}:
let
  # Use the registered implementations, except where the fixture supplies upstream declarations.
  nixosModules = featureRegistry.os // {
    sops = modules + "/features/sops/os";
  };
  homeModules = featureRegistry.hm // {
    editor = modules + "/features/editor/hm";
    niri = modules + "/features/niri/hm";
    sops = modules + "/features/sops/hm";
  };
  attrsOption = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
  };
  desktopProgramOptions = {
    enable = lib.mkEnableOption "fixture program";
    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
    };
    settings = attrsOption;
  };
  nativeOptions.options =
    lib.genAttrs [
      "age"
      "environment"
      "fonts"
      "gtk"
      "home"
      "nixpkgs"
      "qt"
      "services"
      "sops"
      "systemd"
      "users"
      "xdg"
    ] (_: attrsOption)
    // {
      programs =
        lib.genAttrs [
          "alacritty"
          "bash"
          "btop"
          "clash-verge"
          "codex"
          "emacs"
          "fuzzel"
          "github-copilot-cli"
          "kitty"
          "libreoffice"
          "mpv"
          "nixvim"
          "obs-studio"
          "onlyoffice"
          "pi-coding-agent"
          "rofi"
          "starship"
          "sway"
          "swaylock"
          "throne"
          "vim"
          "waybar"
          "wayfile"
          "yazi"
          "zsh"
        ] (_: attrsOption)
        // {
          niri = desktopProgramOptions;
          noctalia = desktopProgramOptions // {
            recommendedServices = attrsOption;
            systemd = attrsOption;
          };
        };
      assertions = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [ ];
      };
    };
  # Supply a native configuration surface and inspect contributions, independently of root delivery.
  evaluate =
    modules: osConfig: packages:
    (lib.evalModules {
      specialArgs = {
        inherit osConfig;
        llib = { inherit types; };
        pkgs = packages;
      };
      modules = [ nativeOptions ] ++ modules;
    }).config;
  unusedSystem = throw "A disabled Feature must not read the system configuration";
  unusedPackages = throw "A disabled Feature must not read pkgs";
  contributions = config: builtins.removeAttrs config [ "features" ];
  empty = contributions (evaluate [ ] unusedSystem unusedPackages);
  disabled =
    name: module:
    let
      config = evaluate [ module ] unusedSystem unusedPackages;
    in
    lib.assertMsg (
      config.features.${name}.enable == false && contributions config == empty
    ) "Imported Feature ${name} must default to false and contribute no configuration.";
  editorSystem = evaluate [
    nixosModules.editor
    { features.editor.enable = true; }
  ] unusedSystem unusedPackages;
  existingDesktop = {
    programs.niri.enable = true;
    programs.noctalia.enable = true;
  };
  disabledDesktop = evaluate [
    homeModules.niri
    existingDesktop
    {
      features.niri.noctalia.enable = true;
      features.niri.waybar.enable = true;
    }
  ] unusedSystem unusedPackages;
  disabledAgent = evaluate [
    homeModules.agent
    { features.agent.pi.providers.deepseek.enable = true; }
  ] unusedSystem unusedPackages;
  disabledFileManager = evaluate [
    homeModules.file-manager
    {
      features.file-manager.fileChooser.enable = true;
      features.file-manager.wayfile.enable = true;
    }
  ] unusedSystem unusedPackages;
  systemShell = evaluate [
    nixosModules.shell
    { programs.zsh.enable = true; }
  ] unusedSystem featureTestPackages;
  shellModules = [
    homeModules.shell
    { features.shell.enable = true; }
  ];
  homeShell = evaluate shellModules systemShell featureTestPackages;
  missingShell = evaluate shellModules { } unusedPackages;
  missingNiri = evaluate [
    homeModules.niri
    {
      features.niri.enable = true;
      programs.niri.enable = false;
    }
  ] { } unusedPackages;
in
assert builtins.all (value: value) (lib.mapAttrsToList disabled nixosModules);
assert builtins.all (value: value) (lib.mapAttrsToList disabled homeModules);
assert builtins.length editorSystem.nixpkgs.overlays == 1;
assert
  contributions disabledDesktop
  == contributions (evaluate [ existingDesktop ] unusedSystem unusedPackages);
assert contributions disabledAgent == empty;
assert contributions disabledFileManager == empty;
assert !systemShell.features.shell.enable;
assert homeShell.programs.zsh.enable;
assert homeShell.programs.zsh.package == systemShell.features.shell.zshPackage;
assert !(builtins.head missingShell.assertions).assertion;
assert missingShell.programs == empty.programs;
assert !(builtins.head missingNiri.assertions).assertion;
assert missingNiri.programs == empty.programs;
runCommand "native-feature-enables" { } "touch $out"
