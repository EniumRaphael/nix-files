{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  nvidia = import ./nvidia.nix {
    inherit config pkgs lib;
  };
  nix-settings = import ./nix-settings.nix {
    inherit config pkgs lib;
  };
  keyboard = import ./keyboard.nix {
    inherit config pkgs lib;
  };
  network = import ./network.nix {
    inherit config pkgs lib;
  };
  printer = import ./printer.nix {
    inherit config pkgs lib;
  };
  bluetooth = import ./bluetooth.nix {
    inherit config pkgs lib;
  };
  streamdeck = import ./streamdeck.nix {
    inherit config pkgs lib;
  };
  fingerprint = import ./fingerprint.nix {
    inherit config pkgs lib;
  };
in
{
  imports = [
    nix-settings
    network
    keyboard
    nvidia
    printer
    bluetooth
    fingerprint
    streamdeck
    inputs.agenix.nixosModules.default
  ];

  options.config-hw = {
    network = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "the configuration for network";
      };
      wireless = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "the configuration for wifi";
      };
    };
    keyboard = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "The configuration for keyboard";
    };
    nix-settings = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "The configuration for nix-settings";
    };
    nvidia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "The configuration for nvidia graphic card";
    };
    printer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "The configuration for printers";
    };
    bluetooth = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "The configuration for bluetooth";
    };
    fingerprint = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "The configuration for fingerprint";
    };
    streamdeck = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "The configuration for streamdeck";
    };
  };
  config = {
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
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

    hardware = {
      enableRedistributableFirmware = true;
      enableAllFirmware = true;
    };

    environment.systemPackages =
      with pkgs;
      [
        age
        bat
        git
        home-manager
        lego
        openssl
        pciutils
        ripgrep
        vim
        vulkan-tools
        wget
        yarn
        zsh
        displaylink
      ]
      ++ [
        inputs.agenix.packages.${pkgs.system}.agenix
      ];

    services = {
      upower.enable = true;
      xserver.videoDrivers = [
        "displaylink"
        "modesetting"
      ];
    };

    boot = {
      extraModulePackages = [ config.boot.kernelPackages.evdi ];
      initrd = {
        kernelModules = [
          "evdi"
        ];
      };
    };

    age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
}
