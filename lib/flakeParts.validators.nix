{ lib, discoverValidatorFiles }: {
  mkValidatorApplications =
    { modules, llib }:
    let
      validators =
        builtins.map
          (
            entry:
            let
              imported = import entry.file;
              declaration = imported { inherit (entry) path; };
              valid =
                builtins.isFunction imported
                && builtins.isAttrs declaration
                && builtins.all (
                  branch:
                  builtins.elem branch [
                    "metadata"
                    "configuration"
                  ]
                  && builtins.isFunction declaration.${branch}
                ) (builtins.attrNames declaration);
            in
            entry
            // {
              branches =
                if valid then
                  declaration
                else
                  throw "Invalid FP validator declaration in ${toString entry.file}: expected a function returning optional metadata/configuration functions.";
            }
          )
          (discoverValidatorFiles {
            inherit modules;
          });
      validate =
        branch: args:
        builtins.all (
          validator:
          let
            context =
              "FP validator ${toString validator.file}, branch ${branch}"
              + lib.optionalString (branch == "configuration") " (system ${args.name})";
            result = validator.branches.${branch} (args // { inherit lib llib; });
          in
          builtins.addErrorContext context (
            if !(builtins.hasAttr branch validator.branches) then
              true
            else if !builtins.isBool result then
              throw "${context}: expected a boolean result."
            else if result then
              true
            else
              throw "${context}: validation returned false."
          )
        ) validators;
    in
    {
      moduleRegistry =
        registry:
        assert validate "metadata" { inherit registry; };
        registry;
      nixosConfigurations =
        registry: configurations:
        lib.mapAttrs (
          name: configuration:
          assert validate "configuration" { inherit name configuration registry; };
          configuration
        ) configurations;
    };
}
