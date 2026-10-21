final: prev: {

  difftastic = final.callPackage ./package.nix { difftastic = prev.difftastic; };

}
