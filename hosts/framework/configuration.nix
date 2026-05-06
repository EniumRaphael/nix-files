{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
in
{
  imports = [
    ../global.nix
    ./hardware-configuration.nix
    ../../modules/games/default.nix
    ../../services/bot_discord/default.nix
    ../../services/server/default.nix
    ../../modules/users/default.nix
    ../../modules/graphical/default.nix
    ../../modules/hardware/default.nix
  ];

  networking = {
    hostName = "raphael-framework";
  };

  config-user = {
    raphael = true;
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

  system.stateVersion = "24.05";
}
