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
  network = import ./network.nix {
    inherit config pkgs lib;
  };
  printer = import ./printer.nix {
    inherit config pkgs lib;
  };
  bluetooth = import ./bluetooth.nix {
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
    nix-settings
    nvidia
    printer
    bluetooth
    fingerprint
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
    nix-settings = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "The configuration for nix-settings graphic card";
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

    hardware.enableRedistributableFirmware = true;

    environment.systemPackages =
      with pkgs;
      [
        age
        bat
        git
        git
        home-manager
        lego
        openssl
        pciutils
        ripgrep
        vim
        vim
        vulkan-tools
        wget
        wget
        yarn
        zsh
      ]
      ++ [
        inputs.agenix.packages.${pkgs.system}.agenix
      ];

    age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
}
