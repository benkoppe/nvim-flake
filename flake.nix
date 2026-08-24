{
  description = "My nvim configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          pkgs,
          self',
          system,
          ...
        }:
        let
          pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${system};
          llm-pkgs = inputs.llm-agents.packages.${system};
          profiles = import ./nix/profiles.nix;

          neovimModules = [
            ./nix/neovim.nix
            {
              inherit pkgs;
              _module.args = {
                inherit (inputs) self;
                inherit pkgs-stable;
                inherit llm-pkgs;
              };
            }
          ];

          evalNeovim = profile: inputs.nix-wrapper-modules.lib.evalPackage (neovimModules ++ [ profile ]);
        in
        {
          formatter = pkgs.writeShellApplication {
            name = "format";
            runtimeInputs = builtins.attrValues {
              inherit (pkgs-stable)
                nixfmt
                deadnix
                statix
                fd
                stylua
                ;
            };
            text = ''
              fd "$@" -t f -e nix -x statix fix -- '{}'
              fd "$@" -t f -e nix -X deadnix -e -- '{}' \; -X nixfmt '{}'
              fd "$@" -t f -e lua -X stylua --indent-type Spaces --indent-width 2 '{}'
            '';
          };

          devShells.default = pkgs.mkShellNoCC {
            packages = [
              self'.formatter
              (pkgs.writeShellScriptBin "dev" "exec ${self'.packages.dev}/bin/nvim \"$@\"")
            ];

            shellHook = ''
              export NVIM_FLAKE_CONFIG="$PWD"
            '';
          };

          packages = {
            default = evalNeovim profiles.default;
            full = evalNeovim profiles.full;
            minimal = evalNeovim profiles.minimal;

            dev = inputs.nix-wrapper-modules.lib.evalPackage (
              neovimModules
              ++ [
                profiles.full
                ({ lib, ... }: {
                  settings.config_directory = lib.mkForce (
                    lib.generators.mkLuaInline ''
                      assert(vim.env.NVIM_FLAKE_CONFIG, "NVIM_FLAKE_CONFIG is not set")
                    ''
                  );
                })
              ]
            );
          };
        };

      flake.herculesCI = {
        ciSystems = [
          "x86_64-linux"
        ];
      };
    };
}
