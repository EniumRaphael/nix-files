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
        ];
        trusted-substituters = [
          "https://eniumraphael.cachix.org"
        ];
        trusted-public-keys = [
          "eniumraphael.cachix.org-1:MnPAkTzOEHAydM9/yMcBq0HuBMCGToNNmHEtyD/Okxg="
        ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        max-jobs = "auto";
        auto-optimise-store = true;
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
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.cachix}/bin/cachix watch-store eniumraphael";
        EnvironmentFile = config.age.secrets.cachix-key.path;
        Restart = "always";
      };
    };
  };
}
