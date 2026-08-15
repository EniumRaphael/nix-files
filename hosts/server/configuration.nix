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
    ./disk.nix
    ../../modules/applications/default.nix
    ../../modules/games/default.nix
    ../../modules/graphical/default.nix
    ../../modules/hardware/default.nix
    ../../modules/security/default.nix
    ../../modules/users/default.nix
    ../../services/bot_discord/default.nix
    ../../services/forty_two/default.nix
    ../../services/self_host/default.nix
    ../../services/server/default.nix
    ../../services/web/default.nix
  ];

  config-user = {
    raphael = true;
  };

  graphical = {
    enable = false;
    greetd = false;
    mail = false;
  };

  config-sec = {
    apparmor = true;
    autorun = true;
    fail2ban = true;
    kernel = true;
    nginx = true;
  };

  applications = {
    docker = true;
    man = true;
    mullvad = false;
    ssh = true;
  };

  config-hw = {
    network = {
      enable = true;
      wireless = false;
    };
    bluetooth = false;
    fingerprint = false;
    printer = false;
    nix-settings = true;
    keyboard = false;
    nvidia = true;
  };

  games = {
    lutris = false;
    steam = {
      enable = false;
      bp = false;
    };
  };

  networking = {
    hostName = "server";
    hostId = "ba9db3c6";
    interfaces.enp0s31f6.ipv4.addresses = [
      {
        address = "192.168.1.1";
        prefixLength = 24;
      }
    ];
    defaultGateway = {
      address = "192.168.1.254";
      interface = "enp0s31f6";
    };
    nameservers = [
      "194.242.2.2"
      "2a07:e340::2"
      "194.242.2.3"
      "2a07:e340::3"
      "194.242.2.4"
      "2a07:e340::4"
      "194.242.2.5"
      "2a07:e340::5"
      "194.242.2.6"
      "2a07:e340::6"
      "194.242.2.9"
      "2a07:e340::9"
    ];
  };

  service = {
    selfhost = {
      git = true;
      htop = false;
      jellyfin = true;
      mail = false;
      matrix = true;
      monitor = true;
      nextcloud = true;
      ollama = false;
      immich = true;
      sso = true;
      vault = true;
    };
    forty_two.irc = false;
    web.portefolio = true;
    server = {
      minecraft = true;
      teamspeak = true;
    };
    bot_discord = {
      master = false;
      bde = false;
      tut = false;
      marty = false;
      ada = false;
      music = false;
      tempvoc = false;
      ticket = false;
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
  nixpkgs.config.nvidia.acceptLicense = true;

  system.stateVersion = "24.05";
}
