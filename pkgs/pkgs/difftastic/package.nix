{
  difftastic,
  lib,
  fetchpatch2,
  rustPlatform,
}:
let

  fixHaskellParser = fetchpatch2 {
    url = "https://github.com/Wilfred/difftastic/commit/c64ad0a587563af2018ce9bd47590740a606043f.diff?full_index=1";
    includes = [
      "Cargo.toml"
      "Cargo.lock"
    ];
    hash = "sha256-6VK/xKFK7/lPKVhNprnIOgQvAZPv48Z6JZBWEvi1H/8=";
  };

in
difftastic.overrideAttrs (
  finalAttrs: old: {

    patches = (old.patches or [ ]) ++ [ fixHaskellParser ];

    cargoHash = "sha256-m3LCB5FHDPxgOciPDDa1jwqJ5l3hiB5oWqNhGgcdktU=";

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (old) pname version src;
      patches = (old.cargoPatches or [ ]) ++ [ fixHaskellParser ];
      hash = finalAttrs.cargoHash;
    };

  }
)
