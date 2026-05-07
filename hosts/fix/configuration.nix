{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/games/default.nix
    ../../modules/graphical/default.nix
    ../../modules/hardware/default.nix
    ../../modules/users/default.nix
    ../../modules/applications/default.nix
  ];

  networking = {
    hostName = "raphael-fix";
  };

  config-user = {
    raphael = true;
  };

  graphical = {
    enable = true;
    greetd = true;
    mail = true;
    laptop = false;
  };

  config-hw = {
    network = {
      enable = true;
      wireless = false;
    };
    bluetooth = false;
    fingerprint = false;
    printer = true;
    nix-settings = true;
    nvidia = true;
  };

  applications = {
    docker = true;
    man = true;
    mullvad = true;
    ssh = true;
  };

  games = {
    lutris = false;
    steam = {
      enable = true;
      bp = false;
    };
  };

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  system.stateVersion = "24.05";
}
