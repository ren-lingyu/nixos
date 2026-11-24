feature_: { lib, ... }: {
  pi.providers = lib.genAttrs (import ../../../../pkgs/lib/agent-providers.nix) (provider: {
    enable = lib.mkOption {
      type = lib.types.bool;
      internal = true;
      readOnly = true;
      description = "Whether to enable the ${provider} provider for pi.";
    };

    apiKey = lib.mkOption {
      type = lib.types.nonEmptyStr;
      internal = true;
      readOnly = true;
      description = "Path to the file containing the ${provider} API key used by pi.";
    };
  });
}
