{ config, lib, pkgs, ... } : {

  home.packages = with pkgs; [
    nodejs
    python3
    go
    jdk
    lua
    julia
    lean4
    typescript
    
    nixd                              # Nix
    bash-language-server              # Shell
    clang-tools                       # C / C++ (clangd)
    gopls                             # Go
    jdt-language-server               # Java
    typescript-language-server        # TS / JS
    pyright                           # Python
    lua-language-server               # Lua
    marksman                          # Markdown
    yaml-language-server              # YAML
    taplo                             # TOML
    vscode-langservers-extracted      # HTML / CSS / JSON
    dockerfile-language-server        # Dockerfile
    sqls                              # SQL
    texlab                            # LaTeX
    lemminx                           # XML
    haskell-language-server           # Haskell

    shfmt                             # shell formatter
    stylua                            # Lua formatter
    nixfmt-rfc-style                  # Nix formatter
  ];

}
