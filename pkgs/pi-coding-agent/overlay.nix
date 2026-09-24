final : prev : {

  pi-coding-agent = final.callPackage ./package.nix {
    pi-coding-agent = prev.pi-coding-agent;
  };

}
