{
  description = "NixOS Configuration";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    hm-config.url = "github:EniumRaphael/home-manager";
    minecraft.url = "github:Infinidoge/nix-minecraft";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim.url = "github:EniumRaphael/nixvim";
    authentik-nix.url = "github:nix-community/authentik-nix";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      agenix,
      authentik-nix,
      home-manager,
      hm-config,
      catppuccin,
      ...
    }@inputs:
    let
      pkgs = import nixpkgs {
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        "nixos-fix" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/fix/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                system = "x86_64-linux";
                nixvim = inputs.nixvim.packages."x86_64-linux".default;
                zen-browser = inputs.zen-browser.packages."x86_64-linux".default;
              };
              home-manager.users.raphael = hm-config.homeConfigurations."hm-fix";
            }
          ];
          specialArgs = {
            inherit inputs;
          };
        };
        "nixos-server" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/server/configuration.nix
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            authentik-nix.nixosModules.default
            {
              home-manager.sharedModules = [ catppuccin.homeModules.catppuccin ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                system = "x86_64-linux";
                nixvim = inputs.nixvim.packages."x86_64-linux".default;
                zen-browser = inputs.zen-browser.packages."x86_64-linux".default;
              };
              home-manager.users.raphael = import hm-config.outputs.homeModules.server;
            }
          ];
          specialArgs = {
            inherit inputs;
          };
        };
        "proxmox-discord" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/proxmox/discord-bots/configuration.nix
          ];
          specialArgs = {
            inherit inputs;
          };
        };
        "nixos-asahi" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./hosts/asahi/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                system = "aarch64-linux";
                nixvim = inputs.nixvim.packages."aarch64-linux".default;
                zen-browser = inputs.zen-browser.packages."aarch64-linux".default;
              };
              home-manager.users.raphael = hm-config.homeConfigurations."hm-asahi";
            }
          ];
        };
      };
    };
}
