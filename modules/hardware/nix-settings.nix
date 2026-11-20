{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.config-hw.nix-settings;
in
{
  config = lib.mkIf cfg {
    nixpkgs.config.allowUnfree = true;
    nix = {
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 14d";
      };
      settings = {
        download-buffer-size = 268435456;
        substituters = [
          "https://eniumraphael.cachix.org"
          "https://cache.nixos-cuda.org"
        ];
        trusted-substituters = [
          "https://eniumraphael.cachix.org"
          "https://cache.nixos-cuda.org"
        ];
        trusted-public-keys = [
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "eniumraphael.cachix.org-1:MnPAkTzOEHAydM9/yMcBq0HuBMCGToNNmHEtyD/Okxg="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        max-jobs = "auto";
        cores = 0;
        keep-outputs = true;
        keep-derivations = true;
      };
      optimise.automatic = true;
    };
    age.secrets."cachix-key" = {
      file = ../../secrets/cachix-key.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };

    systemd.services.cachix-watch = {
      description = "Cachix Watch Store";
      after = [ "agenix.service" ];
      wants = [ "agenix.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.cachix}/bin/cachix watch-store eniumraphael";
        EnvironmentFile = config.age.secrets.cachix-key.path;
        Restart = "always";
      };
    };
  };
}
