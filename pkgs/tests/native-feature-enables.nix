{
  lib,
  pkgs,
  nixosModules,
  homeModules,
}:
let
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
  ] unusedSystem pkgs;
  shellModules = [
    homeModules.shell
    { features.shell.enable = true; }
  ];
  homeShell = evaluate shellModules systemShell pkgs;
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
pkgs.runCommand "native-feature-enables" { } "touch $out"
