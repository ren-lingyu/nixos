{ config, osConfig ? config } : rec {

  fromStructure = { ... }@attrs: let
    go = prefix : value : (
      if builtins.isList value
      then (
        if value == []
        then
          [ prefix ]
        else (
          builtins.map (x : prefix ++ [ x ]) value
        )
      )
      else (
        if
          builtins.isAttrs value
        then
          builtins.concatMap (x : go (prefix ++ [x]) value.${x}) (builtins.attrNames value)
        else
          []
      )
    );
  in go [] attrs;

  # Convert path component lists into sops-nix name/value attributes.
  fromTemplates = let
    origin = { pathPrefix, attrs ? {} } : list : { ... }@overlayAttrs : builtins.map (x : let
        nameString = builtins.concatStringsSep "." x;
        keyString = builtins.concatStringsSep "/" x;
      in {
        name = nameString;
        value = {
          name = nameString;
          key = keyString;
          mode = "0400";
          path = "${pathPrefix}/${nameString}";
          format = config.sops.defaultSopsFormat;
          sopsFile = config.sops.defaultSopsFile;
        } // attrs // overlayAttrs;
      }) list;
  in {
    default = origin {};
    system = origin {
      pathPrefix = "/run/secrets";
      attrs = {
        neededForUsers = false;
        uid = 0;
        gid = 0;
      };
    };
    user = origin {
      pathPrefix = "/run/user/${builtins.toString config.home.uid}/secrets";
    };
  };

  mkSopsSecrets = attrsList : let
    fun = { template ? "default", structure ? {}, overlay ? {} } : fromTemplates.${template} (fromStructure structure) overlay;
  in builtins.listToAttrs (
    builtins.concatLists (
      # Ignore non-attribute entries so optional fragments can share one input list.
      builtins.map (x : fun x) (builtins.filter builtins.isAttrs attrsList)
    )
  );

}
