{ extraArgs }: final_: unused_prev_: {
  pi-workspace-history = final_.callPackage ./package.nix {
    src = extraArgs.sources.pi-workspace-history;
  };
}
