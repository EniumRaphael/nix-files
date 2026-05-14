{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    hm-config = {
      url = "github:EniumRaphael/home-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        firefox-addons.follows = "firefox-addons";
        hytale-launcher.follows = "hytale-launcher";
        catppuccin.follows = "catppuccin";
        home-manager.follows = "home-manager";
        zen-browser.follows = "zen-browser";
        orca-slicer-flake.follows = "orca-slicer-flake";
      };
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hytale-launcher = {
      url = "github:JPyke3/hytale-launcher-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    orca-slicer-flake = {
      url = "github:EniumRaphael/orca-slicer-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:EniumRaphael/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      agenix,
      catppuccin,
      hm-config,
      home-manager,
      nixos-hardware,
      orca-slicer-flake,
      ...
    }@inputs:
    let
      pkgs = import nixpkgs {
        config.allowUnfree = true;
      };
      sys = pkgs.stdenv.hostPlatform.system;

      hmPackages = {
        nixvim = inputs.nixvim.packages.${sys}.default;
        zen-browser = inputs.zen-browser.packages.${sys}.default;
        orca-slicer-pkg =
          if orca-slicer-flake.packages ? ${sys} then
            orca-slicer-flake.packages.${sys}.default
          else
            null;
      };
      mkHomeManagerModule = userModules: {
        home-manager.sharedModules = [ catppuccin.homeModules.catppuccin ];
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hmbak";
        home-manager.extraSpecialArgs = {
          inherit inputs;
        }
        // hmPackages;
        home-manager.users = userModules;
      };
      mkHost =
        {
          nixName,
          hostModules,
          userModules ? {
            raphael = import hm-config.outputs.homeModules.${nixName};
            root = import hm-config.outputs.homeModules.root;
          },
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/${nixName}/configuration.nix
            agenix.nixosModules.default
            home-manager.nixosModules.home-manager
            (mkHomeManagerModule userModules)
          ]
          ++ hostModules
          ++ extraModules;
          specialArgs = { inherit inputs; };
        };
    in
    {
      nixosConfigurations = {
        "nixos-fix" = mkHost {
          nixName = "fix";
          hostModules = [ ];
        };

        "nixos-framework" = mkHost {
          nixName = "framework";
          hostModules = [
            nixos-hardware.nixosModules.framework-16-amd-ai-300-series
          ];
        };

        "nixos-server" = mkHost {
          nixName = "server";
          hostModules = [
            nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
          ];
        };
      };
    };
}
