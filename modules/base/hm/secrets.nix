{
  config,
  options,
  osConfig,
  lib,
  llib,
  ...
}:
{
  options.secrets = lib.mkOption {
    type = llib.secrets.mkTreeType (
      loc:
      osConfig.age.secrets.${llib.secrets.userSecretName config.home.uid (lib.drop (builtins.length options.secrets.loc) loc)}.path
    );
    default = { };
    description = ''
      Tree of Account secrets delivered by OS agenix. Each leaf declares rekeyFile
      and exposes a read-only runtime path. No user-side decryption is performed.
    '';
  };
}
