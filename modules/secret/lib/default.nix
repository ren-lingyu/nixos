{ config, osConfig ? config } : rec {

  fromStructure = { ... }@attrs: let
    go = prefix : value : (
      if builtins.isList value
      then (
        if value == []
        then
          [ prefix ]
        else (
          map (x: prefix ++ [ x ]) value
        )
      )
      else (
        if
          builtins.isAttrs value
        then
          builtins.concatMap (x: go (prefix ++ [x]) value.${x}) (builtins.attrNames value)
        else
          []
      )
    );
  in go [] attrs;

  # 这个函数的第一个参数应当是一个列表, 其中每个元素都是一个字符串的列表.
  fromTemplates = let
    # 这里用到了柯里化
    origin = { pathPrefix, attrs ? {} } : list : { ... }@overlayAttrs : map (x: let
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
    user = let
      uid = osConfig.users.users.${config.home.username}.uid;
    in origin {
      pathPrefix = "/run/user/${builtins.toString uid}/secrets";
    };
  };

  mkSopsSecrets = attrsList : let
    # 这是一个辅助函数.
    fun = { template ? "default", structure ? {}, overlay ? {} } : fromTemplates.${template} (fromStructure structure) overlay;
  in builtins.listToAttrs (
    builtins.concatLists (
      # 确保列表作为输入参数时, 只有作为属性集的列表元素才有效.
      map (x: fun x) (builtins.filter builtins.isAttrs attrsList)
    )
  );

}
