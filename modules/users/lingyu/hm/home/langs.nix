{ config, lib, pkgs, ... } : {

  home.packages = with pkgs; [
    bash-language-server              # Shell
    clang-tools                       # C / C++ (clangd)
    dockerfile-language-server        # Dockerfile
    go
    gopls                             # Go
    guile
    haskell-language-server           # Haskell
    jdk
    jdt-language-server               # Java
    julia
    lean4
    lemminx                           # XML
    lua
    lua-language-server               # Lua
    marksman                          # Markdown
    nixd                              # Nix
    nixfmt                            # Nix formatter
    nodejs
    pyright                           # Python
    python3
    sbcl
    shfmt                             # shell formatter
    sqls                              # SQL
    stylua                            # Lua formatter
    taplo                             # TOML
    texlab                            # LaTeX
    typescript
    typescript-language-server        # TS / JS
    vscode-langservers-extracted      # HTML / CSS / JSON
    yaml-language-server              # YAML
  ];

}
