{

  lib,
  stdenv,
  fetchFromGitHub,

  cmake,
  ninja,
  pkg-config,

  qt6,
  glib,
  gtk3,
  xdg-utils,
  git,

  fd,
  rsync,
  wl-clipboard,

  zip,
  unzip,
  gnutar,
  gzip,
  xz,
  bzip2,
  p7zip,
  libarchive,

} : stdenv.mkDerivation rec {

  pname = "wayfile";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "blackbartblues";
    repo = "Wayfile";
    # Fixed to the commit corresponding to the packaged upstream snapshot.
    rev = "e03db0c44d84aab3d3d67f6ae4b8fb6f9b3ae482";
    # Wayfile uses a git submodule for qml icons.
    fetchSubmodules = true;
    hash = "sha256-zwPvFQCNXyqCfscfDtpF88Aal9Ho+3WsIdDaOQ/kNzg=";
  };

  nativeBuildInputs = [
    # Upstream uses CMake with the Ninja generator.
    cmake
    ninja
    # Used by CMake to find gio-2.0 and gio-unix-2.0.
    pkg-config
    # Wraps the Qt application so that Qt plugins and QML imports are found at runtime.
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    # Provides gio-2.0 and gio-unix-2.0.
    glib
    # Qt modules required by upstream CMakeLists.txt.
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtsvg
    qt6.qtmultimedia
    # Required at runtime for Qt on Wayland.
    qt6.qtwayland
  ];

  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [

      # MIME and external application integration:
      # - gio open
      # - gtk-launch
      # - xdg-mime / xdg-open
      glib
      gtk3
      xdg-utils

      # Used for git status badges / repository information.
      git

      # Runtime helpers used by Wayfile for search and file transfers.
      fd
      rsync

      # Optional Wayland clipboard helper. Wayfile can use wl-paste as a
      # fallback when pasting image data copied from external applications.
      wl-clipboard

      # Archive support. Wayfile calls external tools for compressing and
      # extracting common archive formats.
      zip
      unzip
      gnutar
      gzip
      xz
      bzip2
      p7zip
      libarchive

    ]}"
  ];

  cmakeFlags = [
    # Avoid pulling in the test target and its additional Qt test dependency.
    "-DBUILD_TESTS=OFF"
    # Upstream defaults this to the source tree. In Nix, runtime data should be looked up from the installed output instead.
    "-DWAYFILE_DATA_DIR=${builtins.placeholder "out"}/share/wayfile"
  ];

  postInstall = builtins.concatStringsSep "\n" [
    # The generated Wayfile QML module misses this helper script, although it is installed in the copied source QML tree.
    "install -Dm644 \"$out/share/wayfile/src/qml/views/DropParse.js\" \"$out/share/wayfile/Wayfile/qml/views/DropParse.js\""
  ];

  meta = {
    description = "Qt6/QML file manager for Wayland";
    homepage = "https://github.com/blackbartblues/Wayfile";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "wayfile";
  };

}
