{
  description = "My nvim configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
          ...
        }:
        {
          formatter = pkgs.writeShellApplication {
            name = "format";
            runtimeInputs = builtins.attrValues {
              inherit (pkgs)
                nixfmt-rfc-style
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
              self'.packages.default
            ];
          };

          packages = {
            default = self'.packages.neovim;

            neovim = inputs.mnw.lib.wrap { inherit pkgs inputs; } ./config.nix;
          };
        };
    };
}
