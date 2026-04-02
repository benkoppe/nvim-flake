{
  description = "My nvim configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    mnw.url = "github:Gerg-L/mnw";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      perSystem =
        {
          pkgs,
          self',
          system,
          ...
        }:
        let
          pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${system};
        in
        {
          formatter = pkgs.writeShellApplication {
            name = "format";
            runtimeInputs = builtins.attrValues {
              inherit (pkgs)
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
          };

          packages = {
            default = inputs.mnw.lib.wrap { inherit pkgs pkgs-stable inputs; } ./config.nix;

            dev = self'.packages.default.devMode;
          };
        };

      flake.herculesCI = {
        ciSystems = [
          "x86_64-linux"
        ];
      };
    };
}
