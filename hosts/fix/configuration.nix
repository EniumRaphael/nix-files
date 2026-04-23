{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  mullvad-autostart = pkgs.makeAutostartItem {
    name = "mullvad-vpn";
    package = pkgs.mullvad-vpn;
  };
in
{
  imports = [
    ../global.nix
    ./hardware-configuration.nix
    ../../modules/games.nix
    ../../services/discord.nix
    ../../services/server.nix
  ];

  networking = {
    hostName = "nixos-fix";
    firewall.enable = false;
    networkmanager.enable = true;
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      open = false;
      modesetting.enable = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  games = {
    lutris = false;
    steam = {
      enable = true;
      bp = false;
    };
  };

  security.pam.services = {
    greetd = {
      enableGnomeKeyring = true;
    };
    swaylock = { };
  };

  users.defaultUserShell = pkgs.zsh;

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  programs = {
    thunderbird.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    mullvad-autostart
    pciutils
    vulkan-tools
  ];

  services = {
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
    xserver.videoDrivers = [ "nvidia" ];
    seatd.enable = true;
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --remember --user-menu --remember-user-session --time";
        };
      };
      useTextGreeter = true;
    };
    dbus.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    udev.extraRules = ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="5740", MODE="0666"
    '';
    redis.servers."" = {
      enable = true;
    };
    postgresql = {
      enable = true;
    };
  };

  virtualisation.docker.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  system.stateVersion = "24.05";
}
