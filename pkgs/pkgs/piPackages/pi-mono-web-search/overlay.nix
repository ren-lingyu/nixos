{ extraArgs }: final_: unused_prev_: {
  pi-mono-web-search = final_.callPackage ./package.nix {
    src = extraArgs.sources.pi-mono-extensions;
  };
}
