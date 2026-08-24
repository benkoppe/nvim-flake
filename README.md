# NeoVim Flake

My Neovim configuration, packaged with [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules).

## Test it out

Using flakes:

```console
nix run github:benkoppe/nvim-flake
nix run github:benkoppe/nvim-flake#full
nix run github:benkoppe/nvim-flake#minimal
```

## Profiles

The flake provides three packages built from the same Lua configuration:

| Package   | Commands                    | Intended use                                                 |
| --------- | --------------------------- | ------------------------------------------------------------ |
| `default` | `nvim`, `v`                 | Most features with common language tools bundled             |
| `full`    | `nvim`, `v`                 | Every plugin, language tool, debugger, formatter, and linter |
| `minimal` | `nvim-minimal`, `vi`, `vim` | Fast general editing with the same UI and editing experience |

Install either `default` or `full`, not both, because they intentionally provide the same `nvim` and `v` commands. Either one can be installed alongside `minimal`. A typical shell setup is:

```sh
export VISUAL=nvim
export EDITOR=vi
```

## To install

Add this flake as an input:

```nix
# flake.nix
{
  inputs = {
    nvim-flake = {
      url = "github:benkoppe/nvim-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
...
```

Add the output package to your environment:

```nix
# add system-wide
environment.systemPackages = [
  inputs.nvim-flake.packages.${pkgs.stdenv.hostPlatform.system}.full
  inputs.nvim-flake.packages.${pkgs.stdenv.hostPlatform.system}.minimal
];
# add per-user
users.users."<name>".packages = [
  inputs.nvim-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
  inputs.nvim-flake.packages.${pkgs.stdenv.hostPlatform.system}.minimal
];
```

In the same way, it can be added to `home-manager` or `nix-darwin` configurations.

## Inspiration

- [@Gerg-L](https://github.com/Gerg-L)'s [nvim-flake](https://github.com/Gerg-L/nvim-flake)
