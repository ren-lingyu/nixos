final_ : prev_ : {

  pi-coding-agent = final_.callPackage ./package.nix {
    pi-coding-agent = prev_.pi-coding-agent;
  };

}
