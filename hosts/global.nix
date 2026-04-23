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

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
    };
    settings = {
      download-buffer-size = 268435456;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto";
      auto-optimise-store = true;
    };
  };

  environment.variables.AGE_KEY_FILE = "/root/.config/age/keys.txt";
  programs = {
    zsh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    uwsm
    git
    postgresql
    vim
    wget
  ];
}
