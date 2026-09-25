final : prev : let

  lib = prev.lib;

  extraTexlivePackages_ = (lib.filterAttrs
    (name_ : unused_package_ :
      !(builtins.hasAttr name_ prev.texlivePackages)
    )
    final.texlivePackages
  );

  extendTexlivePackageSet_ = ps_ : (lib.mergeAttrsList [
    ps_
    extraTexlivePackages_
  ]);

  wrapTexliveEnv_ = texliveEnv_ : (
    if (builtins.all
      (x_ : x_)
      [
        (builtins.isAttrs texliveEnv_)
        (texliveEnv_ ? withPackages)
      ]
    )
    then (lib.mergeAttrsList [
      texliveEnv_
      {
        withPackages = f_ : texliveEnv_.withPackages
          (ps_ : f_ (extendTexlivePackageSet_ ps_));
      }
    ])
    else texliveEnv_
  );

  texliveEnvNames_ = [
    "texliveBasic"
    "texliveBookPub"
    "texliveConTeXt"
    "texliveFull"
    "texliveGUST"
    "texliveInfraOnly"
    "texliveMedium"
    "texliveMinimal"
    "texliveSmall"
    "texliveTeTeX"
  ];

  wrappedTexliveEnvs_ = builtins.listToAttrs (
    builtins.map
      (name_ : {
        name = name_;
        value = wrapTexliveEnv_ prev.${name_};
      })
      (builtins.filter
        (name_ : builtins.hasAttr name_ prev)
        texliveEnvNames_
      )
  );

in (lib.mergeAttrsList [

  wrappedTexliveEnvs_

  {
    texlive = (lib.mergeAttrsList [
      prev.texlive
      {
        withPackages = f_ : prev.texlive.withPackages
          (ps_ : f_ (extendTexlivePackageSet_ ps_));

        combined = (lib.mergeAttrsList [
          prev.texlive.combined
          (lib.mapAttrs
            (unused_name_ : texliveEnv_ :
              wrapTexliveEnv_ texliveEnv_
            )
            prev.texlive.combined
          )
        ]);
      }
    ]);
  }

])
