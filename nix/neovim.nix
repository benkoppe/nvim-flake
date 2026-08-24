{
  config,
  options,
  pkgs,
  pkgs-stable,
  llm-pkgs,
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

    php_debug_adapter = "${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js";
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
      harpoon2
      mini-diff

      grug-far-nvim
      flash-nvim
      trouble-nvim
      todo-comments-nvim

      nui-nvim
      plenary-nvim
    ];

    runtimePkgs = with pkgs; [
      git
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
      cmp-git
      tailwind-tools-nvim
      luasnip
      friendly-snippets

      nvim-autopairs
      mini-comment
      nvim-ts-context-commentstring
      mini-surround
      yanky-nvim
      mini-hipatterns
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
          fish
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
          hyprlang
          ini
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
          printf
          prisma
          python
          query
          rasi
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
      shellcheck
      yaml-language-server
      texlab

      kotlin-language-server
      ocamlPackages.ocaml-lsp
      phpactor
      prisma-language-server
      taplo
      zls

      # .NET
      roslyn-ls
      fsautocomplete

      # Java
      jdt-language-server
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
      vimtex
      render-markdown-nvim
      markdown-preview-nvim
      cmake-tools-nvim
      clangd_extensions-nvim
      venv-selector-nvim
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
    ];

    runtimePkgs = with pkgs; [
      # rustaceanvim
      rust-analyzer
      rustfmt
      # VimTeX
      pplatex
      (texliveSmall.withPackages (tex: [
        tex.latexmk
      ]))
      # Markdown preview
      nodejs
      # CMake Tools
      cmake
      ninja
      # PHP
      php
      # Zig
      zig
      # .NET
      dotnet-sdk
      # Java
      jdk21
    ];
  };

  specs.debugging = {
    lazy = true;
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      nvim-nio
      nvim-dap-go
      nvim-dap-python
    ];

    runtimePkgs = with pkgs; [
      # Rust, C, C++
      vscode-extensions.vadimcn.vscode-lldb.adapter

      # Go
      delve

      # Python
      python3Packages.debugpy

      # JS and TS
      vscode-js-debug
      nodejs
      tsx

      # Haskell
      haskellPackages.ghc
      haskellPackages.haskell-debug-adapter
      haskellPackages.ghci-dap
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
      ocamlPackages.ocamlformat
      phpPackages.php-cs-fixer
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
      phpPackages.php-codesniffer
    ];
  };

  specs.ai = {
    lazy = true;
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      opencode-nvim
    ];

    runtimePkgs =
      with pkgs;
      [
        llm-pkgs.opencode
        curl
        lsof
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        pkgs.procps
      ];
  };
}
