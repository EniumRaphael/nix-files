{
  config,
  inputs,
  lib,
  nixName,
  pkgs,
  ...
}:

let
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/games/default.nix
    ../../modules/graphical/default.nix
    ../../modules/hardware/default.nix
    ../../modules/users/default.nix
    ../../modules/applications/default.nix
    ../../modules/security/default.nix
  ];

  networking = {
    hostName = "raphael-framework";
  };

  config-user = {
    raphael = true;
  };

  config-sec = {
    apparmor = false;
    autorun = false;
    fail2ban = false;
    kernel = true;
    nginx = false;
  };

  graphical = {
    enable = true;
    greetd = true;
    mail = true;
    laptop = true;
  };

  config-hw = {
    network = {
      enable = true;
      wireless = true;
    };
    bluetooth = true;
    fingerprint = true;
    printer = true;
    nix-settings = true;
    keyboard = true;
    nvidia = true;
  };

  applications = {
    docker = true;
    man = true;
    mullvad = true;
    ssh = false;
  };

  games = {
    lutris = false;
    steam = {
      enable = true;
      bp = false;
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];


  system.stateVersion = "24.05";
}
