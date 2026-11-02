{ }: final_: prev_: {
  lem-webview = prev_.lem-webview.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      install -Dm644 \
        ${old.src}/scripts/install/lem-webview.desktop \
        $out/share/applications/lem.desktop

      substituteInPlace $out/share/applications/lem.desktop \
        --replace-fail "/usr/local/bin/lem -i webview" \
          "${final_.lib.getExe prev_.lem-webview}"

      install -Dm644 \
        ${old.src}/scripts/install/lem.svg \
        $out/share/icons/hicolor/scalable/apps/lem.svg
    '';
  });
}
