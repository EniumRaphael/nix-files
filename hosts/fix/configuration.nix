{
  config,
  inputs,
  lib,
  nixName,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/games/default.nix
    ../../modules/graphical/default.nix
    ../../modules/hardware/default.nix
    ../../modules/users/default.nix
    ../../modules/security/default.nix
    ../../modules/applications/default.nix
  ];

  networking = {
    hostName = "raphael-fix";
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
    keyboard = true;
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

  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  system.stateVersion = "24.05";
}
