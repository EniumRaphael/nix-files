{
	description = "NixOS Configuration";

	inputs = {
		flake-utils.url = "github:numtide/flake-utils";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		minecraft.url = "github:Infinidoge/nix-minecraft";
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	};

	outputs = { self, nixpkgs, flake-utils, ... }@inputs:
	let
		pkgs = import nixpkgs {
			config.allowUnfree = true;
		};
	in {
		nixosConfigurations."nixos-fix" = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				./hosts/fix/configuration.nix
			];
			specialArgs = {
				inherit inputs;
			};
		};
		nixosConfigurations."nixos-asahi" = nixpkgs.lib.nixosSystem {
			system = "aarch64-linux";
			modules = [
				./hosts/asahi/configuration.nix
			];
		};
	};
}
