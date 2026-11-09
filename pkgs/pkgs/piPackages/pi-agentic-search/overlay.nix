{ extraArgs }: final_: unused_prev_: {
  pi-agentic-search = final_.callPackage ./package.nix { src = extraArgs.sources.pi-agentic-search; };
}
