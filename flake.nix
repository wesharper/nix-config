{
  description = "Default nix configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs =
    inputs@{ nixpkgs, nix-flatpak, ... }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            nix-flatpak.nixosModules.nix-flatpak

            ./nixos/configuration.nix
          ];
        };
      };
    };
}
