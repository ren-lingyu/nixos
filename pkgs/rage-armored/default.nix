{ pkgs, lib } : (pkgs.rage.overrideAttrs
  (old_ : {
    postInstall = (builtins.concatStringsSep
      "\n"
      [
        (old_.postInstall or "")
        (lib.escapeShellArgs [
          "mv"
          "${builtins.placeholder "out"}/bin/rage"
          "${builtins.placeholder "out"}/bin/rage-unwrapped"
        ])
        (lib.escapeShellArgs [
          "install"
          "-Dm755"
          (pkgs.writeText
            "rage-armored-wrapper"
            (builtins.concatStringsSep "\n" [
              "#!${lib.getExe pkgs.guile} --no-auto-compile"
              "!#"
              "(define %rage-unwrapped \"@rage-unwrapped@\")"
              (builtins.readFile ./wrapper.scm)
            ]))
          "${builtins.placeholder "out"}/bin/rage"
        ])
        (lib.escapeShellArgs [
          "substituteInPlace"
          "${builtins.placeholder "out"}/bin/rage"
          "--replace-fail"
          "@rage-unwrapped@"
          "${builtins.placeholder "out"}/bin/rage-unwrapped"
        ])
      ]
    );
  })
)
