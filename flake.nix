{
	description = "NixOS Configuration";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		flake-utils.url = "github:numtide/flake-utils";
	};

	outputs = { self, nixpkgs, flake-utils, ... }@inputs:
	let
		pkgs = import nixpkgs {
			config.allowUnfree = true;
		};
	in {
		nixosConfigurations."nixos-fix" = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [ ./hosts/fix/configuration.nix ];
		};
	};
}
