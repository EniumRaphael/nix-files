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
    ../../modules/games/default.nix
    ../../services/bot_discord/default.nix
    ../../services/server/default.nix
  ];

  networking = {
    hostName = "raphael-framework";
    firewall.enable = false;
    networkmanager = {
      enable = true;
      wifi = {
        powersave = false;
        macAddress = "preserve";
      };
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  games = {
    lutris = false;
    steam = {
      enable = true;
      bp = false;
    };
  };

  security = {
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.systemd1.manage-units" &&
              action.lookup("unit") == "fprintd.service" &&
              subject.user == "raphael") {
            return polkit.Result.YES;
          }
        });
      '';
    };
    pam.services = {
      greetd = {
        enableGnomeKeyring = true;
        fprintAuth = true;
      };
      login.fprintAuth = true;
      sudo.fprintAuth = true;
      hyprlock.text = ''
        auth sufficient pam_fprintd.so
        auth include login
      '';
    };
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
    printing = {
      enable = true;
      drivers = with pkgs; [
        brlaser
      ];
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
    };
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
    gnome.gnome-keyring.enable = true;
    seatd.enable = true;
    blueman.enable = true;
    fprintd = {
      enable = true;
      package = pkgs.fprintd-tod;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-goodix;
      };
    };
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --remember --user-menu --remember-session --time";
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
    udev = {
      packages = with pkgs; [
        libfprint-2-tod1-goodix
      ];
      extraRules = ''
        SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="5740", MODE="0666"
      '';
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
