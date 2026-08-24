{
  config,
  options,
  pkgs,
  llm-pkgs,
  wlib,
  lib,
  profile,
  ...
}:
{
  imports = [ wlib.wrapperModules.neovim ];

  specMods = {
    options.lspServers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "LSP servers associated with this plugin spec.";
    };

    options.runtimePkgs = options.runtimePkgs // {
      description = ''
        Runtime packages associated with this plugin spec.
        Packages are included only when the spec is enabled.
      '';
    };
  };

  runtimePkgs = config.specCollect (packages: spec: packages ++ (spec.runtimePkgs or [ ])) [ ];

  info.specs = builtins.mapAttrs (_: spec: spec.enable) config.specs;

  settings = {
    config_directory = lib.mkDefault ../.;

    profile = profile.name;

    php_debug_adapter = lib.mkIf profile.developmentFeatures "${pkgs.vscode-extensions.xdebug.php-debug}/share/vscode/extensions/xdebug.php-debug/out/phpDebug.js";

    java_debug_bundles = lib.mkIf profile.developmentFeatures "${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar";

    java_test_bundles = lib.mkIf profile.developmentFeatures "${pkgs.vscode-extensions.vscjava.vscode-java-test}/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar";

    lsp_servers = config.specCollect (servers: spec: servers ++ (spec.lspServers or [ ])) [ ];
  };

  hosts = {
    ruby.nvim-host.enable = profile.developmentFeatures;
    python3.nvim-host.enable = profile.developmentFeatures;
    node.nvim-host.enable = profile.developmentFeatures;
    perl.nvim-host.enable = profile.developmentFeatures;
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
    enable = profile.developmentFeatures;
    lazy = true;
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      nvim-lspconfig
      lazydev-nvim
      inc-rename-nvim
    ];

    lspServers = [
      "basedpyright"
      "bashls"
      "cssls"
      "denols"
      "docker_compose_language_service"
      "dockerls"
      "gopls"
      "html"
      "jsonls"
      "nixd"
      "nushell"
      "ruff"
      "svelte"
      "tailwindcss"
      "vtsls"
      "vue_ls"
      "yamlls"
    ]
    ++ lib.optionals profile.extendedTools [
      "clangd"
      "fsautocomplete"
      "kotlin_language_server"
      "ocamllsp"
      "phpactor"
      "prismals"
      "rubocop"
      "sourcekit"
      "taplo"
      "texlab"
      "zls"
    ];

    runtimePkgs =
      with pkgs;
      [
        # Nix
        nixd

        # Lua
        lua-language-server

        # Nushell
        nushell

        # Python
        basedpyright
        ruff

        # Go
        gopls

        # Containers
        dockerfile-language-server
        docker-compose-language-service

        # Web
        deno
        vscode-langservers-extracted
        svelte-language-server
        tailwindcss-language-server
        vue-language-server
        vtsls

        # Shell
        bash-language-server

        # Data formats
        yaml-language-server
      ]
      ++ lib.optionals profile.extendedTools [
        # C, C++
        clang-tools

        # Swift
        sourcekit-lsp
        swift

        # TeX
        texlab

        # Kotlin
        kotlin-language-server

        # OCaml
        ocamlPackages.ocaml-lsp

        # PHP
        phpactor

        # Ruby
        rubocop

        # Prisma
        prisma-language-server

        # TOML
        taplo

        # Zig
        zls

        # .NET
        roslyn-ls
        fsautocomplete

        # Java
        jdt-language-server
      ];
  };

  specs.languages = {
    enable = profile.developmentFeatures;
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
      roslyn-nvim
      nvim-jdtls
    ];

    runtimePkgs =
      with pkgs;
      [
        # rustaceanvim
        rust-analyzer
        rustfmt

        # Markdown preview
        nodejs
      ]
      ++ lib.optionals profile.extendedTools [
        # VimTeX
        pplatex
        (texliveSmall.withPackages (tex: [
          tex.latexmk
        ]))

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
    enable = profile.developmentFeatures;
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

    runtimePkgs =
      with pkgs;
      [
        # Go
        delve

        # Python
        python3Packages.debugpy

        # JS and TS
        vscode-js-debug
        nodejs
        tsx
      ]
      ++ lib.optionals profile.extendedTools [
        # Rust, C, C++
        vscode-extensions.vadimcn.vscode-lldb.adapter

        # Haskell
        haskellPackages.ghc
        (haskell.lib.justStaticExecutables haskellPackages.haskell-debug-adapter)
        haskellPackages.ghci-dap

        # .NET
        netcoredbg
      ];
  };

  specs.formatting = {
    enable = profile.developmentFeatures;
    lazy = true;
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      conform-nvim
    ];

    runtimePkgs =
      with pkgs;
      [
        # Nix
        nixfmt

        # Lua
        stylua

        # Web
        prettierd
        oxfmt

        # Python
        black

        # Go
        gofumpt
        gotools

        # Shell
        shfmt
      ]
      ++ lib.optionals profile.extendedTools [
        # Haskell
        fourmolu
        haskellPackages.cabal-fmt

        # Kotlin
        ktlint

        # Ruby
        rubocop

        # SQL
        sqlfluff

        # OCaml
        ocamlPackages.ocamlformat

        # PHP
        phpPackages.php-cs-fixer

        # .NET
        csharpier
        fantomas

        # Zig
        zig
      ];
  };

  specs.linting = {
    enable = profile.developmentFeatures;
    lazy = true;
    autoconfig = false;
    runtimeDeps = false;
    pluginDeps = false;

    data = with pkgs.vimPlugins; [
      nvim-lint
    ];

    runtimePkgs =
      with pkgs;
      [
        # Nix
        deadnix
        statix

        # Markdown
        markdownlint-cli2

        # Shell
        shellcheck
      ]
      ++ lib.optionals profile.extendedTools [
        # Go
        go
        golangci-lint

        # Haskell
        hlint

        # PHP
        phpPackages.php-codesniffer

        # Kotlin
        ktlint

        # SQL
        sqlfluff
      ];
  };

  specs.ai = {
    enable = profile.developmentFeatures;
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
