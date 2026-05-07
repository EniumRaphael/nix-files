{
  description = "NixOS Configuration";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hm-config.url = "github:EniumRaphael/home-manager";
    orca-slicer-flake.url = "github:EniumRaphael/orca-slicer-flake";
    minecraft.url = "github:Infinidoge/nix-minecraft";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim.url = "github:EniumRaphael/nixvim";
    authentik-nix.url = "github:nix-community/authentik-nix";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
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
      nixos-hardware,
      home-manager,
      orca-slicer-flake,
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
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = [ catppuccin.homeModules.catppuccin ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                nixvim = inputs.nixvim.packages."x86_64-linux".default;
                zen-browser = inputs.zen-browser.packages."x86_64-linux".default;
                orca-slicer-pkg =
                  if orca-slicer-flake.packages ? "x86_64-linux" then
                    orca-slicer-flake.packages.x86_64-linux.default
                  else
                    null;
              };
              home-manager.users.raphael = import hm-config.outputs.homeModules.fix;
              home-manager.users.root = import hm-config.outputs.homeModules.root;
            }
          ];
          specialArgs = {
            inherit inputs;
          };
        };
        "nixos-framework" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/framework/configuration.nix
            nixos-hardware.nixosModules.framework-16-amd-ai-300-series
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.sharedModules = [ catppuccin.homeModules.catppuccin ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                nixvim = inputs.nixvim.packages."x86_64-linux".default;
                zen-browser = inputs.zen-browser.packages."x86_64-linux".default;
                orca-slicer-pkg =
                  if orca-slicer-flake.packages ? "x86_64-linux" then
                    orca-slicer-flake.packages.x86_64-linux.default
                  else
                    null;
              };
              home-manager.users.raphael = import hm-config.outputs.homeModules.framework;
              home-manager.users.root = import hm-config.outputs.homeModules.root;
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
            nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
            agenix.nixosModules.default
            authentik-nix.nixosModules.default
            {
              home-manager.sharedModules = [ catppuccin.homeModules.catppuccin ];
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                nixvim = inputs.nixvim.packages."x86_64-linux".default;
                zen-browser = inputs.zen-browser.packages."x86_64-linux".default;
                orca-slicer-pkg =
                  if orca-slicer-flake.packages ? "x86_64-linux" then
                    orca-slicer-flake.packages.x86_64-linux.default
                  else
                    null;
              };
              home-manager.users.raphael = import hm-config.outputs.homeModules.server;
              home-manager.users.root = import hm-config.outputs.homeModules.root;
            }
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      };
    };
}
