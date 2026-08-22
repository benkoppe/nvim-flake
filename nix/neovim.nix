{
  config,
  options,
  pkgs,
  pkgs-stable,
  wlib,
  lib,
  ...
}:
{
  imports = [ wlib.wrapperModules.neovim ];

  specMods = {
    options.runtimePkgs = options.runtimePkgs // {
      description = ''
        Runtime packages associated with this plugin spec.
        Packages are included only when the spec is enabled.
      '';
    };
  };

  runtimePkgs = config.specCollect (packages: spec: packages ++ (spec.runtimePkgs or [ ])) [ ];

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

    runtimePkgs = with pkgs; [
      ripgrep
      fd
      fzf
      chafa
      lazygit
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

    runtimePkgs = with pkgs; [
      nixd
      lua-language-server
      nushell
      basedpyright
      ruff
      gopls
      dockerfile-language-server
      docker-compose-language-service
      deno
      vscode-langservers-extracted
      svelte-language-server
      tailwindcss-language-server
      vue-language-server
      vtsls
      clang-tools
      sourcekit-lsp
      swift
      bash-language-server
      yaml-language-server
      texlab
    ];
  };

  specs.languages = {
    lazy = true;
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      SchemaStore-nvim
      crates-nvim
      rustaceanvim
    ];

    runtimePkgs = with pkgs; [
      # rustaceanvim
      rust-analyzer
      rustfmt
      lldb

      haskellPackages.haskell-debug-adapter
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

    runtimePkgs = with pkgs; [
      nixfmt
      stylua
      prettierd
      oxfmt
      black
      gofumpt
      gotools
      fourmolu
      pkgs.haskellPackages.cabal-fmt
      ktlint
      rubocop
      shfmt
      sqlfluff
    ];
  };

  specs.linting = {
    lazy = true;
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      nvim-lint
    ];

    runtimePkgs = with pkgs; [
      deadnix
      statix
      go
      golangci-lint
      hlint
      markdownlint-cli2
    ];
  };
}
