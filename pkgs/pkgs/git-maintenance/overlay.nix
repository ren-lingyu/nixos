{ extraArgs }: final_: prev_: {
  git-maintenance = final_.callPackage ./package.nix {
    haskellPackages = final_.haskell.packages.ghc912;
    inherit (extraArgs.sources) keep-a-changelog semver-org;
  };
}
