{
  stdenv,
} : (import
  (builtins.fetchTree {
    type = "git";
    url = "https://github.com/NixOS/nixpkgs.git";
    rev = "363fdbe57ed052c76e816e6270206b0cb348e53a";
    shallow = true;
  })
  {
    system = stdenv.hostPlatform.system;
  }
).zotero
