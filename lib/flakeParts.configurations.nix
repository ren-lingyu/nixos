{ lib, moduleTools }: rec {

  # Adapt only functions explicitly declared with functionTo; do not inspect Nix values
  # to guess whether arbitrary functions, packages or overlays should be called.
  adaptType =
    type: value: scope:
    if type.name == "functionTo" then
      adaptType type.nestedTypes.elemType (value scope) scope
    else if type.name == "submodule" then
      adaptOptions (type.getSubOptions [ ]) value scope
    else
      value;

  adaptOptions =
    options: values: scope:
    builtins.mapAttrs (
      name: value:
      if lib.isOption options.${name} then
        adaptType options.${name}.type value scope
      else
        adaptOptions options.${name} value scope
    ) values;

  moduleConfiguration =
    descriptor: systemConfiguration: registry: scope:
    assert lib.assertMsg (
      lib.intersectLists (builtins.attrNames (lib.getAttrFromPath (lib.drop 1 descriptor.path) systemConfiguration.modules)) (
        builtins.attrNames (lib.getAttrFromPath (lib.drop 1 descriptor.path) registry).metadata
      ) == [ ]
    ) "Configuration and metadata must have disjoint fields for ${lib.showOption descriptor.path}.";
    lib.mergeAttrsList [
      (adaptType (lib.getAttrFromPath (lib.drop 1 descriptor.path) systemConfiguration.moduleOptions).type
        (lib.getAttrFromPath (lib.drop 1 descriptor.path) systemConfiguration.modules)
        scope
      )
      (lib.getAttrFromPath (lib.drop 1 descriptor.path) registry).metadata
    ];

  assembledModules =
    descriptors: systemConfiguration: registry: scope:
    lib.foldl' (
      result: descriptor:
      lib.recursiveUpdate result (
        lib.setAttrByPath (lib.drop 1 descriptor.path) (
          moduleConfiguration descriptor systemConfiguration registry scope
        )
      )
    ) { } descriptors;

  enabledModules =
    descriptors: systemConfiguration:
    builtins.filter (
      descriptor: (lib.getAttrFromPath (lib.drop 1 descriptor.path) systemConfiguration.modules).enable
    ) descriptors;

  homeUserModules =
    descriptors: systemConfiguration: registry:
    builtins.mapAttrs (unused_uid: imports: { inherit imports; }) (
      lib.foldl' (
        byUid: descriptor:
        builtins.foldl'
          (
            previous: uid:
            lib.recursiveUpdate previous {
              "${builtins.toString uid}" = builtins.concatLists [
                (previous.${builtins.toString uid} or [ ])
                (lib.optional (descriptor.hm != null) descriptor.hm)
                (lib.getAttrFromPath (lib.drop 1 descriptor.path) registry).homeModules
              ];
            }
          )
          byUid
          (
            if (builtins.elemAt descriptor.path 1) == "features" then
              (lib.getAttrFromPath (lib.drop 1 descriptor.path) systemConfiguration.modules).allowUidList
            else if (builtins.elemAt descriptor.path 1) == "users" then
              lib.optional (
                (lib.getAttrFromPath (lib.drop 1 descriptor.path) systemConfiguration.modules).uid != null
              ) (lib.getAttrFromPath (lib.drop 1 descriptor.path) systemConfiguration.modules).uid
            else
              [ ]
          )
      ) { } descriptors
    );

  categoryModules =
    rootPath: descriptors:
    builtins.filter builtins.pathExists (
      lib.unique (
        builtins.map (
          descriptor: rootPath + "/modules/${builtins.elemAt descriptor.path 1}/default.nix"
        ) descriptors
      )
    );

  mkNixosSystem =
    {
      rootPath,
      builder,
      registry,
      systemConfiguration,
    }:
    let
      descriptors = moduleTools.discoverModules rootPath (rootPath + "/modules");
      enabled = enabledModules descriptors systemConfiguration;
    in
    builder.nixosSystem {
      inherit (systemConfiguration) system;
      specialArgs = lib.mergeAttrsList [
        builder.specialArgs
        systemConfiguration.specialArgs
      ];
      modules = builtins.concatLists [
        [
          builder.homeManager
          (
            {
              config,
              pkgs,
              lib,
              ...
            }:
            {
              options.modules = lib.mkOption {
                type = lib.types.raw;
                readOnly = true;
                internal = true;
                description = "Resolved flake-parts configuration and registry metadata.";
              };
              config = {
                modules = assembledModules descriptors systemConfiguration registry (
                  lib.mergeAttrsList [
                    { inherit config pkgs lib; }
                    builder.specialArgs
                    systemConfiguration.specialArgs
                  ]
                );
                nixpkgs.overlays = builtins.concatMap (
                  descriptor: (lib.getAttrFromPath (lib.drop 1 descriptor.path) registry).nixpkgsOverlays
                ) enabled;
                home-manager = {
                  extraSpecialArgs = lib.mergeAttrsList [
                    builder.specialArgs
                    systemConfiguration.specialArgs
                  ];
                  sharedModules = builtins.concatMap (
                    descriptor:
                    lib.optionals
                      (
                        !builtins.elem (builtins.elemAt descriptor.path 1) [
                          "features"
                          "users"
                        ]
                      )
                      (
                        builtins.concatLists [
                          (lib.optional (descriptor.hm != null) descriptor.hm)
                          (lib.getAttrFromPath (lib.drop 1 descriptor.path) registry).homeModules
                        ]
                      )
                  ) enabled;
                  users = homeUserModules enabled systemConfiguration registry;
                };
              };
            }
          )
        ]
        (categoryModules rootPath descriptors)
        (builtins.concatMap (
          descriptor:
          builtins.concatLists [
            (lib.optional (descriptor.os != null) descriptor.os)
            (lib.optional (builtins.pathExists (descriptor.module + "/default.nix")) (
              descriptor.module + "/default.nix"
            ))
            (lib.getAttrFromPath (lib.drop 1 descriptor.path) registry).nixosModules
          ]
        ) enabled)
      ];
    };

  mkNixosConfigurations =
    {
      rootPath,
      builder,
      registry,
      configurations,
    }:
    lib.mapAttrs (
      unused_name: systemConfiguration:
      mkNixosSystem {
        inherit
          rootPath
          builder
          registry
          systemConfiguration
          ;
      }
    ) configurations;

}
