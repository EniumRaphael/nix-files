{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  documentation = {
    enable = true;
    man.enable = true;
    dev.enable = true;
  };

  time.timeZone = "Europe/Paris";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
  };
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      raphael = {
        isNormalUser = true;
        description = "Raphael";
        useDefaultShell = true;
        extraGroups = [
          "dialout"
          "docker"
          "input"
          "networkmanager"
          "plugdev"
          "render"
          "video"
          "wheel"
        ];
      };
    };
  };

  nixpkgs.config.allowUnfree = true;

  age.secrets."cachix-key" = {
    file = ../secrets/cachix-key.age;
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

  environment.variables.AGE_KEY_FILE = "/root/.config/age/keys.txt";
  programs = {
    zsh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    age
    uwsm
    git
    home-manager
    postgresql
    vim
    wget
  ] ++ [
    inputs.agenix.packages.${pkgs.system}.agenix
  ];
}
