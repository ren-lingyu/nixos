{ config, lib, ... }: {
  imports = [
    ./options.nix
    ./aliyun
    ./matebook
    ./thinkbook
    ./wsl
  ];

  perSystem = { pkgs, ... }: {
    checks.host-registry = builtins.deepSeq (lib.mapAttrsToList (_: host: {
      inherit (host)
        number
        users
        monitors
        wireguard
        ;
    }) config.nixosBuilderArgs.hostRegistry) (pkgs.runCommand "nixos-host-registry" { } "touch $out");
  };
}
