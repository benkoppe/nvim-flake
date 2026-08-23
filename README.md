# NeoVim Flake

My Neovim configuration, packaged with [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules).

## Test it out

Using flakes:

```console
nix run github:benkoppe/nvim-flake
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
  inputs.nvim-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
];
# add per-user
users.users."<name>".packages = [
  inputs.nvim-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

In the same way, it can be added to `home-manager` or `nix-darwin` configurations.

## Inspiration

- [@Gerg-L](https://github.com/Gerg-L)'s [nvim-flake](https://github.com/Gerg-L/nvim-flake)
