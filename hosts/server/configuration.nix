{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../global.nix
    ./hardware-configuration.nix
    ./secrets.nix
    ../../modules/games.nix
    ../../services/forty_two.nix
    ../../services/discord.nix
    ../../services/server.nix
    ../../services/web.nix
    ../../services/self_host.nix
  ];

  networking = {
    hostName = "nixos-fix";
    firewall.enable = false;
    networkmanager.enable = true;
    wireless.enable = false;
  };

  games = {
    lutris = false;
    steam = {
      enable = false;
      bp = false;
    };
  };

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  service = {
    selfhost = {
      htop = true;
      ollama = false;
      mail = true;
      monitor = true;
      nextcloud = true;
      jellyfin = true;
      sso = true;
    };
    forty_two.irc = true;
    web.portefolio = true;
    server = {
      minecraft = false;
      teamspeak = true;
    };
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

  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      axel = {
        isNormalUser = true;
        initialPassword = "Feuyllelpb12341234";
        description = "feuylle";
        useDefaultShell = true;
        extraGroups = [
          "networkmanager"
          "plugdev"
          "docker"
        ];
        packages = with pkgs; [
          home-manager
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    age
    bat
    cairo
    dconf
    fastfetch
    git
    home-manager
    lego
    libjpeg
    libpng
    libuuid
    linux-manual
    man
    man-pages
    man-pages-posix
    networkmanager
    openssl
    pkg-config
    postgresql
    protonup-ng
    python3
    python3Packages.pip
    qFlipper
    ripgrep
    swaylock
    swaylock-fancy
    tmux
    unzip
    vim
    wget
    wl-clipboard
    xclip
    xdg-desktop-portal-hyprland
    xsel
    yarn
    zsh
  ] ++ [
    inputs.agenix.packages.${pkgs.system}.agenix
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services = {
    seatd.enable = true;
    xserver = {
      enable = true;
      videoDrivers = [
        "nvidia"
      ];
    };
    dbus.enable = true;
    openssh = {
      enable = true;
      ports = [ 42131 ];
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
  system.stateVersion = "24.05";
}
