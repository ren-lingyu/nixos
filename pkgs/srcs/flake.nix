{
  inputs = {
    keep-a-changelog = {
      url = "git+https://github.com/olivierlacan/keep-a-changelog.git?ref=refs/heads/main&shallow=1";
      flake = false;
    };
    semver-org = {
      url = "git+https://github.com/semver/semver.org.git?ref=refs/heads/gh-pages&shallow=1";
      flake = false;
    };
    wayfile = {
      url = "git+https://github.com/blackbartblues/Wayfile.git?ref=refs/heads/main&shallow=1&submodules=1";
      flake = false;
    };
    luadraw = {
      url = "git+https://github.com/pfradin/luadraw.git?ref=refs/heads/main&shallow=1";
      flake = false;
    };
    pi-agentic-search = {
      url = "git+https://github.com/dantetekanem/pi-agentic-search.git?ref=refs/heads/main&shallow=1";
      flake = false;
    };
    pi-mono-extensions = {
      url = "git+https://github.com/emanuelcasco/pi-mono-extensions.git?ref=refs/heads/main&shallow=1";
      flake = false;
    };
    pi-workspace-history = {
      url = "git+https://github.com/wcldyx/pi-workspace-history.git?ref=refs/heads/main&shallow=1";
      flake = false;
    };
  };

  outputs = _: { };
}
