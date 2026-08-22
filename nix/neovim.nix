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

    config_directory = lib.mkDefault ../.;
  };

  hosts = {
    ruby.nvim-host.enable = true;
    python3.nvim-host.enable = true;
    node.nvim-host.enable = true;
    perl.nvim-host.enable = true;
  };

  specs.foundation = {
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      lze
      lzextras

      mini-icons
      snacks-nvim
      tokyonight-nvim
    ];
  };

  specs.editor = {
    lazy = true;
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      fzf-lua
      neo-tree-nvim
      lualine-nvim
      which-key-nvim
      persistence-nvim

      nui-nvim
      plenary-nvim
    ];
  };

  specs.coding = {
    lazy = true;
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp_luasnip
      luasnip
      friendly-snippets

      nvim-autopairs
      mini-comment
      nvim-ts-context-commentstring
      mini-surround
      yanky-nvim
    ];
  };

  specs.treesitter = {
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (
        parsers: with parsers; [
          bash
          bibtex
          c
          c_sharp
          cmake
          cpp
          diff
          dockerfile
          fsharp
          git_config
          git_rebase
          gitattributes
          gitcommit
          gitignore
          go
          gomod
          gosum
          gowork
          haskell
          html
          java
          javascript
          jsdoc
          json
          json5
          kotlin
          latex
          lua
          luadoc
          luap
          markdown
          markdown_inline
          ninja
          nix
          nu
          ocaml
          php
          prisma
          printf
          python
          query
          regex
          ron
          rst
          ruby
          rust
          sql
          svelte
          toml
          tsx
          typescript
          vim
          vimdoc
          xml
          yaml
          zig
        ]
      ))
      nvim-treesitter-textobjects
      nvim-treesitter-context
      nvim-ts-autotag
      mini-ai
    ];
  };

  specs.lsp = {
    lazy = true;
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      nvim-lspconfig
      lazydev-nvim
      inc-rename-nvim
    ];
  };

  specs.formatting = {
    lazy = true;
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      conform-nvim
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
