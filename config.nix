{
  pkgs,
  pkgs-stable,
  wlib,
  lib,
  ...
}:
{
  imports = [ wlib.wrapperModules.neovim ];

  settings = {
    aliases = [
      # "vi"
      # "vim"
      "v"
    ];

    config_directory = lib.mkDefault ./.;
  };

  hosts = {
    ruby.nvim-host.enable = true;
    python3.nvim-host.enable = true;
    node.nvim-host.enable = true;
    perl.nvim-host.enable = true;
  };

  specs.bootstrap = {
    autoconfig = false;
    runtimeDeps = false;

    data = with pkgs.vimPlugins; [
      lazy-nvim
      plenary-nvim
    ];
  };

  runtimePkgs = with pkgs; [
    #
    # runtime dependencies
    #
    deadnix
    statix
    nixd
    nixfmt
    lazygit

    ripgrep
    fd
    fzf
    chafa
    tree-sitter
    clang

    # lua
    lua-language-server
    stylua

    prettierd
    oxfmt

    nushell

    # python
    black
    # pyright
    basedpyright
    ruff

    # go
    gopls
    gofumpt
    gotools
    golangci-lint

    # docker
    dockerfile-language-server
    docker-compose-language-service

    # webdev
    pkgs-stable.deno
    vscode-langservers-extracted
    svelte-language-server
    tailwindcss-language-server
    vue-language-server
    vtsls # typescript
    typescript-language-server
    javascript-typescript-langserver

    # rust
    rust-analyzer
    rustfmt
    lldb

    # clang
    clang-tools

    # swift
    sourcekit-lsp
    swift

    # random
    bash-language-server
    yaml-language-server

    # csharpier  # Disabled due to .NET build issues on macOS ARM64
    ktlint
    markdownlint-cli2
    rubocop
    shfmt
    pkgs-stable.sqlfluff

    # latex
    texlab

    # haskell
    # ghc
    # haskell-language-server
    fourmolu
    hlint
    pkgs.haskellPackages.cabal-fmt
    pkgs.haskellPackages.haskell-debug-adapter
  ];
}
