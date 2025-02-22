{
	description = "NixOS Configuration";

	inputs = {
		flake-utils.url = "github:numtide/flake-utils";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	};

	outputs = { self, nixpkgs, flake-utils, home-manager,... }@inputs:
	let
		pkgs = import nixpkgs {
			config.allowUnfree = true;
		};
	in {
		nixosConfigurations."nixos-fix" = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				home-manager.nixosModules.home-manager
				./hosts/fix/configuration.nix
				./hm-config/host/fix.nix
			];
		};
		nixosConfigurations."nixos-asahi" = nixpkgs.lib.nixosSystem {
			system = "aarch64-linux";
			modules = [
				./hosts/asahi/configuration.nix
			];
		};
	};
}
