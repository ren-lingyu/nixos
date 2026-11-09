{ extraArgs }: final_: unused_prev_: {
  pi-mono-context = final_.callPackage ./package.nix { src = extraArgs.sources.pi-mono-extensions; };
}
