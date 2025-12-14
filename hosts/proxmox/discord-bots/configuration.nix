{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../../global.nix
    ./hardware-configuration.nix
    ../../../services/discord.nix
  ];

  networking = {
    hostName = "pve-discord-bot";
    firewall.enable = false;
    networkmanager.enable = true;
    wireless.enable = false;
  };

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  service = {
    bot_discord = {
      master = true;
      bde = false;
      tut = false;
      marty = false;
      ada = false;
      music = false;
      tempvoc = true;
      ticket = true;
    };
  };

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      device = "/dev/sda";
    };
  };

  services = {
    openssh = {
      enable = true;
      ports = [ 42131 ];
    };
    redis.servers."" = {
      enable = true;
    };
    postgresql = {
      enable = true;
    };
  };
  virtualisation.docker.enable = true;
  system.stateVersion = "24.05";
}
