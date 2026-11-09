{ extraArgs }: final_: prev_: {
  luadraw = final_.callPackage ./package.nix { src = extraArgs.sources.luadraw; };
}
