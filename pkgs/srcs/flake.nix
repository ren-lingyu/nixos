{
  inputs = {
    keep-a-changelog = {
      url = "git+https://github.com/olivierlacan/keep-a-changelog.git?rev=5417981223f2e87fb2c94e9c57a6c0b011447306&shallow=1";
      flake = false;
    };
    semver-org = {
      url = "git+https://github.com/semver/semver.org.git?rev=839c747aeb15078beea00dbe93a84f2c0fd39878&shallow=1";
      flake = false;
    };
    wayfile = {
      url = "git+https://github.com/blackbartblues/Wayfile.git?rev=e03db0c44d84aab3d3d67f6ae4b8fb6f9b3ae482&shallow=1&submodules=1";
      flake = false;
    };
    luadraw = {
      url = "git+https://github.com/pfradin/luadraw.git?rev=eba63b144ba788209191a611f461cd65a5e8935a&shallow=1";
      flake = false;
    };
    pi-agentic-search = {
      url = "git+https://github.com/dantetekanem/pi-agentic-search.git?rev=fda2434bdfc9ffc810c145f66dc552c2464f1614&shallow=1";
      flake = false;
    };
    pi-mono-extensions = {
      url = "git+https://github.com/emanuelcasco/pi-mono-extensions.git?rev=e4e047a5a203cac78f5e420c92a3115ccd2fe6bb&shallow=1";
      flake = false;
    };
    pi-workspace-history = {
      url = "git+https://github.com/wcldyx/pi-workspace-history.git?rev=4c51d3cad723bd8733c73fb36f4b971efb2eb53a&shallow=1";
      flake = false;
    };
  };

  outputs = _: { };
}
